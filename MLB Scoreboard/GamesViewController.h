//
//  GamesViewController.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapDismissActionSheet.h"
#import "Game.h"
#import "GameDetailsViewController.h"
#import "IASKAppSettingsViewController.h"
#import "GamesDataController.h"

@interface GamesViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,IASKSettingsDelegate,GamesDataDelegate> {
    IASKAppSettingsViewController *appSettingsViewController;
}

@property (strong) UIView *spinnerView;
@property (strong) UILabel *navigationTitle;
@property (strong) TapDismissActionSheet *datePickerSheet;
@property (strong) UIDatePicker *datePicker;
@property (strong) IBOutlet UITableView *tableView;
@property (strong) UITableViewController *tableController;
@property (strong) GamesDataController *gamesController;
@property (strong) UIPopoverController *popoverController;
@property (strong) UIPopoverController *storeStandingsPopover;

-(void)reloadGames:(id)sender;
-(IBAction)showSettings:(id)sender;
-(IBAction)showStandings:(id)sender; //iPad only
-(void) showSpinnerView;
-(NSIndexPath*) getIndexForGameday:(NSString*)gameday;

@end
