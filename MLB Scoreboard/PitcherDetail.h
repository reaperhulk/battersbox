//
//  PitcherDetail.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PitcherDetail : NSObject

@property (nonatomic,strong) NSString *firstName;
@property (nonatomic,strong) NSString *lastName;

@property (nonatomic,strong) NSString *jerseyNumber;
@property (nonatomic,strong) NSString *height;
@property (nonatomic,strong) NSString *weight;
@property (nonatomic,strong) NSString *dateOfBirth;
@property (nonatomic,strong) NSString *throws;
@property (nonatomic,strong) NSMutableArray *stats;

-(id) init;
-(NSString*) fullName;
-(NSString*) age;

@end
