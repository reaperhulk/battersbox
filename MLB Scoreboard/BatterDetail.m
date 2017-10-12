//
//  BatterDetail.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BatterDetail.h"

@implementation BatterDetail

@synthesize firstName,lastName,jerseyNumber,height,weight,dateOfBirth,bats,throws,stats;

-(id) init {
    if ([super init]) {
        self.stats = [NSMutableArray array];
    }
    return self;
}

-(NSString*) fullName {
    return [NSString stringWithFormat:@"%@ %@",self.firstName,self.lastName];
}

-(NSString*) age {
    NSArray *separated = [self.dateOfBirth componentsSeparatedByString:@"/"];
    if (separated.count == 3) {
        NSDateComponents *dobComponents = [[NSDateComponents alloc] init];
        dobComponents.month = [[separated objectAtIndex:0] intValue];
        dobComponents.day = [[separated objectAtIndex:1] intValue];
        dobComponents.year = [[separated objectAtIndex:2] intValue];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *dob = [calendar dateFromComponents:dobComponents];
        NSUInteger unitFlags = NSYearCalendarUnit;
        NSDateComponents *components = [calendar components:unitFlags fromDate:dob toDate:[NSDate date] options:0];
        return [NSString stringWithFormat:@"%d",components.year];
    } else {
        return @"";
    }
}

@end
