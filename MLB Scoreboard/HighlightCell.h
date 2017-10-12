//
//  HighlightCell.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighlightCell : UITableViewCell

@property (nonatomic,retain) IBOutlet UILabel *headline;
@property (nonatomic,retain) IBOutlet UILabel *duration;
@property (nonatomic,retain) IBOutlet UIImageView *thumb;


@end
