//
//  NSArray+Reverse.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Reverse)

-(NSArray*) reversedArray;

@end

@interface NSMutableArray (Reverse)

-(void) reverse;

@end
