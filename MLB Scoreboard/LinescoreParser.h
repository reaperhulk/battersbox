//
//  LinescoreParser.h
//  Batter's Box
//
//  Created by Paul Kehrer on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFXMLRequestOperation.h"
#import "Game.h"

@protocol LinescoreParserDelegate

-(void) linescoreLoaded:(NSString*)awayRecapLink homeLink:(NSString*)homeRecapLink;
-(void) linescoreLoadFailed;
@end


@interface LinescoreParser : NSObject <NSXMLParserDelegate>

@property (nonatomic,strong) AFXMLRequestOperation *afOperation;
@property (nonatomic,weak) id<LinescoreParserDelegate> delegate;
@property (nonatomic,strong) Game *game;

-(id) initWithDelegate:(id<LinescoreParserDelegate>)pDelegate game:(Game*)pGame;
-(void) cancel;

@end
