//
//  GenericDetailViewController.m
//  Batter's Box
//
//  Created by Paul Kehrer on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GenericDetailViewController.h"
#import "Game.h"
#import "InningView.h"
#import "Inning.h"
#import "NSDate+DateIsToday.h"

#define kBoxScoreRunsLabel 500
#define kBoxScoreHitsLabel 501
#define kBoxScoreErrorsLabel 502

@interface GenericDetailViewController ()

@end

@implementation GenericDetailViewController

@synthesize awayTeamLabel,awayRecord;
@synthesize homeTeamLabel,homeRecord;
@synthesize awayTeamRuns;
@synthesize homeTeamRuns;
@synthesize ballsStrikesOuts,statusOrTime,venue;
@synthesize menOnBase;

@synthesize awayTeamBoxRuns;
@synthesize homeTeamBoxRuns;
@synthesize awayTeamHits;
@synthesize awayTeamErrors;
@synthesize homeTeamHits;
@synthesize homeTeamErrors;

@synthesize boxScoreView;
@synthesize gameInfoWebView;

@synthesize firstLabel,secondLabel,thirdLabel,fourthLabel;
@synthesize firstPlayer,secondPlayer,thirdPlayer,fourthPlayer;
@synthesize firstPlayerImage,secondPlayerImage;

@synthesize seatsNoGameImage;

@synthesize pitcherGridView;

@synthesize awayPreviewRecapLink,homePreviewRecapLink;

@synthesize homeRecapUrl,awayRecapUrl;

@synthesize dayBackground,nightBackground,stadiumLights,thirdFourthBackgroundBox;

@synthesize homeRunLayer,weatherLayer;

@synthesize dataContainerView;

@synthesize lastPlayView;

@synthesize isNightModeSet,scoreAndAtBatFromPlays,atBatsView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addShadow:self.menOnBase];
    //these next two lines are for performance reasons. rasterize this layer (which contains most of the images/text at the top of the view) and performance is much better
    //when animating
    self.dataContainerView.layer.shouldRasterize = YES;
    self.dataContainerView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.lastPlayView.layer.cornerRadius = 7.0f;
    self.lastPlayView.layer.masksToBounds = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) hideFirst:(BOOL)hide {
    self.firstLabel.hidden = hide;
    self.firstPlayer.hidden = hide;
}

-(void) hideSecond:(BOOL)hide {
    self.secondLabel.hidden = hide;
    self.secondPlayer.hidden = hide;
}

-(void) hideThird:(BOOL)hide {
    self.thirdLabel.hidden = hide;
    self.thirdPlayer.hidden = hide;
}

-(void) hideFourth:(BOOL)hide {
    self.fourthPlayer.hidden = hide;
    self.fourthLabel.hidden = hide;
}

-(void) hidePlayerLabels:(BOOL)hide {
    [self hideFirst:hide];
    [self hideSecond:hide];
    [self hideThird:hide];
    [self hideFourth:hide];
}

//THIS METHOD IS OVERRIDDEN IN ALL CHILDREN
-(Game*) game {
    [NSException raise:@"NO OVERRIDE" format:@"Must override game method"];
    return [[Game alloc] init];
}

-(void) buildViewData {
    Game *game = self.game;
    [self showPlay:game.lastPlay];
    [self setTimeBasedColorsAndBackground];
    
    self.awayTeamLabel.text = game.awayTeamName;
    self.homeTeamLabel.text = game.homeTeamName;
    if (game.awayWin != nil) {
        self.awayRecord.text = [NSString stringWithFormat:@"(%@-%@)",game.awayWin,game.awayLoss];        
        self.homeRecord.text = [NSString stringWithFormat:@"(%@-%@)",game.homeWin,game.homeLoss];
    } else {
        self.awayRecord.text = @"";
        self.homeRecord.text = @"";
    }
    
    if (self.game.statusCode == 1) {
        self.ballsStrikesOuts.hidden = NO;
        self.menOnBase.hidden = NO;
    } else {
        self.ballsStrikesOuts.hidden = YES;
        self.menOnBase.hidden = YES;
    }

    self.venue.text = game.venue;
    
    [self hidePlayerLabels:YES];
    
    [self setupPreviewRecapLinks];
    
    if ([game beforeFirstPitch] && game.statusCode == 0) {
        self.statusOrTime.text = [game gameTimeInLocalTime];
    } else {
        self.statusOrTime.text = game.status;
    }
    
    
    if (game.statusCode != 1 && self.atBatsView == nil) {
        self.pitcherGridView.hidden = YES;
    } else {
        self.pitcherGridView.hidden = NO;
    }

    if (game.statusCode == 0) {
        if (![game.awayProbablePitcher.name isEqualToString:@""]) {
            if (IS_IPAD()) {
                [self.firstPlayerImage loadImageWithObject:game.awayProbablePitcher mugshot:NO];
            }
            [self hideFirst:NO];
            self.firstLabel.text = @"Away Pitcher";
            self.firstPlayer.text = [NSString stringWithFormat:@"%@ (%@ ERA, %i-%i)",game.awayProbablePitcher.name,game.awayProbablePitcher.earnedRunAverage, [game.awayProbablePitcher.wins intValue],[game.awayProbablePitcher.losses intValue]];
        }
        if (![game.homeProbablePitcher.name isEqualToString:@""]) {
            if (IS_IPAD()) {
                [self.secondPlayerImage loadImageWithObject:game.homeProbablePitcher mugshot:NO];
            }
            [self hideSecond:NO];
            self.secondLabel.text = @"Home Pitcher";
            self.secondPlayer.text = [NSString stringWithFormat:@"%@ (%@ ERA, %i-%i)",game.homeProbablePitcher.name,game.homeProbablePitcher.earnedRunAverage, [game.homeProbablePitcher.wins intValue],[game.homeProbablePitcher.losses intValue]];
        }
        
    }
    if (game.statusCode == 1) {
        [self hidePlayerLabels:NO];
        if (!self.scoreAndAtBatFromPlays) {
            self.ballsStrikesOuts.text = [NSString stringWithFormat:@"%@-%@ %@ out",game.balls,game.strikes,game.outs];
        }
        [self.menOnBase setMenOnBase:[game.runnerOnBaseStatus intValue]];
        self.firstLabel.text = @"Pitching";
        self.firstPlayer.text = [NSString stringWithFormat:@"%@ (%@ ERA, %i-%i)",game.currentPitcher.name,game.currentPitcher.earnedRunAverage,[game.currentPitcher.wins intValue],[game.currentPitcher.losses intValue]];
        self.secondLabel.text = @"Batting";
        self.secondPlayer.text = [NSString stringWithFormat:@"%@ (%i-%i, %@ OPS)",game.currentBatter.name,[game.currentBatter.hits intValue],[game.currentBatter.atBats intValue],game.currentBatter.ops];
        self.thirdLabel.text = @"On Deck";
        self.thirdPlayer.text = [NSString stringWithFormat:@"%@ (%i-%i, %@ OPS)",game.currentOnDeck.name,[game.currentOnDeck.hits intValue],[game.currentOnDeck.atBats intValue],game.currentOnDeck.ops];
        self.fourthLabel.text = @"In Hole";
        self.fourthPlayer.text = [NSString stringWithFormat:@"%@ (%i-%i, %@ OPS)",game.currentInHole.name,[game.currentInHole.hits intValue],[game.currentInHole.atBats intValue],game.currentInHole.ops];
    }

    if (game.homeTeamHits != nil && game.statusCode != 0) {
        self.awayTeamRuns.text = game.awayTeamRuns;
        self.homeTeamRuns.text = game.homeTeamRuns;
        self.homeTeamBoxRuns.text = game.homeTeamRuns;
        self.homeTeamHits.text = game.homeTeamHits;
        self.homeTeamErrors.text = game.homeTeamErrors;
        self.awayTeamBoxRuns.text = game.awayTeamRuns;
        self.awayTeamHits.text = game.awayTeamHits;
        self.awayTeamErrors.text = game.awayTeamErrors;
    } else {
        self.awayTeamRuns.text = @"";
        self.homeTeamRuns.text = @"";
        self.homeTeamBoxRuns.text = @"";
        self.homeTeamHits.text = @"";
        self.homeTeamErrors.text = @"";
        self.awayTeamBoxRuns.text = @"";
        self.awayTeamHits.text = @"";
        self.awayTeamErrors.text = @"";        
    }
    
    [self showWinLossPitcherData];
    [self buildBoxScore];
}

-(void) showWinLossPitcherData {
    Game *game = self.game;
    if (game.statusCode == 2) {
        if (![game.winningPitcher.name isEqualToString:@""]) {
            if (IS_IPAD()) {
                [self.firstPlayerImage loadImageWithObject:game.winningPitcher mugshot:NO];
            }
            [self hideFirst:NO];
            self.firstLabel.text = @"Winner";
            self.firstPlayer.text = [NSString stringWithFormat:@"%@ (%@ ERA, %i-%i)",game.winningPitcher.name,game.winningPitcher.earnedRunAverage, [game.winningPitcher.wins intValue],[game.winningPitcher.losses intValue]];
        }
        if (![game.savePitcher.name isEqualToString:@""]) {
            if (IS_IPAD()) {
                [self.secondPlayerImage loadImageWithObject:game.savePitcher mugshot:NO];
            }
            [self hideSecond:NO];
            self.secondLabel.text = @"Save";
            self.secondPlayer.text = [NSString stringWithFormat:@"%@ (%@ ERA, %i-%i)",game.savePitcher.name,game.savePitcher.earnedRunAverage,[game.savePitcher.wins intValue],[game.savePitcher.losses intValue]];
        }
        if (![game.losingPitcher.name isEqualToString:@""]) {
            if (IS_IPAD() && [game.savePitcher.name isEqualToString:@""]) {
                [self.secondPlayerImage loadImageWithObject:game.losingPitcher mugshot:NO];
                [self hideSecond:NO];
                self.secondLabel.text = @"Loser";
                self.secondPlayer.text = [NSString stringWithFormat:@"%@ (%@ ERA, %i-%i)",game.losingPitcher.name,game.losingPitcher.earnedRunAverage, [game.losingPitcher.wins intValue],[game.losingPitcher.losses intValue]];
            } else {
                [self hideThird:NO];
                self.thirdLabel.text = @"Loser";
                self.thirdPlayer.text = [NSString stringWithFormat:@"%@ (%@ ERA, %i-%i)",game.losingPitcher.name,game.losingPitcher.earnedRunAverage, [game.losingPitcher.wins intValue],[game.losingPitcher.losses intValue]];
            }
        }
    }
}

-(void) buildBoxScore {
    Game *game = self.game;

    int inningsCount = [game.innings count];
    int fakeInningsCount = inningsCount;
    if (fakeInningsCount < 9) {
        fakeInningsCount = 9;
    }
    
    BOOL isNight = [NSDate isNight];
    for (int i=1;i <= 9; i++) {
        
        int reverse = fakeInningsCount-i;
        InningView *inningView = (InningView*)[self.boxScoreView viewWithTag:i];
        inningView.isNight = isNight;
        [inningView resetColors];
        if (inningsCount-1 < reverse) {
            [inningView emptyLabels];
            [inningView noActive];
            continue;
        }
        if (inningView == nil) {
            float offset = 225.0f - 25.0f*i;
            inningView = [[InningView alloc] initWithFrame:CGRectMake(offset, -4, 25, 41)];
            inningView.isNight = isNight;
            [inningView resetColors];
            inningView.tag = i;
        }
        Inning *anInning = [game.innings objectAtIndex:reverse];
        inningView.inningLabel.text = [NSString stringWithFormat:@"%d",anInning.inningNumber];
        inningView.away.text = anInning.away;
        inningView.home.text = anInning.home;
        if ([game.inning intValue] == anInning.inningNumber && game.statusCode == 1) {
            if ([game.inningState isEqualToString:@"Top"]) {
                [inningView awayActive];
            } else {
                //this will catch middle/bottom/end
                [inningView homeActive];
            }
        } else {
            [inningView noActive];
        }
        
        [self.boxScoreView addSubview:inningView];
    }
}

-(void) showPlay:(NSString*)play {
    if ([play length] == 0 && self.atBatsView == nil) {
        self.lastPlayView.hidden = YES;
    } else {
        UILabel *playLabel = (UILabel*)[self.lastPlayView viewWithTag:5];
        if (([play isEqualToString:playLabel.text] && !self.lastPlayView.hidden) || [play length] == 0) {
            //same play as last time around, bail out
            return;
        }
        playLabel.text = play;
        [UIView animateWithDuration:0.1f animations:^{
            playLabel.alpha = 0.0;
        }];
        float fontSize;
        if (IS_IPAD()) {
            fontSize = 13.0;
        } else {
            fontSize = 11.0;
        }
        UIFont *constraintFont = [UIFont systemFontOfSize:fontSize];
        CGSize constraintSize = CGSizeMake(playLabel.bounds.size.width, MAXFLOAT);
        CGSize labelSize = [playLabel.text sizeWithFont:constraintFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
        CGRect currentRect = playLabel.frame;
        currentRect.size.height = labelSize.height;
        
        CGRect lastPlayFrame = self.lastPlayView.frame;
        lastPlayFrame.size.height = labelSize.height+12;
        
        if (self.lastPlayView.hidden) {
            self.lastPlayView.hidden = NO;
            self.lastPlayView.alpha = 0.0;
            playLabel.frame = currentRect;
            self.lastPlayView.frame = lastPlayFrame;
            self.lastPlayView.transform = CGAffineTransformMakeScale(0.1,0.1);
            [UIView animateWithDuration:0.3f animations:^{
                playLabel.alpha = 1.0f;
                self.lastPlayView.transform = CGAffineTransformMakeScale(1.0,1.0);
                self.lastPlayView.alpha = 1.0f;
            }];
        } else {
            [UIView animateWithDuration:0.3f animations:^{
                playLabel.alpha = 1.0f;
                playLabel.frame = currentRect;
                self.lastPlayView.frame = lastPlayFrame;
            }];
        }
    }
}



-(void) setTimeBasedColorsAndBackground {
    UIColor *color;
    UIColor *linkColor;
    if ([NSDate isNight] && !self.isNightModeSet) {
        self.isNightModeSet = YES;
        self.nightBackground.hidden = NO;
        color = [UIColor whiteColor];
        linkColor = [UIColor colorWithRed:182/255.0f green:215/255.0f blue:255/255.0f alpha:1.0f];
        self.stadiumLights.alpha = 0.0;
        self.thirdFourthBackgroundBox.alpha = 0.0;
        self.stadiumLights.hidden = NO;
        self.thirdFourthBackgroundBox.hidden = NO;
        [self.awayPreviewRecapLink setTitleColor:linkColor forState:UIControlStateNormal];
        [self.homePreviewRecapLink setTitleColor:linkColor forState:UIControlStateNormal];
        self.firstLabel.textColor = color;
        self.firstPlayer.textColor = color;
        self.secondLabel.textColor = color;
        self.secondPlayer.textColor = color;
        self.thirdLabel.textColor = color;
        self.thirdPlayer.textColor = color;
        self.fourthLabel.textColor = color;
        self.fourthPlayer.textColor = color;
        self.awayTeamRuns.textColor = color;
        self.homeTeamRuns.textColor = color;
        self.statusOrTime.textColor = color;
        self.ballsStrikesOuts.textColor = color;
        self.awayTeamBoxRuns.textColor = color;
        self.homeTeamBoxRuns.textColor = color;
        self.awayTeamHits.textColor = color;
        self.homeTeamHits.textColor = color;
        self.awayTeamErrors.textColor = color;
        self.homeTeamErrors.textColor = color;
        self.homeTeamLabel.textColor = color;
        self.awayTeamLabel.textColor = color;
        self.awayRecord.textColor = color;
        self.homeRecord.textColor = color;
        self.venue.textColor = color;
        UILabel *runsLabel = (UILabel*)[self.boxScoreView viewWithTag:kBoxScoreRunsLabel];
        runsLabel.textColor = color;
        UILabel *hitsLabel = (UILabel*)[self.boxScoreView viewWithTag:kBoxScoreHitsLabel];
        hitsLabel.textColor = color;
        UILabel *errorsLabel = (UILabel*)[self.boxScoreView viewWithTag:kBoxScoreErrorsLabel];
        errorsLabel.textColor = color;
        NSTimeInterval duration = 30.0;
        if ([NSDate duskRange] > 10) {
            duration = 0.0;
        } else {
//            [TestFlight passCheckpoint:@"It's dusk! Shifting from day to night animated-like."];
            //[FlurryAnalytics logEvent:@"Dusk animation"];
//            [AdDashDelegate reportCustomEvent:@"Dusk animation" withDetail:@""];
        }
        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.dayBackground.alpha = 0.0;
            self.stadiumLights.alpha = 1.0;
            self.thirdFourthBackgroundBox.alpha = 0.2;
        } completion:^(BOOL finished) {
            self.dayBackground.hidden = YES;
        }];
    } else if (![NSDate isNight] && self.isNightModeSet) {
        self.isNightModeSet = NO;
        self.dayBackground.hidden = NO;
        color = [UIColor blackColor];
        linkColor = [UIColor colorWithRed:62/255.0f green:100/255.0f blue:147/255.0f alpha:1.0f];
        [self.awayPreviewRecapLink setTitleColor:linkColor forState:UIControlStateNormal];
        [self.homePreviewRecapLink setTitleColor:linkColor forState:UIControlStateNormal];
        self.firstLabel.textColor = color;
        self.firstPlayer.textColor = color;
        self.secondLabel.textColor = color;
        self.secondPlayer.textColor = color;
        self.thirdLabel.textColor = color;
        self.thirdPlayer.textColor = color;
        self.fourthLabel.textColor = color;
        self.fourthPlayer.textColor = color;
        self.awayTeamRuns.textColor = color;
        self.homeTeamRuns.textColor = color;
        self.statusOrTime.textColor = color;
        self.ballsStrikesOuts.textColor = color;
        self.awayTeamBoxRuns.textColor = color;
        self.homeTeamBoxRuns.textColor = color;
        self.awayTeamHits.textColor = color;
        self.homeTeamHits.textColor = color;
        self.awayTeamErrors.textColor = color;
        self.homeTeamErrors.textColor = color;
        self.homeTeamLabel.textColor = color;
        self.awayTeamLabel.textColor = color;
        self.awayRecord.textColor = color;
        self.homeRecord.textColor = color;
        self.venue.textColor = color;
        UILabel *runsLabel = (UILabel*)[self.boxScoreView viewWithTag:kBoxScoreRunsLabel];
        runsLabel.textColor = color;
        UILabel *hitsLabel = (UILabel*)[self.boxScoreView viewWithTag:kBoxScoreHitsLabel];
        hitsLabel.textColor = color;
        UILabel *errorsLabel = (UILabel*)[self.boxScoreView viewWithTag:kBoxScoreErrorsLabel];
        errorsLabel.textColor = color;
        NSTimeInterval duration = 30.0;
        if ([NSDate dawnRange] > 10) {
            duration = 0.0;
        } else {
//            [TestFlight passCheckpoint:@"It's dawn! Shifting from night to day animated-like."];
            //[FlurryAnalytics logEvent:@"Dawn animation"];
//            [AdDashDelegate reportCustomEvent:@"Dawn animation" withDetail:@""];
        }
        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.dayBackground.alpha = 1.0;
            self.stadiumLights.alpha = 0.0;
            self.thirdFourthBackgroundBox.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.stadiumLights.hidden = YES;
            self.thirdFourthBackgroundBox.hidden = YES;
            self.nightBackground.hidden = YES;
        }];
    }
}

-(void) addShadow:(UIImageView*)imageView {
    imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    imageView.layer.shadowOffset = CGSizeMake(0, 1);
    imageView.layer.shadowOpacity = 1;
    imageView.layer.shadowRadius = 1.0;
    imageView.clipsToBounds = NO;
}

-(void) setupPreviewRecapLinks {
    Game *game = self.game;
    if ([game beforeFirstPitch]) {
        if (![game.awayPreviewLink isEqualToString:@""]) {
            self.awayPreviewRecapLink.hidden = NO;
            [self.awayPreviewRecapLink setTitle:@"Away Preview" forState:UIControlStateNormal];
        } else {
            self.awayPreviewRecapLink.hidden = YES;
        }
        if (![game.awayPreviewLink isEqualToString:@""]) {
            self.homePreviewRecapLink.hidden = NO;
            [self.homePreviewRecapLink setTitle:@"Home Preview" forState:UIControlStateNormal];
        } else {
            self.homePreviewRecapLink.hidden = YES;
        }
    } else {
        if (![self.awayRecapUrl isEqualToString:@""] && self.awayRecapUrl != nil) {
            self.awayPreviewRecapLink.hidden = NO;
            [self.awayPreviewRecapLink setTitle:@"Away Recap" forState:UIControlStateNormal];
        } else {
            self.awayPreviewRecapLink.hidden = YES;
        }
        if (![self.homeRecapUrl isEqualToString:@""] && self.homeRecapUrl != nil) {
            self.homePreviewRecapLink.hidden = NO;
            [self.homePreviewRecapLink setTitle:@"Home Recap" forState:UIControlStateNormal];
        } else {
            self.homePreviewRecapLink.hidden = YES;
        }
    }
    
}


-(IBAction)followAwayLink:(id)sender {
    Game *game = self.game;
    NSString *urlPrefix;
    if (IS_IPAD()) {
        urlPrefix = @"http://mlb.mlb.com";
    } else {
        urlPrefix = @"http://m.mlb.com";        
    }
    if ([game beforeFirstPitch]) {
        NSString *previewLink;
        if (IS_IPAD()) {
            previewLink = game.awayPreviewLink;
        } else {
            previewLink = [NSString stringWithFormat:@"/%@",game.gameday];
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",urlPrefix,previewLink]]];
    } else {
        NSString *recapLink;
        if (IS_IPAD()) {
            recapLink = self.awayRecapUrl;
        } else {
            recapLink = [NSString stringWithFormat:@"/%@/recap/?team=away",game.gameday];
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",urlPrefix,recapLink]]];
    }
}


-(IBAction)followHomeLink:(id)sender {
    Game *game = self.game;
    NSString *urlPrefix;
    if (IS_IPAD()) {
        urlPrefix = @"http://mlb.mlb.com";
    } else {
        urlPrefix = @"http://m.mlb.com";        
    }
    if ([game beforeFirstPitch]) {
        NSString *previewLink;
        if (IS_IPAD()) {
            previewLink = game.homePreviewLink;
        } else {
            previewLink = [NSString stringWithFormat:@"/%@",game.gameday];
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",urlPrefix,previewLink]]];
    } else {
        NSString *recapLink;
        if (IS_IPAD()) {
            recapLink = self.homeRecapUrl;
        } else {
            recapLink = [NSString stringWithFormat:@"/%@/recap/?team=home",game.gameday];
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",urlPrefix,recapLink]]];
    }
}


-(void) linescoreLoaded:(NSString *)awayRecapLink homeLink:(NSString *)homeRecapLink {
    self.awayRecapUrl = awayRecapLink;
    self.homeRecapUrl = homeRecapLink;
    [self setupPreviewRecapLinks];
}

-(void) linescoreLoadFailed {
    //ignore it
}

-(void) atBatCountAndScoreLoaded:(NSDictionary *)count {
    self.scoreAndAtBatFromPlays = YES;
    DebugLog(@"writing balls/strikes/outs from plays XML");
    self.ballsStrikesOuts.text = [NSString stringWithFormat:@"%@-%@ %@ out",[count objectForKey:@"balls"],[count objectForKey:@"strikes"],[count objectForKey:@"outs"]];
}

@end
