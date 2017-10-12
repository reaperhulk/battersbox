//
//  PitchParser.h
//  Batter's Box
//
//  Created by Paul Kehrer on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFXMLRequestOperation.h"
#import "Pitch.h"
#import "Game.h"
#import "Weather.h"

@protocol PitchParserDelegate

-(void) pitchesLoaded:(NSArray *)pitches atBatNum:(NSInteger)pAtBatNum stand:stand complete:(BOOL)complete pastAtBat:(BOOL)pPastAtBat;
-(void) pitchLoadFailed;
-(void) pitchParseComplete;
@end

@protocol WeatherDelegate <NSObject>

-(void) weatherLoaded:(Weather*)weather;

@end

@protocol HomeRunDelegate <NSObject>

-(void) homeRunHit:(NSInteger)atBatNum;

@end

@protocol AtBatCountAndScoreDelegate <NSObject>

-(void) atBatCountAndScoreLoaded:(NSDictionary*)count;

@end

@interface PitchParser : NSObject <NSXMLParserDelegate>

@property (nonatomic,strong) NSMutableArray *pitches;
@property (nonatomic,strong) AFXMLRequestOperation *afOperation;
@property NSInteger atBatNum;
@property BOOL atBatComplete;
@property (nonatomic,strong) NSString *batterStand;
@property (nonatomic,strong) NSString *gameStatus;
@property (nonatomic,strong) NSString *gameReason;
@property (nonatomic,strong) NSString *gameEvent;
@property (nonatomic,weak) id<PitchParserDelegate,WeatherDelegate,HomeRunDelegate,AtBatCountAndScoreDelegate> delegate;
@property (nonatomic,strong) Game *game;
@property (nonatomic,strong) NSMutableDictionary *batterCount;

- (id) initWithDelegate:(id<PitchParserDelegate,WeatherDelegate,HomeRunDelegate,AtBatCountAndScoreDelegate>)pDelegate game:(Game*)pGame;
-(void) cancel;

@end
