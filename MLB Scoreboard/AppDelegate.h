//
//  AppDelegate.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) CLLocationManager *locationManager;
@property (strong,nonatomic) NSMutableDictionary *preferences;
@property (strong,nonatomic) NSMutableArray *notificationQueue;
@property BOOL notificationActive;
@property BOOL shouldShowNotifications;
@property (strong,nonatomic) NSDate *lastActive;

-(void) loadPrefs;
-(void) queueNotificationForDisplay:(UILocalNotification*)notification;

@end
