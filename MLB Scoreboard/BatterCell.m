//
//  BatterCell.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BatterCell.h"

@implementation BatterCell

@synthesize batterName;
@synthesize atBats;
@synthesize hits;
@synthesize homeRuns;
@synthesize runs;
@synthesize runsBattedIn;
@synthesize baseOnBalls;
@synthesize strikeOuts;
@synthesize leftOnBase;
@synthesize stolenBases;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
