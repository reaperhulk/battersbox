//
//  Pitch.m
//  Batter's Box
//
//  Created by Paul Kehrer on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Pitch.h"

@implementation Pitch

@synthesize des,pitchId,type,tfs,tfsZulu,svId,startSpeed,endSpeed;
@synthesize szTop,szBot,pfxX,pfxZ,px,pz,x0,y0,z0,vx0,vy0,vz0,x,y;
@synthesize ax0,ay0,az0,breakY,breakAngle,breakLength,pitchType;
@synthesize typeConfidence,zone,nasty,spinDir,spinRate,pitchCount;

-(BOOL) isPopulated {
    if (!szTop || !szBot || !pz || !px || !pitchType) {
        DebugLog(@"pitch is missing data");
        return false;
    } else {
        return true;
    }
}

-(void) fudgeData {
    //occasionally szTop or szBot are missing for a pitch or two. in this case we'll add
    //a fudged rough strike zone so we can still paint the pitch in
    if (!szTop) {
        szTop = 3.3;
    }
    if (!szBot) {
        szBot = 1.6;
    }
    if (!px || !pz) {
        //these numbers are derived from comparing x and y on pitches that have px and pz. rough approximation
        self.px = (98 - self.x) * 0.03;
        self.pz = (210 - self.y) * 0.038;
    }
    if (!pitchType) {
        self.pitchType = @"Data Missing";
    }
}

-(NSString*)ballOrStrike {
    if ([self.type isEqualToString:@"B"]) {
        return @"ball";
    } else {
        return @"strike";
    }
}

-(NSString*) pitchTypeFriendly {
    if ([self.pitchType isEqualToString:@"FA"]) {
        return @"Fastball";
    } else if ([self.pitchType isEqualToString:@"FF"]) {
        return @"Four-seam";
    } else if ([self.pitchType isEqualToString:@"FT"]) {
        return @"Two-seam";
    } else if ([self.pitchType isEqualToString:@"SI"]) {
        return @"Sinker";
    } else if ([self.pitchType isEqualToString:@"CH"]) {
        return @"Change-up";
    } else if ([self.pitchType isEqualToString:@"SL"]) {
        return @"Slider";
    } else if ([self.pitchType isEqualToString:@"CU"]) {
        return @"Curveball";
    } else if ([self.pitchType isEqualToString:@"FC"]) {
        return @"Cutter";
    } else if ([self.pitchType isEqualToString:@"FS"]) {
        return @"Split-finger";
    } else if ([self.pitchType isEqualToString:@"KN"]) {
        return @"Knuckleball";
    } else if ([self.pitchType isEqualToString:@"PO"]) {
        return @"Pitch Out";
    } else if ([self.pitchType isEqualToString:@"KC"]) {
        return @"Knuckle Curve";
    } else if ([self.pitchType isEqualToString:@"EP"]) {
        return @"Eephus";
    } else if ([self.pitchType isEqualToString:@"FO"]) {
        return @"Forkball";
    } else if ([self.pitchType isEqualToString:@"SC"]) {
        return @"Screwball";
    } else {
        DebugLog(@"unknown pitch type %@",self.pitchType);
        return self.pitchType;
    }
}

@end
