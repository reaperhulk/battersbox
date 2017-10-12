//
//  GameEvent.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameEvent : NSObject

@property (nonatomic,strong) NSString *eventType;
@property (nonatomic,strong) NSString *inningNumber;
@property (nonatomic,strong) NSString *eventDescription;
@property (nonatomic,strong) NSString *outs;
@property (nonatomic,strong) NSString *homeTeamRuns;
@property (nonatomic,strong) NSString *awayTeamRuns;

@end
