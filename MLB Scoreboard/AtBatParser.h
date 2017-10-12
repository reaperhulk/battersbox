//
//  AtBatParser.h
//  Batter's Box
//
//  Created by Paul Kehrer on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFXMLRequestOperation.h"
#import "Game.h"

@protocol AtBatDelegate
-(void)atBatsLoaded:(NSMutableDictionary*)atBats sectionNames:(NSMutableArray*)sectionNames;
-(void)atBatsLoadFailed;
@end


@interface AtBatParser : NSObject <NSXMLParserDelegate>

@property (nonatomic,strong) NSMutableDictionary *batterCount;
@property (nonatomic,strong) NSMutableDictionary *atBats;
@property (nonatomic,strong) NSMutableDictionary *parseMetadata;
@property (nonatomic,strong) NSMutableArray *sectionNames;
@property (nonatomic,strong) AFXMLRequestOperation *afOperation;
@property (nonatomic,weak) id<AtBatDelegate> delegate;
@property (nonatomic,strong) Game *game;

- (id) initWithDelegate:(id<AtBatDelegate>)pDelegate game:(Game *)pGame;

-(void) cancel;

@end
