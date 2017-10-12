//
//  Game.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pitcher.h"
#import "Batter.h"

@interface Game : NSObject

@property (strong) NSDateComponents *dateComponents;

@property (strong) NSString *gameday;

@property (strong) NSString *status;
@property (strong) NSString *ind;
@property (strong) NSString *reason;

@property (strong) NSString *venue;
@property (strong) NSString *gameDescription;
@property (strong) NSDate *gameDate;
@property (strong) NSString *time;
@property (strong) NSString *ampm;
@property (strong) NSString *awayCode;
@property (strong) NSString *awayNameAbbrev;
@property (strong) NSString *awayTeamName;
@property (strong) NSString *awayWin;
@property (strong) NSString *awayLoss;

@property (strong) NSString *homeCode;
@property (strong) NSString *homeNameAbbrev;
@property (strong) NSString *homeTeamName;
@property (strong) NSString *homeWin;
@property (strong) NSString *homeLoss;

@property (strong) NSString *awayTeamRuns;
@property (strong) NSString *awayTeamHits;
@property (strong) NSString *awayTeamErrors;

@property (strong) NSString *homeTeamRuns;
@property (strong) NSString *homeTeamHits;
@property (strong) NSString *homeTeamErrors;

@property (strong) NSMutableArray *innings;
@property (strong) NSString *inning;
@property (strong) NSString *inningState;
@property (strong) NSString *runnerOnBaseStatus;
@property (strong) NSString *outs;
@property (strong) NSString *balls;
@property (strong) NSString *strikes;

@property (strong) NSString *awayPreviewLink;
@property (strong) NSString *homePreviewLink;

@property (strong) Pitcher *currentPitcher;
@property (strong) Batter *currentBatter;
@property (strong) Batter *currentOnDeck;
@property (strong) Batter *currentInHole;
@property (strong) NSString *lastPlay;

@property (strong) Pitcher *winningPitcher;
@property (strong) Pitcher *losingPitcher;
@property (strong) Pitcher *savePitcher;

@property (strong) Pitcher *homeProbablePitcher;
@property (strong) Pitcher *awayProbablePitcher;

@property (strong) NSString *awayRadio;
@property (strong) NSString *homeRadio;
@property (strong) NSString *awayTv;
@property (strong) NSString *homeTv;

-(BOOL) beforeFirstPitch;
-(NSString*) gameTimeInLocalTime;
-(NSInteger) statusCode;

@end