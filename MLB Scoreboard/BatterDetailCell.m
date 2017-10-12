//
//  BatterDetailCell.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BatterDetailCell.h"

@implementation BatterDetailCell

@synthesize name,atBats,average,homeRuns,runsBattedIn,ops;


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
