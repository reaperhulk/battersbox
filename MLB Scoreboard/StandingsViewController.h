//
//  StandingsViewController.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StandingsViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic,strong) IBOutlet UIWebView *webView;
@property (nonatomic,strong) IBOutlet UIActivityIndicatorView *activityIndicator;

-(IBAction)closeSheet:(id)sender;
@end
