//
//  BatterViewController.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Batter.h"
#import "Game.h"
#import "BatterDetail.h"
#import "AsyncImageView.h"
#import "AFXMLRequestOperation.h"

@interface BatterViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,NSXMLParserDelegate>

@property (strong) Batter *batter;
@property (strong) UIView *spinnerView;
@property (strong) UIImageView *failView;
@property (strong) BatterDetail *batterDetail;

@property (strong) IBOutlet UITableView *tableView;

@property (nonatomic,strong) IBOutlet UILabel *jerseyNumber;
@property (nonatomic,strong) IBOutlet UILabel *position;
@property (nonatomic,strong) IBOutlet UIButton *batterName;
@property (nonatomic,strong) IBOutlet UILabel *weightHeight;
@property (nonatomic,strong) IBOutlet UILabel *bats;
@property (nonatomic,strong) IBOutlet UILabel *throws;
@property (nonatomic,strong) IBOutlet UILabel *dateOfBirth;
@property (nonatomic,strong) IBOutlet UILabel *age;
@property (nonatomic,strong) IBOutlet AsyncImageView *photo;
@property (nonatomic,strong) AFXMLRequestOperation *afOperation;

-(IBAction)followLink:(id)sender;

@end
