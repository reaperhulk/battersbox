//
//  HomeRunView.h
//  Batter's Box
//
//  Created by Paul Kehrer on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PitchParser.h"

@interface HomeRunView : UIView <HomeRunDelegate>

@property NSInteger homeRunForAtBat;
@property NSTimer *homeRunTimer;

-(IBAction) triggerFireworks;
-(void) resetFireworks;

@end
