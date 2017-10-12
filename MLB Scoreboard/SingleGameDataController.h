//
//  SingleGameDataController.h
//  Batter's Box
//
//  Created by Paul Kehrer on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoxScoreParser.h"
#import "EventLogParser.h"
#import "PitchParser.h"
#import "LinescoreParser.h"
#import "Game.h"

@protocol SingleGameBoxScoreDelegate <NSObject>
-(void) boxScoreLoaded:(NSDictionary*)boxScore;
-(void) boxScoreLoadFailed;
@end

@protocol SingleGameEventDelegate
-(void) eventLogLoaded:(NSDictionary*)eventLog sectionNames:(NSArray *)sectionNames;
-(void) eventLogLoadFailed;
@end


@interface SingleGameDataController : NSObject <BoxScoreDelegate,EventLogDelegate,PitchParserDelegate,LinescoreParserDelegate,WeatherDelegate,HomeRunDelegate,AtBatCountAndScoreDelegate>

@property (nonatomic, strong) BoxScoreParser *boxParser;
@property (nonatomic, strong) EventLogParser *eventParser;
@property (nonatomic, strong) PitchParser *pitchParser;
@property (nonatomic, strong) LinescoreParser *lineParser;
@property (nonatomic, strong) NSString *gameday;
@property (nonatomic, strong) NSTimer *refreshTimer;
@property (nonatomic, weak) id<SingleGameEventDelegate> eventDelegate;
@property (nonatomic, weak) id<PitchParserDelegate> pitchDelegate;
@property (nonatomic, weak) id<WeatherDelegate> weatherDelegate;
@property (nonatomic, weak) id<HomeRunDelegate> homeRunDelegate;
@property (nonatomic, weak) id<LinescoreParserDelegate> lineDelegate;
@property (nonatomic, weak) id<SingleGameBoxScoreDelegate> detailsBoxDelegate;
@property (nonatomic, weak) id<SingleGameBoxScoreDelegate> batterBoxDelegate;
@property (nonatomic, weak) id<SingleGameBoxScoreDelegate> pitcherBoxDelegate;
@property (nonatomic, weak) id<AtBatCountAndScoreDelegate> atBatAndScoreDelegate;

@property (nonatomic,strong) NSDictionary *boxScoreData;
@property (nonatomic,strong) NSDictionary *eventLogData;
@property (nonatomic,strong) NSArray *eventLogSectionNames;
@property NSInteger atBatNum;
@property BOOL finalLoad;


-(id) initWithGameday:(NSString*)pGameday;
-(void) start;
-(void) stop;
-(void) loadData;
-(void) getLinescore;

@end
