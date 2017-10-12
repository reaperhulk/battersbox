//
//  BatterCell.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BatterCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UILabel *batterName;
@property (nonatomic,strong) IBOutlet UILabel *atBats;
@property (nonatomic,strong) IBOutlet UILabel *hits;
@property (nonatomic,strong) IBOutlet UILabel *homeRuns;
@property (nonatomic,strong) IBOutlet UILabel *runs;
@property (nonatomic,strong) IBOutlet UILabel *runsBattedIn;
@property (nonatomic,strong) IBOutlet UILabel *baseOnBalls;
@property (nonatomic,strong) IBOutlet UILabel *strikeOuts;
@property (nonatomic,strong) IBOutlet UILabel *leftOnBase;
@property (nonatomic,strong) IBOutlet UILabel *stolenBases;


@end
