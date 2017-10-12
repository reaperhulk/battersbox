//
//  NSDate+DateIsToday.m
//  Batter's Box
//
//  Created by Paul Kehrer on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSDate+DateIsToday.h"

@implementation NSDate (DateIsToday)

/* true for same day or up to 5 hours into the next day */
-(BOOL) isTodayish {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comp = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate:[NSDate date]];
    if (comp.hour <= 5) {
        comp.day -= 1;
    }
    NSDateComponents *today = [[NSDateComponents alloc] init];
    today.year = comp.year;
    today.day = comp.day;
    today.month = comp.month;
    NSDateComponents *other = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
    NSDate *otherDate = [cal dateFromComponents:other];
    NSDate *todayDate = [cal dateFromComponents:today];
    return [todayDate isEqualToDate:otherDate];
}

-(BOOL) isSameDay:(NSDate*) date {
    NSDateComponents *comp1 = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
    NSDateComponents *comp2 = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    return (comp1.year == comp2.year && comp1.month == comp2.month && comp1.day == comp2.day);
}

+(BOOL) isNight {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comp = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date]];
    return (comp.hour >= 21 || comp.hour <= 6);
}

+(int) duskRange {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comp = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date]];
    if (comp.hour == 21 && comp.minute < 10) {
        return comp.minute;
    } else {
        return 100;
    }
}

+(int) dawnRange {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comp = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date]];
    if (comp.hour == 6 && comp.minute < 10) {
        return comp.minute;
    } else {
        return 100;
    }
}


+(NSDate*) dateTodayish {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comp = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate:[NSDate date]];
    if (comp.hour <= 5) {
        comp.day -= 1;
    }
    NSDateComponents *today = [[NSDateComponents alloc] init];
    today.year = comp.year;
    today.day = comp.day;
    today.month = comp.month;
    return [cal dateFromComponents:today];
}
@end
