//
//  GamesDataController.m
//  Batter's Box
//
//  Created by Paul Kehrer on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GamesDataController.h"
#import "NSDate+DateIsToday.h"
#import "AppDelegate.h"

@implementation GamesDataController

@synthesize parser,todayParser,games,gamesDict,todayGames,todayGamesDict;
@synthesize scheduleDate,refreshTimer,todayRefreshTimer,selectedGameday;
@synthesize gamesDelegate,detailsDelegate;

+(GamesDataController*)sharedSingleton {
    static GamesDataController *sharedSingleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[GamesDataController alloc] init];
    });
    return sharedSingleton;
}

-(void) startup {
    [self loadDataWithDate:[NSDate dateTodayish] reset:YES];
    [self scheduleUpdate];
}

-(void) restart:(BOOL)reset {
    [self loadDataWithDate:self.scheduleDate reset:reset];
    [self scheduleUpdate];
}

-(void) stop {
    [self unscheduleUpdate];
    [self unscheduleTodayUpdate];
    if (self.parser) {
        [self.parser cancel];
        self.parser = nil;
    }
}

-(void) reloadData {
    if (![self.scheduleDate isTodayish] && self.games != nil) {
        DebugLog(@"current date is not todayish and we already have data so no need to reload");
        return;
    } else {
        [self loadDataWithDate:self.scheduleDate reset:NO];
    }
}

-(void) loadToday {
    [self loadDataWithDate:[NSDate dateTodayish] reset:YES];
}

-(void) changeDate:(NSDate*)date reset:(BOOL)reset {
    [self loadDataWithDate:date reset:reset];
}

-(void) goForward {
    NSDateComponents* components = [[NSDateComponents alloc] init];
    components.day = 1;
    self.scheduleDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self.scheduleDate options:0];
    
    [self loadDataWithDate:self.scheduleDate reset:YES];
}

-(void) goBackward {
    NSDateComponents* components = [[NSDateComponents alloc] init];
    components.day = -1;
    self.scheduleDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self.scheduleDate options:0];
    
    [self loadDataWithDate:self.scheduleDate reset:YES];    
}

- (void) loadDataWithDate:(NSDate*)date reset:(BOOL)reset {
    self.scheduleDate = date;
    if ([self.gamesDelegate respondsToSelector:@selector(setNavTitle)]) {
        [self.gamesDelegate setNavTitle];
    }
    if ([self.detailsDelegate respondsToSelector:@selector(setNavTitle)]) {
        [self.detailsDelegate setNavTitle];
    }
    if (![date isTodayish] && self.todayRefreshTimer == nil) {
        [self scheduleTodayUpdate];
    } else if (self.todayRefreshTimer != nil && [date isTodayish]) {
        [self unscheduleTodayUpdate];
    }
    if (reset) {
        //refreshing everything so null it out
        self.games = nil;
        self.gamesDict = nil;
        self.selectedGameday = nil;
    }
        
    if (self.parser != nil) {
        [self.parser cancel];
        self.parser = nil;
    }
    self.parser = [[MainScoreboardParser alloc] initWithDelegate:self date:self.scheduleDate alertOnly:NO];
}

-(NSMutableDictionary*) getAppPreferences {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return appDelegate.preferences;
}


-(void) scheduleUpdate {
    [self unscheduleUpdate];
    NSInteger refreshInterval = [[[self getAppPreferences] objectForKey:@"refreshInterval"] intValue];
    if (refreshInterval > 0) {
        DebugLog(@"scheduled update interval %d",refreshInterval);
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:refreshInterval target:self selector:@selector(reloadData) userInfo:nil repeats:YES];
    } else {
        DebugLog(@"no scheduled update interval");
    }
}

-(void) unscheduleUpdate {
    DebugLog(@"unscheduling update");
    if (self.refreshTimer != nil) {
        [self.refreshTimer invalidate];
        self.refreshTimer = nil;
    }
}

-(void) scheduleTodayUpdate {
    [self unscheduleTodayUpdate];
    NSInteger refreshInterval = [[[self getAppPreferences] objectForKey:@"refreshInterval"] intValue];
    NSString *showScoreAlerts = [[self getAppPreferences] objectForKey:@"showScoreAlerts"];
    if (![showScoreAlerts isEqualToString:@"None"]) {
        if (refreshInterval == 0)
            refreshInterval = 60;
        DebugLog(@"scheduled today timer");
        self.todayRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:refreshInterval target:self selector:@selector(loadDataForScoreAlerts) userInfo:nil repeats:YES];
    }
}

-(void) unscheduleTodayUpdate {
    if (self.todayRefreshTimer != nil) {
        DebugLog(@"unscheduled today timer");
        [self.todayRefreshTimer invalidate];
        self.todayRefreshTimer = nil;
        if (self.todayParser != nil) {
            [self.todayParser cancel];
            self.todayParser = nil;
        }
    }    
}

-(void) loadDataForScoreAlerts {
    if (self.todayParser != nil) {
        [self.todayParser cancel];
        self.todayParser = nil;
    }
    self.todayParser = [[MainScoreboardParser alloc] initWithDelegate:self date:[NSDate dateTodayish] alertOnly:YES];
}

-(Game*)gameForGameday:(NSString*)gameday {
    return (Game*)[self.gamesDict objectForKey:gameday];
}

#pragma mark -
#pragma mark MainScoreboardDelegate methods
-(void) failedLoad {
    self.parser = nil;
    [self.gamesDelegate failedLoad];
    [self.detailsDelegate failedLoad];
}

-(void) saveArray:(NSMutableArray *)pGames dict:(NSMutableDictionary *)dict {
    self.parser = nil;
    if ([self.scheduleDate isTodayish]) {
        [self saveTodayArray:pGames dict:dict];
    }    
    self.gamesDict = [dict copy];
    self.games = [pGames copy];
    [self.gamesDelegate loadGamesData];
    [self.detailsDelegate loadGamesData];
}

-(void) failedTodayLoad {
    DebugLog(@"failed to load today");
}

-(void) saveTodayArray:(NSMutableArray *)pGames dict:(NSMutableDictionary *)dict {
    if ([self.gamesDelegate respondsToSelector:@selector(showScoreAlerts:)]) {
        [self.gamesDelegate showScoreAlerts:pGames];
    }
    self.todayParser = nil;
    self.todayGames = pGames;
    self.todayGamesDict = dict;
}

@end
