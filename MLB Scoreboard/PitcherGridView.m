//
//  PitcherGridView.m
//  Batter's Box
//
//  Created by Paul Kehrer on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PitcherGridView.h"
#import "PitchMarker.h"
#import <QuartzCore/QuartzCore.h>

#define kPitchDataViewTag -1
#define kAtBatResultTag -2

@implementation PitcherGridView

@synthesize gridImage,batterToken;
@synthesize pitchesAdded,atBatNum,pastAtBat;
@synthesize closeTimer;

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPitchDataView)];
        [self addGestureRecognizer:gesture];
        self.pitchesAdded = [NSMutableArray array];
    }
    return self;
}

-(PitchMarker*) addPitch:(Pitch*)pitch animated:(BOOL)animated {
    CGRect newFrame = self.gridImage.frame;
    PitchMarker *pitchMarker = [PitchMarker markerFromPitch:pitch withFrame:newFrame number:self.pitchesAdded.count+1];
    UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedPitch:)];
    [pitchMarker addGestureRecognizer:recog];
    if (pitchMarker != nil) {
        [self.pitchesAdded addObject:pitchMarker];
        [self addSubview:pitchMarker];
        if (animated) {
            pitchMarker.alpha = 0.0f;
            [UIView animateWithDuration:0.4f animations:^{
                pitchMarker.alpha = 1.0f;
            }];
        }
        //if the view is present, bring it to the front so pitch badges don't go on top
        [self bringSubviewToFront:[self viewWithTag:kPitchDataViewTag]];
    } else {
        //add this to keep the count accurate if bad pitch data is coming through
        //for instance, if szTop, szBot, pz, px, type are missing, then the pitch will not be added
        //however, the next time we add pitches the count added and count received will mismatch
        //since we use this array to remove from superview we can't just add junk here though
        //so we make an empty pitchmarker and add it to the array
        PitchMarker *empty = [[PitchMarker alloc] init];
        [self.pitchesAdded addObject:empty];
    }
    return pitchMarker;
}

-(void) resetPitchesAndRemoveDataView {
    self.pastAtBat = NO;
    self.atBatNum = 0;
    [[self viewWithTag:kPitchDataViewTag] removeFromSuperview];
    [self resetPitches];
}

-(void) resetPitches {
    for (PitchMarker *marker in self.pitchesAdded) {
        [UIView animateWithDuration:0.3f animations:^{
            marker.alpha = 0.0;
        } completion:^(BOOL finished) {
            [marker removeFromSuperview];
        }];
    }
    [self.pitchesAdded removeAllObjects];
}

-(void) addNewPitches:(NSArray*)newPitches atBatComplete:(BOOL)complete {
    PitchMarker *aPitchMarker;
    for (int i = self.pitchesAdded.count; i < newPitches.count; i++) {
        aPitchMarker = [self addPitch:[newPitches objectAtIndex:i] animated:YES];
    }
    if (aPitchMarker != nil) {
        [self dismissPitchDataView];
        [self showPitchDataView:aPitchMarker];
        if (!complete) {
        self.closeTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(dismissPitchDataView) userInfo:nil repeats:NO];
        }
    }
}

-(void) placeBatterToken:(NSString*)stand {
    if (IS_IPAD()) {
        if ([stand isEqualToString:@"R"]) {
            if (self.batterToken.frame.origin.x != 72.0) {
                [UIView animateWithDuration:0.2f animations:^{
                    self.batterToken.alpha = 0.0;
                } completion:^(BOOL finished) {
                    self.batterToken.image = [UIImage imageNamed:@"batter-right.png"];
                    self.batterToken.frame = CGRectMake(72, 63, 140, 291);
                    [UIView animateWithDuration:0.2f animations:^{
                        self.batterToken.alpha = 1.0;
                    }];
                }];
            }
        } else {
            if (self.batterToken.frame.origin.x != 325.0) {
                [UIView animateWithDuration:0.2f animations:^{
                    self.batterToken.alpha = 0.0;
                } completion:^(BOOL finished) {
                    self.batterToken.image = [UIImage imageNamed:@"batter-left.png"];
                    self.batterToken.frame = CGRectMake(325, 63, 140, 291);        
                    [UIView animateWithDuration:0.2f animations:^{
                        self.batterToken.alpha = 1.0;
                    }];
                }];
            }
        }
    } else {
        if ([stand isEqualToString:@"R"]) {
            if (self.batterToken.frame.origin.x != 58.0) {
                [UIView animateWithDuration:0.2f animations:^{
                    self.batterToken.alpha = 0.0;
                } completion:^(BOOL finished) {
                    self.batterToken.image = [UIImage imageNamed:@"batter-right.png"];
                    self.batterToken.frame = CGRectMake(58, 35, 70, 145);
                    [UIView animateWithDuration:0.2f animations:^{
                        self.batterToken.alpha = 1.0;
                    }];
                }];
            }
        } else {
            if (self.batterToken.frame.origin.x != 187.0) {
                [UIView animateWithDuration:0.2f animations:^{
                    self.batterToken.alpha = 0.0;
                } completion:^(BOOL finished) {
                    self.batterToken.image = [UIImage imageNamed:@"batter-left.png"];
                    self.batterToken.frame = CGRectMake(187, 35, 70, 145);        
                    [UIView animateWithDuration:0.2f animations:^{
                        self.batterToken.alpha = 1.0;
                    }];
                }];
            }
        }
    }
}

-(void) showPitchDataView:(PitchMarker*) marker {
    UIView *pitchView = [[NSBundle.mainBundle loadNibNamed:@"PitchDataView" owner:self options:nil] objectAtIndex:0];
    pitchView.tag = kPitchDataViewTag;
    int pitchViewOriginalWidth = pitchView.frame.size.width;
    int pitchViewOriginalHeight = pitchView.frame.size.height;
    pitchView.transform = CGAffineTransformMakeScale(0.1,0.1);
    pitchView.layer.cornerRadius = 7.0f;
    pitchView.layer.masksToBounds = YES;
    UILabel *pitchType = (UILabel*)[pitchView viewWithTag:1];
    UILabel *speed = (UILabel*)[pitchView viewWithTag:2];
    UILabel *des = (UILabel*)[pitchView viewWithTag:3];
    UILabel *count = (UILabel*)[pitchView viewWithTag:4];
    pitchType.text = marker.pitchData.pitchTypeFriendly;
    speed.text = [NSString stringWithFormat:@"%.0f",round(marker.pitchData.startSpeed)];
    des.text = marker.pitchData.des;
    count.text = marker.pitchData.pitchCount;
    CGRect newFrame = pitchView.frame;
    int xOffset;
    int yOffset;
    if (IS_IPAD()) {
        xOffset = 15;
        yOffset = 15;
    } else {
        xOffset = 10;
        yOffset = 10;
        //this will compensate if the pitch view would be cut off by the right edge of the screen 
        DebugLog(@"%f",marker.frame.origin.x);
        DebugLog(@"%f",pitchView.frame.size.width);
        int additionalOffset = 320 - (marker.frame.origin.x  + pitchViewOriginalWidth/2 + xOffset );
        if (additionalOffset < 0) {
            xOffset += additionalOffset;
        }
        if (marker.frame.origin.x  - pitchViewOriginalWidth/2 + xOffset < 0) {
            xOffset += -1 * (marker.frame.origin.x  - pitchViewOriginalWidth/2 + xOffset);
        }
        //this moves the pitch popup for low pitches (which are not a problem on iPad)
        if (!IS_IPAD()) {
            int additionalYOffset = 184 - (marker.frame.origin.y + pitchViewOriginalHeight/2 + yOffset);
            if (additionalYOffset < 0) {
                yOffset += additionalYOffset;
            }
        }        
    }
    newFrame.origin.x = marker.frame.origin.x - newFrame.size.width/2 + xOffset;
    newFrame.origin.y = marker.frame.origin.y - newFrame.size.height/2 + yOffset;
    pitchView.frame = newFrame;
    pitchView.alpha = 0.0f;
    [self addSubview:pitchView];
    [UIView animateWithDuration:0.3f animations:^{
        pitchView.transform = CGAffineTransformMakeScale(1.0,1.0);
        pitchView.alpha = 1.0f;
    }];
}


-(void) tappedPitch:(id)sender {
//    [TestFlight passCheckpoint:@"Tapped a pitch to view detail"];
    //[FlurryAnalytics logEvent:@"Tapped pitch"];
//    [AdDashDelegate reportCustomEvent:@"Tapped pitch" withDetail:@""];
    [self dismissPitchDataView];
    PitchMarker *marker = (PitchMarker*)((UIGestureRecognizer*)sender).view;
    [self showPitchDataView:marker];
}

-(void) dismissPitchDataView {
    if (self.closeTimer) {
        [self.closeTimer invalidate];
        self.closeTimer = nil;
    }
    UIView *oldView = [self viewWithTag:kPitchDataViewTag];
    if (oldView) {
        [UIView animateWithDuration:0.3f animations:^{
            oldView.alpha = 0.0f;
            oldView.transform = CGAffineTransformMakeScale(0.1,0.1);
        } completion:^(BOOL finished) {
            [oldView removeFromSuperview];
        }];
    }
}


-(void) pitchesLoaded:(NSArray *)pitches atBatNum:(NSInteger)pAtBatNum stand:stand complete:(BOOL)complete pastAtBat:(BOOL)pPastAtBat {
    if (pPastAtBat == NO && self.pastAtBat == YES) {
        return;
    }
    self.pastAtBat = pPastAtBat;
    
    if (self.atBatNum != pAtBatNum) {
        [self resetPitchesAndRemoveDataView];
        self.atBatNum = pAtBatNum;
    }
    [self addNewPitches:pitches atBatComplete:complete];
    [self placeBatterToken:stand];
}

-(void) pitchLoadFailed {
    
}

-(void) pitchParseComplete {
    
}

@end
