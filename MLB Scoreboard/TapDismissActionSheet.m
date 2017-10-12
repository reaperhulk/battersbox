//
//  TapDismissActionSheet.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TapDismissActionSheet.h"

@implementation TapDismissActionSheet

-(void)addTapDetector {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOut:)];
    tap.cancelsTouchesInView = NO; // So that legit taps on the table bubble up to the tableview
    [self.superview addGestureRecognizer:tap];
}

-(void)tapOut:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint p = [gestureRecognizer locationInView:self];
    if (p.y < 0) { // They tapped outside
        [self dismissWithClickedButtonIndex:0 animated:YES];
    }
}


@end
