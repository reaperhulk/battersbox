//
//  BoxScoreParser.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BoxScoreParser.h"
#import "Batter.h"
#import "Pitcher.h"

@implementation BoxScoreParser

@synthesize boxScore,afOperation,delegate,game,parserMetadata,isGameInfo;

-(id) initWithDelegate:(id<BoxScoreDelegate>)pDelegate game:(Game *)pGame {
    if ([super init]) {
        self.delegate = pDelegate;
        self.game = pGame;
        self.parserMetadata = [NSMutableDictionary dictionary];
        self.boxScore = [NSMutableDictionary dictionary];
        [self.boxScore setObject:[NSMutableDictionary dictionary] forKey:@"batters"];
        [self.boxScore setObject:[NSMutableDictionary dictionary] forKey:@"pitchers"];
        
        NSString *url = [NSString stringWithFormat:@"http://gdx.mlb.com/components/game/mlb/year_%04d/month_%02d/day_%02d/gid_%@/boxscore.xml",game.dateComponents.year,game.dateComponents.month,game.dateComponents.day,game.gameday];
        DebugLog(@"Loading %@",url);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:url]];
        [request setTimeoutInterval:kTimeoutInterval];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setHTTPMethod:@"GET"];
        self.afOperation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {
            XMLParser.delegate = self;
            [XMLParser parse];
            [(NSObject*)self.delegate performSelectorOnMainThread:@selector(boxScoreLoaded:) withObject:self.boxScore waitUntilDone:NO];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParse) {
            [(NSObject*)self.delegate performSelectorOnMainThread:@selector(boxScoreLoadFailed) withObject:nil waitUntilDone:NO];
            #ifdef DEBUG
            NSLog(@"Error %@ %@",[error localizedDescription],[error userInfo]);
            #endif
        }];
        self.afOperation.successCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
        self.afOperation.failureCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
        
        [self.afOperation start];
    }
    return self;
}

-(void) cancel {
    DebugLog(@"aborting async request");
    if (self.afOperation != nil) {
        [self.afOperation cancel];
    }
}

#pragma mark -
#pragma mark NSXMLParser delegate methods

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
 namespaceURI:(NSString *)namespaceURI 
qualifiedName:(NSString *)qName 
   attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"game_info"]) {
        self.isGameInfo = YES;
    } else if ([elementName isEqualToString:@"batting"]) {
        NSString *teamFlag = [[attributeDict objectForKey:@"team_flag"] capitalizedString];
        if ([teamFlag length] > 0) {
            [self.parserMetadata setObject:teamFlag forKey:@"team_flag"];
        }
    } else if ([elementName isEqualToString:@"batter"]) {
        Batter *batter = [[Batter alloc] init];
        batter.name = [attributeDict objectForKey:@"name"];
        batter.batterId = [attributeDict objectForKey:@"id"];
        batter.fullName = [attributeDict objectForKey:@"name_display_first_last"];
        batter.position = [attributeDict objectForKey:@"pos"];
        batter.atBats = [attributeDict objectForKey:@"ab"];
        batter.runs = [attributeDict objectForKey:@"r"];
        batter.baseOnBalls = [attributeDict objectForKey:@"bb"];
        batter.hits = [attributeDict objectForKey:@"h"];
        batter.homeRuns = [attributeDict objectForKey:@"hr"];
        batter.runsBattedIn = [attributeDict objectForKey:@"rbi"];
        batter.leftOnBase = [attributeDict objectForKey:@"lob"];
        batter.stolenBases = [attributeDict objectForKey:@"sb"];
        batter.strikeOuts = [attributeDict objectForKey:@"so"];
        NSString *teamFlag = [self.parserMetadata objectForKey:@"team_flag"];
        if (!teamFlag) {
            DebugLog(@"unable to get team flag for batter in box score parser");
            [(NSObject*)self.delegate performSelectorOnMainThread:@selector(boxScoreLoadFailed) withObject:nil waitUntilDone:NO];
            [parser abortParsing];
        } else {
            NSMutableDictionary *batters = [self.boxScore objectForKey:@"batters"];
            NSMutableArray *batterContainer = [batters objectForKey:teamFlag];
            if (!batterContainer) {
                NSMutableArray *batterContainer = [NSMutableArray array];
                [batters setObject:batterContainer forKey:teamFlag];
                [batterContainer addObject:batter];
            } else {
                [batterContainer addObject:batter];
            }
        }
    } else if ([elementName isEqualToString:@"pitching"]) {
        NSString *teamFlag = [[attributeDict objectForKey:@"team_flag"] capitalizedString];
        if ([teamFlag length] > 0) {
            [self.parserMetadata setObject:teamFlag forKey:@"team_flag"];
        }
    } else if ([elementName isEqualToString:@"pitcher"]) {
        Pitcher *pitcher = [[Pitcher alloc] init];
        pitcher.name = [attributeDict objectForKey:@"name"];
        pitcher.pitcherId = [attributeDict objectForKey:@"id"];
        pitcher.inningsPitched = [attributeDict objectForKey:@"out"];
        pitcher.runsAllowed = [attributeDict objectForKey:@"r"];
        pitcher.earnedRuns = [attributeDict objectForKey:@"er"];
        pitcher.hitsAllowed = [attributeDict objectForKey:@"h"];
        pitcher.baseOnBalls = [attributeDict objectForKey:@"bb"];
        pitcher.strikeOuts = [attributeDict objectForKey:@"so"];
        pitcher.homeRunsAllowed = [attributeDict objectForKey:@"hr"];
        pitcher.earnedRunAverage = [attributeDict objectForKey:@"era"];
        
        
        NSString *teamFlag = [self.parserMetadata objectForKey:@"team_flag"];
        if (!teamFlag) {
            DebugLog(@"unable to get team flag for pitcher in box score parser");
            [(NSObject*)self.delegate performSelectorOnMainThread:@selector(boxScoreLoadFailed) withObject:nil waitUntilDone:NO];
            [parser abortParsing];
        } else {
            NSMutableDictionary *pitchers = [self.boxScore objectForKey:@"pitchers"];
            NSMutableArray *pitcherContainer = [pitchers objectForKey:teamFlag];
            if (!pitcherContainer) {
                NSMutableArray *pitcherContainer = [NSMutableArray array];
                [pitchers setObject:pitcherContainer forKey:teamFlag];
                [pitcherContainer addObject:pitcher];
            } else {
                [pitcherContainer addObject:pitcher];
            }
        }
    }
}

-(void) parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
    if (self.isGameInfo) {
        [self.boxScore setObject:[[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding] forKey:@"gameInfo"];
    }
}

-(void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    self.isGameInfo = NO;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if ([parseError code] != NSXMLParserDelegateAbortedParseError) {
        DebugLog(@"%@",parseError);
    }
}


@end
