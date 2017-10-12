//
//  PitchMarker.m
//  Batter's Box
//
//  Created by Paul Kehrer on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PitchMarker.h"
#import <QuartzCore/QuartzCore.h>

@implementation PitchMarker

@synthesize pitchNumLabel,pitchData;

-(id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        [self addShadow];
        self.pitchNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        double fontSize = 14.0f;
        if (IS_IPAD()) {
            fontSize = 17.0f;
        }
        self.pitchNumLabel.font = [UIFont boldSystemFontOfSize:fontSize];
        self.pitchNumLabel.textColor = [UIColor whiteColor];
        self.pitchNumLabel.backgroundColor = [UIColor clearColor];
        self.pitchNumLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:self.pitchNumLabel];
    }
    return self;
}

+(PitchMarker*) markerFromPitch:(Pitch*)pitch withFrame:(CGRect)frame number:(NSInteger)number {
    if (![pitch isPopulated]) {
        [pitch fudgeData];
    }
    double widthMiddle = frame.origin.x + (frame.size.width/2.0);
    double heightPixelsPerFoot = frame.size.height/(pitch.szTop - pitch.szBot);
    double widthPixelsPerFoot = frame.size.width/1.42f;
    // minus 15 because the object is 30x30 and we want the position to be dead center, not upper left
    // minus 10 if its iphone since we scale object to 20x20
    int markerSize = 20;
    int markerOffset = 10;
    if (IS_IPAD()) {
        markerSize = 30;
        markerOffset = 15;
    }
    CGFloat xPos = round(pitch.px * widthPixelsPerFoot + widthMiddle - markerOffset);
    double yFromTop = pitch.szTop - pitch.pz;
    CGFloat yPos = round(frame.origin.y + yFromTop * heightPixelsPerFoot - markerOffset);
    DebugLog(@"adding pitch at x:%f y:%f",xPos,yPos);
    PitchMarker *marker = [[PitchMarker alloc] initWithFrame:CGRectMake(xPos, yPos, markerSize, markerSize)];
    marker.pitchData = pitch;

    [marker setPitchType:pitch.pitchType ballOrStrike:[pitch ballOrStrike] number:number];
    return marker;
}

-(void) addShadow {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowOpacity = 1;
    self.layer.shadowRadius = 1.0;
    self.clipsToBounds = NO;
}

/*
 this list is also used in Pitch.m to set friendly pitch names.
 FA    Fastball
 FF    Four-seam fastball
 FT    Two-seam fastball
 SI    Sinker
 CH    Change-up
 SL    Slider
 CU    Curveball
 FC    Cut fastball
 FS    Split-finger fastball
 KN    Knuckleball
 PO    Pitch Out
 KC    Knuckle Curve
 EP    Eephus *no color
 FO    Forkball *no color
 SC    Screwball *no color
*/

-(void) setPitchType:(NSString*)pitchType ballOrStrike:(NSString*)ballOrStrike number:(NSInteger)number {
    self.pitchNumLabel.text = [NSString stringWithFormat:@"%d",number];
    if ([pitchType isEqualToString:@"FA"]) {
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"pitch-marker-%@-red.png",ballOrStrike]];
    } else if ([pitchType isEqualToString:@"FF"]) {
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"pitch-marker-%@-red-faded.png",ballOrStrike]];
    } else if ([pitchType isEqualToString:@"FT"]) {
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"pitch-marker-%@-darkred.png",ballOrStrike]];
    } else if ([pitchType isEqualToString:@"SI"]) {
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"pitch-marker-%@-orange.png",ballOrStrike]];
    } else if ([pitchType isEqualToString:@"CH"]) {
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"pitch-marker-%@-darkblue.png",ballOrStrike]];
    } else if ([pitchType isEqualToString:@"SL"]) {
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"pitch-marker-%@-bluegreen.png",ballOrStrike]];
    } else if ([pitchType isEqualToString:@"CU"]) {
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"pitch-marker-%@-blue.png",ballOrStrike]];
    } else if ([pitchType isEqualToString:@"FC"]) {
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"pitch-marker-%@-fuschia.png",ballOrStrike]];
    } else if ([pitchType isEqualToString:@"FS"]) {
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"pitch-marker-%@-purple.png",ballOrStrike]];
    } else if ([pitchType isEqualToString:@"KN"]) {
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"pitch-marker-%@-green.png",ballOrStrike]];
    } else if ([pitchType isEqualToString:@"KC"]) {
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"pitch-marker-%@-darkgreen.png",ballOrStrike]];
    } else if ([pitchType isEqualToString:@"PO"]) {
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"pitch-marker-%@-grey.png",ballOrStrike]];
    } else {
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"pitch-marker-%@-grey.png",ballOrStrike]];
        DebugLog(@"unknown pitch type %@",pitchType);
    }
}

@end
