//
//  ArcView.m
//  Batter's Box
//
//  Created by Paul Kehrer on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ArcView.h"

@implementation ArcView

@synthesize arc;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void) drawRect:(CGRect) rect {
}

-(void) animate {
    if (self.arc) {
        [self.arc removeFromSuperlayer];
        self.arc = nil;
    }
    self.arc = [CAShapeLayer layer];
    self.arc.strokeColor = [UIColor redColor].CGColor;
    self.arc.lineWidth = 5.0f;
    self.arc.fillColor = [UIColor clearColor].CGColor;
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 2.0f;
    path.lineCapStyle = kCGLineCapButt;
    [path moveToPoint:CGPointMake(330, 210)];
    [path addQuadCurveToPoint:CGPointMake(500, 155) controlPoint:CGPointMake(500, -50)];
    self.arc.path = path.CGPath;
    [self.layer addSublayer:self.arc];
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.duration            = 2.0;
    drawAnimation.repeatCount         = 1.0;
    drawAnimation.removedOnCompletion = NO;
    
    // Animate from no part of the stroke being drawn to the entire stroke being drawn
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [self.arc addAnimation:drawAnimation forKey:@"strokeEndAnimation"];
}
@end
