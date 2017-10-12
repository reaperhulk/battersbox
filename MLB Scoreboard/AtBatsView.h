//
//  AtBatsView.h
//  Batter's Box
//
//  Created by Paul Kehrer on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AtBatParser.h"

@interface AtBatsView : UIView <UITableViewDelegate,UITableViewDataSource,AtBatDelegate>

@property (nonatomic,strong) AtBatParser *atBatParser;
@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSDictionary *atBats;
@property (nonatomic,strong) NSArray *sectionNames;
@property (nonatomic,strong) NSDictionary *boxScoreData;

-(void) loadData;
-(void) reset;

@end
