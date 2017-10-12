//
//  BoxScoreParser.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"
#import "AFXMLRequestOperation.h"

@protocol BoxScoreDelegate
-(void) boxScoreLoaded:(NSMutableDictionary*)boxScore;
-(void) boxScoreLoadFailed;
@end

@interface BoxScoreParser : NSObject <NSXMLParserDelegate>

@property (nonatomic,strong) NSMutableDictionary *boxScore;
@property (nonatomic,strong) NSMutableDictionary *parserMetadata;
@property (nonatomic,strong) AFXMLRequestOperation *afOperation;
@property (nonatomic,weak) id<BoxScoreDelegate>delegate;
@property (nonatomic,strong) Game *game;
@property BOOL isGameInfo;

- (id) initWithDelegate:(id<BoxScoreDelegate>)pDelegate game:(Game*)pGame;

-(void) cancel;
@end
