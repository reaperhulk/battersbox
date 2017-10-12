//
//  PlayByPlayViewController.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayByPlayViewController.h"
#import "EventLogParser.h"
#import "GameEvent.h"
#import "GameTabBarViewController.h"
#import "GamesViewController.h"
#import "GamesDataController.h"


@interface PlayByPlayViewController ()

@end

@implementation PlayByPlayViewController

@synthesize events;
@synthesize sectionNames;
@synthesize searchBar;
@synthesize searchDictionary;
@synthesize shouldBeginEditing;

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
    
    self.searchDictionary = [NSMutableDictionary dictionary];
    self.shouldBeginEditing = YES;
}

-(void)viewWillAppear:(BOOL)animated {
    self.tabBarController.navigationItem.title = @"Play By Play";
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
    return [self.sectionNames count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *eventList;
    if(([self.searchBar isFirstResponder] && self.searchBar.text.length > 0) || self.searchBar.text.length > 0) {
        eventList = self.searchDictionary;
    } else {
        eventList = self.events;
    }

    return [[eventList objectForKey:[self.sectionNames objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *eventList;
    if(([self.searchBar isFirstResponder] && self.searchBar.text.length > 0) || self.searchBar.text.length > 0) {
        eventList = self.searchDictionary;
    } else {
        eventList = self.events;
    }
	UITableViewCell *cell = [pTableView dequeueReusableCellWithIdentifier:@"EventCell"];
    NSInteger count = [[eventList objectForKey:[self.sectionNames objectAtIndex:indexPath.section]] count];
	GameEvent *gameEvent = [[eventList objectForKey:[self.sectionNames objectAtIndex:indexPath.section]] objectAtIndex:(count - 1 - indexPath.row)];

    cell.textLabel.text = gameEvent.eventDescription;

    
    //add outs
    UIImageView *outsView = (UIImageView*)[cell viewWithTag:50];
    if (outsView == nil) {
        outsView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"outs-v-%@.png"]];
        outsView.tag = 50;
    }
    outsView.image = [UIImage imageNamed:[NSString stringWithFormat:@"outs-v-%@.png",gameEvent.outs]];
    CGFloat height = [self tableView:pTableView heightForRowAtIndexPath:indexPath];
    outsView.frame = CGRectMake(265, (height/2)-17, 34, 33);
    [cell addSubview:outsView];

    return cell;
}

//just to color the scoring cells
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *eventList;
    if(([self.searchBar isFirstResponder] && self.searchBar.text.length > 0) || self.searchBar.text.length > 0) {
        eventList = self.searchDictionary;
    } else {
        eventList = self.events;
    }
    NSInteger count = [[eventList objectForKey:[self.sectionNames objectAtIndex:indexPath.section]] count];
	GameEvent *gameEvent = [[eventList objectForKey:[self.sectionNames objectAtIndex:indexPath.section]] objectAtIndex:(count - 1 - indexPath.row)];

    if (gameEvent.homeTeamRuns != nil || gameEvent.awayTeamRuns != nil) {
            cell.backgroundColor = [UIColor colorWithRed:221/255.0f green:255/255.0f blue:222/255.0f alpha:1.0f];
    }
}

- (NSInteger) tableView: (UITableView*) tableView sectionForSectionIndexTitle: (NSString*) title atIndex: (NSInteger) indexNum { 
    if(indexNum == 0) {
        [self.tableView scrollRectToVisible:CGRectMake(0,0,1,1) animated:NO];
    }
    //we have 1 extra index title (the search icon) so we need to subtract by 1 to get the "proper" index
    return indexNum -1; 
} 

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionNames objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if ([self.searchBar isFirstResponder]) {
        return nil;
    }
    
    NSMutableArray *secNames = [NSMutableArray array];
    [secNames addObject:UITableViewIndexSearch];
    for (NSString *name in self.sectionNames) {
        NSString *alteredName = [name stringByReplacingOccurrencesOfString:@"Top " withString:@"T"];
        alteredName = [alteredName stringByReplacingOccurrencesOfString:@"Bottom " withString:@"B"];
        [secNames addObject:alteredName];
    }
    return secNames;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *eventList;
    if(([self.searchBar isFirstResponder] && self.searchBar.text.length > 0) || self.searchBar.text.length > 0) {
        eventList = self.searchDictionary;
    } else {
        eventList = self.events;
    }

    NSInteger count = [[eventList objectForKey:[self.sectionNames objectAtIndex:indexPath.section]] count];
	GameEvent *gameEvent = [[eventList objectForKey:[self.sectionNames objectAtIndex:indexPath.section]] objectAtIndex:(count - 1 - indexPath.row)];
    UIFont *cellFont = [UIFont systemFontOfSize:13.0];
    CGSize constraintSize = CGSizeMake(272.0f, MAXFLOAT);
    CGSize labelSize = [gameEvent.eventDescription sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat totalHeight = labelSize.height + 20;
    return (totalHeight >=40)?totalHeight:40;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
        [self.tableView reloadData];
    }
}


#pragma mark - UISearchBar delegate methods

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    [self.tableView reloadData];
}


- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    if(![searchBar isFirstResponder]) {
        // user tapped the 'clear' button
        self.shouldBeginEditing = NO;
        [self.tableView reloadData];
    } else {
        if([searchText length] > 0) {
            [self searchTableView];
        }
        [self.tableView reloadData];
    }
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [self.searchBar resignFirstResponder];
    [self.tableView reloadData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)bar {
    // reset the shouldBeginEditing BOOL ivar to YES, but first take its value and use it to return it from the method call
    BOOL boolToReturn = self.shouldBeginEditing;
    self.shouldBeginEditing = YES;
    return boolToReturn;
}

-(void) eventLogLoaded:(NSDictionary *)eventsToLoad sectionNames:(NSArray*)secNames {
    [self performSelectorOnMainThread:@selector(setEvents:) withObject:eventsToLoad waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(setSectionNames:) withObject:secNames waitUntilDone:YES];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];

}
-(void) eventLogLoadFailed {
    DebugLog(@"event log failed to load");
}


- (void) searchTableView {
    NSString *searchText = searchBar.text;

    [self.searchDictionary removeAllObjects];

    for (id key in self.events) {
        NSMutableArray *copiedEventList = [[self.events objectForKey:key] mutableCopy];
        if (copiedEventList) {
            [self.searchDictionary setObject:copiedEventList forKey:key];
        }
    }
    for (id key in self.searchDictionary) {
        NSMutableArray *itemsToDiscard = [NSMutableArray array];
        NSMutableArray *eventsByInning = [self.searchDictionary objectForKey:key];
        for (GameEvent *gameEvent in eventsByInning) {
            NSRange titleResultsRange = [gameEvent.eventDescription rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (titleResultsRange.length == 0) {
                [itemsToDiscard addObject:gameEvent];
            }
        
        }
        [eventsByInning removeObjectsInArray:itemsToDiscard];
    }
}

-(Game*) game {
    if (IS_IPAD()) {
        return [[GamesDataController sharedSingleton] gameForGameday:[[GamesDataController sharedSingleton] selectedGameday]];
    } else {
        GameTabBarViewController *tabController = (GameTabBarViewController*)self.tabBarController;
        return [[GamesDataController sharedSingleton] gameForGameday:tabController.singleGameDataController.gameday];
    }
}

@end
