//
//  InningView.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InningView : UIView

@property (nonatomic,strong) UILabel *inningLabel;
@property (nonatomic,strong) UILabel *away;
@property (nonatomic,strong) UILabel *home;
@property BOOL isNight;

-(void) homeActive;
-(void) awayActive;
-(void) noActive;
-(void) emptyLabels;
-(void) resetColors;
@end
