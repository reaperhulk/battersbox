//
//  AsyncImageView.m
//  Batter's Box
//
//  Created by Paul Kehrer on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AsyncImageView.h"
#import "Pitcher.h"
#import "Batter.h"

#define kSpinnerViewTag 1

@implementation AsyncImageView

@synthesize asyncRequest,receivedData,maskLayer;
@synthesize successful,loadedId,playerObject;

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.receivedData = [NSMutableData data];
        self.maskLayer = [CAGradientLayer layer];
        
        maskLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1.0 alpha:1.0].CGColor, (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor, nil];
        maskLayer.locations = [NSArray arrayWithObjects: [NSNumber numberWithFloat:0.6], [NSNumber numberWithFloat:1.0], nil];
        
        maskLayer.bounds = self.bounds;
        maskLayer.anchorPoint = CGPointZero;
        
        self.layer.mask = maskLayer;
        self.layer.cornerRadius = 12.0;
        self.layer.masksToBounds = YES;
    }
    return self;
}

-(void) loadImageWithObject:(id)player mugshot:(BOOL)mugshot {
    self.playerObject = player;
    NSInteger playerId;
    if ([player isKindOfClass:[Pitcher class]]) {
        playerId = [((Pitcher*)player).pitcherId integerValue];
    } else if ([player isKindOfClass:[Batter class]]) {
        playerId = [((Batter*)player).batterId integerValue];
    } else {
        DebugLog(@"this should not happen!");
        return;
    }
    if (playerId == self.loadedId && self.successful == YES) {
        //this has already been loaded
        //NOTE: if you load a 525x330 and then try to load the same image as a mugshot this will improperly cache
        //so don't do that. why would you even WANT to do that? that's just stupid for a single instance of an AsyncImageView
        return;
    }
    self.successful = NO;
    self.loadedId = playerId;
    
    [self startSpinner];
    if (self.asyncRequest != nil) {
        [self.asyncRequest cancel];
        self.asyncRequest = nil;
    }
    NSURL *url;
    if (mugshot) {
        self.layer.cornerRadius = 0;
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://mlb.mlb.com/images/players/mugshot/ph_%i.jpg",playerId]];
    } else {
        self.layer.cornerRadius = 12.0;
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://mlb.mlb.com/images/players/525x330/%i.jpg",playerId]];
    }
    DebugLog(@"loading image: %@",url);

    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10];
    self.asyncRequest = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

-(void) clearImage {
    self.playerObject = nil;
    self.loadedId = 0;
    CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
    crossFade.duration = 0.3;
    crossFade.fromValue = (id)self.image.CGImage;
    crossFade.toValue = (id)[UIImage imageNamed:@"black-player-placeholder.png"].CGImage;
    self.image = [UIImage imageNamed:@"black-player-placeholder.png"];
}

-(void) startSpinner {
    CGRect parentFrame = self.frame;
    if (![self viewWithTag:kSpinnerViewTag]) {
        UIImageView *spinnerView = [[UIImageView alloc] initWithFrame:CGRectMake(parentFrame.size.width/2-15, parentFrame.size.height/2-15, 30, 30)];
        spinnerView.tag = kSpinnerViewTag;
        [self addSubview:spinnerView];
        spinnerView.animationDuration = 1.0f;
        spinnerView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"spinner-0.png"],[UIImage imageNamed:@"spinner-1.png"],[UIImage imageNamed:@"spinner-2.png"],[UIImage imageNamed:@"spinner-3.png"],[UIImage imageNamed:@"spinner-4.png"],[UIImage imageNamed:@"spinner-5.png"],[UIImage imageNamed:@"spinner-6.png"],[UIImage imageNamed:@"spinner-7.png"],[UIImage imageNamed:@"spinner-8.png"],[UIImage imageNamed:@"spinner-9.png"],[UIImage imageNamed:@"spinner-10.png"],[UIImage imageNamed:@"spinner-11.png"], nil];
        spinnerView.contentMode = UIViewContentModeCenter;
        [spinnerView startAnimating];
    }
}

-(void) stopSpinner {
    UIImageView *spinnerView = (UIImageView*)[self viewWithTag:kSpinnerViewTag];
    [spinnerView removeFromSuperview];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //handle the error
    self.asyncRequest = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self stopSpinner];
    UIImage *receivedImage = [[UIImage alloc] initWithData:self.receivedData];
    if (receivedImage) {
        self.successful = YES;
        CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
        crossFade.duration = 0.3;
        crossFade.fromValue = (id)self.image.CGImage;
        crossFade.toValue = (id)receivedImage.CGImage;
        [self.layer addAnimation:crossFade forKey:@"animateContents"];

        self.image = receivedImage;
    } else {
        self.successful = NO;
        self.image = [UIImage imageNamed:@"black-player-placeholder.png"];
    }
    self.asyncRequest = nil;
}

@end
