//
//  Batter.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Batter : NSObject

@property (nonatomic,strong) NSString *batterId;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *fullName;
@property (nonatomic,strong) NSString *position;
@property (nonatomic,strong) NSString *atBats;
@property (nonatomic,strong) NSString *runs;
@property (nonatomic,strong) NSString *baseOnBalls;
@property (nonatomic,strong) NSString *hits;
@property (nonatomic,strong) NSString *homeRuns;
@property (nonatomic,strong) NSString *runsBattedIn;
@property (nonatomic,strong) NSString *stolenBases;
@property (nonatomic,strong) NSString *leftOnBase;
@property (nonatomic,strong) NSString *strikeOuts;
@property (nonatomic,strong) NSString *average;
@property (nonatomic,strong) NSString *ops;


@end
