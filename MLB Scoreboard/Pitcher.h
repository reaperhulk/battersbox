//
//  Pitcher.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Pitcher : NSObject

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *pitcherId;
@property (nonatomic,strong) NSString *inningsPitched;
@property (nonatomic,strong) NSString *runsAllowed;
@property (nonatomic,strong) NSString *earnedRuns;
@property (nonatomic,strong) NSString *hitsAllowed;
@property (nonatomic,strong) NSString *baseOnBalls;
@property (nonatomic,strong) NSString *strikeOuts;
@property (nonatomic,strong) NSString *homeRunsAllowed;
@property (nonatomic,strong) NSString *earnedRunAverage;
@property (nonatomic,strong) NSString *wins;
@property (nonatomic,strong) NSString *losses;


@end
