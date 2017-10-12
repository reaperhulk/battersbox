//
//  DetailViewController.h
//  Batter's Box
//
//  Created by Paul Kehrer on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GamesDataController.h"
#import "SingleGameDataController.h"
#import "GenericDetailViewController.h"
#import "ArcView.h"

@interface DetailViewController : GenericDetailViewController <GamesDataDelegate,SingleGameBoxScoreDelegate>

@property (nonatomic,strong) SingleGameDataController *singleGameDataController;
@property (nonatomic,strong) UIPopoverController *playerPopoverController;
@property (nonatomic,strong) IBOutlet UIView *primaryView;
@property (nonatomic,strong) IBOutlet UIButton *showHideAtBats;

-(IBAction) pitchingStatsPopover;
-(IBAction) battingStatsPopover;
-(IBAction) playByPlayPopover;
-(IBAction) highlightsPopover;

-(void) setupWithGameday:(NSString *)gameday;
-(void) noGameSelected;

@end
