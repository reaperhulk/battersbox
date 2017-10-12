//
//  GameTabBarViewController.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameTabBarViewController.h"
#import "AppDelegate.h"
#import "GameDetailsViewController.h"
#import "BattingStatsViewController.h"
#import "PitchingStatsViewController.h"
#import "PlayByPlayViewController.h"
#import "GamesDataController.h"

@interface GameTabBarViewController ()

@end

@implementation GameTabBarViewController

@synthesize singleGameDataController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([[self.navigationController viewControllers] indexOfObject:self] == NSNotFound) {
        DebugLog(@"tab bar was popped off the stack so we're back at the main view. cancel all outstanding single game async requests");
        [self.singleGameDataController stop];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];

}

-(void) dealloc {
    [self.singleGameDataController stop];
}

-(void) setupWithGameday:(NSString *)gameday {
    self.singleGameDataController = [[SingleGameDataController alloc] initWithGameday:gameday];
    //add delegates
    GameDetailsViewController *gameDetailsController = [[self viewControllers] objectAtIndex:0];
    self.singleGameDataController.detailsBoxDelegate = gameDetailsController;
    BattingStatsViewController *battingStatsController = [[self viewControllers] objectAtIndex:2];
    self.singleGameDataController.batterBoxDelegate = battingStatsController;
    PitchingStatsViewController *pitchingStatsController = [[self viewControllers] objectAtIndex:3];
    self.singleGameDataController.pitcherBoxDelegate = pitchingStatsController;
    PlayByPlayViewController *playByPlayController = [[self viewControllers] objectAtIndex:1];
    self.singleGameDataController.eventDelegate = playByPlayController;
    self.singleGameDataController.pitchDelegate = gameDetailsController.pitcherGridView;
    self.singleGameDataController.atBatAndScoreDelegate = gameDetailsController;
    [self.singleGameDataController start];
    //add gameDetails to the delegate list for the main scoreboard
    [GamesDataController sharedSingleton].detailsDelegate = gameDetailsController;
    //reset update schedule to match with new data
    [[GamesDataController sharedSingleton] scheduleUpdate];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)reload:(id)sender {
    [self.singleGameDataController start];
    [[GamesDataController sharedSingleton] scheduleUpdate];
    [[GamesDataController sharedSingleton] reloadData];
}
@end
