//
//  PrecipView.m
//  Batter's Box
//
//  Created by Paul Kehrer on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PrecipView.h"
#import <QuartzCore/QuartzCore.h>
#import "stdlib.h"

@implementation PrecipView
{
    CAEmitterLayer* rainEmitter;
}

-(void)awakeFromNib
{
    //set ref to the layer
    rainEmitter = (CAEmitterLayer*)self.layer;
    rainEmitter.emitterPosition = CGPointMake(floor(self.frame.size.width/2)-20,self.frame.origin.y);
    rainEmitter.emitterSize = CGSizeMake(self.frame.size.width+40, 10);
    
    rainEmitter.emitterShape = kCAEmitterLayerRectangle;
}

+ (Class) layerClass
{
    //configure the UIView to have emitter layer
    return [CAEmitterLayer class];
}

-(void) makeItRain {
    [self clearSkies];
    self.hidden = NO;
    CAEmitterCell* rain = [CAEmitterCell emitterCell];
    rain.birthRate = 20;
    rain.lifetime = 6.0;
    rain.lifetimeRange = 0.0;
    rain.contents = (id)[[UIImage imageNamed:@"particle-raindrop.png"] CGImage];
    rain.velocity = 70;
    rain.velocityRange = 20;
    rain.alphaSpeed = 0.1;
    rain.alphaRange = 0.2;
    rain.scale = 0.4;
    rain.yAcceleration = 80;
    rain.xAcceleration = 10;
    rain.scaleRange = 0.1;
    rain.color = [[UIColor colorWithRed:0.9 green:0.9 blue:1.0 alpha:0.2] CGColor];
    rain.emissionRange = M_PI_4/8;
    rain.emissionLongitude = M_PI_2;
    
    [rain setName:@"rain"];
    
    rainEmitter.emitterCells = [NSArray arrayWithObject:rain];
}

-(void) makeItDrizzle {
    [self clearSkies];
    self.hidden = NO;
    CAEmitterCell* rain = [CAEmitterCell emitterCell];
    rain.birthRate = 10;
    rain.lifetime = 6.0;
    rain.lifetimeRange = 0.0;
    rain.contents = (id)[[UIImage imageNamed:@"particle-raindrop.png"] CGImage];
    rain.velocity = 70;
    rain.velocityRange = 20;
    rain.alphaSpeed = 0.1;
    rain.alphaRange = 0.2;
    rain.scale = 0.4;
    rain.yAcceleration = 80;
    rain.xAcceleration = 10;
    rain.scaleRange = 0.1;
    rain.color = [[UIColor colorWithRed:0.9 green:0.9 blue:1.0 alpha:0.2] CGColor];
    rain.emissionRange = M_PI_4/8;
    rain.emissionLongitude = M_PI_2;
    
    [rain setName:@"rain"];
    
    rainEmitter.emitterCells = [NSArray arrayWithObject:rain];
}


-(void) makeItBiblical {
    [self clearSkies];
    self.hidden = NO;
    CAEmitterCell* rain = [CAEmitterCell emitterCell];
    rain.birthRate = 200;
    rain.lifetime = 6.0;
    rain.lifetimeRange = 0.0;
    rain.contents = (id)[[UIImage imageNamed:@"particle-raindrop.png"] CGImage];
    rain.velocity = 320;
    rain.velocityRange = 20;
    rain.alphaSpeed = 0.1;
    rain.alphaRange = 0.2;
    rain.scale = 0.5;
    rain.yAcceleration = 80;
    rain.xAcceleration = 10;
    rain.scaleRange = 0.1;
    rain.color = [[UIColor colorWithRed:0.9 green:0.9 blue:1.0 alpha:0.2] CGColor];
    rain.emissionRange = M_PI_4/8;
    rain.emissionLongitude = M_PI_2;
    
    [rain setName:@"rain"];
    
    rainEmitter.emitterCells = [NSArray arrayWithObject:rain];
}



-(void) clearSkies {
    rainEmitter.emitterCells = nil;
    self.hidden = YES;
}

@end
