//
//  NSDate+DateIsToday.h
//  Batter's Box
//
//  Created by Paul Kehrer on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (DateIsToday)
-(BOOL) isTodayish;
-(BOOL) isSameDay:(NSDate*) date;
+(NSDate*) dateTodayish;
+(BOOL) isNight;
+(int) duskRange;
+(int) dawnRange;
@end
