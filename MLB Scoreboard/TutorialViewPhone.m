//
//  TutorialViewPhone.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TutorialViewPhone.h"
#import "AppDelegate.h"

@implementation TutorialViewPhone

@synthesize tutorialViews;
@synthesize currentStep;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.currentStep = 0;
        self.tutorialViews = [NSBundle.mainBundle loadNibNamed:@"TutorialViewPhone" owner:self options:nil];
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(void) showWelcome {
    UIView *tutorialView = [tutorialViews objectAtIndex:0];
    tutorialView.alpha = 0.0f;

    [self addSubview:tutorialView];
    [UIView animateWithDuration:0.7f delay:0.8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        tutorialView.alpha = 1.0f;
    } completion:^(BOOL finished) {
    }];
}

-(void) nextStep {
    self.currentStep++;
    if ([self.tutorialViews count] <= self.currentStep) {
        [self endTutorial];
        return;
    }
    UIView *tutorialView = [tutorialViews objectAtIndex:self.currentStep];
    tutorialView.alpha = 0.0f;
    UIImageView *arrow = nil;
    if (self.currentStep == 6 && IS_IPAD()) {
        UILabel *labelText = (UILabel*)[tutorialView viewWithTag:10];
        labelText.text = @"Tap a row to reveal the game detail on the right. You can also tap the icons at the bottom for play by play, stats, and video highlights!";
    }
    if (self.currentStep == 2 || self.currentStep == 3) {
        arrow = (UIImageView*)[tutorialView viewWithTag:1];
        if (self.currentStep == 2) {
            arrow.frame = CGRectMake(320, arrow.frame.origin.y, arrow.frame.size.width, arrow.frame.size.height);
        } else {
            arrow.frame = CGRectMake(-320, arrow.frame.origin.y, arrow.frame.size.width, arrow.frame.size.height);
        }

        [UIView animateWithDuration:1.5f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            if (self.currentStep == 2) {
                arrow.frame = CGRectMake(-320, arrow.frame.origin.y, arrow.frame.size.width, arrow.frame.size.height);
                arrow.alpha = 0.0f;
            } else if (self.currentStep == 3) {
                arrow.frame = CGRectMake(320, arrow.frame.origin.y, arrow.frame.size.width, arrow.frame.size.height);
                arrow.alpha = 0.0f;
            }
        } completion:^(BOOL finished) {
        }];
    }
    
    [self addSubview:tutorialView];
    [UIView animateWithDuration:0.4f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        tutorialView.alpha = 1.0f;
        if (self.currentStep == 2) {
            arrow.frame = CGRectMake(-320, arrow.frame.origin.y, arrow.frame.size.width, arrow.frame.size.height);
        } else if (self.currentStep == 3) {
            arrow.frame = CGRectMake(320, arrow.frame.origin.y, arrow.frame.size.width, arrow.frame.size.height);
        }
    } completion:^(BOOL finished) {
    }];
}

+(void) runTutorial {
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    CGRect frame;
    if (IS_IPAD()) {
        frame = CGRectMake(0, 0, 1024, 768);
    } else {
        frame = CGRectMake(0, 0, 320, 480);
    }
    TutorialViewPhone *tutorial = [[TutorialViewPhone alloc] initWithFrame:frame];
    UITapGestureRecognizer *tapStop = [[UITapGestureRecognizer alloc] initWithTarget:tutorial action:@selector(goToNext)];
    [tutorial addGestureRecognizer:tapStop];

    [delegate.window.rootViewController.view addSubview:tutorial];
    [tutorial showWelcome];
    
}

-(void) endTutorial {
    [UIView animateWithDuration:0.5f animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void) goToNext {
    for (UIView *currentView in [self subviews]) {
        [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            currentView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [currentView removeFromSuperview];
        }];
    }
    [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(nextStep) userInfo:nil repeats:NO];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    DebugLog(@"touched");
    return YES;
}
@end
