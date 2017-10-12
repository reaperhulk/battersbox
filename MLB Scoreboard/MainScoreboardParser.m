//
//  MainScoreboardParser.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainScoreboardParser.h"
#import "Game.h"
#import "Inning.h"
#import "Pitcher.h"
#import "Batter.h"
#import "AppDelegate.h"

@implementation MainScoreboardParser

@synthesize games;
@synthesize gamesDict;
@synthesize dateComponents;
@synthesize afOperation,delegate,alertOnly,isBroadcastNode,isHomeNode,isTvNode,isAwayNode,isRadioNode;

-(id) initWithDelegate:(id<MainScoreboardDelegate>)pDelegate date:(NSDate *)date alertOnly:(BOOL)pAlertOnly {
    if ([super init]) {
        self.delegate = pDelegate;
        self.alertOnly = pAlertOnly;
        self.games = [NSMutableArray array];
        self.gamesDict = [NSMutableDictionary dictionary];
        NSDateComponents *lDateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit  | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
        self.dateComponents = lDateComponents;
        
        NSString *url = [NSString stringWithFormat:@"http://gdx.mlb.com/components/game/mlb/year_%4d/month_%02d/day_%02d/master_scoreboard.xml",self.dateComponents.year,self.dateComponents.month,self.dateComponents.day];
//        NSString *url = @"http://saseliminator.com/master_scoreboard.xml";
        DebugLog(@"Loading %@",url);

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:url]];
        [request setTimeoutInterval:kTimeoutInterval];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setHTTPMethod:@"GET"];
        self.afOperation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {
            XMLParser.delegate = self;
            [XMLParser parse];
            //reorder the array so in progress games are at the top
            NSMutableArray *reorderedGames = [NSMutableArray array];
            NSMutableArray *notInProgressGames = [NSMutableArray array];
            for (Game *game in self.games) {
                if (game.statusCode == 1) {
                    [reorderedGames addObject:game];
                } else {
                    [notInProgressGames addObject:game];
                }
            }
            [reorderedGames addObjectsFromArray:notInProgressGames];
            self.games = reorderedGames;
            NSString *favoriteTeamName = [[self getAppPreferences] objectForKey:@"favoriteTeam"];
            NSString *secondFavoriteTeamName = [[self getAppPreferences] objectForKey:@"secondFavoriteTeam"];
            NSString *thirdFavoriteTeamName = [[self getAppPreferences] objectForKey:@"thirdFavoriteTeam"];
            if (![favoriteTeamName isEqualToString:@"None"] || ![secondFavoriteTeamName isEqualToString:@"None"] || ![thirdFavoriteTeamName isEqualToString:@"None"]) {
                NSMutableArray *favoriteTeamGames = [NSMutableArray array];
                NSMutableArray *secondFavoriteTeamGames = [NSMutableArray array];
                NSMutableArray *thirdFavoriteTeamGames = [NSMutableArray array];
                NSMutableArray *notFavoriteGames = [NSMutableArray array];        
                for (Game *game in reorderedGames) {
                    if ([game.awayTeamName isEqualToString:favoriteTeamName] || [game.homeTeamName isEqualToString:favoriteTeamName]) {
                        [favoriteTeamGames addObject:game];
                    } else if ([game.awayTeamName isEqualToString:secondFavoriteTeamName] || [game.homeTeamName isEqualToString:secondFavoriteTeamName]) {
                        [secondFavoriteTeamGames addObject:game];
                    } else if ([game.awayTeamName isEqualToString:thirdFavoriteTeamName] || [game.homeTeamName isEqualToString:thirdFavoriteTeamName]) {
                        [thirdFavoriteTeamGames addObject:game];
                    } else {
                        [notFavoriteGames addObject:game];
                    }
                }
                [favoriteTeamGames addObjectsFromArray:secondFavoriteTeamGames];
                [favoriteTeamGames addObjectsFromArray:thirdFavoriteTeamGames];
                [favoriteTeamGames addObjectsFromArray:notFavoriteGames];
                self.games = [favoriteTeamGames copy];
            }
            if (self.alertOnly) {
                [self performSelectorOnMainThread:@selector(dispatchToday) withObject:nil waitUntilDone:NO];
            } else {
                [self performSelectorOnMainThread:@selector(dispatchSave) withObject:nil waitUntilDone:NO];
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParse) {
            DebugLog(@"Error %@ %@",[error localizedDescription],[error userInfo]);
            if (!self.alertOnly) {
                [(NSObject*)self.delegate performSelectorOnMainThread:@selector(failedLoad) withObject:nil waitUntilDone:NO];
            } else {
                [(NSObject*)self.delegate performSelectorOnMainThread:@selector(failedTodayLoad) withObject:nil waitUntilDone:NO];
            }
        }];
        self.afOperation.successCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
        self.afOperation.failureCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);

        [self.afOperation start];
    }
    return self;
}

-(void) dispatchToday {
    [self.delegate saveTodayArray:self.games dict:self.gamesDict];
}

-(void) dispatchSave {
    [self.delegate saveArray:self.games dict:self.gamesDict];
}

//- (void) parseGames:(TBXML*)tbxmlDocument {
//    __block NSError *error = nil;
//    [TBXML iterateElementsForQuery:@"game" fromElement:tbxmlDocument.rootXMLElement withBlock:^(TBXMLElement *element) {
//        if (error) {
//            DebugLog(@"Error! %@ %@", [error localizedDescription], [error userInfo]);
//        } else {
//            Game *game = [[Game alloc] init];
//            game.dateComponents = self.dateComponents;
//            [self.games addObject:game];
//            [TBXML iterateAttributesOfElement:element withBlock:^(TBXMLAttribute *attribute, NSString *name, NSString *value) {
//                NSString *methodName = [self generateMethodName:name];
//                
//                if ([game respondsToSelector:NSSelectorFromString(methodName)]) {
//                    #pragma clang diagnostic push
//                    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//                    [game performSelector:NSSelectorFromString(methodName) withObject:[value stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"]];
//                    #pragma clang diagnostic pop
//                }
//            }];
//            game.gameDate = [self dateFromTime:game.time ampm:game.ampm dateComponents:self.dateComponents];
////            [self parseStatus:element forGame:game];
////            [self parseTVRadio:element forGame:game];
////            [self parseLineScore:element forGame:game];
////            [self parseLinks:element forGame:game];
////            [self parseRunnersOnBase:element forGame:game];
////            [self parsePitcherBatterPlay:element forGame:game];
//            [self.gamesDict setObject:game forKey:game.gameday];
//        }
//    }];
//}

//- (void) parseStatus:(TBXMLElement*)element forGame:(Game*)game {
//    TBXMLElement *status = [TBXML childElementNamed:@"status" parentElement:element];
//    if (status != nil) {
//        game.status =  [TBXML valueOfAttributeNamed:@"status" forElement:status];
//        if ([game.status isEqualToString:@"Final"] || [game.status isEqualToString:@"Game Over"] || [game.status isEqualToString:@"Completed Early"]) {
//            game.statusCode = 2;
//        } else if ([game.status isEqualToString:@"In Progress"] || [game.status isEqualToString:@"Replay"]) {
//            game.statusCode = 1;
//        } else if ([game.status isEqualToString:@"Preview"] || [game.status isEqualToString:@"Pre-Game"] || [game.status isEqualToString:@"Warmup"]) {
//            game.statusCode = 0;
//        } else if ([game.status isEqualToString:@"Postponed"] || [game.status isEqualToString:@"Delayed"] || [game.status isEqualToString:@"Delayed Start"]) {
//            //same status code as unknown, but this way it won't log it as an "unknown status"
//            game.statusCode = -1;
//        } else {
//            DebugLog(@"unknown status: %@",game.status);
//            game.statusCode = -1;
//        }
//        game.ind = [TBXML valueOfAttributeNamed:@"ind" forElement:status];
//        game.inning = [TBXML valueOfAttributeNamed:@"inning" forElement:status];
//        game.outs = [TBXML valueOfAttributeNamed:@"o" forElement:status];
//        game.balls = [TBXML valueOfAttributeNamed:@"b" forElement:status];
//        game.strikes = [TBXML valueOfAttributeNamed:@"s" forElement:status];
//        game.inningState = [TBXML valueOfAttributeNamed:@"inning_state" forElement:status];
//        game.reason = [TBXML valueOfAttributeNamed:@"reason" forElement:status];
//    }    
//}
//
//- (void) parseRunnersOnBase:(TBXMLElement*)element forGame:(Game*)game {
//    TBXMLElement *runnersOnBase = [TBXML childElementNamed:@"runners_on_base" parentElement:element];
//    if (runnersOnBase != nil) {
//        game.runnerOnBaseStatus = [TBXML valueOfAttributeNamed:@"status" forElement:runnersOnBase];
//    }    
//}



//- (void) parseLineScore:(TBXMLElement *)element forGame:(Game*)game {
//    TBXMLElement *lineScore = [TBXML childElementNamed:@"linescore" parentElement:element];
//    game.innings = [NSMutableArray array];
//    if (lineScore != nil) {
//        TBXMLElement *inning = [TBXML childElementNamed:@"inning" parentElement:lineScore];
//        int i = 0;
//        while (inning != nil) {
//            i++;
//            Inning *inningObj = [[Inning alloc] init];
//            inningObj.inningNumber = i;
//            [game.innings addObject:inningObj];
//            inningObj.away = [TBXML valueOfAttributeNamed:@"away" forElement:inning];
//            inningObj.home = [TBXML valueOfAttributeNamed:@"home" forElement:inning];
//            inning = [TBXML nextSiblingNamed:@"inning" searchFromElement:inning];
//        }
//        TBXMLElement *r = [TBXML childElementNamed:@"r" parentElement:lineScore];
//        if (r != nil) {
//            game.awayTeamRuns = [TBXML valueOfAttributeNamed:@"away" forElement:r];
//            game.homeTeamRuns = [TBXML valueOfAttributeNamed:@"home" forElement:r];
//        }
//
//        TBXMLElement *h = [TBXML childElementNamed:@"h" parentElement:lineScore];
//        if (h != nil) {
//            game.awayTeamHits = [TBXML valueOfAttributeNamed:@"away" forElement:h];
//            game.homeTeamHits = [TBXML valueOfAttributeNamed:@"home" forElement:h];
//        }
//        
//        TBXMLElement *e = [TBXML childElementNamed:@"e" parentElement:lineScore];
//        if (e != nil) {
//            game.awayTeamErrors = [TBXML valueOfAttributeNamed:@"away" forElement:e];
//            game.homeTeamErrors = [TBXML valueOfAttributeNamed:@"home" forElement:e];        
//        }
//    }
//}

//- (void) parseTVRadio:(TBXMLElement *)element forGame:(Game*)game {
//    TBXMLElement *broadcast = [TBXML childElementNamed:@"broadcast" parentElement:element];
//    if (broadcast) {
//        TBXMLElement *home = [TBXML childElementNamed:@"home" parentElement:broadcast];
//        if (home) {
//            TBXMLElement *homeTv = [TBXML childElementNamed:@"tv" parentElement:home];
//            if (homeTv) {
//                game.homeTv = [TBXML textForElement:homeTv];
//            }
//            TBXMLElement *homeRadio = [TBXML childElementNamed:@"radio" parentElement:home];
//            if (homeRadio) {
//                game.homeRadio = [TBXML textForElement:homeRadio];
//            }
//        }
//        TBXMLElement *away = [TBXML childElementNamed:@"away" parentElement:broadcast];
//        if (away) {
//            TBXMLElement *awayTv = [TBXML childElementNamed:@"tv" parentElement:away];
//            if (awayTv) {
//                game.awayTv = [TBXML textForElement:awayTv];
//            }
//            TBXMLElement *awayRadio = [TBXML childElementNamed:@"radio" parentElement:away];
//            if (awayRadio) {
//                game.awayRadio = [TBXML textForElement:awayRadio];
//            }
//        }
//    }
//}


//- (void) parseLinks:(TBXMLElement *)element forGame:(Game*)game {
//    /*<links mlbtv="bam.media.launchPlayer({calendar_event_id:'14-287501-2011-05-15',media_type:'video'})" wrapup="/mlb/gameday/index.jsp?gid=2011_05_15_slnmlb_cinmlb_1&mode=wrap&c_id=mlb" home_audio="bam.media.launchPlayer({calendar_event_id:'14-287501-2011-05-15',media_type:'audio'})" away_audio="bam.media.launchPlayer({calendar_event_id:'14-287501-2011-05-15',media_type:'audio'})" home_preview="/mlb/gameday/index.jsp?gid=2011_05_15_slnmlb_cinmlb_1&mode=preview&c_id=mlb" away_preview="/mlb/gameday/index.jsp?gid=2011_05_15_slnmlb_cinmlb_1&mode=preview&c_id=mlb" preview="/mlb/gameday/index.jsp?gid=2011_05_15_slnmlb_cinmlb_1&mode=preview&c_id=mlb" tv_station="FS-O"/>*/
//    TBXMLElement *links = [TBXML childElementNamed:@"links" parentElement:element];
//    if (links != nil) {
//        game.awayPreviewLink = [[TBXML valueOfAttributeNamed:@"away_preview" forElement:links] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
//        game.homePreviewLink = [[TBXML valueOfAttributeNamed:@"home_preview" forElement:links] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
//    }
//
//}

//- (void) parsePitcherBatterPlay:(TBXMLElement *)element forGame:(Game*)game {
//    TBXMLElement *homeProbablePitcher = [TBXML childElementNamed:@"home_probable_pitcher" parentElement:element];
//    if (homeProbablePitcher != nil) {
//        game.homeProbablePitcher = [[Pitcher alloc] init];
//        game.homeProbablePitcher.name = [TBXML valueOfAttributeNamed:@"name_display_roster" forElement:homeProbablePitcher];
//        game.homeProbablePitcher.pitcherId = [TBXML valueOfAttributeNamed:@"id" forElement:homeProbablePitcher];
//        
//        game.homeProbablePitcher.wins = [TBXML valueOfAttributeNamed:@"wins" forElement:homeProbablePitcher];
//        game.homeProbablePitcher.losses = [TBXML valueOfAttributeNamed:@"losses" forElement:homeProbablePitcher];
//        game.homeProbablePitcher.earnedRunAverage = [TBXML valueOfAttributeNamed:@"era" forElement:homeProbablePitcher];
//        
//    }
//    TBXMLElement *awayProbablePitcher = [TBXML childElementNamed:@"away_probable_pitcher" parentElement:element];
//    if (awayProbablePitcher != nil) {
//        game.awayProbablePitcher = [[Pitcher alloc] init];
//        game.awayProbablePitcher.name = [TBXML valueOfAttributeNamed:@"name_display_roster" forElement:awayProbablePitcher];
//        game.awayProbablePitcher.pitcherId = [TBXML valueOfAttributeNamed:@"id" forElement:awayProbablePitcher];
//        
//        game.awayProbablePitcher.wins = [TBXML valueOfAttributeNamed:@"wins" forElement:awayProbablePitcher];
//        game.awayProbablePitcher.losses = [TBXML valueOfAttributeNamed:@"losses" forElement:awayProbablePitcher];
//        game.awayProbablePitcher.earnedRunAverage = [TBXML valueOfAttributeNamed:@"era" forElement:awayProbablePitcher];
//    }
//    TBXMLElement *currentPitcher = [TBXML childElementNamed:@"pitcher" parentElement:element];
//    if (currentPitcher != nil) {
//        game.currentPitcher = [[Pitcher alloc] init];
//        game.currentPitcher.name = [TBXML valueOfAttributeNamed:@"name_display_roster" forElement:currentPitcher];
//        game.currentPitcher.pitcherId = [TBXML valueOfAttributeNamed:@"id" forElement:currentPitcher];
//        
//        game.currentPitcher.wins = [TBXML valueOfAttributeNamed:@"wins" forElement:currentPitcher];
//        game.currentPitcher.losses = [TBXML valueOfAttributeNamed:@"losses" forElement:currentPitcher];
//        game.currentPitcher.earnedRunAverage = [TBXML valueOfAttributeNamed:@"era" forElement:currentPitcher];
//    }
//    TBXMLElement *batter = [TBXML childElementNamed:@"batter" parentElement:element];
//    if (batter != nil) {
//        game.currentBatter = [[Batter alloc] init];
//        game.currentBatter.batterId = [TBXML valueOfAttributeNamed:@"id" forElement:batter];
//        game.currentBatter.name = [TBXML valueOfAttributeNamed:@"name_display_roster" forElement:batter];
//        game.currentBatter.hits = [TBXML valueOfAttributeNamed:@"h" forElement:batter];
//        game.currentBatter.atBats = [TBXML valueOfAttributeNamed:@"ab" forElement:batter];
//        game.currentBatter.position = [TBXML valueOfAttributeNamed:@"pos" forElement:batter];
//        game.currentBatter.average = [TBXML valueOfAttributeNamed:@"avg" forElement:batter];
//        game.currentBatter.ops = [TBXML valueOfAttributeNamed:@"ops" forElement:batter];
//
//    }
//    TBXMLElement *onDeck = [TBXML childElementNamed:@"ondeck" parentElement:element];
//    if (onDeck != nil) {
//        game.currentOnDeck = [[Batter alloc] init];
//        game.currentOnDeck.name = [TBXML valueOfAttributeNamed:@"name_display_roster" forElement:onDeck];
//        game.currentOnDeck.batterId = [TBXML valueOfAttributeNamed:@"id" forElement:onDeck];
//        game.currentOnDeck.hits = [TBXML valueOfAttributeNamed:@"h" forElement:onDeck];
//        game.currentOnDeck.atBats = [TBXML valueOfAttributeNamed:@"ab" forElement:onDeck];
//        game.currentOnDeck.position = [TBXML valueOfAttributeNamed:@"pos" forElement:onDeck];
//        game.currentOnDeck.average = [TBXML valueOfAttributeNamed:@"avg" forElement:onDeck];
//        game.currentOnDeck.ops = [TBXML valueOfAttributeNamed:@"ops" forElement:onDeck];
//    }
//    TBXMLElement *currentInHole = [TBXML childElementNamed:@"inhole" parentElement:element];
//    if (currentInHole != nil) {
//        game.currentInHole = [[Batter alloc] init];
//        game.currentInHole.name = [TBXML valueOfAttributeNamed:@"name_display_roster" forElement:currentInHole];
//        game.currentInHole.batterId = [TBXML valueOfAttributeNamed:@"id" forElement:currentInHole];
//        game.currentInHole.hits = [TBXML valueOfAttributeNamed:@"h" forElement:currentInHole];
//        game.currentInHole.atBats = [TBXML valueOfAttributeNamed:@"ab" forElement:currentInHole];
//        game.currentInHole.position = [TBXML valueOfAttributeNamed:@"pos" forElement:currentInHole];
//        game.currentInHole.average = [TBXML valueOfAttributeNamed:@"avg" forElement:currentInHole];
//        game.currentInHole.ops = [TBXML valueOfAttributeNamed:@"ops" forElement:currentInHole];
//    }
//    TBXMLElement *winningPitcher = [TBXML childElementNamed:@"winning_pitcher" parentElement:element];
//    if (winningPitcher != nil) {
//        game.winningPitcher = [[Pitcher alloc] init];
//        game.winningPitcher.name = [TBXML valueOfAttributeNamed:@"name_display_roster" forElement:winningPitcher];
//        game.winningPitcher.pitcherId = [TBXML valueOfAttributeNamed:@"id" forElement:winningPitcher];
//        
//        game.winningPitcher.wins = [TBXML valueOfAttributeNamed:@"wins" forElement:winningPitcher];
//        game.winningPitcher.losses = [TBXML valueOfAttributeNamed:@"losses" forElement:winningPitcher];
//        game.winningPitcher.earnedRunAverage = [TBXML valueOfAttributeNamed:@"era" forElement:winningPitcher];
//    }
//    TBXMLElement *losingPitcher = [TBXML childElementNamed:@"losing_pitcher" parentElement:element];
//    if (losingPitcher != nil) {
//        game.losingPitcher = [[Pitcher alloc] init];
//        game.losingPitcher.name = [TBXML valueOfAttributeNamed:@"name_display_roster" forElement:losingPitcher];
//        game.losingPitcher.pitcherId = [TBXML valueOfAttributeNamed:@"id" forElement:losingPitcher];
//        
//        game.losingPitcher.wins = [TBXML valueOfAttributeNamed:@"wins" forElement:losingPitcher];
//        game.losingPitcher.losses = [TBXML valueOfAttributeNamed:@"losses" forElement:losingPitcher];
//        game.losingPitcher.earnedRunAverage = [TBXML valueOfAttributeNamed:@"era" forElement:losingPitcher];
//    }
//    TBXMLElement *savePitcher = [TBXML childElementNamed:@"save_pitcher" parentElement:element];
//    if (savePitcher != nil) {
//        game.savePitcher = [[Pitcher alloc] init];
//        game.savePitcher.name = [TBXML valueOfAttributeNamed:@"name_display_roster" forElement:savePitcher];
//        game.savePitcher.pitcherId = [TBXML valueOfAttributeNamed:@"id" forElement:savePitcher];
//        
//        game.savePitcher.wins = [TBXML valueOfAttributeNamed:@"wins" forElement:savePitcher];
//        game.savePitcher.losses = [TBXML valueOfAttributeNamed:@"losses" forElement:savePitcher];
//        game.savePitcher.earnedRunAverage = [TBXML valueOfAttributeNamed:@"era" forElement:savePitcher];
//    }
//    TBXMLElement *pbp = [TBXML childElementNamed:@"pbp" parentElement:element];
//    if (pbp != nil) {
//        game.lastPlay = [[[TBXML valueOfAttributeNamed:@"last" forElement:pbp] stringByReplacingOccurrencesOfString:@"  " withString:@" "] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    }
//}
//
//
//- (NSString*) generateMethodName:(NSString*)name {
//    if ([name isEqualToString:@"description"]) {
//        return @"setGameDescription:";
//    }
//    NSMutableString *upCase = [NSMutableString string];
//    BOOL makeNextCharacterUpperCase = YES;
//    for (NSInteger idx = 0; idx < [name length]; idx += 1) {
//        unichar c = [name characterAtIndex:idx];
//        if (c == '_') {
//            makeNextCharacterUpperCase = YES;
//        } else if (makeNextCharacterUpperCase) {
//            [upCase appendString:[[NSString stringWithCharacters:&c length:1] uppercaseString]];
//            makeNextCharacterUpperCase = NO;
//        } else {
//            [upCase appendFormat:@"%C", c];
//        }
//    }
//    return [NSString stringWithFormat:@"set%@:",upCase];
//}

-(void) cancel {
    DebugLog(@"aborting async request");
    if (self.afOperation != nil) {
        [self.afOperation cancel];
    }
}

-(NSDate*) dateFromTime:(NSString*)time ampm:(NSString*)ampm dateComponents:(NSDateComponents*)pDateComponents {
    NSDateComponents *components = [pDateComponents copy];
    NSArray *timeComponents = [time componentsSeparatedByString:@":"];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    components.timeZone = [NSTimeZone timeZoneWithName:@"US/Eastern"];
    NSInteger hour = [[timeComponents objectAtIndex:0] intValue];
    ampm = [ampm uppercaseString];
    if ([ampm isEqualToString:@"PM"] && hour != 12) {
        hour += 12;
    }
    components.hour = hour;
    components.minute = [[timeComponents objectAtIndex:1] intValue];
    return [calendar dateFromComponents:components];
}

-(NSMutableDictionary*) getAppPreferences {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return appDelegate.preferences;
}

#pragma mark -
#pragma mark NSXMLParser delegate methods

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
 namespaceURI:(NSString *)namespaceURI 
qualifiedName:(NSString *)qName 
   attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"game"]) {
        [self parseGame:attributeDict];
    } else if ([elementName isEqualToString:@"status"]) {
        [self parseStatus:attributeDict];
    } else if ([elementName isEqualToString:@"runners_on_base"]) {
        Game *game = [self.games lastObject];
        game.runnerOnBaseStatus = [attributeDict objectForKey:@"status"];
    } else if ([elementName isEqualToString:@"linescore"]) {
        Game *game = [self.games lastObject];
        if (!game.innings) {
            game.innings = [NSMutableArray array];
        }
    } else if ([elementName isEqualToString:@"inning"]) {
        Game *game = [self.games lastObject];
        Inning *inningObj = [[Inning alloc] init];
        inningObj.inningNumber = game.innings.count + 1;
        [game.innings addObject:inningObj];
        inningObj.away = [attributeDict objectForKey:@"away"];
        inningObj.home = [attributeDict objectForKey:@"home"];
    } else if ([elementName isEqualToString:@"r"]) {
        Game *game = [self.games lastObject];
        game.awayTeamRuns = [attributeDict objectForKey:@"away"];
        game.homeTeamRuns = [attributeDict objectForKey:@"home"];
    } else if ([elementName isEqualToString:@"h"]) {
        Game *game = [self.games lastObject];
        game.awayTeamHits = [attributeDict objectForKey:@"away"];
        game.homeTeamHits = [attributeDict objectForKey:@"home"];
    } else if ([elementName isEqualToString:@"e"]) {
        Game *game = [self.games lastObject];
        game.awayTeamErrors = [attributeDict objectForKey:@"away"];
        game.homeTeamErrors = [attributeDict objectForKey:@"home"];        
    } else if ([elementName isEqualToString:@"broadcast"]) {
        self.isBroadcastNode = YES;
    } else if ([elementName isEqualToString:@"home"] && self.isBroadcastNode) {
        self.isHomeNode = YES;
    } else if ([elementName isEqualToString:@"away"] && self.isBroadcastNode) {
        self.isAwayNode = YES;
    } else if ([elementName isEqualToString:@"tv"] && self.isBroadcastNode) {
        self.isTvNode = YES;
    } else if ([elementName isEqualToString:@"radio"] && self.isBroadcastNode) {
        self.isRadioNode = YES;
    } else if ([elementName isEqualToString:@"links"]) {
        Game *game = [self.games lastObject];
        game.awayPreviewLink = [[attributeDict objectForKey:@"away_preview"] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        game.homePreviewLink = [[attributeDict objectForKey:@"home_preview"] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    } else if ([elementName isEqualToString:@"home_probable_pitcher"]) {
        Game *game = [self.games lastObject];
        game.homeProbablePitcher = [[Pitcher alloc] init];
        [self populatePitcher:game.homeProbablePitcher withData:attributeDict];
    } else if ([elementName isEqualToString:@"away_probable_pitcher"]) {
        Game *game = [self.games lastObject];
        game.awayProbablePitcher = [[Pitcher alloc] init];
        [self populatePitcher:game.awayProbablePitcher withData:attributeDict];        
    } else if ([elementName isEqualToString:@"pitcher"]) {
        Game *game = [self.games lastObject];
        game.currentPitcher = [[Pitcher alloc] init];
        [self populatePitcher:game.currentPitcher withData:attributeDict];        
    } else if ([elementName isEqualToString:@"winning_pitcher"]) {
        Game *game = [self.games lastObject];
        game.winningPitcher = [[Pitcher alloc] init];
        [self populatePitcher:game.winningPitcher withData:attributeDict];        
    } else if ([elementName isEqualToString:@"losing_pitcher"]) {
        Game *game = [self.games lastObject];
        game.losingPitcher = [[Pitcher alloc] init];
        [self populatePitcher:game.losingPitcher withData:attributeDict];        
    } else if ([elementName isEqualToString:@"save_pitcher"]) {
        Game *game = [self.games lastObject];
        game.savePitcher = [[Pitcher alloc] init];
        [self populatePitcher:game.savePitcher withData:attributeDict];        
    } else if ([elementName isEqualToString:@"batter"]) {
        Game *game = [self.games lastObject];
        game.currentBatter = [[Batter alloc] init];
        [self populateBatter:game.currentBatter withData:attributeDict];        
    } else if ([elementName isEqualToString:@"ondeck"]) {
        Game *game = [self.games lastObject];
        game.currentOnDeck = [[Batter alloc] init];
        [self populateBatter:game.currentOnDeck withData:attributeDict];        
    } else if ([elementName isEqualToString:@"inhole"]) {
        Game *game = [self.games lastObject];
        game.currentInHole = [[Batter alloc] init];
        [self populateBatter:game.currentInHole withData:attributeDict];        
    } else if ([elementName isEqualToString:@"pbp"]) {
        Game *game = [self.games lastObject];
        game.lastPlay = [[[attributeDict objectForKey:@"last"] stringByReplacingOccurrencesOfString:@"  " withString:@" "] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
}

-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (self.isBroadcastNode) {
        Game *game = [self.games lastObject];
        if (self.isHomeNode) {
            if (self.isTvNode) {
                game.homeTv = [game.homeTv stringByAppendingString:string];
            } else if (self.isRadioNode) {
                game.homeRadio = [game.homeRadio stringByAppendingString:string];
            }
        } else if (self.isAwayNode) {
            if (self.isTvNode) {
                game.awayTv = [game.awayTv stringByAppendingString:string];
            } else if (self.isRadioNode) {
                game.awayRadio = [game.awayRadio stringByAppendingString:string];
            }            
        }
    }
}


-(void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"broadcast"]) {
        self.isBroadcastNode = NO;
    } else if (self.isBroadcastNode && [elementName isEqualToString:@"home"]) {
        self.isHomeNode = NO;
    } else if (self.isBroadcastNode && [elementName isEqualToString:@"away"]) {
        self.isAwayNode = NO;
    } else if (self.isBroadcastNode && [elementName isEqualToString:@"tv"]) {
        self.isTvNode = NO;
    } else if (self.isBroadcastNode && [elementName isEqualToString:@"radio"]) {
        self.isRadioNode = NO;
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if ([parseError code] != NSXMLParserDelegateAbortedParseError) {
        DebugLog(@"%@",parseError);
        if (!self.alertOnly) {
            [(NSObject*)self.delegate performSelectorOnMainThread:@selector(failedLoad) withObject:nil waitUntilDone:NO];
        } else {
            [(NSObject*)self.delegate performSelectorOnMainThread:@selector(failedTodayLoad) withObject:nil waitUntilDone:NO];
        }
    }
}

-(void) parseGame:(NSDictionary*)attributeDict {
    Game *game = [[Game alloc] init];
    [self.games addObject:game];
    game.dateComponents = self.dateComponents;
    game.gameday = [attributeDict objectForKey:@"gameday"];
    [self.gamesDict setObject:game forKey:game.gameday];
    game.gameDescription = [attributeDict objectForKey:@"description"];
    game.status = [attributeDict objectForKey:@"status"];
    game.venue = [attributeDict objectForKey:@"venue"];
    game.time = [attributeDict objectForKey:@"time"];
    game.ampm = [attributeDict objectForKey:@"ampm"];
    game.gameDate = [self dateFromTime:game.time ampm:game.ampm dateComponents:self.dateComponents];
    game.awayCode = [attributeDict objectForKey:@"away_code"];
    game.awayNameAbbrev = [attributeDict objectForKey:@"away_name_abbrev"];
    game.awayTeamName = [attributeDict objectForKey:@"away_team_name"];
    game.awayWin = [attributeDict objectForKey:@"away_win"];
    game.awayLoss = [attributeDict objectForKey:@"away_loss"];
    game.homeCode = [attributeDict objectForKey:@"home_code"];
    game.homeNameAbbrev = [attributeDict objectForKey:@"home_name_abbrev"];
    game.homeTeamName = [attributeDict objectForKey:@"home_team_name"];
    game.homeWin = [attributeDict objectForKey:@"home_win"];
    game.homeLoss = [attributeDict objectForKey:@"home_loss"];
}

-(void) parseStatus:(NSDictionary*)attributeDict {
    Game *game = [self.games lastObject];
    game.status = [attributeDict objectForKey:@"status"];
    game.ind = [attributeDict objectForKey:@"ind"];
    game.inning = [attributeDict objectForKey:@"inning"];
    game.outs = [attributeDict objectForKey:@"o"];
    game.balls = [attributeDict objectForKey:@"b"];
    game.strikes = [attributeDict objectForKey:@"s"];
    game.inningState = [attributeDict objectForKey:@"inning_state"];
    game.reason = [attributeDict objectForKey:@"reason"];
}

-(void) populatePitcher:(Pitcher*)pitcher withData:(NSDictionary*)attributeDict {
    pitcher.name = [attributeDict objectForKey:@"name_display_roster"];
    pitcher.pitcherId = [attributeDict objectForKey:@"id"];
    pitcher.wins = [attributeDict objectForKey:@"wins"];
    pitcher.losses = [attributeDict objectForKey:@"losses"];
    pitcher.earnedRunAverage = [attributeDict objectForKey:@"era"];
}

-(void) populateBatter:(Batter*)batter withData:(NSDictionary*)attributeDict {
    batter.batterId = [attributeDict objectForKey:@"id"];
    batter.name = [attributeDict objectForKey:@"name_display_roster"];
    batter.hits = [attributeDict objectForKey:@"h"];
    batter.atBats = [attributeDict objectForKey:@"ab"];
    batter.position = [attributeDict objectForKey:@"pos"];
    batter.average = [attributeDict objectForKey:@"avg"];
    batter.ops = [attributeDict objectForKey:@"ops"];
}

@end
