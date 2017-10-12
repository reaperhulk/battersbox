//
//  BattingStatsViewController.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"
#import "SingleGameDataController.h"

@interface BattingStatsViewController : UITableViewController <SingleGameBoxScoreDelegate>

@property (nonatomic,strong) NSDictionary *batters;
@property (nonatomic,strong) IBOutlet UISegmentedControl  *segmentedControl;

-(IBAction)segmentedControlIndexChanged:(id)sender;
-(void) buildTable;

@end
