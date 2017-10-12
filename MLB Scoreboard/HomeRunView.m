//
//  HomeRunView.m
//  Batter's Box
//
//  Created by Paul Kehrer on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeRunView.h"
#import <QuartzCore/QuartzCore.h>

@implementation HomeRunView
{
    CAEmitterLayer* mortar;
}

@synthesize homeRunForAtBat,homeRunTimer;

-(void) awakeFromNib {
	//Create the root layer
	mortar = (CAEmitterLayer*)self.layer;
	
	//Set the root layer's attributes
	//CGColorRef color = [UIColor clearColor].CGColor;
    //self.layer.backgroundColor = color;
	
	if (IS_IPAD()) {
        mortar.emitterPosition = CGPointMake(320, 430);        
    } else if([ [ UIScreen mainScreen ] bounds ].size.height == 568) {
        //iphone 5 casing (should refactor this to use autoresizing masks probably)
        mortar.emitterPosition = CGPointMake(160, 333);
    } else {
        mortar.emitterPosition = CGPointMake(160, 250);
    }
	mortar.renderMode = kCAEmitterLayerAdditive;
    mortar.speed = 80/100.0;
    
    self.homeRunForAtBat = 0;
}

+ (Class) layerClass
{
    //configure the UIView to have emitter layer
    return [CAEmitterLayer class];
}

-(void) startFireworks {
    mortar.birthRate = 1;
    [self setupFireworks];
}

-(void) startGrandSlamFireworks {
    mortar.birthRate = 5;
    [self setupFireworks];    
}

-(void) setupFireworks {
    //Invisible particle representing the rocket before the explosion
	CAEmitterCell *rocket = [CAEmitterCell emitterCell];
	rocket.emissionLongitude = M_PI / 2;
	rocket.emissionLatitude = 0;
	rocket.lifetime = 1.6;
	rocket.birthRate = 1;
    if (IS_IPAD()) {
        rocket.velocity = -300;
        rocket.yAcceleration = 200;
    } else {
        rocket.velocity = -200;
        rocket.yAcceleration = 150;
    }
	rocket.velocityRange = 100;
	rocket.emissionRange = M_PI / 4;
	rocket.color = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0].CGColor;
	rocket.redRange = 0.5;
	rocket.greenRange = 0.5;
	rocket.blueRange = 0.5;
	
	//Name the cell so that it can be animated later using keypath
	[rocket setName:@"rocket"];
	
	//Flare particles emitted from the rocket as it flys
	CAEmitterCell *flare = [CAEmitterCell emitterCell];
    flare.contents = (id)[[UIImage imageNamed:@"tspark.png"] CGImage];
	flare.emissionLongitude = (4 * M_PI) / 2;
	flare.scale = 0.2;
	flare.velocity = -100;
	flare.birthRate = 200;
	flare.lifetime = 0.3;
	flare.yAcceleration = 200;
	flare.emissionRange = M_PI / 7;
	flare.alphaSpeed = -3.0;
	flare.scaleSpeed = -0.2;
	flare.scaleRange = 0.1;
	flare.beginTime = 0.01;
	flare.duration = 0.5;
	
	//The particles that make up the explosion
	CAEmitterCell *firework = [CAEmitterCell emitterCell];
    firework.contents = (id)[[UIImage imageNamed:@"particle-firework.png"] CGImage];
	firework.birthRate = 4000;
	firework.scale = 0.45;
	firework.velocity = -170;
	firework.lifetime = 1.3;
	firework.alphaSpeed = -0.6;
	firework.yAcceleration = 80;
	firework.beginTime = 1.5;
	firework.duration = 0.2;
	firework.emissionRange = 2 * M_PI;
	firework.scaleSpeed = -0.3;
	
	//Name the cell so that it can be animated later using keypath
	[firework setName:@"firework"];
	
	rocket.emitterCells = [NSArray arrayWithObjects:flare, firework, nil];
	mortar.emitterCells = [NSArray arrayWithObjects:rocket, nil];	
}

-(IBAction) triggerFireworks {
    [self resetFireworks];
    [self startFireworks];
    self.homeRunTimer = [NSTimer scheduledTimerWithTimeInterval:8.0 target:self selector:@selector(stopFireworks) userInfo:nil repeats:NO];
}

-(IBAction) triggerGrandSlamFireworks {
    [self resetFireworks];
    [self startGrandSlamFireworks];
    self.homeRunTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(stopFireworks) userInfo:nil repeats:NO];
}

-(void) stopFireworks {
    mortar.birthRate = 0;
    [self killTimer];
}

-(void) resetFireworks {
    self.homeRunForAtBat = 0;
    mortar.emitterCells = nil;
    [self killTimer];
}

-(void) killTimer {
    if (self.homeRunTimer != nil) {
        [self.homeRunTimer invalidate];
        self.homeRunTimer = nil;
    }
}

-(void) homeRunHit:(NSInteger)atBatNum {
    if (atBatNum != self.homeRunForAtBat) {
//        [TestFlight passCheckpoint:@"Fireworks!"];
        //[FlurryAnalytics logEvent:@"Fireworks!"];
//        [AdDashDelegate reportCustomEvent:@"Fireworks!" withDetail:@""];
        [self triggerFireworks];
        self.homeRunForAtBat = atBatNum;
    } else {
        DebugLog(@"already fired fireworks for that at bat");
    }
}

@end
