//
//  GameDetailsViewController.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SingleGameDataController.h"
#import "GamesDataController.h"
#import "GenericDetailViewController.h"

@interface GameDetailsViewController : GenericDetailViewController <SingleGameBoxScoreDelegate,GamesDataDelegate>

@property (nonatomic,strong) IBOutlet UIButton *togglePitchAndWebViewButton;

@end
