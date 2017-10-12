//
//  PitchingStatsViewController.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"
#import "SingleGameDataController.h"

@interface PitchingStatsViewController : UITableViewController <SingleGameBoxScoreDelegate>

@property (nonatomic,strong) NSDictionary *pitchers;
@property (nonatomic,strong) IBOutlet UISegmentedControl *segmentedControl;

-(IBAction)segmentedControlIndexChanged:(id)sender;
-(void) buildTable;

@end
