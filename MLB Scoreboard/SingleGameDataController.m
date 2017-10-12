//
//  SingleGameDataController.m
//  Batter's Box
//
//  Created by Paul Kehrer on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SingleGameDataController.h"
#import "GamesDataController.h"
#import "AppDelegate.h"

@implementation SingleGameDataController

@synthesize boxParser,eventParser,pitchParser,lineParser,gameday;
@synthesize detailsBoxDelegate,batterBoxDelegate,pitcherBoxDelegate;
@synthesize eventDelegate,pitchDelegate,lineDelegate,weatherDelegate,homeRunDelegate,atBatAndScoreDelegate;
@synthesize refreshTimer,finalLoad;
@synthesize eventLogData,eventLogSectionNames,boxScoreData,atBatNum;

-(id) initWithGameday:(NSString*)pGameday {
    self = [super init];
    if (self) {
        self.gameday = pGameday;
    }
    return self;
}

-(void) dealloc {
    DebugLog(@"called dealloc");
    [self cancelAsyncRequests];
}

-(void) start {
    [self scheduleUpdate];
    [self loadData];
}

-(void) stop {
    [self cancelAsyncRequests];
    [self unscheduleUpdate];
}

-(void) loadData {
    Game *game = [[GamesDataController sharedSingleton].gamesDict objectForKey:self.gameday];
    if (game.statusCode != 2 || (game.statusCode == 2 && self.finalLoad == NO)) {
        if (game.statusCode == 2) {
            self.finalLoad = YES;
        }
        [self cancelAsyncRequests];
        self.boxParser = [[BoxScoreParser alloc] initWithDelegate:self game:game];
        self.pitchParser = [[PitchParser alloc] initWithDelegate:self game:game];
        [self loadEventLog];
    }
}

-(void) loadEventLog {
    Game *game = [[GamesDataController sharedSingleton].gamesDict objectForKey:self.gameday];
    self.eventParser = [[EventLogParser alloc] initWithDelegate:self game:game];
}

//used to trigger a potentially faster reload after an at bat is complete
-(void) maybeLoadEventLog {
    DebugLog(@"maybe loading event log");
    if (!self.eventParser) {
        DebugLog(@"no event load in progress, let's give it a shot!");
        [self loadEventLog];
    }
}

-(void) scheduleUpdate {
    [self unscheduleUpdate];
    NSInteger refreshInterval = [[[self getAppPreferences] objectForKey:@"refreshInterval"] intValue];
    if (refreshInterval > 0) {
        DebugLog(@"scheduled single game update interval %d",refreshInterval);
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:refreshInterval target:self selector:@selector(loadData) userInfo:nil repeats:YES];
    }
}

-(void) unscheduleUpdate {
    DebugLog(@"unscheduling single game updates");
    if (self.refreshTimer != nil) {
        [self.refreshTimer invalidate];
        self.refreshTimer = nil;
    }
}

-(void) getLinescore {
    Game *game = [[GamesDataController sharedSingleton].gamesDict objectForKey:self.gameday];
    self.lineParser = [[LinescoreParser alloc] initWithDelegate:self game:game];
}

-(NSMutableDictionary*) getAppPreferences {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return appDelegate.preferences;
}

-(void) boxScoreLoaded:(NSDictionary *)boxScore {
    self.boxParser = nil;
    [self.detailsBoxDelegate boxScoreLoaded:boxScore];
    [self.batterBoxDelegate boxScoreLoaded:boxScore];
    [self.pitcherBoxDelegate boxScoreLoaded:boxScore];
    self.boxScoreData = boxScore;
}

-(void) boxScoreLoadFailed {
    self.boxParser = nil;
    [self.detailsBoxDelegate boxScoreLoadFailed];
    [self.batterBoxDelegate boxScoreLoadFailed];
    [self.pitcherBoxDelegate boxScoreLoadFailed];
}

-(void) eventLogLoaded:(NSDictionary*)eventLog sectionNames:(NSArray *)sectionNames {
    self.eventParser = nil;
    [self.eventDelegate eventLogLoaded:eventLog sectionNames:sectionNames];
    self.eventLogData = eventLog;
    self.eventLogSectionNames = sectionNames;
}

-(void) eventLogLoadFailed {
    self.eventParser = nil;
    [self.eventDelegate eventLogLoadFailed];
}

-(void) pitchesLoaded:(NSArray *)pitches atBatNum:(NSInteger)pAtBatNum stand:(NSString*)stand complete:(BOOL)complete pastAtBat:(BOOL)pPastAtBat {
    self.pitchParser = nil;
    if (complete && self.atBatNum != pAtBatNum) {
        self.atBatNum = pAtBatNum;
        //potentially re-trigger to get faster last play data from plays.xml
    }
    [self.pitchDelegate pitchesLoaded:pitches atBatNum:pAtBatNum stand:stand complete:complete pastAtBat:pPastAtBat];
}

-(void) pitchLoadFailed {
    self.pitchParser = nil;
    [self.pitchDelegate pitchLoadFailed];
}

-(void) pitchParseComplete {
    self.pitchParser = nil;
    [self.pitchDelegate pitchParseComplete];
}

-(void) weatherLoaded:(Weather *)weather {
    [self.weatherDelegate weatherLoaded:weather];
}

-(void) homeRunHit:(NSInteger)pAtBatNum {
    [self.homeRunDelegate homeRunHit:pAtBatNum];
}

-(void) linescoreLoaded:(NSString *)awayRecapLink homeLink:(NSString *)homeRecapLink {
    self.lineParser = nil;
    [self.lineDelegate linescoreLoaded:awayRecapLink homeLink:homeRecapLink];
}

-(void) linescoreLoadFailed {
    self.lineParser = nil;
    [self.lineDelegate linescoreLoadFailed];
}

-(void) atBatCountAndScoreLoaded:(NSDictionary *)count {
    [self.atBatAndScoreDelegate atBatCountAndScoreLoaded:count];
}


-(void) cancelAsyncRequests {
    if (self.boxParser != nil) {
        [self.boxParser cancel];
        self.boxParser = nil;
    }
    if (self.eventParser != nil) {
        [self.eventParser cancel];
        self.eventParser = nil;
    }
    if (self.pitchParser != nil) {
        [self.pitchParser cancel];
        self.pitchParser = nil;
    }
    if (self.lineParser != nil) {
        [self.lineParser cancel];
        self.lineParser = nil;
    }
}
@end
