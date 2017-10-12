//
//  PitcherDetailCell.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PitcherDetailCell.h"

@implementation PitcherDetailCell

@synthesize name,strikeOuts,baseOnBalls,homeRuns,average,atBats;


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
