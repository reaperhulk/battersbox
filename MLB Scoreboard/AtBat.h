//
//  AtBat.h
//  Batter's Box
//
//  Created by Paul Kehrer on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pitch.h"
#import "Batter.h"
#import "Pitcher.h"

@interface AtBat : NSObject

@property (nonatomic,strong) NSString *num;
@property (nonatomic,strong) NSString *batterId;
@property (nonatomic,strong) NSString *batterStand;
@property (nonatomic,strong) NSString *pitcherId;
@property (nonatomic,strong) NSString *pitcherThrow;
@property (nonatomic,strong) NSString *des;
@property (nonatomic,strong) NSString *event;
@property (nonatomic,strong) NSString *outs;
@property (nonatomic,strong) Batter *batter;
@property (nonatomic,strong) Pitcher *pitcher;

@property (nonatomic,strong) NSMutableArray *pitches;

-(void) addPitch:(Pitch*)pitch;
@end
