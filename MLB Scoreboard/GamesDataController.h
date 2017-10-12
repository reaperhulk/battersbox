//
//  GamesDataController.h
//  Batter's Box
//
//  Created by Paul Kehrer on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Game.h"
#import "MainScoreboardParser.h"

@protocol GamesDataDelegate <NSObject>
-(void) loadGamesData;
-(void) failedLoad;
@optional
-(void) showScoreAlerts:(NSMutableArray *)array;
-(void) setNavTitle;
@end

@interface GamesDataController : NSObject <MainScoreboardDelegate>

@property (nonatomic,strong) MainScoreboardParser *parser;
@property (nonatomic,strong) MainScoreboardParser *todayParser;
@property (nonatomic,strong) NSArray *games;
@property (nonatomic,strong) NSDictionary *gamesDict;
@property (nonatomic,strong) NSDate *scheduleDate;
@property (nonatomic,strong) NSTimer *refreshTimer;
@property (nonatomic,strong) NSTimer *todayRefreshTimer;
@property (nonatomic,strong) NSArray *todayGames;
@property (nonatomic,strong) NSDictionary *todayGamesDict;
@property (nonatomic,strong) NSString *selectedGameday;
@property (nonatomic,weak) id<GamesDataDelegate> gamesDelegate;
@property (nonatomic,weak) id<GamesDataDelegate> detailsDelegate;

+(GamesDataController*) sharedSingleton;
-(void) startup;
-(void) restart:(BOOL)reset;
-(void) stop;
-(void) changeDate:(NSDate*)date reset:(BOOL)reset;
-(void) goForward;
-(void) goBackward;
-(void) reloadData;

-(void) scheduleUpdate;
-(void) unscheduleUpdate;

-(void) loadToday;

-(Game*)gameForGameday:(NSString*)gameday;

@end
