//
//  NotificationView.h
//  Batter's Box
//
//  Created by Paul Kehrer on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationView : UIView

@property (nonatomic,strong) NSString *gameday;
@property (nonatomic,strong) IBOutlet UILabel *teamScoresLabel;
@property (nonatomic,strong) IBOutlet UILabel *lastPlayLabel;

-(void) goToGame;

@end
