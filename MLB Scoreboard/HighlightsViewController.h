//
//  HighlightsViewController.h
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IconDownloader.h"
#import "AFXMLRequestOperation.h"
#import "MovieViewController.h"

@interface HighlightsViewController : UITableViewController <UIScrollViewDelegate,IconDownloaderDelegate,NSXMLParserDelegate>

@property (nonatomic,strong) NSMutableArray *highlights;
@property (nonatomic,strong) NSMutableArray *highlightsNew;
@property (nonatomic,strong) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic,strong) NSMutableDictionary *cachedImages;
@property (nonatomic,strong) AFXMLRequestOperation *afOperation;
@property (nonatomic,strong) MovieViewController *movieViewController;
@property BOOL isHeadline;
@property BOOL isDuration;
@property BOOL isThumb;
@property BOOL isThumbRetina;
@property BOOL isURLCloudMobile;
@property BOOL isURLCloudTablet;
@property BOOL isThumbnailNode;

-(void) loadHighlights;
@end
