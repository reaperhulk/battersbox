//
//  BoxScoreColumn.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BoxScoreColumn.h"

@implementation BoxScoreColumn

@synthesize away,home,inningNumber;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.inningNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 22, 19)];
        self.inningNumber.font = [UIFont boldSystemFontOfSize:12.0f];
        self.inningNumber.backgroundColor = [UIColor clearColor];
        self.inningNumber.textAlignment = UITextAlignmentCenter;
        self.away = [[UILabel alloc] initWithFrame:CGRectMake(0,19, 22, 20)];
        self.away.backgroundColor = [UIColor clearColor];
        self.away.textAlignment = UITextAlignmentCenter;
        self.away.font = [UIFont systemFontOfSize:12.0f];
        self.home = [[UILabel alloc] initWithFrame:CGRectMake(0,40, 22, 20)];
        self.home.backgroundColor = [UIColor clearColor];
        self.home.font = [UIFont systemFontOfSize:12.0f];
        self.home.textAlignment = UITextAlignmentCenter;
        [self addSubview:self.inningNumber];
        [self addSubview:self.away];
        [self addSubview:self.home];
    }
    return self;
}

-(void) emptyLabels {
    self.inningNumber.text = @"";
    self.away.text = @"";
    self.home.text = @"";
}

-(void) homeActive {
    self.away.backgroundColor = [UIColor clearColor];
    self.home.backgroundColor = [UIColor colorWithRed:224/255.0f green:224/255.0f blue:224/255.0f alpha:1.0f];
}

-(void) awayActive {
    self.home.backgroundColor = [UIColor clearColor];
    self.away.backgroundColor = [UIColor colorWithRed:224/255.0f green:224/255.0f blue:224/255.0f alpha:1.0f];    
}

-(void) noActive {
    self.home.backgroundColor = [UIColor clearColor];
    self.away.backgroundColor = [UIColor clearColor];
}

@end
