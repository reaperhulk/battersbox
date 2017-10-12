//
//  PostGameCell.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"

@interface PostGameCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *awayTeamLabel;
@property (nonatomic, strong) IBOutlet UILabel *homeTeamLabel;
@property (nonatomic, strong) IBOutlet UILabel *awayRecord;
@property (nonatomic, strong) IBOutlet UILabel *homeRecord;
@property (nonatomic, strong) IBOutlet UILabel *awayTeamRuns;
@property (nonatomic, strong) IBOutlet UILabel *homeTeamRuns;
@property (nonatomic, strong) IBOutlet UILabel *firstPlayer;
@property (nonatomic, strong) IBOutlet UILabel *secondPlayer;
@property (nonatomic, strong) IBOutlet UILabel *firstLabel;
@property (nonatomic, strong) IBOutlet UILabel *secondLabel;

@property (nonatomic, strong) IBOutlet UILabel *statusOrTime;

@property (nonatomic, strong) IBOutlet UIView *boxScoreView;

@property (nonatomic, strong) IBOutlet UILabel *boxAwayRunsScored;
@property (nonatomic, strong) IBOutlet UILabel *boxHomeRunsScored;
@property (nonatomic, strong) IBOutlet UILabel *boxAwayHits;
@property (nonatomic, strong) IBOutlet UILabel *boxHomeHits;
@property (nonatomic, strong) IBOutlet UILabel *boxAwayErrors;
@property (nonatomic, strong) IBOutlet UILabel *boxHomeErrors;

@property (nonatomic,strong) Game* game;


-(void) configureCellWithGame:(Game*)game date:(NSDate*)date;

@end
