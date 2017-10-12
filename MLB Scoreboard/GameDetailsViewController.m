//
//  GameDetailsViewController.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameDetailsViewController.h"
#import "Inning.h"
#import "InningView.h"
#import "BoxScoreParser.h"
#import "EventLogParser.h"
#import "GamesViewController.h"
#import "BattingStatsViewController.h"
#import "PitchingStatsViewController.h"
#import "PlayByPlayViewController.h"
#import "Game.h"
#import "GameTabBarViewController.h"
#import <QuartzCore/CALayer.h>
#import "NSDate+DateIsToday.h"


@interface GameDetailsViewController ()

@end

@implementation GameDetailsViewController

@synthesize togglePitchAndWebViewButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

/*- (void)loadView
{
    // If you create your views manually, you MUST override this method and use it to create your views.
    // If you use Interface Builder to create your views, then you must NOT override this method.
}*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    GameTabBarViewController *tabController = (GameTabBarViewController*)self.tabBarController;
    tabController.singleGameDataController.pitchDelegate = self.pitcherGridView; //can't do this in tabcontroller where we should because the object doesn't exist yet. annoying
    tabController.singleGameDataController.homeRunDelegate = self.homeRunLayer;
    tabController.singleGameDataController.weatherDelegate = self.weatherLayer;
    
    //handle postpone weather here (this is for the case where plays.xml is not available so it can't load weather that way)
    if ([self.game.reason isEqualToString:@"Rain"]) {
        [self.weatherLayer makeItRain];
    } else if ([self.game.reason isEqualToString:@"Inclement Weather"]) {
        [self.weatherLayer makeItBiblical];
    }

    self.menOnBase.doubleSize = YES;
    [self.gameInfoWebView loadHTMLString:@"<style>@-webkit-keyframes spinner {  0% { opacity:1; }  100% { opacity:.1; }}div {  top:50%;  left:50%;  width:32px;  height:0;  margin:-16px 0 0 -16px;  padding-top:32px;  position:absolute;  overflow:hidden;}div * {  position:absolute;  width:25%;  height:25%;  background:rgb(93, 108, 127);  -webkit-border-radius:16px;  -moz-border-radius:16px;  border-radius:16px;  -webkit-animation:spinner 1s linear infinite;  -webkit-box-shadow:0 1px 0 rgba(0, 0, 0, .7) inset, 0 1px 0 rgba(255, 255, 255, .7);}div :nth-child(1) {  top:0;  right:12px;  -webkit-animation-delay:.125s;}div :nth-child(2) {  top:4px;  right:4px;  -webkit-animation-delay:.25s;}div :nth-child(3) {  top:12px;  right:0;  -webkit-animation-delay:.375s;}div :nth-child(4) {  bottom:4px;  right:4px;  -webkit-animation-delay:.5s;}div :nth-child(5) {  bottom:0;  right:12px;  -webkit-animation-delay:.625s;}div :nth-child(6) {  bottom:4px;  left:4px;  -webkit-animation-delay:.75s;}div :nth-child(7) {  bottom:12px;  left:0;  -webkit-animation-delay:.875s;}div :nth-child(8) {  top:4px;  left:4px;  -webkit-animation-delay:.975s;}</style><div id=\"spinner\">    <span></span>    <span></span>    <span></span>    <span></span>    <span></span>    <span></span>    <span></span>    <span></span></div>" baseURL:[NSURL URLWithString:@"file:///"]];
    //turn off scroll bounce for this webview
    for (id subview in self.gameInfoWebView.subviews)
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
            ((UIScrollView *)subview).bounces = NO;

    [self buildViewData];
    
//    [TestFlight passCheckpoint:@"Game Detail Viewed (iPhone)"];
//    [AdDashDelegate reportCustomEvent:@"Game Detail" withDetail:self.game.gameday];
    ////[FlurryAnalytics logEvent:@"Game Detail" withParameters:[NSDictionary dictionaryWithObject:self.game.gameday forKey:@"game"]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.title = @"Game Details";
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
    GameTabBarViewController *tabController = (GameTabBarViewController*)self.tabBarController;
    return [[GamesDataController sharedSingleton] gameForGameday:tabController.singleGameDataController.gameday];
}

-(void) buildViewData {
    [super buildViewData];
    if (self.game.statusCode == 1) {
        if (self.togglePitchAndWebViewButton.hidden) {
            [self togglePitchAndWebView:nil];
        }
        self.togglePitchAndWebViewButton.hidden = NO;
    } else {
        self.togglePitchAndWebViewButton.hidden = YES;
        //make sure the webview is visible...
        if (self.gameInfoWebView.alpha == 0) {
            [self togglePitchAndWebView:nil];
        }
    }
    //fetch linescore for recap links if the game is complete
    //we do this in this class rather than the super because the singlegamedatacontroller is in a diff place on ipad/iphone
    if (self.game.statusCode == 2) {
        GameTabBarViewController *tabController = (GameTabBarViewController*)self.tabBarController;
        tabController.singleGameDataController.lineDelegate = self;
        [tabController.singleGameDataController getLinescore];
    }
}


-(IBAction)togglePitchAndWebView:(id)sender {
//    [TestFlight passCheckpoint:@"Toggled between pitch/webview"];
    ////[FlurryAnalytics logEvent:@"Toggle Pitch/Webview"];
//    [AdDashDelegate reportCustomEvent:@"Toggle Pitch/Webview" withDetail:@""];
    UIView *hideObject;
    UIView *showObject;
    self.togglePitchAndWebViewButton.enabled = NO;
    if (self.pitcherGridView.alpha == 0) {
        [self.togglePitchAndWebViewButton setImage:[UIImage imageNamed:@"icon-data.png"] forState:UIControlStateNormal];
        showObject = self.pitcherGridView;
        hideObject = self.gameInfoWebView;
    } else {
        [self.togglePitchAndWebViewButton setImage:[UIImage imageNamed:@"icon-baseball.png"] forState:UIControlStateNormal];
        showObject = self.gameInfoWebView;
        hideObject = self.pitcherGridView;
    }
    hideObject.alpha = 1.0f;
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        hideObject.alpha = 0.0f;
        CGRect newFrame = hideObject.frame;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenHeight = screenRect.size.height;
        //subtract 49 for tab bar, subtract 64 for status bar + nav bar
        newFrame.origin.y = screenHeight - 49 - 64 + newFrame.size.height;
        DebugLog(@"%f",newFrame.origin.y);
        hideObject.frame = newFrame;
    } completion:^(BOOL finished) {
        hideObject.hidden = YES;
        self.togglePitchAndWebViewButton.enabled = YES;
    }];
    showObject.alpha = 0.0f;
    showObject.hidden = NO;
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        showObject.alpha = 1.0f;
        CGRect newFrame = showObject.frame;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenHeight = screenRect.size.height;
        newFrame.origin.y = screenHeight - 49 - 64 - newFrame.size.height;
        showObject.frame = newFrame;
    } completion:^(BOOL finished) {
        self.togglePitchAndWebViewButton.enabled = YES;
    }];
}

-(void) boxScoreLoaded:(NSDictionary *)boxScore {
    NSString *fontColor = @"color:#000;";
    NSString *backgroundColor = @"background-color:rgba(255,255,255,0.4);";
    if ([NSDate isNight]) {
        fontColor = @"color:#fff;";
        backgroundColor = @"background-color:rgba(0,0,0,0.4);";
    }
    NSString *scrollY = [self.gameInfoWebView stringByEvaluatingJavaScriptFromString:@"window.scrollY"];
    NSString *html = [[boxScore objectForKey:@"gameInfo"] stringByReplacingOccurrencesOfString:@"<br/>" withString:@"</p><p>"];
    html = [NSString stringWithFormat:@"<style>* { -webkit-user-select: none; } p { margin-top:10px 0; }</style><div style=\"font-size:11px;font-family:'Helvetica';padding:3px;border-radius:5px;%@%@\"><p>%@</p></div><script>window.scrollTo(0,%@);</script>",fontColor,backgroundColor,html,scrollY];
    [self.gameInfoWebView loadHTMLString:html baseURL:[NSURL URLWithString:@"file:///"]];
}

-(void) boxScoreLoadFailed {
    //check if we've loaded something successfully previously
    BattingStatsViewController *battingStatsController = [[self.tabBarController viewControllers] objectAtIndex:2];
    if (battingStatsController.batters == nil) {
        NSString *fontColor = @"color:#000;";
        NSString *backgroundColor = @"background-color:rgba(255,255,255,0.4);";
        if ([NSDate isNight]) {
            fontColor = @"color:#fff;";
            backgroundColor = @"background-color:rgba(0,0,0,0.4);";
        }
        NSString *html = [NSString stringWithFormat:@"<style>* { -webkit-user-select: none; }</style><div style=\"font-size:11px;font-family:'Helvetica';text-align:center;padding:3px;border-radius:5px;%@%@\">No data available at this time.</div>",fontColor,backgroundColor];
        [self.gameInfoWebView loadHTMLString:html baseURL:[NSURL URLWithString:@"file:///"]];
    }
    
}

-(void) loadGamesData {
    [self performSelectorOnMainThread:@selector(buildViewData) withObject:nil waitUntilDone:NO];
}

-(void) failedLoad {
    //do nothing (don't remove this method, protocol requires it)
}

@end
