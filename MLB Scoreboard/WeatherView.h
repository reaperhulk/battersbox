//
//  WeatherView.h
//  Batter's Box
//
//  Created by Paul Kehrer on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PitchParser.h"
#import "Weather.h"
#import "PrecipView.h"

@interface WeatherView : UIView <WeatherDelegate>

@property (nonatomic,strong) Weather* currentWeather;
@property (nonatomic,strong) IBOutlet PrecipView *precipView;

-(void) clearWeather;
-(void) reloadWeather;
-(IBAction)tapToRain;
-(void) makeItRain;
-(void) makeItBiblical;

@end
