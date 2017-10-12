//
//  InningView.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InningView.h"

@implementation InningView

@synthesize inningLabel;
@synthesize away;
@synthesize home;
@synthesize isNight;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.inningLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 25, 14)];
        self.inningLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        self.inningLabel.backgroundColor = [UIColor clearColor];
        self.inningLabel.textAlignment = UITextAlignmentCenter;
        self.away = [[UILabel alloc] initWithFrame:CGRectMake(0,13, 25, 20)];
        self.away.backgroundColor = [UIColor clearColor];
        self.away.textAlignment = UITextAlignmentCenter;
        self.away.font = [UIFont systemFontOfSize:12.0f];
        self.home = [[UILabel alloc] initWithFrame:CGRectMake(0,34, 25, 20)];
        self.home.backgroundColor = [UIColor clearColor];
        self.home.font = [UIFont systemFontOfSize:12.0f];
        self.home.textAlignment = UITextAlignmentCenter;
        [self addSubview:inningLabel];
        [self addSubview:away];
        [self addSubview:home];
    }
    return self;
}

-(void) resetColors {
    if (self.isNight) {
        self.inningLabel.textColor = [UIColor whiteColor];
        self.away.textColor = [UIColor whiteColor];
        self.home.textColor = [UIColor whiteColor];
    } else {
        self.inningLabel.textColor = [UIColor blackColor];
        self.away.textColor = [UIColor blackColor];
        self.home.textColor = [UIColor blackColor];        
    }
}

-(void) emptyLabels {
    [self resetColors];
    self.inningLabel.text = @"";
    self.away.text = @"";
    self.home.text = @"";
}

-(void) homeActive {
    self.away.backgroundColor = [UIColor clearColor];
    self.home.backgroundColor = [UIColor colorWithRed:224/255.0f green:224/255.0f blue:224/255.0f alpha:1.0f];
    [self resetColors];
    if (self.isNight) {
        self.home.textColor = [UIColor blackColor];
    }
}

-(void) awayActive {
    self.home.backgroundColor = [UIColor clearColor];
    self.away.backgroundColor = [UIColor colorWithRed:224/255.0f green:224/255.0f blue:224/255.0f alpha:1.0f];    
    [self resetColors];
    if (self.isNight) {
        self.away.textColor = [UIColor blackColor];
    }
}

-(void) noActive {
    [self resetColors];
    self.home.backgroundColor = [UIColor clearColor];
    self.away.backgroundColor = [UIColor clearColor];
}

@end
