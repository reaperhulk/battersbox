//
//  PitcherDetailCell.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PitcherDetailCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UILabel *name;
@property (nonatomic,strong) IBOutlet UILabel *strikeOuts;
@property (nonatomic,strong) IBOutlet UILabel *baseOnBalls;
@property (nonatomic,strong) IBOutlet UILabel *homeRuns;
@property (nonatomic,strong) IBOutlet UILabel *average;
@property (nonatomic,strong) IBOutlet UILabel *atBats;

@end
