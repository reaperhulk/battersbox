//
//  EventLogParser.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"
#import "AFXMLRequestOperation.h"

@protocol EventLogDelegate
-(void)eventLogLoaded:(NSMutableDictionary*)events sectionNames:(NSMutableArray*)sectionNames;
-(void)eventLogLoadFailed;
@end

@interface EventLogParser : NSObject <NSXMLParserDelegate>

@property (nonatomic,strong) NSMutableDictionary *events;
@property (nonatomic,strong) NSMutableDictionary *parseMetadata;
@property (nonatomic,strong) NSMutableArray *sectionNames;
@property (nonatomic,strong) AFXMLRequestOperation *afOperation;
@property (nonatomic,weak) id<EventLogDelegate>delegate;
@property (nonatomic,strong) Game *game;

- (id) initWithDelegate:(id<EventLogDelegate>)pDelegate game:(Game *)pGame;

-(void) cancel;
@end
