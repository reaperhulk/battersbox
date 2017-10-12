//
//  ArcView.h
//  Batter's Box
//
//  Created by Paul Kehrer on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ArcView : UIView

@property (nonatomic,strong) CAShapeLayer *arc;

-(void) animate;

@end
