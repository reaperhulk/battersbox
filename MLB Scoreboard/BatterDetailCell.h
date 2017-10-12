//
//  BatterDetailCell.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BatterDetailCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UILabel *name;
@property (nonatomic,strong) IBOutlet UILabel *atBats;
@property (nonatomic,strong) IBOutlet UILabel *average;
@property (nonatomic,strong) IBOutlet UILabel *homeRuns;
@property (nonatomic,strong) IBOutlet UILabel *runsBattedIn;
@property (nonatomic,strong) IBOutlet UILabel *ops;

@end
