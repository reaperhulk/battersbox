//
//  PitchMarker.h
//  Batter's Box
//
//  Created by Paul Kehrer on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pitch.h"

@interface PitchMarker : UIImageView

@property (nonatomic,strong) UILabel *pitchNumLabel;
@property (nonatomic,strong) Pitch *pitchData;

-(void) setPitchType:(NSString*)pitchType ballOrStrike:(NSString*)ballOrStrike number:(NSInteger)number;
+(PitchMarker*) markerFromPitch:(Pitch*)pitch withFrame:(CGRect)frame number:(NSInteger)number;

@end
