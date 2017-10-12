//
//  AtBatCell.h
//  Batter's Box
//
//  Created by Paul Kehrer on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AtBatCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UILabel *pitcherBatter;
@property (nonatomic,strong) IBOutlet UILabel *result;
@property (nonatomic,strong) IBOutlet UILabel *pitchesThrown;

@end
