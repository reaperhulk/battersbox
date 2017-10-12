//
//  BoxScoreColumn.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoxScoreColumn : UIView

@property (nonatomic,strong) UILabel *away;
@property (nonatomic,strong) UILabel *home;
@property (nonatomic,strong) UILabel *inningNumber;

-(void) emptyLabels;
-(void) homeActive;
-(void) awayActive;
-(void) noActive;

@end
