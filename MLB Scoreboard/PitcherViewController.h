//
//  PitcherViewController.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pitcher.h"
#import "Game.h"
#import "PitcherDetail.h"
#import "AsyncImageView.h"
#import "AFXMLRequestOperation.h"

@interface PitcherViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,NSXMLParserDelegate>

@property (strong) Pitcher *pitcher;
@property (strong) UIView *spinnerView;
@property (strong) UIImageView *failView;
@property (strong) PitcherDetail *pitcherDetail;

@property (strong) IBOutlet UITableView *tableView;

@property (nonatomic,strong) IBOutlet UILabel *jerseyNumber;
@property (nonatomic,strong) IBOutlet UIButton *pitcherName;
@property (nonatomic,strong) IBOutlet UILabel *weightHeight;
@property (nonatomic,strong) IBOutlet UILabel *throws;
@property (nonatomic,strong) IBOutlet UILabel *dateOfBirth;
@property (nonatomic,strong) IBOutlet UILabel *age;
@property (nonatomic,strong) IBOutlet AsyncImageView *photo;
@property (nonatomic,strong) AFXMLRequestOperation *afOperation;

-(IBAction)followLink:(id)sender;

@end
