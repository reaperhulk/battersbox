//
//  Inning.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Inning: NSObject

@property (nonatomic) int inningNumber;
@property (nonatomic,strong) NSString *home;
@property (nonatomic,strong) NSString *away;

@end