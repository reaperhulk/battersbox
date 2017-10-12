//
//  BattingStatsViewController.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BattingStatsViewController.h"
#import "BoxScoreParser.h"
#import "BatterCell.h"
#import "Batter.h"
#import "BatterViewController.h"
#import "GameTabBarViewController.h"
#import "GamesViewController.h"
#import "GamesDataController.h"

@interface BattingStatsViewController ()

@end

@implementation BattingStatsViewController


@synthesize batters;
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
    if (self.batters == nil) {
        //TODO
        DebugLog(@"TODO: data hasn't loaded yet. I need to handle this situation");
    }
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
	if (selection)
		[self.tableView deselectRowAtIndexPath:selection animated:YES];

    self.tabBarController.navigationItem.title = @"Batting Stats";
    self.navigationItem.title = @"Batting Stats";
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
    return [self.batters count];
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

    return [[self.batters objectForKey:key] count];
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
    static NSString *CellIdentifier = @"BatterCell";
    BatterCell *cell = [pTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    Batter *batter = [[self.batters objectForKey:key] objectAtIndex:indexPath.row];
    cell.atBats.text = batter.atBats;
    cell.batterName.text = batter.name;
    cell.hits.text = batter.hits;
    cell.homeRuns.text = batter.homeRuns;
    cell.runs.text = batter.runs;
    cell.runsBattedIn.text = batter.runsBattedIn;
    cell.baseOnBalls.text = batter.baseOnBalls;
    cell.strikeOuts.text = batter.strikeOuts;
    cell.leftOnBase.text = batter.leftOnBase;
    cell.stolenBases.text = batter.stolenBases;
    
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
    UIView *view = [[NSBundle.mainBundle loadNibNamed:@"PitcherBatterHeader" owner:self options:nil] objectAtIndex:0];
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

-(IBAction)segmentedControlIndexChanged:(id)sender {
    [self.tableView reloadData];
}

-(void) buildTable {
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BatterViewController *batterViewController = segue.destinationViewController;
    NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
    
    NSString *key = nil;
    if (selectedPath.section == 0) {
        key = @"Away";
    } else {
        key = @"Home";
    }
    
    batterViewController.batter = [[self.batters objectForKey:key] objectAtIndex:selectedPath.row];
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
    self.batters = [boxScore objectForKey:@"batters"];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(void) boxScoreLoadFailed {
    DebugLog(@"box score load failed (batting stats load)");
}


@end
