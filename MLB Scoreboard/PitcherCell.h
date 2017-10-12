//
//  PitcherCell.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PitcherCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UILabel *name;
@property (nonatomic,strong) IBOutlet UILabel *inningsPitched;
@property (nonatomic,strong) IBOutlet UILabel *runsAllowed;
@property (nonatomic,strong) IBOutlet UILabel *earnedRuns;
@property (nonatomic,strong) IBOutlet UILabel *hitsAllowed;
@property (nonatomic,strong) IBOutlet UILabel *baseOnBalls;
@property (nonatomic,strong) IBOutlet UILabel *strikeOuts;
@property (nonatomic,strong) IBOutlet UILabel *homeRunsAllowed;
@property (nonatomic,strong) IBOutlet UILabel *earnedRunAverage;


@end
