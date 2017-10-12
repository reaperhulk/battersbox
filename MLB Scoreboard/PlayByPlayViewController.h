//
//  PlayByPlayViewController.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"
#import "SingleGameDataController.h"

@interface PlayByPlayViewController : UITableViewController <UISearchBarDelegate,SingleGameEventDelegate>

@property (nonatomic,strong) NSDictionary *events;
@property (nonatomic,strong) NSArray *sectionNames;
@property (nonatomic,strong) NSMutableDictionary *searchDictionary;
@property (nonatomic,strong) IBOutlet UISearchBar *searchBar;
@property BOOL shouldBeginEditing;

@end
