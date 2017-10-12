//
//  PitchingStatsViewController.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PitchingStatsViewController.h"
#import "Pitcher.h"
#import "PitcherCell.h"
#import "PitcherViewController.h"
#import "GameTabBarViewController.h"
#import "GamesViewController.h"

@interface PitchingStatsViewController ()

@end

@implementation PitchingStatsViewController

@synthesize pitchers;
@synthesize segmentedControl;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set segmented control label names
    [self.segmentedControl setTitle:self.game.awayTeamName forSegmentAtIndex:0];
    [self.segmentedControl setTitle:self.game.homeTeamName forSegmentAtIndex:1];
}

-(void)viewWillAppear:(BOOL)animated {
    if (self.pitchers == nil) {
        //TODO
        DebugLog(@"TODO: data hasn't loaded yet. I need to handle this situation");
    }
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
	if (selection)
		[self.tableView deselectRowAtIndexPath:selection animated:YES];


    self.tabBarController.navigationItem.title = @"Pitching Stats";
    self.navigationItem.title = @"Pitching Stats";
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.pitchers count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.segmentedControl.selectedSegmentIndex != section) {
        return 0;
    }
    NSString *key = nil;
    if (section == 0) {
        key = @"Away";
    } else {
        key = @"Home";
    }
    
    return [[self.pitchers objectForKey:key] count];
}

- (UITableViewCell *)tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex != indexPath.section) {
        return nil;
    }
    NSString *key = nil;
    if (indexPath.section == 0) {
        key = @"Away";
    } else {
        key = @"Home";
    }
    static NSString *CellIdentifier = @"PitcherCell";
    PitcherCell *cell = [pTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    Pitcher *pitcher = [[self.pitchers objectForKey:key] objectAtIndex:indexPath.row];
    cell.name.text = pitcher.name;
    cell.inningsPitched.text = [self parseInningsPitched:pitcher.inningsPitched];
    cell.runsAllowed.text = pitcher.runsAllowed;
    cell.earnedRuns.text = pitcher.earnedRuns;
    cell.hitsAllowed.text = pitcher.hitsAllowed;
    cell.baseOnBalls.text = pitcher.baseOnBalls;
    cell.strikeOuts.text = pitcher.strikeOuts;
    cell.homeRunsAllowed.text = pitcher.homeRunsAllowed;
    cell.earnedRunAverage.text = pitcher.earnedRunAverage;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.segmentedControl.selectedSegmentIndex == section) {
        return 25;
    } else {
        return 0;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[NSBundle.mainBundle loadNibNamed:@"PitcherBatterHeader" owner:self options:nil] objectAtIndex:1];
    return view;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor whiteColor];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1.0];
    }
}

-(NSString*) parseInningsPitched:(NSString*)outs {
    int innings = [outs intValue]/3;
    int decimal = [outs intValue] % 3;
    return [NSString stringWithFormat:@"%d.%d",innings,decimal];
}


-(IBAction)segmentedControlIndexChanged:(id)sender {
    [self.tableView reloadData];
}

-(void) buildTable {
    [self.segmentedControl setTitle:self.game.awayTeamName forSegmentAtIndex:0];
    [self.segmentedControl setTitle:self.game.homeTeamName forSegmentAtIndex:1];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PitcherViewController *pitcherViewController = segue.destinationViewController;
    NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
    
    NSString *key = nil;
    if (selectedPath.section == 0) {
        key = @"Away";
    } else {
        key = @"Home";
    }

    pitcherViewController.pitcher = [[self.pitchers objectForKey:key] objectAtIndex:selectedPath.row];
}

-(Game*) game {
    if (IS_IPAD()) {
        return [[GamesDataController sharedSingleton] gameForGameday:[[GamesDataController sharedSingleton] selectedGameday]];
    } else {
        GameTabBarViewController *tabController = (GameTabBarViewController*)self.tabBarController;
        return [[GamesDataController sharedSingleton] gameForGameday:tabController.singleGameDataController.gameday];
    }
}

-(void) boxScoreLoaded:(NSDictionary *)boxScore {
    self.pitchers = [boxScore objectForKey:@"pitchers"];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(void) boxScoreLoadFailed {
    DebugLog(@"box score load failed (pitching stats load)");
}

@end
