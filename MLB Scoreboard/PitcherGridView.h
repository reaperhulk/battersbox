//
//  PitcherGridView.h
//  Batter's Box
//
//  Created by Paul Kehrer on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pitch.h"
#import "SingleGameDataController.h"

@interface PitcherGridView : UIView <PitchParserDelegate>

@property (nonatomic,strong) IBOutlet UIImageView *gridImage;
@property (nonatomic,strong) IBOutlet UIImageView *batterToken;
@property (nonatomic,strong) NSTimer *closeTimer;

@property NSInteger atBatNum;
@property BOOL pastAtBat;
@property (nonatomic,strong) NSMutableArray *pitchesAdded;

-(void) resetPitches;
-(void) resetPitchesAndRemoveDataView;

@end
