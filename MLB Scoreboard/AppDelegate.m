//
//  AppDelegate.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "TutorialViewPhone.h"
#import <QuartzCore/QuartzCore.h>
#import "DefaultViewController.h"
#import "GamesViewController.h"
#import "DetailViewController.h"
#import "GameTabBarViewController.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "NSDate+DateIsToday.h"
#import "NotificationView.h"
//#import "Crittercism.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize locationManager;
@synthesize preferences;
@synthesize notificationQueue;
@synthesize notificationActive,shouldShowNotifications;
@synthesize lastActive;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [TestFlight takeOff:@"58289614160245a03b13a922b7beaca3_MTAyMzM"];
    //[Crittercism initWithAppID: @"4fcc16e1eeaf413053000007" andKey:@"vbxftdqloun8umpoelptzwq2iehz" andSecret:@"tgny1xfjup8weriv9kzhqjvdcy34eull"];
    ////[FlurryAnalytics startSession:@"341X2Q6XMWLPEKBGI5Q8"];
//    [AdDashDelegate setAdvertiserIdentifier:@"6bd50c40-6950-11e1-9f33-c938e9104dee" andPrivateKey:@"74fb6b40-87e1-11e1-8579-1959572deb89"];
    self.shouldShowNotifications = YES;
    self.notificationQueue = [NSMutableArray array];
    self.preferences = [NSMutableDictionary dictionary];
    [self loadPrefs];

    //make AFNetworking calls always show activity indicator
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"tutorialHasRun"] == nil) {
        [TutorialViewPhone runTutorial];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"tutorialHasRun"];
    }
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    //[Crittercism leaveBreadcrumb:@"entering background"];
    self.lastActive = [NSDate date];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    if (IS_IPAD()) {
        DefaultViewController *defaultViewController = (DefaultViewController*)self.window.rootViewController;
        UINavigationController *nav = (UINavigationController *)[defaultViewController.viewControllers objectAtIndex:0];
        GamesViewController *gamesViewController = (GamesViewController *)[nav.viewControllers objectAtIndex:0];
        [gamesViewController.gamesController stop];
        DetailViewController *detail;
        for (id controller in defaultViewController.viewControllers) {
            if ([controller isKindOfClass:[DefaultViewController class]]) {
                detail = (DetailViewController*)controller;
            }
        }
        if ([detail respondsToSelector:@selector(singleGameDataController)]) {
            [detail.singleGameDataController stop];
        }
    } else {
        UINavigationController *nav = (UINavigationController*)self.window.rootViewController;
        GamesViewController *gamesViewController = (GamesViewController *)[nav.viewControllers objectAtIndex:0];
        [gamesViewController.gamesController stop];
        for (id controller in nav.viewControllers) {
            if ([controller isKindOfClass:[GameTabBarViewController class]]) {
                GameTabBarViewController *gameTab = (GameTabBarViewController*)controller;
                [gameTab.singleGameDataController stop];
            }
        }
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //[Crittercism leaveBreadcrumb:@"entering foreground"];
    [self loadPrefs];
    DebugLog(@"last active is %@",self.lastActive);
    DebugLog(@"time since now %f",-1*[self.lastActive timeIntervalSinceNow]);
    if (-1*[self.lastActive timeIntervalSinceNow] > 120) {
        self.shouldShowNotifications = NO;
        DebugLog(@"disabling next notification set since it's been > 120 seconds since last active");
    }
    BOOL reloadToday = NO;
    if (-1*[self.lastActive timeIntervalSinceNow] > 21600) {
        reloadToday = YES;
    }
    self.lastActive = nil;
    if (IS_IPAD()) {
        DefaultViewController *defaultViewController = (DefaultViewController*)self.window.rootViewController;
        UINavigationController *nav = (UINavigationController *)[defaultViewController.viewControllers objectAtIndex:0];
        GamesViewController *gamesViewController = (GamesViewController *)[nav.viewControllers objectAtIndex:0];
        DetailViewController *detail;
        for (id controller in defaultViewController.viewControllers) {
            if ([controller isKindOfClass:[DefaultViewController class]]) {
                detail = (DetailViewController*)controller;
            }
        }
        if (reloadToday) {
            gamesViewController.gamesController.scheduleDate = [NSDate dateTodayish];
            [gamesViewController showSpinnerView];
            [detail noGameSelected];
        }
        [gamesViewController.gamesController restart:reloadToday];
        [detail.singleGameDataController start];
    } else {
        UINavigationController *nav = (UINavigationController*)self.window.rootViewController;
        GamesViewController *gamesViewController = (GamesViewController *)[nav.viewControllers objectAtIndex:0];
        GameTabBarViewController *gameTab;
        for (id controller in nav.viewControllers) {
            if ([controller isKindOfClass:[GameTabBarViewController class]]) {
                gameTab = (GameTabBarViewController*)controller;
                [gameTab.singleGameDataController start];
            }
        }
        if (reloadToday) {
            if (gameTab) {
                [gameTab.navigationController popViewControllerAnimated:YES];
            }
            gamesViewController.gamesController.scheduleDate = [NSDate dateTodayish];
            [gamesViewController showSpinnerView];
        }
        [gamesViewController.gamesController restart:reloadToday];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //restart the animations (which complete instantly when backgrounding)
    if (IS_IPAD()) {
        DefaultViewController *defaultViewController = (DefaultViewController*)self.window.rootViewController;
        DetailViewController *detailViewController;
        for (id controller in defaultViewController.viewControllers) {
            if ([controller isKindOfClass:[DefaultViewController class]]) {
                detailViewController = (DetailViewController*)controller;
            }
        }
        if (detailViewController.seatsNoGameImage.hidden == YES) {
            [detailViewController.weatherLayer reloadWeather];
        }
    } else {
        UINavigationController *nav = (UINavigationController*)self.window.rootViewController;
        GameTabBarViewController *gameTab;
        for (id controller in nav.viewControllers) {
            if ([controller isKindOfClass:[GameTabBarViewController class]]) {
                gameTab = (GameTabBarViewController*)controller;
            }
        }
        if (gameTab) {
            GameDetailsViewController *detail = (GameDetailsViewController*)[gameTab.viewControllers objectAtIndex:0];
            [detail.weatherLayer reloadWeather];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)queueNotificationForDisplay:(UILocalNotification*)notification {
    [self.notificationQueue addObject:notification];
    if (self.notificationActive) {
        return;
    } else {
        [self showNotifications];
    }
}

- (void)showNotifications {
    if ([self.notificationQueue count] == 0) {
        return;
    }
    self.notificationActive = YES;

    UILocalNotification *notification = [self.notificationQueue objectAtIndex:0];
    [self.notificationQueue removeObjectAtIndex:0];
    DebugLog(@"notification: %@ %@",notification.alertAction,notification.alertBody);
    NotificationView *view = [[NSBundle.mainBundle loadNibNamed:@"Notification" owner:self options:nil] objectAtIndex:0];
    view.userInteractionEnabled = YES;
    view.gameday = notification.alertLaunchImage;
    view.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:view action:@selector(goToGame)];
    [view addGestureRecognizer:gesture];
    view.frame = CGRectMake(0, -44, view.frame.size.width, view.frame.size.height);
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowOpacity = 0.8;
    view.layer.shadowRadius = 2.0;
    view.clipsToBounds = NO;

    view.teamScoresLabel.text = notification.alertAction;
    view.lastPlayLabel.text = notification.alertBody;
    [self.window.rootViewController.view addSubview:view];
    //on iphone we're adding to the uinavigationcontroller, on ipad to the uisplitviewcontroller (defaultviewcontroller)
    //for whatever reason this means we need to offset by 20px less for iPhone than iPad (size of a status bar)
    int statusBarOffset = 20;
    if (IS_IPAD()) {
        statusBarOffset = 0;
    }
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        view.frame = CGRectMake(0, 0+statusBarOffset, 320, 44);
    } completion:^(BOOL finished) {
        [NSTimer scheduledTimerWithTimeInterval:4.5f target:self selector:@selector(hideNotification:) userInfo:view repeats:NO]; 
    }];
}

-(void) hideNotification:(NSTimer*)timer {
    UIView *view = (UIView*)timer.userInfo;
    int statusBarOffset = 20;
    if (IS_IPAD()) {
        statusBarOffset = 0;
    }
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        view.frame = CGRectMake(0, -44+statusBarOffset, 320, 44);
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
        self.notificationActive = NO;
        [self showNotifications];
    }];
}


-(void) loadPrefs {
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *favoriteTeam = [[NSUserDefaults standardUserDefaults] objectForKey:@"favoriteTeam"];
    if (favoriteTeam == nil) {
        favoriteTeam = @"None";
    }
    [self.preferences setObject:favoriteTeam forKey:@"favoriteTeam"];

    NSString *secondFavoriteTeam = [[NSUserDefaults standardUserDefaults] objectForKey:@"secondFavoriteTeam"];
    if (secondFavoriteTeam == nil) {
        secondFavoriteTeam = @"None";
    }
    [self.preferences setObject:secondFavoriteTeam forKey:@"secondFavoriteTeam"];

    NSString *thirdFavoriteTeam = [[NSUserDefaults standardUserDefaults] objectForKey:@"thirdFavoriteTeam"];
    if (thirdFavoriteTeam == nil) {
        thirdFavoriteTeam = @"None";
    }
    [self.preferences setObject:thirdFavoriteTeam forKey:@"thirdFavoriteTeam"];

    NSString *refreshInterval = [[NSUserDefaults standardUserDefaults] objectForKey:@"refreshInterval"];
    if (refreshInterval == nil) {
        refreshInterval = @"15";
    }
    [self.preferences setObject:refreshInterval forKey:@"refreshInterval"];

    NSString *showScoreAlerts = [[NSUserDefaults standardUserDefaults] objectForKey:@"showScoreAlerts"];
    if (showScoreAlerts == nil) {
        showScoreAlerts = @"None";
    }
    [self.preferences setObject:showScoreAlerts forKey:@"showScoreAlerts"];

    NSString *disableAutoLock = [[NSUserDefaults standardUserDefaults] objectForKey:@"disableAutoLock"];
    BOOL autoLock = NO;
    if (disableAutoLock == nil) {
        autoLock = YES;
    } else {
        autoLock = [disableAutoLock boolValue];
    }
    if (autoLock) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    } else {
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
    [self.preferences setObject:[NSNumber numberWithBool:autoLock] forKey:@"disableAutoLock"];
}

@end
