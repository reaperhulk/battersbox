//
//  GamesViewController.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GamesViewController.h"
#import "GameCell.h"
#import "PreGameCell.h"
#import "PostGameCell.h"
#import "GameTabBarViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDate+DateIsToday.h"
#import "DefaultViewController.h"
#import "DetailViewController.h"

#define kNoGames 25
#define kErrorMessage 26

@interface GamesViewController ()


@end

@implementation GamesViewController

@synthesize spinnerView;
@synthesize navigationTitle;
@synthesize datePickerSheet,popoverController;
@synthesize datePicker;
@synthesize tableView;
@synthesize gamesController;
@synthesize storeStandingsPopover;
@synthesize tableController;

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
    
    [self addSwipeRecognizers];

    [self buildTitleView];
    self.gamesController = [GamesDataController sharedSingleton];
    self.gamesController.gamesDelegate = self;
    [self showSpinnerView];
    [self.gamesController startup];
    [self setNavTitle];
    self.tableController = [[UITableViewController alloc] initWithStyle:self.tableView.style];
    self.tableController.tableView = self.tableView;
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(reloadGames:)
             forControlEvents:UIControlEventValueChanged];
    self.tableController.refreshControl = refreshControl;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void) setNavTitle {
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit  | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self.gamesController.scheduleDate];
    self.navigationTitle.text = [NSString stringWithFormat:@"%02d/%02d/%04d",[dateComponents month],[dateComponents day],[dateComponents year]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.games count];
}

- (UITableViewCell *)tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	Game *game = [self.games objectAtIndex:indexPath.row];
    UITableViewCell *cell;
    if (game.statusCode == 0) {
        cell = [pTableView dequeueReusableCellWithIdentifier:@"PreGameCell"];
        [(PreGameCell*)cell configureCellWithGame:game date:self.gamesController.scheduleDate];
    } else if (game.statusCode == 2 || game.statusCode == -1) {
        //yes use postgame cell for "unknown" status. This typically means delayed or postponed.
        cell = [pTableView dequeueReusableCellWithIdentifier:@"PostGameCell"];
        [(PostGameCell*)cell configureCellWithGame:game date:self.gamesController.scheduleDate];
    } else {
        cell = [pTableView dequeueReusableCellWithIdentifier:@"GameCell"];        
        [(GameCell*)cell configureCellWithGame:game date:self.gamesController.scheduleDate];
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Game *game = (Game*)[self.games objectAtIndex:indexPath.row];
    if (IS_IPAD()) {
//        [TestFlight passCheckpoint:@"Selected A Game (iPad)"];
//        [AdDashDelegate reportCustomEvent:@"Selected A Game (iPad)" withDetail:@""];
        //[FlurryAnalytics logEvent:@"Selected A Game (iPad)" withParameters:[NSDictionary dictionaryWithObject:game.gameday forKey:@"game"]];

        if (self.gamesController.selectedGameday != nil && [game.gameday isEqualToString:self.gamesController.selectedGameday]) {
            //already selected, do nothing
        } else {
            self.gamesController.selectedGameday = game.gameday;
            AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            DefaultViewController *defaultViewController = (DefaultViewController*)delegate.window.rootViewController;
            DetailViewController *detailController = (DetailViewController *)[defaultViewController.viewControllers lastObject];
            [detailController setupWithGameday:game.gameday];
        }
    } else {
//        [TestFlight passCheckpoint:@"Expanded A Game (iPhone)"];
//        [AdDashDelegate reportCustomEvent:@"Expanded A Game (iPhone)" withDetail:@""];
        //[FlurryAnalytics logEvent:@"Expanded A Game (iPhone)" withParameters:[NSDictionary dictionaryWithObject:game.gameday forKey:@"game"]];
        if (self.gamesController.selectedGameday != nil && [game.gameday isEqualToString:self.gamesController.selectedGameday]) {
            self.gamesController.selectedGameday = nil;
        } else {
            self.gamesController.selectedGameday = game.gameday;
        }
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IS_IPAD()) {
        return 60.0f;
    } else {
        Game *game = (Game*)[self.games objectAtIndex:indexPath.row];
        if (self.gamesController.selectedGameday != nil && [game.gameday isEqualToString:self.gamesController.selectedGameday]) {
            if (game.statusCode == 1) {
                //slightly larger to accommodate the play by play label
                return 130.0f;
            } else {
                return 120.0f;
            }
        } else {
            return 60.0f;
        }
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor whiteColor];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1.0];
    }
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"GameDetailsSegue"]) {
        NSIndexPath *selectedPath = (NSIndexPath*)sender;
        Game *game = [self.games objectAtIndex:selectedPath.row];
        
        GameTabBarViewController *tabController = segue.destinationViewController;
        [tabController setupWithGameday:game.gameday];
    } else if ([[segue identifier] isEqualToString:@"StandingsSegue"] && IS_IPAD()) {
        self.storeStandingsPopover = ((UIStoryboardPopoverSegue*)segue).popoverController;
    }
}

//only used on iPad
-(IBAction)showStandings:(id)sender {
    if (self.storeStandingsPopover != nil) {
        [self.storeStandingsPopover dismissPopoverAnimated:YES];
        self.storeStandingsPopover = nil;
    } else {
        [self performSegueWithIdentifier:@"StandingsSegue" sender:sender];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"GameDetailsSegue" sender:indexPath];
}

-(void) crazyEvilSlideAnimationForward:(BOOL)direction {
    int directionMult = -1;
    if (direction) {
        directionMult = 1;
    }
    if ([[UIScreen mainScreen] scale] == 2.0f) {
        //retina context
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 2.0f);
    } else {
        //non-retina context
        UIGraphicsBeginImageContext(self.view.bounds.size);
    }
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView *imageView = [[UIImageView alloc] initWithImage:viewImage];
    UIGraphicsEndImageContext();
    imageView.frame = CGRectMake(0,0,imageView.frame.size.width,imageView.frame.size.height);
    [self.view addSubview:imageView];
    self.tableView.frame = CGRectMake(320*directionMult,0,self.tableView.frame.size.width,self.tableView.frame.size.height);
    [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        imageView.frame = CGRectMake(-320*directionMult,0,imageView.frame.size.width,imageView.frame.size.height);
        self.tableView.frame = CGRectMake(0,0,self.tableView.frame.size.width,self.tableView.frame.size.height);
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
    }];
}


-(IBAction)goForward:(id)sender {
    
    [self crazyEvilSlideAnimationForward:YES];
    self.tableView.contentOffset = CGPointMake(0,0); //scroll to the top so when the new data loads it's at the top

//    [TestFlight passCheckpoint:@"Swiped Forward"];
    //[FlurryAnalytics logEvent:@"Swiped Forward"];
//    [AdDashDelegate reportCustomEvent:@"Swipe" withDetail:@"Forward"];
    [self showSpinnerView];
    [self.gamesController goForward];
}

-(IBAction)goBackward:(id)sender {
    [self crazyEvilSlideAnimationForward:NO];
    self.tableView.contentOffset = CGPointMake(0,0); //scroll to the top so when the new data loads it's at the top

//    [TestFlight passCheckpoint:@"Swiped Backward"];
    //[FlurryAnalytics logEvent:@"Swiped Backward"];
//    [AdDashDelegate reportCustomEvent:@"Swipe" withDetail:@"Backward"];
    [self showSpinnerView];
    [self.gamesController goBackward];
}

-(void) showSpinnerView {
    if (self.spinnerView != nil) {
        return;
    }
    self.tableView.contentOffset = CGPointMake(0,0); //scroll to the top so when the new data loads it's at the top
    self.tableView.scrollEnabled = NO;
    if (IS_IPAD()) {
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        DefaultViewController *defaultController = (DefaultViewController*)delegate.window.rootViewController;
        DetailViewController *detailController = (DetailViewController*)[defaultController.viewControllers lastObject];
        [detailController noGameSelected];
    }
    self.spinnerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.tableView.frame.size.height)];
    self.spinnerView.backgroundColor = [UIColor colorWithRed:78/255.0f green:78/255.0f blue:78/255.0f alpha:1.0f];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(self.spinnerView.frame.size.width/2, self.spinnerView.frame.size.height/2);
    [spinner startAnimating];
    [self.spinnerView addSubview:spinner];
    [self.tableView addSubview:self.spinnerView];
}

-(void) hideSpinnerView {
    self.tableView.scrollEnabled = YES;
    [UIView animateWithDuration:0.5f animations:^{
        self.spinnerView.alpha = 0.0f;
    } completion:^(BOOL completed){
        if(completed) {
            [self.spinnerView removeFromSuperview];
        }
    }];
    
    self.spinnerView = nil;
}

-(NSArray*) games {
    return self.gamesController.games;
}


-(void) buildTitleView {
    self.navigationItem.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 125, 30)];
    self.navigationTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 125, 30)];
    self.navigationTitle.font = [UIFont boldSystemFontOfSize:20.0f];
    self.navigationTitle.textAlignment = UITextAlignmentCenter;
    if (IS_IPAD()) {
        self.navigationTitle.textColor = [UIColor darkGrayColor];
        self.navigationTitle.shadowColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:.35];
    } else {
        self.navigationTitle.textColor = [UIColor blackColor];
//        self.navigationTitle.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.35];
    }
    self.navigationTitle.shadowOffset = CGSizeMake(0,-1.0);
    self.navigationTitle.backgroundColor = [UIColor clearColor];
    self.navigationTitle.userInteractionEnabled = YES;
    UITapGestureRecognizer *gestureRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDatePicker)];
    [self.navigationItem.titleView addGestureRecognizer:gestureRec];

    [self.navigationItem.titleView addSubview:self.navigationTitle];
}

-(void) showDatePicker {
//    [TestFlight passCheckpoint:@"Showed Date Picker"];
    //[FlurryAnalytics logEvent:@"Date Picker Shown"];
//    [AdDashDelegate reportCustomEvent:@"Date Picker Showed" withDetail:@""];
    self.datePickerSheet = [[TapDismissActionSheet alloc] initWithTitle:nil 
                                                             delegate:nil
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    [self.datePickerSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    

    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, 0, 0)];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.date = self.gamesController.scheduleDate;
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = 2;
    components.month = 4;
    components.year = 2007;
    self.datePicker.minimumDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    NSDateComponents *maxComponents = [[NSDateComponents alloc] init];
    maxComponents.day = 1;
    maxComponents.month = 12;
    maxComponents.year = 2015;
    self.datePicker.maximumDate = [[NSCalendar currentCalendar] dateFromComponents:maxComponents];
    
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Go"]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    //closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
    UISegmentedControl *todayButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Today"]];
    todayButton.momentary = YES; 
    todayButton.frame = CGRectMake(10, 7.0f, 50.0f, 30.0f);
    todayButton.segmentedControlStyle = UISegmentedControlStyleBar;
    //closeButton.tintColor = [UIColor blackColor];
    [todayButton addTarget:self action:@selector(setToday:) forControlEvents:UIControlEventValueChanged];
    
    if (IS_IPAD()) {
        //dismiss the standings popover if it's present
        [self.storeStandingsPopover dismissPopoverAnimated:YES];
        UIViewController* popoverContent = [[UIViewController alloc] init];
        UIView* popoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 344)];
        popoverView.backgroundColor = [UIColor colorWithRed:100/255.0f green:105/255.0f blue:121/255.0f alpha:1.0f];
                
        [popoverView addSubview:todayButton];
        [popoverView addSubview:closeButton];
        [popoverView addSubview:self.datePicker];
        popoverContent.view = popoverView;
        
        popoverContent.contentSizeForViewInPopover = CGSizeMake(320, 244);
        
        //create a popover controller
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        
        [self.popoverController presentPopoverFromRect:CGRectMake(160, -10, 1, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        
    } else {
        [self.datePickerSheet addSubview:datePicker];
        [self.datePickerSheet addSubview:todayButton];
        [self.datePickerSheet addSubview:closeButton];
        [self.datePickerSheet showInView:[[UIApplication sharedApplication] keyWindow]];
        [self.datePickerSheet addTapDetector]; //adds uigesturerecognizer so you can tap outside the actionsheet and dismiss it
        [UIView beginAnimations:nil context:nil];
        [self.datePickerSheet setBounds:CGRectMake(0, 0, 320, 485)];
        [UIView commitAnimations]; 
    }
}

-(void) dismissActionSheet:(id)sender {
    if (IS_IPAD()) {
        [self.popoverController dismissPopoverAnimated:YES];
        self.popoverController = nil;
    } else {
        [self.datePickerSheet dismissWithClickedButtonIndex:0 animated:YES];
        self.datePickerSheet = nil;
    }
    //only reload if the date has changed
    if (![self.datePicker.date isSameDay:self.gamesController.scheduleDate]) {
        [self showSpinnerView];
        [self.gamesController changeDate:self.datePicker.date reset:YES];
    }
}

//method called by action sheet
-(void) setToday:(id)sender {
    if (IS_IPAD()) {
        [self.popoverController dismissPopoverAnimated:YES];
        self.popoverController = nil;
    } else {
        [self.datePickerSheet dismissWithClickedButtonIndex:0 animated:YES];
        self.datePickerSheet = nil;
    }
    self.datePicker.date = [NSDate dateTodayish];
    if (![self.datePicker.date isSameDay:self.gamesController.scheduleDate]) {
        [self showSpinnerView];
        [self.gamesController changeDate:[NSDate dateTodayish] reset:YES];    
    }
}

-(void) addSwipeRecognizers {
    UISwipeGestureRecognizer* swipe;

    swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goForward:)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.tableView addGestureRecognizer:swipe];

    swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goBackward:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight; // default
    [self.tableView addGestureRecognizer:swipe];
}

-(void) loadGamesData {
    [[self.tableView viewWithTag:kErrorMessage] removeFromSuperview]; //successfully loaded, remove the error view if present
    [self.tableController.refreshControl endRefreshing];
    [self checkForNoGames];
    [self.tableView reloadData];
    [self performSelectorOnMainThread:@selector(hideSpinnerView) withObject:nil waitUntilDone:NO];
    if (self.gamesController.selectedGameday != nil) {
        NSIndexPath *calculatedPath = [self getIndexForGameday:self.gamesController.selectedGameday];
        if (calculatedPath) {
            //re-select so nothing changes during a reload
            [self.tableView selectRowAtIndexPath:calculatedPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        } else {
            DebugLog(@"this should not happen");
            self.gamesController.selectedGameday = nil; //just in case
        }
    }
}

-(NSIndexPath*) getIndexForGameday:(NSString*)gameday {
    int calculatedIndex = -1;
    for (Game *game in self.games) {
        if ([game.gameday isEqualToString:gameday]) {
            calculatedIndex = [self.games indexOfObject:game];
        }
    }
    if (calculatedIndex != -1) {
        return [NSIndexPath indexPathForRow:calculatedIndex inSection:0];
    } else {
        return nil;
    }
}

-(void) failedLoad {
    if (self.spinnerView != nil) {
        //display an error msg since it failed to load and the spinner was showing
        [self.tableView reloadData];
        [self hideSpinnerView];
        if ([self.tableView viewWithTag:kErrorMessage] == nil) {
            UIView *error = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 320, 40)];
            error.backgroundColor = [UIColor clearColor];
            error.tag = kErrorMessage;
            UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
            errorLabel.text = @"Failed to load, please try again.";
            errorLabel.textAlignment = UITextAlignmentCenter;
            errorLabel.font = [UIFont boldSystemFontOfSize:16.0];
            errorLabel.backgroundColor = [UIColor clearColor];
            [error addSubview:errorLabel];
            [self.tableView addSubview:error];
        }
    }
}

-(void) checkForNoGames {
    if (self.games.count == 0 && [self.tableView viewWithTag:kNoGames] == nil) {
        UIImage *noGameImage = [UIImage imageNamed:@"no-games.png"];
        UIImageView *noGames = [[UIImageView alloc] initWithImage:noGameImage];
        noGames.tag = kNoGames;
        [self.tableView addSubview:noGames];
    } else {
        [[self.tableView viewWithTag:kNoGames] removeFromSuperview];
    }
}

-(void)reloadGames:(id)sender {
    //this method is invoked when tapping the reload button. reset the update schedule when this happens as well
    //we do this so reloads aren't canceled 1 second later by the scheduled timer
    if (IS_IPAD()) {
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        DefaultViewController *defaultController = (DefaultViewController*)delegate.window.rootViewController;
        DetailViewController *detailController = (DetailViewController*)[defaultController.viewControllers lastObject];
        [detailController.singleGameDataController start];
        [self.gamesController scheduleUpdate];
        [self.gamesController reloadData];
    } else {
        [self.gamesController scheduleUpdate];
        [self.gamesController reloadData];
    }
}

-(NSMutableDictionary*) getAppPreferences {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return appDelegate.preferences;
}


#pragma mark in app settings methods and delegate method
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
	
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate loadPrefs];
    //we call scheduleUpdate here because viewWillAppear triggers on this view controller before loadPrefs fires.
    //we'll also refresh the data in case they've changed their favorite team
    //reset and reload since we may be changing the game order (if they picked a favorite team) or the refresh interval
    [self showSpinnerView];
    [self.gamesController changeDate:self.gamesController.scheduleDate reset:YES];
    [self.gamesController scheduleUpdate];
}

-(void)showSettings:(id)sender {
//    [TestFlight passCheckpoint:@"Looked at the settings"];
    //[FlurryAnalytics logEvent:@"Viewed Settings"];
//    [AdDashDelegate reportCustomEvent:@"Settings Showed" withDetail:@""];
    UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:self.appSettingsViewController];
    //[viewController setShowCreditsFooter:NO];   // Uncomment to not display InAppSettingsKit credits for creators.
    // But we encourage you not to uncomment. Thank you!
    self.appSettingsViewController.showDoneButton = YES;
    [self presentViewController:aNavController animated:YES completion:nil];
}

- (IASKAppSettingsViewController*)appSettingsViewController {
	if (!appSettingsViewController) {
		appSettingsViewController = [[IASKAppSettingsViewController alloc] initWithNibName:@"IASKAppSettingsView" bundle:nil];
		appSettingsViewController.delegate = self;
	}
	return appSettingsViewController;
}


-(void) showScoreAlerts:(NSMutableArray *)array {
    NSString *showScoreAlerts = [[self getAppPreferences] objectForKey:@"showScoreAlerts"];
    if ([showScoreAlerts isEqualToString:@"None"]) {
        return;
    }
    
    if (self.gamesController.todayGamesDict == nil) {
        //first load, we have no data to compare against (plus if we tried we'd crash)
        return;
    }
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (!delegate.shouldShowNotifications) {
        delegate.shouldShowNotifications = YES;
        return;
    }
    for (Game *newGame in array) {
        Game *oldGame = [self.gamesController.todayGamesDict objectForKey:newGame.gameday];
        if (oldGame == nil) {
            continue;
        }
        if ([oldGame.awayTeamRuns intValue] != [newGame.awayTeamRuns intValue]) {
            if ([self shouldShowScoreAlertForGame:newGame]) {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.alertAction = [NSString stringWithFormat:@"%@ scored! %@ %@, %@ %@",newGame.awayTeamName,newGame.awayTeamName,newGame.awayTeamRuns,newGame.homeTeamName,newGame.homeTeamRuns];
                notification.alertBody = newGame.lastPlay;
                notification.alertLaunchImage = newGame.gameday;
                [delegate queueNotificationForDisplay:notification];
            }
        }
        if ([oldGame.homeTeamRuns intValue] != [newGame.homeTeamRuns intValue]) {
            if ([self shouldShowScoreAlertForGame:newGame]) {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.alertAction = [NSString stringWithFormat:@"%@ scored! %@ %@, %@ %@",newGame.homeTeamName,newGame.awayTeamName,newGame.awayTeamRuns,newGame.homeTeamName,newGame.homeTeamRuns];
                notification.alertBody = newGame.lastPlay;
                notification.alertLaunchImage = newGame.gameday;
                [delegate queueNotificationForDisplay:notification];
            }
        }
    }
}

-(BOOL) shouldShowScoreAlertForGame:(Game*)pGame {
    NSString *showScoreAlerts = [[self getAppPreferences] objectForKey:@"showScoreAlerts"];
    NSString *favoriteTeamName = [[self getAppPreferences] objectForKey:@"favoriteTeam"];
    NSString *secondFavoriteTeamName = [[self getAppPreferences] objectForKey:@"secondFavoriteTeam"];
    NSString *thirdFavoriteTeamName = [[self getAppPreferences] objectForKey:@"thirdFavoriteTeam"];
    if ([showScoreAlerts isEqualToString:@"All"]) {
        return YES;
    } else if ([showScoreAlerts isEqualToString:@"None"]) {
        return NO;
    } else if ((([pGame.awayTeamName isEqualToString:favoriteTeamName] || [pGame.homeTeamName isEqualToString:favoriteTeamName]) ||
                ([pGame.awayTeamName isEqualToString:secondFavoriteTeamName] || [pGame.homeTeamName isEqualToString:secondFavoriteTeamName]) ||
                ([pGame.awayTeamName isEqualToString:thirdFavoriteTeamName] || [pGame.homeTeamName isEqualToString:thirdFavoriteTeamName])) && [showScoreAlerts isEqualToString:@"Favorite"]) {
        return YES;
    } else {
        return NO;
    }
}


@end
