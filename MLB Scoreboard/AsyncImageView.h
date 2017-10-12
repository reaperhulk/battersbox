//
//  AsyncImageView.h
//  Batter's Box
//
//  Created by Paul Kehrer on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface AsyncImageView : UIImageView <NSURLConnectionDelegate>

@property (nonatomic,strong) NSURLConnection *asyncRequest;
@property (nonatomic,strong) NSMutableData *receivedData;
@property (nonatomic,strong) CAGradientLayer *maskLayer;
@property (nonatomic,strong) id playerObject;
@property NSInteger loadedId;
@property BOOL successful;

-(void) loadImageWithObject:(id)player mugshot:(BOOL)mugshot;
-(void) clearImage;

@end
