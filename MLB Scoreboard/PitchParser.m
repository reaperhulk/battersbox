//
//  The increasingly inaccurately named...
//  PitchParser.m
//  Batter's Box
//
//  Created by Paul Kehrer on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PitchParser.h"

@implementation PitchParser

@synthesize pitches,afOperation,atBatNum,atBatComplete,batterStand,delegate,game,gameStatus,gameReason,gameEvent,batterCount;

-(id) initWithDelegate:(id<PitchParserDelegate,WeatherDelegate,HomeRunDelegate,AtBatCountAndScoreDelegate>)pDelegate game:(Game *)pGame {
    self = [super init];
    if (self) {
        self.pitches = [NSMutableArray array];
        self.batterCount = [NSMutableDictionary dictionary];
        [self.batterCount setObject:[NSNumber numberWithInt:0] forKey:@"balls"];
        [self.batterCount setObject:[NSNumber numberWithInt:0] forKey:@"strikes"];
        self.delegate = pDelegate;
        self.game = pGame;
        NSString *url = [NSString stringWithFormat:@"http://gdx.mlb.com/components/game/mlb/year_%04d/month_%02d/day_%02d/gid_%@/plays.xml",self.game.dateComponents.year,self.game.dateComponents.month,self.game.dateComponents.day,self.game.gameday];
//        NSString *url = [NSString stringWithFormat:@"http://saseliminator.com/plays.xml"];
        DebugLog(@"Loading %@",url);
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:url]];
        [request setTimeoutInterval:kTimeoutInterval];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setHTTPMethod:@"GET"];
        self.afOperation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {
            XMLParser.delegate = self;
            [XMLParser parse];
            DebugLog(@"pitches: %d at bat num: %d batter stand: %@",self.pitches.count,self.atBatNum,self.batterStand);
            if (game.statusCode != 2 && game.statusCode != 0) {
                Pitch *lastPitch = [self.pitches lastObject];
                self.atBatComplete = NO;
                if ([lastPitch.type isEqualToString:@"X"] || [[self.gameEvent lowercaseString] isEqualToString:@"strikeout"] || [[self.gameEvent lowercaseString] isEqualToString:@"walk"] || [[self.gameEvent lowercaseString] isEqualToString:@"hit_by_pitch"] || [[self.batterCount objectForKey:@"balls"] integerValue] == 4) {
                    self.atBatComplete = YES;
                }
                if ([[self.gameEvent lowercaseString] isEqualToString:@"home_run"] && self.atBatNum != 0) {
                    [self performSelectorOnMainThread:@selector(dispatchHomeRun) withObject:nil waitUntilDone:NO];
                }
                [self performSelectorOnMainThread:@selector(dispatchPitchesLoaded) withObject:nil waitUntilDone:NO];
            }
            //this fires even if the game is not in progress to nil out the parser object
            [(NSObject*)self.delegate performSelectorOnMainThread:@selector(pitchParseComplete) withObject:nil waitUntilDone:NO];

        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParse) {
            [(NSObject*)self.delegate performSelectorOnMainThread:@selector(pitchLoadFailed) withObject:nil waitUntilDone:NO];
            DebugLog(@"Error %@ %@",[error localizedDescription],[error userInfo]);
        }];
        self.afOperation.successCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
        self.afOperation.failureCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);

        [self.afOperation start];
    }
    return self;
}

-(void) dispatchPitchesLoaded {
    [self.delegate pitchesLoaded:self.pitches atBatNum:self.atBatNum stand:self.batterStand complete:self.atBatComplete pastAtBat:NO];
}

-(void) dispatchHomeRun {
    if ([self.delegate respondsToSelector:@selector(homeRunHit:)]) {
        [self.delegate homeRunHit:self.atBatNum];
    }
}

#pragma mark -
#pragma mark NSXMLParser delegate methods

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
 namespaceURI:(NSString *)namespaceURI 
qualifiedName:(NSString *)qName 
   attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"game"]) {
        [self parseCount:attributeDict];
        self.gameStatus = [attributeDict objectForKey:@"status"];
        self.gameReason = [attributeDict objectForKey:@"reason"];
        self.gameEvent = [attributeDict objectForKey:@"event"];
    } else if ([elementName isEqualToString:@"batter"]) {
        self.batterStand = [attributeDict objectForKey:@"stand"];
    } else if ([elementName isEqualToString:@"pitcher"] && [self.batterStand isEqualToString:@"S"]) {
        //handle switch hitters by assuming they position against the pitcher's throwing arm
        if ([[attributeDict objectForKey:@"p_throws"] isEqualToString:@"R"]) {
            self.batterStand = @"L";
        } else {
            self.batterStand = @"R";
        }
    } else if ([elementName isEqualToString:@"weather"]) {
        [self parseWeather:attributeDict];
    } else if ([elementName isEqualToString:@"atbat"]) {
        self.atBatNum = [[attributeDict objectForKey:@"num"] integerValue];
    } else if ([elementName isEqualToString:@"p"]) {
        [self parsePitch:attributeDict];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"atbat"]) {
        //handle strikeout case. we handle it at the end of the atbat node so we know we have all the pitches
        if ([[self.gameEvent lowercaseString] isEqualToString:@"strikeout"]) {
            Pitch *lastPitch = [self.pitches lastObject];
            lastPitch.pitchCount = [NSString stringWithFormat:@"%d-%d",[[self.batterCount objectForKey:@"balls"] integerValue],3];
        }

    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if ([parseError code] != NSXMLParserDelegateAbortedParseError) {
        DebugLog(@"%@",parseError);
        [(NSObject*)self.delegate performSelectorOnMainThread:@selector(pitchLoadFailed) withObject:nil waitUntilDone:NO];
    }
}

-(void) cancel {
    DebugLog(@"aborting async request");
    if (self.afOperation != nil) {
        [self.afOperation cancel];
    }
}

-(void) parseCount:(NSDictionary*)attributeDict {
    NSMutableDictionary *currentCount = [NSMutableDictionary dictionary];
    NSString *balls = [attributeDict objectForKey:@"b"];
    if (balls.length > 0) {
        [currentCount setObject:balls forKey:@"balls"];
    }
    NSString *strikes = [attributeDict objectForKey:@"s"];
    if (strikes.length > 0) {
        [currentCount setObject:strikes forKey:@"strikes"];
    }
    NSString *outs = [attributeDict objectForKey:@"o"];
    if (outs.length > 0) {
        [currentCount setObject:outs forKey:@"outs"];
    }
    if ([self.delegate respondsToSelector:@selector(atBatCountAndScoreLoaded:)]) {
        [(NSObject*)self.delegate performSelectorOnMainThread:@selector(atBatCountAndScoreLoaded:) withObject:currentCount waitUntilDone:NO];
    }
}

-(void) parseWeather:(NSDictionary*)attributeDict {
    Weather *weatherObj = [[Weather alloc] init];
    weatherObj.temperature = [attributeDict objectForKey:@"temp"];
    weatherObj.condition = [attributeDict objectForKey:@"condition"];
    weatherObj.wind = [attributeDict objectForKey:@"wind"];
    if (([self.gameStatus isEqualToString:@"Delayed"] || [self.gameStatus isEqualToString:@"Delayed Start"]) && [self.gameReason isEqualToString:@"Rain"]) {
        weatherObj.condition = @"Rain";
    }
    if ([self.delegate respondsToSelector:@selector(weatherLoaded:)]) {
        [(NSObject*)self.delegate performSelectorOnMainThread:@selector(weatherLoaded:) withObject:weatherObj waitUntilDone:NO];
    }
}

-(void) parsePitch:(NSDictionary *)attributeDict {
    Pitch *pitch = [[Pitch alloc] init];
    [self.pitches addObject:pitch];
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
