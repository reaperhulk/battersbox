//
//  Weather.h
//  Batter's Box
//
//  Created by Paul Kehrer on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Weather : NSObject

@property (nonatomic,strong) NSString *temperature;
@property (nonatomic,strong) NSString *condition;
@property (nonatomic,strong) NSString *wind;

@end
