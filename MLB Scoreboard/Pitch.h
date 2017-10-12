//
//  Pitch.h
//  Batter's Box
//
//  Created by Paul Kehrer on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Pitch : NSObject

@property (nonatomic, strong) NSString *des;
@property NSUInteger pitchId;
@property (nonatomic, strong) NSString *type; //ball, strike
@property NSUInteger tfs;
@property (nonatomic, strong) NSString *tfsZulu;
@property (nonatomic, strong) NSString *svId;
@property double startSpeed;
@property double endSpeed;
@property double szTop;
@property double szBot;
@property double pfxX;
@property double pfxZ;
@property double px;
@property double pz;
@property double x0;
@property double y0;
@property double z0;
@property double vx0;
@property double vy0;
@property double vz0;
@property double ax0;
@property double ay0;
@property double az0;
@property double x;
@property double y;
@property double breakY;
@property double breakAngle;
@property double breakLength;
@property (nonatomic,strong) NSString *pitchType;
@property double typeConfidence;
@property NSInteger zone;
@property NSInteger nasty;
@property double spinDir;
@property double spinRate;
@property (nonatomic,strong) NSString *pitchCount;

-(BOOL) isPopulated;
-(void) fudgeData;
-(NSString*) ballOrStrike;
-(NSString*) pitchTypeFriendly;

@end

