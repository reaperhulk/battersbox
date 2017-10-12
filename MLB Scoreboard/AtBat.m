//
//  AtBat.m
//  Batter's Box
//
//  Created by Paul Kehrer on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AtBat.h"

@implementation AtBat

@synthesize num,pitches,batterId,batterStand,pitcherId,pitcherThrow,des,event,outs,batter,pitcher;

-(id) init {
    self = [super init];
    if (self) {
        self.pitches = [NSMutableArray array];
    }
    return self;
}

-(void) addPitch:(Pitch*) pitch {
    [self.pitches addObject:pitch];
}

@end
