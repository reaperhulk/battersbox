//
//  MenOnBase.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MenOnBase.h"

@implementation MenOnBase

@synthesize doubleSize;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) setMenOnBase:(NSInteger)num {
    if (self.doubleSize) {
        if (IS_IPAD()) {
            self.image = [UIImage imageNamed:[NSString stringWithFormat:@"bases-big-ipad-%d.png",num]];
        } else {
            self.image = [UIImage imageNamed:[NSString stringWithFormat:@"bases-big-%d.png",num]];        
        }
    } else {
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"bases-%d.png",num]];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
