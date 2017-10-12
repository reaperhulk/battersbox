//
//  TapDismissActionSheet.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TapDismissActionSheet : UIActionSheet <UIGestureRecognizerDelegate>

-(void)addTapDetector;
-(void)tapOut:(UIGestureRecognizer*)sender;

@end
