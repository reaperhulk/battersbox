//
//  AtBatParser.m
//  Batter's Box
//
//  Created by Paul Kehrer on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AtBatParser.h"
#import "NSArray+Reverse.h"
#import "Pitch.h"
#import "AtBat.h"

@implementation AtBatParser

@synthesize atBats,afOperation,sectionNames,delegate,game,parseMetadata,batterCount;

-(id) initWithDelegate:(id<AtBatDelegate>)pDelegate game:(Game *)pGame {
    if ([super init]) {
        self.atBats = [NSMutableDictionary dictionary];
        self.parseMetadata = [NSMutableDictionary dictionary];
        self.batterCount = [NSMutableDictionary dictionary];
        self.sectionNames = [NSMutableArray array];
        self.delegate = pDelegate;
        self.game = pGame;
        
        NSString *url = [NSString stringWithFormat:@"http://gdx.mlb.com/components/game/mlb/year_%04d/month_%02d/day_%02d/gid_%@/inning/inning_all.xml",game.dateComponents.year,game.dateComponents.month,game.dateComponents.day,game.gameday];
        DebugLog(@"Loading %@",url);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:url]];
        [request setTimeoutInterval:kTimeoutInterval];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setHTTPMethod:@"GET"];
        self.afOperation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {
            XMLParser.delegate = self;
            [XMLParser parse];
            NSMutableArray *currentAtBat = [NSMutableArray array];
            [self.atBats setObject:currentAtBat forKey:@"Current At Bat"];
            [self.sectionNames addObject:@"Current At Bat"];
            [self.sectionNames reverse];
            [self performSelectorOnMainThread:@selector(dispatchAtBatsLoaded) withObject:nil waitUntilDone:NO];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParse) {
            [(NSObject*)self.delegate performSelectorOnMainThread:@selector(atBatsLoadFailed) withObject:nil waitUntilDone:NO];
            DebugLog(@"Error %@ %@",[error localizedDescription],[error userInfo]);
        }];
        self.afOperation.successCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
        self.afOperation.failureCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
        [self.afOperation start];
    }
    return self;
}

-(void) dispatchAtBatsLoaded {
    [self.delegate atBatsLoaded:self.atBats sectionNames:self.sectionNames];    
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
        [self addContainer];
    } else if ([elementName isEqualToString:@"bottom"]) {
        [self.parseMetadata setObject:@"Bottom" forKey:@"inningState"];
        [self addContainer];
    } else if ([elementName isEqualToString:@"inning"]) {
        [self.parseMetadata setObject:[attributeDict objectForKey:@"num"] forKey:@"inningNumber"];
    } else if ([elementName isEqualToString:@"atbat"]) {
        [self.batterCount setObject:[NSNumber numberWithInt:0] forKey:@"balls"];
        [self.batterCount setObject:[NSNumber numberWithInt:0] forKey:@"strikes"];
        AtBat *atBat = [[AtBat alloc] init];
        atBat.num = [attributeDict objectForKey:@"num"];
        atBat.pitcherId = [attributeDict objectForKey:@"pitcher"];
        atBat.pitcherThrow = [attributeDict objectForKey:@"p_throws"];
        atBat.batterId = [attributeDict objectForKey:@"batter"];
        atBat.batterStand = [attributeDict objectForKey:@"stand"];
        atBat.event = [attributeDict objectForKey:@"event"];
        atBat.outs = [attributeDict objectForKey:@"o"];
        atBat.des = [[attributeDict objectForKey:@"des"] stringByReplacingOccurrencesOfString:@"  " withString:@" "];
        [[self.atBats objectForKey:[self.sectionNames lastObject]] addObject:atBat];

    } else if ([elementName isEqualToString:@"pitch"]) {
        [self parsePitch:attributeDict];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"atbat"]) {
        AtBat *atBat = [[self.atBats objectForKey:[self.sectionNames lastObject]] lastObject];
        if ([atBat.event isEqualToString:@"Strikeout"]) {
            Pitch *pitch = [atBat.pitches lastObject];
            pitch.pitchCount = [NSString stringWithFormat:@"%d-%d",[[self.batterCount objectForKey:@"balls"] integerValue],3];
        }
    }
}

-(void) addContainer {
    NSString *key = [NSString stringWithFormat:@"%@ %@",[self.parseMetadata objectForKey:@"inningState"],[self.parseMetadata objectForKey:@"inningNumber"]];
    [self.sectionNames addObject:key];
    NSMutableArray *inningContainer = [NSMutableArray array];
    [self.atBats setObject:inningContainer forKey:key];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if ([parseError code] != NSXMLParserDelegateAbortedParseError) {
        DebugLog(@"%@",parseError);
        [(NSObject*)self.delegate performSelectorOnMainThread:@selector(atBatsLoadFailed) withObject:nil waitUntilDone:NO];
    }
}

-(void) parsePitch:(NSDictionary *)attributeDict {
    Pitch *pitch = [[Pitch alloc] init];
    AtBat *atBat = [[self.atBats objectForKey:[self.sectionNames lastObject]] lastObject];
    [atBat addPitch:pitch];
    pitch.des = [attributeDict objectForKey:@"des"];
    pitch.pitchId = [[attributeDict objectForKey:@"id"] integerValue];
    pitch.type = [attributeDict objectForKey:@"type"];
    if ([pitch.type isEqualToString:@"B"]) {
        NSInteger balls = [[self.batterCount objectForKey:@"balls"] integerValue];
        if (balls < 4) {
            balls += 1;
        }
        [self.batterCount setObject:[NSNumber numberWithInteger:balls] forKey:@"balls"];
    } else if (![pitch.type isEqualToString:@"X"]) {
        NSInteger strikes = [[self.batterCount objectForKey:@"strikes"] integerValue];
        //look up in the af completion block to see how we compensate for a strikeout
        if (strikes < 2) {
            strikes += 1;
        }
        [self.batterCount setObject:[NSNumber numberWithInteger:strikes] forKey:@"strikes"];
    }
    if (![pitch.type isEqualToString:@"X"]) {
        pitch.pitchCount = [NSString stringWithFormat:@"%d-%d",[[self.batterCount objectForKey:@"balls"] integerValue],[[self.batterCount objectForKey:@"strikes"] integerValue]];
    }
    pitch.tfs = [[attributeDict objectForKey:@"tfs"] integerValue];            
    pitch.tfsZulu = [attributeDict objectForKey:@"tfs_zulu"];
    pitch.svId = [attributeDict objectForKey:@"sv_id"];
    pitch.startSpeed = [[attributeDict objectForKey:@"start_speed"] doubleValue];
    pitch.endSpeed = [[attributeDict objectForKey:@"end_speed"] doubleValue];
    pitch.szTop = [[attributeDict objectForKey:@"sz_top"] doubleValue];
    pitch.szBot = [[attributeDict objectForKey:@"sz_bot"] doubleValue];
    pitch.pfxX = [[attributeDict objectForKey:@"pfx_x"] doubleValue];
    pitch.pfxZ = [[attributeDict objectForKey:@"pfx_z"] doubleValue];
    pitch.px = [[attributeDict objectForKey:@"px"] doubleValue];
    pitch.pz = [[attributeDict objectForKey:@"pz"] doubleValue];
    pitch.x0 = [[attributeDict objectForKey:@"x0"] doubleValue];
    pitch.y0 = [[attributeDict objectForKey:@"y0"] doubleValue];
    pitch.z0 = [[attributeDict objectForKey:@"z0"] doubleValue];
    pitch.vx0 = [[attributeDict objectForKey:@"vx0"] doubleValue];
    pitch.vy0 = [[attributeDict objectForKey:@"vy0"] doubleValue];
    pitch.vz0 = [[attributeDict objectForKey:@"vz0"] doubleValue];
    pitch.ax0 = [[attributeDict objectForKey:@"ax0"] doubleValue];
    pitch.ay0 = [[attributeDict objectForKey:@"ay0"] doubleValue];
    pitch.az0 = [[attributeDict objectForKey:@"az0"] doubleValue];
    pitch.x = [[attributeDict objectForKey:@"x"] doubleValue];
    pitch.y = [[attributeDict objectForKey:@"y"] doubleValue];
    pitch.breakY = [[attributeDict objectForKey:@"break_y"] doubleValue];
    pitch.breakAngle = [[attributeDict objectForKey:@"break_angle"] doubleValue];        
    pitch.breakLength = [[attributeDict objectForKey:@"break_length"] doubleValue];
    pitch.pitchType = [attributeDict objectForKey:@"pitch_type"];
    pitch.typeConfidence = [[attributeDict objectForKey:@"type_confidence"] doubleValue];
    pitch.zone = [[attributeDict objectForKey:@"zone"] integerValue];
    pitch.nasty = [[attributeDict objectForKey:@"nasty"] integerValue];
    pitch.spinDir = [[attributeDict objectForKey:@"spin_dir"] doubleValue];
    pitch.spinRate = [[attributeDict objectForKey:@"spin_rate"] doubleValue];
}

@end
