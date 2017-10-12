//
//  GameTabBarViewController.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SingleGameDataController.h"

@interface GameTabBarViewController : UITabBarController

@property (nonatomic,strong) SingleGameDataController *singleGameDataController;

-(IBAction)reload:(id)sender;
-(void)setupWithGameday:(NSString*)gameday;
@end
