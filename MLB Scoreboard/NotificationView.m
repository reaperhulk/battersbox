//
//  NotificationView.m
//  Batter's Box
//
//  Created by Paul Kehrer on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NotificationView.h"
#import "AppDelegate.h"
#import "GamesViewController.h"
#import "DefaultViewController.h"
#import "GameTabBarViewController.h"

@implementation NotificationView

@synthesize gameday,teamScoresLabel,lastPlayLabel;

-(void) goToGame {
    GamesViewController *gamesViewController;
    if (IS_IPAD()) {
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        DefaultViewController *defaultViewController = (DefaultViewController*)delegate.window.rootViewController;
        UINavigationController *nav = (UINavigationController *)[defaultViewController.viewControllers objectAtIndex:0];
        gamesViewController = (GamesViewController *)[nav.viewControllers objectAtIndex:0];
        NSIndexPath *index = [gamesViewController getIndexForGameday:self.gameday];
        if (index) {
            [gamesViewController.tableView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionNone];
            [gamesViewController tableView:gamesViewController.tableView didSelectRowAtIndexPath:index];
        }
    } else {
        UINavigationController *nav = (UINavigationController*)self.window.rootViewController;
        gamesViewController = (GamesViewController *)[nav.viewControllers objectAtIndex:0];
        NSIndexPath *index = [gamesViewController getIndexForGameday:self.gameday];
        if (index) {
            GameTabBarViewController *gameTab;
            for (id controller in nav.viewControllers) {
                if ([controller isKindOfClass:[GameTabBarViewController class]]) {
                    gameTab = (GameTabBarViewController*)controller;
                }
            }
            if (gameTab) {
                [gameTab.navigationController popViewControllerAnimated:NO];
            }
            [gamesViewController performSegueWithIdentifier:@"GameDetailsSegue" sender:index];
        }

    }
}



@end
