//
//  AtBatsView.m
//  Batter's Box
//
//  Created by Paul Kehrer on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AtBatsView.h"
#import "AtBat.h"
#import "GamesDataController.h"
#import "GameTabBarViewController.h"
#import "DefaultViewController.h"
#import "DetailViewController.h"
#import "GameTabBarViewController.h"
#import "AppDelegate.h"
#import "AtBatCell.h"
#import "DetailViewController.h"
#import "UIView+RoundedCorners.h"

@interface AtBatsView ()

@end

@implementation AtBatsView

@synthesize tableView,atBatParser,atBats,sectionNames,boxScoreData;

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setRoundedCorners:UIRectCornerTopRight|UIRectCornerBottomRight radius:10.0];
    }
    return self;
}

- (void)dealloc {
    if (self.atBatParser) {
        [self.atBatParser cancel];
        self.atBatParser = nil;
    }
}

-(void) loadData {
    self.atBatParser = [[AtBatParser alloc] initWithDelegate:self game:self.game];
}

-(void) reset {
    if (self.atBatParser) {
        [self.atBatParser cancel];
        self.atBatParser = nil;
    }
    self.atBats = nil;
    self.sectionNames = nil;
    [self.tableView reloadData];
}

-(Game*) game {
    if (IS_IPAD()) {
        return [[GamesDataController sharedSingleton] gameForGameday:[[GamesDataController sharedSingleton] selectedGameday]];
    } else {
        //figure something out. next line is to just suppress a warning
        return [[Game alloc] init];
    }
}

-(NSDictionary*) getBoxData {
    if (IS_IPAD()) {
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        DefaultViewController *defaultViewController = (DefaultViewController*)delegate.window.rootViewController;
        DetailViewController *detail = (DetailViewController *)[defaultViewController.viewControllers lastObject];
        return detail.singleGameDataController.boxScoreData;
    } else {
        //figure something out. next line is to just suppress a warning
        return [NSDictionary dictionary];
    }
}

#pragma mark - AtBatDelegate methods

-(void) atBatsLoaded:(NSMutableDictionary *)pAtBats sectionNames:(NSMutableArray *)pSectionNames {
    self.sectionNames = pSectionNames;
    self.atBats = pAtBats;
    self.boxScoreData = [self getBoxData]; //grab the data and hold a strong ref to it in this object
    [self getBatterAndPitcherNames];
    [self.tableView reloadData];
}

-(void) atBatsLoadFailed {
    DebugLog(@"at bat load failed");
}

-(void) getBatterAndPitcherNames {
    NSDictionary *batters = [self.boxScoreData objectForKey:@"batters"];
    NSDictionary *pitchers = [self.boxScoreData objectForKey:@"pitchers"];
    [self.atBats enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        for (AtBat *atBat in obj) {
            //find batter
            for (NSDictionary *awayHome in batters) {
                for (Batter *batter in [batters objectForKey:awayHome]) {
                    if ([batter.batterId isEqualToString:atBat.batterId]) {
                        atBat.batter = batter;
                        break;
                    }
                }
            }
            //find pitcher
            for (NSDictionary *awayHome in pitchers) {
                for (Pitcher *pitcher in [pitchers objectForKey:awayHome]) {
                    if ([pitcher.pitcherId isEqualToString:atBat.pitcherId]) {
                        atBat.pitcher = pitcher;
                        break;
                    }
                }
            }
        }
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionNames count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.atBats objectForKey:[self.sectionNames objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    for(UIView *view in [self.tableView subviews]) {
        if([view respondsToSelector:@selector(setIndexColor:)]) {
            [view performSelector:@selector(setIndexColor:) withObject:[UIColor whiteColor]];
        }
    }
	AtBatCell *cell = [pTableView dequeueReusableCellWithIdentifier:@"AtBatCell"];
    if (!cell) {
        cell = [[NSBundle.mainBundle loadNibNamed:@"AtBatsView" owner:self options:nil] objectAtIndex:1];
    }
    NSInteger count = [[self.atBats objectForKey:[self.sectionNames objectAtIndex:indexPath.section]] count];
	AtBat *atBat = [[self.atBats objectForKey:[self.sectionNames objectAtIndex:indexPath.section]] objectAtIndex:(count - 1 - indexPath.row)];
    cell.pitcherBatter.text = atBat.batter.fullName;
    cell.pitchesThrown.text = [NSString stringWithFormat:@"%d",atBat.pitches.count];
    cell.result.text = atBat.event;

    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionNames objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *secNames = [NSMutableArray array];
    for (NSString *name in self.sectionNames) {
        NSString *alteredName = [name stringByReplacingOccurrencesOfString:@"Current At Bat" withString:@"C"];
        alteredName = [alteredName stringByReplacingOccurrencesOfString:@"Top " withString:@"T"];
        alteredName = [alteredName stringByReplacingOccurrencesOfString:@"Bottom " withString:@"B"];
        [secNames addObject:alteredName];
    }
    return secNames;
}

- (UIView *) tableView:(UITableView *)pTableView viewForHeaderInSection:(NSInteger)section 
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pTableView.bounds.size.width, 22)];
    headerView.backgroundColor = [UIColor blackColor];
    if (section == 0) {
        UIButton *headerButton = [[UIButton alloc] initWithFrame:CGRectMake(6, 0, pTableView.bounds.size.width-12, 22)];
        headerButton.backgroundColor = [UIColor clearColor];
        headerButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [headerButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [headerButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [headerButton setTitle:[self.sectionNames objectAtIndex:section] forState:UIControlStateNormal];
        [headerView addSubview:headerButton];
        [headerButton addTarget:self action:@selector(resetToCurrentAtBat) forControlEvents:UIControlEventTouchDown];
    } else {
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, pTableView.bounds.size.width-12, 22)];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:15.0];
        headerLabel.textColor = [UIColor yellowColor];
        [headerView addSubview:headerLabel];
        headerLabel.text = [self.sectionNames objectAtIndex:section];
    }
    return headerView;
}

-(void) resetToCurrentAtBat {
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    DefaultViewController *defaultViewController = (DefaultViewController*)delegate.window.rootViewController;
    DetailViewController *detailController = (DetailViewController *)[defaultViewController.viewControllers lastObject];
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:selection animated:YES];
    if ([self.game.lastPlay length] != 0) {
        [detailController showPlay:self.game.lastPlay];
    } else {
        detailController.lastPlayView.hidden = YES;
    }
    [detailController.pitcherGridView resetPitchesAndRemoveDataView];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    DefaultViewController *defaultViewController = (DefaultViewController*)delegate.window.rootViewController;
    DetailViewController *detailController = (DetailViewController *)[defaultViewController.viewControllers lastObject];
    detailController.pitcherGridView.hidden = NO;
    NSInteger count = [[self.atBats objectForKey:[self.sectionNames objectAtIndex:indexPath.section]] count];
    AtBat *atBat = [[self.atBats objectForKey:[self.sectionNames objectAtIndex:indexPath.section]] objectAtIndex:(count - 1 - indexPath.row)];
    [detailController.pitcherGridView pitchesLoaded:atBat.pitches atBatNum:[atBat.num integerValue] stand:atBat.batterStand complete:YES pastAtBat:YES];
    [detailController showPlay:atBat.des];
}

@end
