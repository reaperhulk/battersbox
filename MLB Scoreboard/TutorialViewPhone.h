//
//  TutorialViewPhone.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialViewPhone : UIView <UIGestureRecognizerDelegate>

@property (strong) NSArray *tutorialViews;
@property NSInteger currentStep;

+(void) runTutorial;

@end
