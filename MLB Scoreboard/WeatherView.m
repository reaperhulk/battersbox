//
//  WeatherView.m
//  Batter's Box
//
//  Created by Paul Kehrer on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeatherView.h"
#import <QuartzCore/QuartzCore.h>
#import "stdlib.h"

@implementation WeatherView

@synthesize currentWeather,precipView;

-(void)awakeFromNib
{
    //set ref to the layer
}

-(IBAction)tapToRain {
    [self makeItRain];
}

-(void) makeItRain {
    [self resetWeather];
    [self makeItCloudy:@"storm-cloud"];
    [self.precipView makeItRain];
}

-(void) makeItDrizzle {
    [self resetWeather];
    [self makeItCloudy:@"cloud"];
    [self.precipView makeItDrizzle];
}


-(void) makeItBiblical {
    [self resetWeather];
    [self makeItCloudy:@"storm-cloud"];
    [self.precipView makeItBiblical];
}

-(void) clearWeather {
    self.currentWeather = nil;
    [self resetWeather];
}

-(void) resetWeather {
    [self.precipView clearSkies];
    for (UIView *view in self.subviews) {
        [view.layer removeAllAnimations];
        [view removeFromSuperview];
    }
}

-(void) reloadWeather {
    [self resetWeather];
    [self playGod];
    
}

-(void) makeItSunny {
    [self resetWeather];
}

-(void) makeItPartlyCloudy {
    [self resetWeather];
    CGPoint point;
    point.x = -50;
    point.y = (arc4random() % 200) - 100.0;
    if (!IS_IPAD()) {
        point.x = -13;
        point.y = floor(point.y/2.0);
    }
    [self addCloud:@"cloud" atPoint:point animate:YES repeat:NO delay:0];
    point.x = 500;
    point.y = (arc4random() % 150);
    if (!IS_IPAD()) {
        point.x = 250;
        point.y = floor(point.y/2.0);
    }
    [self addCloud:@"cloud" atPoint:point animate:YES repeat:NO delay:0];
    [self animatedPartlyCloudy];
}

-(void) animatedPartlyCloudy {
    CGPoint point = CGPointMake(-450, 0);
    point.y = (arc4random() % 50) - 100.0;
    if (!IS_IPAD()) {
        point.x = -225;
        point.y = floor(point.y/2.0);
    }
    float delay = 90.0;
    [self addCloud:@"cloud" atPoint:point animate:YES repeat:YES delay:delay];
    CGPoint point2 = CGPointMake(-450, 0);
    point2.y = (arc4random() % 100) + 50.0;
    if (!IS_IPAD()) {
        point2.x = -225;
        point2.y = floor(point2.y/2.0);
    }
    delay = 180.0;
    [self addCloud:@"cloud" atPoint:point2 animate:YES repeat:YES delay:delay];
}


-(void) makeItCloudy:(NSString*)type {
    [self resetWeather];
    CGPoint point;
    if (IS_IPAD()) {
        point.x = -100;
        point.y = -80;
        [self addCloud:type atPoint:point animate:NO repeat:NO delay:0];
        point.x = 200;
        point.y = -70;
        [self addCloud:type atPoint:point animate:NO repeat:NO delay:0];
        point.x = 50;
        point.y = -70;
        [self addCloud:type atPoint:point animate:NO repeat:NO delay:0];
        point.x = 350;
        point.y = -80;
        [self addCloud:type atPoint:point animate:NO repeat:NO delay:0];
        point.x = 500;
        point.y = -70;
        [self addCloud:type atPoint:point animate:NO repeat:NO delay:0];
        point.x = -50;
        point.y = -150;
        [self addCloud:type atPoint:point animate:NO repeat:NO delay:0];
        point.x = 150;
        point.y = -150;
        [self addCloud:type atPoint:point animate:NO repeat:NO delay:0];
        point.x = 300;
        point.y = -150;
        [self addCloud:type atPoint:point animate:NO repeat:NO delay:0];
    } else {
        point.x = -50;
        point.y = -40;
        [self addCloud:type atPoint:point animate:NO repeat:NO delay:0];
        point.x = 100;
        point.y = -35;
        [self addCloud:type atPoint:point animate:NO repeat:NO delay:0];
        point.x = 25;
        point.y = -35;
        [self addCloud:type atPoint:point animate:NO repeat:NO delay:0];
        point.x = 175;
        point.y = -40;
        [self addCloud:type atPoint:point animate:NO repeat:NO delay:0];
        point.x = 250;
        point.y = -35;
        [self addCloud:type atPoint:point animate:NO repeat:NO delay:0];
        point.x = -25;
        point.y = -75;
        [self addCloud:type atPoint:point animate:NO repeat:NO delay:0];
        point.x = 150;
        point.y = -75;
        [self addCloud:type atPoint:point animate:NO repeat:NO delay:0];
        point.x = 150;
        point.y = -75;
        [self addCloud:type atPoint:point animate:NO repeat:NO delay:0];
    }
}

-(void) addCloud:(NSString*)type atPoint:(CGPoint)point animate:(BOOL)animate repeat:(BOOL)repeat delay:(float)delay {
    if (!IS_IPAD()) {
        type = [type stringByAppendingString:@"-iphone"];
    }
    UIImageView *cloud = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",type]]];
    cloud.alpha = 0.0;
    cloud.frame = CGRectMake(point.x,point.y,cloud.frame.size.width,cloud.frame.size.height);
    [self addSubview:cloud];
    [UIView animateWithDuration:0.5f animations:^{
        cloud.alpha = 1.0;
    }];
    if (animate) {
        [UIView animateWithDuration:240.0 delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
            if (repeat) {
                [UIView setAnimationRepeatCount:FLT_MAX];
            }
            CGRect newRect = cloud.frame;
            if (IS_IPAD()) {
                newRect.origin.x += 1200;
            } else {
                newRect.origin.x += 600;
            }
            cloud.frame = newRect;
        } completion:^(BOOL finished) {
        }];
    }
}


-(void) weatherLoaded:(Weather *)weather {
    DebugLog(@"%@",weather.condition);
    if (![weather.condition isEqualToString:self.currentWeather.condition]) {
        self.currentWeather = weather;
        [self playGod];
    }
}

-(void) playGod {
    if ([self.currentWeather.condition isEqualToString:@"Sunny"] || [self.currentWeather.condition isEqualToString:@"Clear"]) {
        [self makeItSunny];
    } else if ([self.currentWeather.condition isEqualToString:@"Roof Closed"] || [self.currentWeather.condition isEqualToString:@"Dome"]) {
        [self makeItSunny];
    } else if ([self.currentWeather.condition isEqualToString:@"Partly Cloudy"]) {
        [self makeItPartlyCloudy];
    } else if ([self.currentWeather.condition isEqualToString:@"Cloudy"] || [self.currentWeather.condition isEqualToString:@"Overcast"]) {
        [self makeItCloudy:@"cloud"];
    } else if ([self.currentWeather.condition isEqualToString:@"Rain"]) {
        [self makeItRain];
    } else if ([self.currentWeather.condition isEqualToString:@"Drizzle"]) {
        [self makeItDrizzle];
    } else {
        //don't know what it is, make it cloudy.
        [self makeItCloudy:@"cloud"];
    }
}



@end
