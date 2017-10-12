//
//  DetailViewController.m
//  Batter's Box
//
//  Created by Paul Kehrer on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "Game.h"
#import <QuartzCore/CALayer.h>
#import "InningView.h"
#import "Inning.h"
#import "BattingStatsViewController.h"
#import "BatterViewController.h"
#import "PitchingStatsViewController.h"
#import "PitcherViewController.h"
#import "PlayByPlayViewController.h"
#import "NSDate+DateIsToday.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

@synthesize singleGameDataController,playerPopoverController;
@synthesize primaryView,showHideAtBats;

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

    self.menOnBase.doubleSize = YES;
    self.seatsNoGameImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"seats.jpg"]];
    self.seatsNoGameImage.userInteractionEnabled = YES;
    [self.primaryView addSubview:self.seatsNoGameImage];
    self.seatsNoGameImage.hidden = NO;
    self.thirdFourthBackgroundBox.layer.cornerRadius = 7.0f;
    
    //turn off scroll bounce for this webview
    for (id subview in self.gameInfoWebView.subviews)
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
            ((UIScrollView *)subview).bounces = NO;
    
    [self.firstPlayerImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPlayerDetails:)]];
    [self.secondPlayerImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPlayerDetails:)]];
//    [self.thirdPlayer addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOnDeckInHoleDetails:)]];
//    [self.fourthPlayer addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOnDeckInHoleDetails:)]];
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

-(Game*) game {
    return [[GamesDataController sharedSingleton] gameForGameday:self.singleGameDataController.gameday];
}

-(void) buildViewData {
    [super buildViewData];
    if (self.game.statusCode == 1) {
        [self.firstPlayerImage loadImageWithObject:self.game.currentPitcher mugshot:NO];
        [self.secondPlayerImage loadImageWithObject:self.game.currentBatter mugshot:NO];
    } else if (self.game.statusCode == 2) {
        self.singleGameDataController.lineDelegate = self;
        [self.singleGameDataController getLinescore];
    }
}

-(void) setupWithGameday:(NSString *)gameday {
//    [self scrollUp]; //this appears to be too expensive on iPad (3rd gen). Noticeable lag
    if (self.atBatsView) {
        [self showAtBats];
    }
    [self.homeRunLayer resetFireworks];
    [self.weatherLayer clearWeather];
    self.homeRecapUrl = nil;
    self.awayRecapUrl = nil;
    
    if (self.singleGameDataController) {
        [self.singleGameDataController stop];
        self.singleGameDataController = nil;
    }
    [self.firstPlayerImage clearImage];
    [self.secondPlayerImage clearImage];
    [self.gameInfoWebView loadHTMLString:@"<style>@-webkit-keyframes spinner {  0% { opacity:1; }  100% { opacity:.1; }}div {  top:50%;  left:50%;  width:32px;  height:0;  margin:-16px 0 0 -16px;  padding-top:32px;  position:absolute;  overflow:hidden;}div * {  position:absolute;  width:25%;  height:25%;  background:rgb(93, 108, 127);  -webkit-border-radius:16px;  -moz-border-radius:16px;  border-radius:16px;  -webkit-animation:spinner 1s linear infinite;  -webkit-box-shadow:0 1px 0 rgba(0, 0, 0, .7) inset, 0 1px 0 rgba(255, 255, 255, .7);}div :nth-child(1) {  top:0;  right:12px;  -webkit-animation-delay:.125s;}div :nth-child(2) {  top:4px;  right:4px;  -webkit-animation-delay:.25s;}div :nth-child(3) {  top:12px;  right:0;  -webkit-animation-delay:.375s;}div :nth-child(4) {  bottom:4px;  right:4px;  -webkit-animation-delay:.5s;}div :nth-child(5) {  bottom:0;  right:12px;  -webkit-animation-delay:.625s;}div :nth-child(6) {  bottom:4px;  left:4px;  -webkit-animation-delay:.75s;}div :nth-child(7) {  bottom:12px;  left:0;  -webkit-animation-delay:.875s;}div :nth-child(8) {  top:4px;  left:4px;  -webkit-animation-delay:.975s;}</style><div id=\"spinner\">    <span></span>    <span></span>    <span></span>    <span></span>    <span></span>    <span></span>    <span></span>    <span></span></div>" baseURL:[NSURL URLWithString:@"file:///"]];
    self.scoreAndAtBatFromPlays = NO; //this should be set to no until we get data back from the atBatAndScoreDelegate
    [self performSelectorOnMainThread:@selector(buildViewData) withObject:nil waitUntilDone:NO];
    self.singleGameDataController = [[SingleGameDataController alloc] initWithGameday:gameday];
    //add delegates
    self.singleGameDataController.detailsBoxDelegate = self;
    self.singleGameDataController.pitchDelegate = self.pitcherGridView;
    self.singleGameDataController.homeRunDelegate = self.homeRunLayer;
    self.singleGameDataController.weatherDelegate = self.weatherLayer;
    self.singleGameDataController.atBatAndScoreDelegate = self;
    [self.singleGameDataController start];
    //add self to the delegate list for the main scoreboard
    [GamesDataController sharedSingleton].detailsDelegate = self;
    //reset update schedule to match with new data
    [[GamesDataController sharedSingleton] scheduleUpdate];
    
    [self.pitcherGridView resetPitchesAndRemoveDataView];
    
    if (!self.seatsNoGameImage.hidden) {
        [UIView animateWithDuration:0.3f animations:^{
            self.seatsNoGameImage.alpha = 0.0f;
        } completion:^(BOOL finished) {
            if (finished) {
                self.seatsNoGameImage.hidden = YES;
            }
        }];
    }
    
    //handle postpone weather here (this is for the case where plays.xml is not available so it can't load weather that way)
    if ([self.game.reason isEqualToString:@"Rain"]) {
        [self.weatherLayer makeItRain];
    } else if ([self.game.reason isEqualToString:@"Inclement Weather"]) {
        [self.weatherLayer makeItBiblical];
    }
    
//    if (self.game.statusCode == 0) {
//        self.showHideAtBats.hidden = YES;
//    } else {
//        self.showHideAtBats.hidden = NO;
//    }
}

//This method is too expensive on iPad (3rd gen). CALayer renderInContext: is apparently very slow with retina resolutions
-(void) scrollUp {
    if ([[UIScreen mainScreen] scale] == 2.0f) {
        //retina context
        UIGraphicsBeginImageContextWithOptions(self.primaryView.bounds.size, NO, 2.0f);
    } else {
        //non-retina context
        UIGraphicsBeginImageContext(self.primaryView.bounds.size);
    }
    [self.primaryView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView *imageView = [[UIImageView alloc] initWithImage:viewImage];
    UIGraphicsEndImageContext();
    imageView.frame = CGRectMake(0,0,imageView.frame.size.width,imageView.frame.size.height);
    [self.view addSubview:imageView];
    CGRect oldFrame = self.primaryView.frame;
    CGRect newFrame = self.primaryView.frame;
    newFrame.origin.y = 748;
    self.primaryView.frame = newFrame;
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.primaryView.frame = oldFrame;
        imageView.frame = CGRectMake(0,-748,imageView.frame.size.width,imageView.frame.size.height);
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
    }];
}



-(void) noGameSelected {
    if (self.seatsNoGameImage.hidden || self.seatsNoGameImage.alpha != 1.0) {
        self.seatsNoGameImage.hidden = NO;
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.seatsNoGameImage.alpha = 1.0f;
        } completion:^(BOOL finished) {
        }];
    }
    [GamesDataController sharedSingleton].detailsDelegate = nil;
    [self.singleGameDataController stop];
    self.singleGameDataController = nil;
}

-(IBAction) pitchingStatsPopover {
}

-(IBAction) battingStatsPopover {
}

-(IBAction) playByPlayPopover {
}

-(IBAction) highlightsPopover {
}

-(void) showPlayerDetails:(UITapGestureRecognizer*)tap {
    DebugLog(@"%@",self.playerPopoverController);
    AsyncImageView *asyncImageView = (AsyncImageView*)tap.view;
    if (asyncImageView.playerObject != 0) {
        UIViewController *popoverContent;
        if ([asyncImageView.playerObject isKindOfClass:[Pitcher class]]) {
            popoverContent = [self.storyboard instantiateViewControllerWithIdentifier:@"pitcherDetails"];
            ((PitcherViewController*)popoverContent).pitcher = asyncImageView.playerObject;
        } else if ([asyncImageView.playerObject isKindOfClass:[Batter class]]) {
            popoverContent = [self.storyboard instantiateViewControllerWithIdentifier:@"batterDetails"];
            ((BatterViewController*)popoverContent).batter = asyncImageView.playerObject;
        } else {
            DebugLog(@"this should not happen!");
            return;
        }
        popoverContent.contentSizeForViewInPopover = CGSizeMake(320, 420);
        self.playerPopoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        [self.playerPopoverController presentPopoverFromRect:asyncImageView.frame inView:self.primaryView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

    }
}

//-(void) showOnDeckInHoleDetails:(UITapGestureRecognizer*)tap {
//    if (self.game.statusCode == 1) {
//        BatterViewController *popoverContent = (BatterViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"batterDetails"];
//        if (tap.view == self.thirdPlayer) {
//            popoverContent.batter = self.game.currentOnDeck;
//        } else if (tap.view == self.fourthPlayer) {
//            popoverContent.batter = self.game.currentInHole;
//        }
//        popoverContent.contentSizeForViewInPopover = CGSizeMake(320, 420);
//        self.playerPopoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
//        [self.playerPopoverController presentPopoverFromRect:tap.view.frame inView:self.primaryView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//    }
//}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"BattingStatsSegue"]) {
        BattingStatsViewController* battingStatsController = (BattingStatsViewController*)((UINavigationController*)segue.destinationViewController).topViewController;
        if (self.singleGameDataController.boxScoreData != nil) {
            [battingStatsController boxScoreLoaded:self.singleGameDataController.boxScoreData];
        }
    } else if ([[segue identifier] isEqualToString:@"PitchingStatsSegue"]) {
        PitchingStatsViewController* pitchingStatsController = (PitchingStatsViewController*)((UINavigationController*)segue.destinationViewController).topViewController;
        if (self.singleGameDataController.boxScoreData != nil) {
            [pitchingStatsController boxScoreLoaded:self.singleGameDataController.boxScoreData];
        }
    } else if ([[segue identifier] isEqualToString:@"PlayByPlaySegue"]) {
        PlayByPlayViewController* playByPlayController = (PlayByPlayViewController*)segue.destinationViewController;
        if (self.singleGameDataController.eventLogData != nil && self.singleGameDataController.eventLogSectionNames != nil) {
            [playByPlayController eventLogLoaded:self.singleGameDataController.eventLogData sectionNames:self.singleGameDataController.eventLogSectionNames];
        }
    }
}

-(void) boxScoreLoaded:(NSDictionary *)boxScore {
    NSString *fontColor = @"color:#000;";
    if ([NSDate isNight]) {
        fontColor = @"color:#fff;";
    }
    NSString *scrollY = [self.gameInfoWebView stringByEvaluatingJavaScriptFromString:@"window.scrollY"];
    NSString *html = [[boxScore objectForKey:@"gameInfo"] stringByReplacingOccurrencesOfString:@"<br/>" withString:@"</p><p>"];
    html = [NSString stringWithFormat:@"<style>* { -webkit-user-select: none; } p { margin-top:10px 0; }</style><div style=\"font-size:11px;font-family:'Helvetica';%@\"><p>%@</p></div><script>window.scrollTo(0,%@);</script>",fontColor,html,scrollY];
    [self.gameInfoWebView loadHTMLString:html baseURL:[NSURL URLWithString:@"file:///"]];
}

-(void) boxScoreLoadFailed {
    //check if we've loaded something successfully previously
    if (self.singleGameDataController.boxScoreData == nil) {
        NSString *fontColor = @"color:#000;";
        if ([NSDate isNight]) {
            fontColor = @"color:#fff;";
        }
        NSString *html = [NSString stringWithFormat:@"<style>* { -webkit-user-select: none; }</style><div style=\"font-size:11px;font-family:'Helvetica';text-align:center;%@\">No data available at this time.</div>",fontColor];
        [self.gameInfoWebView loadHTMLString:html baseURL:[NSURL URLWithString:@"file:///"]];
    }
    
}

-(void) loadGamesData {
    [self buildViewData];
}

-(void) failedLoad {

}

-(IBAction)showAtBats {
    if (!self.atBatsView) {
        self.atBatsView = [[NSBundle.mainBundle loadNibNamed:@"AtBatsView" owner:self options:nil] objectAtIndex:0];
        [self.atBatsView loadData];
        CGRect initialFrame = self.atBatsView.frame;
        initialFrame.origin.x = -151;
        initialFrame.origin.y = 375;
        self.atBatsView.frame = initialFrame;
        [self.view addSubview:self.atBatsView];
    }
    CGRect frame = self.atBatsView.frame;
    BOOL willHide = NO;
    if (frame.origin.x == -151) {
        frame.origin.x = 0;
    } else {
        frame.origin.x = -151;
    }
    if (frame.origin.x == -151 && self.game.statusCode != 1) {
        willHide = YES;
    }
    CGRect buttonFrame = self.showHideAtBats.frame;
    if (buttonFrame.origin.x == -1) {
        buttonFrame.origin.x = 150;
    } else {
        buttonFrame.origin.x = -1;
    }
    if (willHide) {
        [UIView animateWithDuration:0.5f animations:^{
            self.pitcherGridView.alpha = 0.0;
            self.lastPlayView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.pitcherGridView.hidden = YES;
            self.pitcherGridView.alpha = 1.0;
            self.lastPlayView.hidden = YES;
            self.lastPlayView.alpha = 1.0;
        }];
    }
    [UIView animateWithDuration:0.5f animations:^{
        self.atBatsView.frame = frame;
        self.showHideAtBats.frame = buttonFrame;
    } completion:^(BOOL finished) {
        if (frame.origin.x == -151) {
            [self.atBatsView removeFromSuperview];
            self.atBatsView = nil;
        }
    }];
}

@end
