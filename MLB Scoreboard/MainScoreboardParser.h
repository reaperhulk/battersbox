//
//  MainScoreboardParser.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFXMLRequestOperation.h"

@protocol MainScoreboardDelegate <NSObject>
-(void) saveArray:(NSMutableArray*)games dict:(NSMutableDictionary*)dict;
-(void) failedLoad;
-(void) failedTodayLoad;
-(void) saveTodayArray:(NSMutableArray*)games dict:(NSMutableDictionary*)dict;
@end

@interface MainScoreboardParser : NSObject <NSXMLParserDelegate>

@property (nonatomic,strong) NSMutableArray *games;
@property (nonatomic,strong) NSMutableDictionary *gamesDict;
@property (nonatomic,strong) NSDateComponents *dateComponents;
@property (nonatomic,strong) AFXMLRequestOperation *afOperation;
@property (nonatomic,weak) id<MainScoreboardDelegate> delegate;
@property BOOL alertOnly;
@property BOOL isBroadcastNode;
@property BOOL isHomeNode;
@property BOOL isAwayNode;
@property BOOL isTvNode;
@property BOOL isRadioNode;

- (id) initWithDelegate:(id<MainScoreboardDelegate>)delegate date:(NSDate*)date alertOnly:(BOOL)alertOnly;
- (void) cancel;
@end
