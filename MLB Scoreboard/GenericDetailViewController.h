//
//  GenericDetailViewController.h
//  Batter's Box
//
//  Created by Paul Kehrer on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenOnBase.h"
#import "AsyncImageView.h"
#import "PitcherGridView.h"
#import "LinescoreParser.h"
#import "WeatherView.h"
#import "HomeRunView.h"
#import "AtBatsView.h"

@interface GenericDetailViewController : UIViewController <LinescoreParserDelegate,AtBatCountAndScoreDelegate>

@property (nonatomic,strong) IBOutlet AsyncImageView *firstPlayerImage;
@property (nonatomic,strong) IBOutlet AsyncImageView *secondPlayerImage;
@property (nonatomic, strong) IBOutlet UILabel *firstLabel;
@property (nonatomic, strong) IBOutlet UILabel *firstPlayer;
@property (nonatomic, strong) IBOutlet UILabel *secondLabel;
@property (nonatomic, strong) IBOutlet UILabel *secondPlayer;
@property (nonatomic, strong) IBOutlet UILabel *thirdLabel;
@property (nonatomic, strong) IBOutlet UILabel *thirdPlayer;
@property (nonatomic, strong) IBOutlet UILabel *fourthLabel;
@property (nonatomic, strong) IBOutlet UILabel *fourthPlayer;
@property (nonatomic, strong) IBOutlet UILabel *awayTeamLabel;
@property (nonatomic, strong) IBOutlet UILabel *homeTeamLabel;
@property (nonatomic, strong) IBOutlet UILabel *awayRecord;
@property (nonatomic, strong) IBOutlet UILabel *homeRecord;
@property (nonatomic, strong) IBOutlet MenOnBase *menOnBase;
@property (nonatomic, strong) IBOutlet UILabel *awayTeamRuns;
@property (nonatomic, strong) IBOutlet UILabel *homeTeamRuns;
@property (nonatomic, strong) IBOutlet UILabel *ballsStrikesOuts;
@property (nonatomic, strong) IBOutlet UILabel *statusOrTime;
@property (nonatomic, strong) IBOutlet UILabel *venue;

@property (nonatomic, strong) IBOutlet UILabel *awayTeamBoxRuns;
@property (nonatomic, strong) IBOutlet UILabel *homeTeamBoxRuns;
@property (nonatomic, strong) IBOutlet UILabel *awayTeamHits;
@property (nonatomic, strong) IBOutlet UILabel *homeTeamHits;
@property (nonatomic, strong) IBOutlet UILabel *awayTeamErrors;
@property (nonatomic, strong) IBOutlet UILabel *homeTeamErrors;

@property (nonatomic, strong) IBOutlet UIView *boxScoreView;

@property (nonatomic, strong) IBOutlet UIWebView *gameInfoWebView;

@property (nonatomic, strong) UIImageView *seatsNoGameImage;

@property (nonatomic, strong) IBOutlet PitcherGridView *pitcherGridView;

@property (nonatomic,strong) IBOutlet UIButton *awayPreviewRecapLink;
@property (nonatomic,strong) IBOutlet UIButton *homePreviewRecapLink;
@property (nonatomic,strong) NSString *homeRecapUrl;
@property (nonatomic,strong) NSString *awayRecapUrl;

@property (nonatomic,strong) IBOutlet UIImageView *dayBackground;
@property (nonatomic,strong) IBOutlet UIImageView *nightBackground;
@property (nonatomic,strong) IBOutlet UIImageView *stadiumLights;

@property (nonatomic,strong) IBOutlet WeatherView *weatherLayer;
@property (nonatomic,strong) IBOutlet HomeRunView *homeRunLayer;

@property (nonatomic,strong) IBOutlet UIView *dataContainerView;

@property (nonatomic,strong) IBOutlet UIView *lastPlayView;

@property (nonatomic,strong) AtBatsView *atBatsView;

@property BOOL isNightModeSet;
@property BOOL scoreAndAtBatFromPlays;

//ipad only
@property (nonatomic,strong) IBOutlet UIView *thirdFourthBackgroundBox;

-(void) buildViewData;
-(void) showPlay:(NSString*)play;

@end
