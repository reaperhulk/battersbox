//
//  PreGameCell.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenOnBase.h"
#import "Game.h"

@interface PreGameCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *awayTeamLabel;
@property (nonatomic, strong) IBOutlet UILabel *homeTeamLabel;
@property (nonatomic, strong) IBOutlet UILabel *awayRecord;
@property (nonatomic, strong) IBOutlet UILabel *homeRecord;
@property (nonatomic, strong) IBOutlet UILabel *firstPlayer;
@property (nonatomic, strong) IBOutlet UILabel *secondPlayer;
@property (nonatomic, strong) IBOutlet UILabel *firstLabel;
@property (nonatomic, strong) IBOutlet UILabel *secondLabel;

@property (nonatomic, strong) IBOutlet UILabel *statusOrTime;

@property (nonatomic,strong) IBOutlet UIView *pregameView;
@property (nonatomic,strong) IBOutlet UIButton *previewLink;
@property (nonatomic,strong) IBOutlet UILabel *awayTv;
@property (nonatomic,strong) IBOutlet UILabel *homeTv;
@property (nonatomic,strong) IBOutlet UILabel *awayRadio;
@property (nonatomic,strong) IBOutlet UILabel *homeRadio;

@property (nonatomic,strong) Game* game;


-(void) configureCellWithGame:(Game*)game date:(NSDate*)date;

@end
