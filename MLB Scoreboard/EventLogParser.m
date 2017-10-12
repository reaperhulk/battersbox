//
//  EventLogParser.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventLogParser.h"
#import "GameEvent.h"
#import "NSArray+Reverse.h"


@implementation EventLogParser

@synthesize events,afOperation,sectionNames,delegate,game,parseMetadata;

-(id) initWithDelegate:(id<EventLogDelegate>)pDelegate game:(Game *)pGame {
    if ([super init]) {
        self.events = [NSMutableDictionary dictionary];
        self.parseMetadata = [NSMutableDictionary dictionary];
        self.sectionNames = [NSMutableArray array];
        self.delegate = pDelegate;
        self.game = pGame;
        
        NSString *url = [NSString stringWithFormat:@"http://gdx.mlb.com/components/game/mlb/year_%04d/month_%02d/day_%02d/gid_%@/game_events.xml",game.dateComponents.year,game.dateComponents.month,game.dateComponents.day,game.gameday];
        DebugLog(@"Loading %@",url);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:url]];
        [request setTimeoutInterval:kTimeoutInterval];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setHTTPMethod:@"GET"];
        self.afOperation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {
            XMLParser.delegate = self;
            [XMLParser parse];
            [self.sectionNames reverse];
            [self performSelectorOnMainThread:@selector(dispatchEventLogLoaded) withObject:nil waitUntilDone:NO];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParse) {
            [(NSObject*)self.delegate performSelectorOnMainThread:@selector(eventLogLoadFailed) withObject:nil waitUntilDone:NO];
            DebugLog(@"Error %@ %@",[error localizedDescription],[error userInfo]);
        }];
        self.afOperation.successCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
        self.afOperation.failureCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
        [self.afOperation start];
    }
    return self;
}

-(void) dispatchEventLogLoaded {
    [self.delegate eventLogLoaded:self.events sectionNames:self.sectionNames];    
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
    if ([elementName isEqualToString:@"top"]) {
        [self.parseMetadata setObject:@"Top" forKey:@"inningState"];
    } else if ([elementName isEqualToString:@"bottom"]) {
        [self.parseMetadata setObject:@"Bottom" forKey:@"inningState"];        
    }
    if ([elementName isEqualToString:@"inning"]) {
        [self.parseMetadata setObject:[attributeDict objectForKey:@"num"] forKey:@"inningNumber"];
    }
    if ([elementName isEqualToString:@"action"] || [elementName isEqualToString:@"atbat"]) {
        GameEvent *gameEvent = [[GameEvent alloc] init];
        gameEvent.inningNumber = [self.parseMetadata objectForKey:@"inningNumber"];
        gameEvent.eventDescription = [[attributeDict objectForKey:@"des"] stringByReplacingOccurrencesOfString:@"  " withString:@" "];
        gameEvent.outs = [attributeDict objectForKey:@"o"];
        gameEvent.eventType = [attributeDict objectForKey:@"event"];
        gameEvent.homeTeamRuns = [attributeDict objectForKey:@"home_team_runs"];
        gameEvent.awayTeamRuns = [attributeDict objectForKey:@"away_team_runs"];
        NSString *key = [NSString stringWithFormat:@"%@ %@",[self.parseMetadata objectForKey:@"inningState"],gameEvent.inningNumber];
        NSMutableArray *inningContainer = [self.events objectForKey:key];
        if (inningContainer == nil) {
            [self.sectionNames addObject:key];
            NSMutableArray *inningContainer = [NSMutableArray array];
            [self.events setObject:inningContainer forKey:key];
            [inningContainer addObject:gameEvent];
        } else {
            [inningContainer addObject:gameEvent];
        }
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if ([parseError code] != NSXMLParserDelegateAbortedParseError) {
        DebugLog(@"%@",parseError);
        [(NSObject*)self.delegate performSelectorOnMainThread:@selector(eventLogLoadFailed) withObject:nil waitUntilDone:NO];
    }
}


@end
