//
//  HighlightsViewController.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HighlightsViewController.h"
#import "Game.h"
#import "GameTabBarViewController.h"
#import "GamesViewController.h"
#import "HighlightCell.h"
#import "MovieViewController.h"

@interface HighlightsViewController ()

@end

@implementation HighlightsViewController

@synthesize highlights,highlightsNew,imageDownloadsInProgress,cachedImages,afOperation;
@synthesize isDuration,isHeadline,isThumb,isThumbRetina,isThumbnailNode,isURLCloudMobile,isURLCloudTablet,movieViewController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.highlights = [NSMutableArray array];
    self.cachedImages = [NSMutableDictionary dictionary];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.navigationItem.title = @"Highlights";
    [self loadHighlights];
}

-(void) viewWillDisappear:(BOOL)animated {
    DebugLog(@"firing");
    if (self.afOperation) {
        [self.afOperation cancel];
        self.afOperation = nil;
    }
    for (NSIndexPath *path in self.imageDownloadsInProgress) {
        IconDownloader *downloader = (IconDownloader*)[self.imageDownloadsInProgress objectForKey:path];
        [downloader cancelDownload];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) dealloc {
    if (self.afOperation) {
        [self.afOperation cancel];
        self.afOperation = nil;
    }
}

-(Game*) game {
    if (IS_IPAD()) {
        return [[GamesDataController sharedSingleton] gameForGameday:[[GamesDataController sharedSingleton] selectedGameday]];
    } else {
        GameTabBarViewController *tabController = (GameTabBarViewController*)self.tabBarController;
        return [[GamesDataController sharedSingleton] gameForGameday:tabController.singleGameDataController.gameday];
    }
}


-(void) loadHighlights {
    NSString *url = [NSString stringWithFormat:@"http://gdx.mlb.com/components/game/mlb/year_%04d/month_%02d/day_%02d/gid_%@/media/mobile.xml",self.game.dateComponents.year,self.game.dateComponents.month,self.game.dateComponents.day,self.game.gameday];
    DebugLog(@"Loading %@",url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:kTimeoutInterval];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setHTTPMethod:@"GET"];
    self.afOperation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {
        XMLParser.delegate = self;
        self.highlightsNew = [NSMutableArray array];
        [XMLParser parse];
        self.highlights = self.highlightsNew;
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        self.highlightsNew = nil;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParse) {
        DebugLog(@"Error %@ %@",[error localizedDescription],[error userInfo]);
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
    self.afOperation.successCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
    self.afOperation.failureCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);

    [self.afOperation start];
}

#pragma mark -
#pragma mark NSXMLParser delegate methods

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
 namespaceURI:(NSString *)namespaceURI 
qualifiedName:(NSString *)qName 
   attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"media"]) {
        NSMutableDictionary *highlight = [NSMutableDictionary dictionary];
        [self.highlightsNew addObject:highlight];
    } else if ([elementName isEqualToString:@"headline"]) {
        self.isHeadline = YES;
    } else if ([elementName isEqualToString:@"duration"]) {
        self.isDuration = YES;
    } else if ([elementName isEqualToString:@"thumbnails"]) {
        self.isThumbnailNode = YES;
    } else if (self.isThumbnailNode == YES && [elementName isEqualToString:@"thumb"] && [[attributeDict objectForKey:@"type"] isEqualToString:@"8"]) {
        self.isThumb = YES;
    } else if (self.isThumbnailNode == YES && [elementName isEqualToString:@"thumb"] && [[attributeDict objectForKey:@"type"] isEqualToString:@"22"]) {
        self.isThumbRetina = YES;
    } else if ([elementName isEqualToString:@"url"]) {
        NSString *value = [attributeDict objectForKey:@"playback-scenario"];
        if ([value isEqualToString:@"HTTP_CLOUD_MOBILE"]) {
            self.isURLCloudMobile = YES;
        } else if ([value isEqualToString:@"HTTP_CLOUD_TABLET"]) {
            self.isURLCloudTablet = YES;
        }
    }
}

-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (self.isHeadline) {
        NSMutableDictionary *highlight = [self.highlightsNew lastObject];
        NSString *headline = [highlight objectForKey:@"headline"];
        if (!headline) {
            headline = @"";
        }
        [highlight setObject:[headline stringByAppendingString:string] forKey:@"headline"];
    } else if (self.isDuration) {
        NSMutableDictionary *highlight = [self.highlightsNew lastObject];
        NSString *duration = [highlight objectForKey:@"duration"];
        if (!duration) {
            duration = @"";
        }
        [highlight setObject:[duration stringByAppendingString:string] forKey:@"duration"];        
    } else if (self.isThumb) {
        NSMutableDictionary *highlight = [self.highlightsNew lastObject];
        NSString *thumb = [highlight objectForKey:@"thumb"];
        if (!thumb) {
            thumb = @"";
        }
        [highlight setObject:[thumb stringByAppendingString:string] forKey:@"thumb"];                
    } else if (self.isThumbRetina) {
        NSMutableDictionary *highlight = [self.highlightsNew lastObject];
        NSString *thumbRetina = [highlight objectForKey:@"thumb@2x"];
        if (!thumbRetina) {
            thumbRetina = @"";
        }
        [highlight setObject:[thumbRetina stringByAppendingString:string] forKey:@"thumb@2x"];
    } else if (self.isURLCloudMobile) {
        NSMutableDictionary *highlight = [self.highlightsNew lastObject];
        NSString *url = [highlight objectForKey:@"url"];
        if (!url) {
            url = @"";
        }
        [highlight setObject:[url stringByAppendingString:string] forKey:@"url"];        
    } else if (self.isURLCloudTablet) {
        NSMutableDictionary *highlight = [self.highlightsNew lastObject];
        NSString *url = [highlight objectForKey:@"url-ipad"];
        if (!url) {
            url = @"";
        }
        [highlight setObject:[url stringByAppendingString:string] forKey:@"url-ipad"];  
    }
}

-(void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"headline"]) {
        self.isHeadline = NO;
    } else if ([elementName isEqualToString:@"duration"]) {
        self.isDuration = NO;
    } else if ([elementName isEqualToString:@"thumbnails"]) {
        self.isThumbnailNode = NO;
    } else if ([elementName isEqualToString:@"thumb"]) {
        self.isThumb = NO;
        self.isThumbRetina = NO;
    } else if ([elementName isEqualToString:@"url"]) {
        self.isURLCloudMobile = NO;
        self.isURLCloudTablet = NO;
    }    
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if ([parseError code] != NSXMLParserDelegateAbortedParseError) {
        DebugLog(@"%@",parseError);
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [self.highlights count];
    if (count > 0) {
        return count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.highlights count] == 0 && indexPath.row == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaceholderCell"];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                           reuseIdentifier:@"PlaceHolderCell"];   
            cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (!self.afOperation.isFinished) {
            cell.detailTextLabel.text = @"Loading…";
        } else {
            cell.detailTextLabel.text = @"No highlights available";
        }
        
        return cell;
    }

    HighlightCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HighlightCell"];
    NSMutableDictionary *highlight = [self.highlights objectAtIndex:indexPath.row];
    cell.headline.text = [highlight objectForKey:@"headline"]; 
    cell.duration.text = [highlight objectForKey:@"duration"];
    UIImage *thumb = [self.cachedImages objectForKey:indexPath];
    if (!thumb) {
        [self startIconDownload:[highlight objectForKey:@"thumb"] forIndexPath:indexPath];
        cell.thumb.animationDuration = 1.0f;
        cell.thumb.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"spinner-0.png"],[UIImage imageNamed:@"spinner-1.png"],[UIImage imageNamed:@"spinner-2.png"],[UIImage imageNamed:@"spinner-3.png"],[UIImage imageNamed:@"spinner-4.png"],[UIImage imageNamed:@"spinner-5.png"],[UIImage imageNamed:@"spinner-6.png"],[UIImage imageNamed:@"spinner-7.png"],[UIImage imageNamed:@"spinner-8.png"],[UIImage imageNamed:@"spinner-9.png"],[UIImage imageNamed:@"spinner-10.png"],[UIImage imageNamed:@"spinner-11.png"], nil];
        cell.thumb.contentMode = UIViewContentModeCenter;
        [cell.thumb startAnimating];
    } else {
        cell.thumb.animationImages = nil;
        [cell.thumb stopAnimating];
        cell.thumb.image = thumb;
    }

    return cell;
}

-(void) moviePlayBackDidFinish {
    if (self.tableView.indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}

-(void) airPlayEvent:(NSNotification*)notification {
    MPMoviePlayerController *moviePlayer = (MPMoviePlayerController*)notification.object;
    if (moviePlayer.airPlayVideoActive) {
        //[FlurryAnalytics logEvent:@"AirPlay activated"];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.highlights count] == 0) {
        //nothing has loaded yet, if we try to select it'll crash when getting the object from self.highlights so let's just return
        return;
    }
//    [TestFlight passCheckpoint:@"Watched a highlight video"];
//    [AdDashDelegate reportCustomEvent:@"Highlight" withDetail:@"watched"];
    NSMutableDictionary *highlight = [self.highlights objectAtIndex:indexPath.row];
    NSString *url;
    if (IS_IPAD()) {
        url = [highlight objectForKey:@"url-ipad"];
    } else {
        url = [highlight objectForKey:@"url"];
    }
    if ([url length] > 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:url forKey:@"url"];
        [dict setObject:[highlight objectForKey:@"headline"] forKey:@"highlight-name"];
        //[FlurryAnalytics logEvent:@"Highlight Watched" withParameters:dict];
        self.movieViewController = nil;
        self.movieViewController = [[MovieViewController alloc] initWithContentURL: [NSURL URLWithString:url]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish)
                                                                                  name:MPMoviePlayerPlaybackDidFinishNotification 
                                                                                  object:self.movieViewController.moviePlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(airPlayEvent:)
                                                     name:MPMoviePlayerIsAirPlayVideoActiveDidChangeNotification 
                                                   object:self.movieViewController.moviePlayer];
        self.movieViewController.moviePlayer.allowsAirPlay = YES;
        self.movieViewController.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
        [self presentViewController:self.movieViewController animated:YES completion:nil];
        [self.movieViewController.moviePlayer prepareToPlay];
        
        [self.movieViewController.moviePlayer play];
    }
}

#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(NSString*)url forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil) {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        iconDownloader.url = url;
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.highlights count] > 0) {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths) {
            NSMutableDictionary *highlight = [self.highlights objectAtIndex:indexPath.row];
            UIImage *thumb = [self.cachedImages objectForKey:indexPath];
            if (!thumb) {
                [self startIconDownload:[highlight objectForKey:@"thumb"] forIndexPath:indexPath];
            }
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)imageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil) {
        HighlightCell *cell = (HighlightCell*)[self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        // Display the newly loaded image
        [self.cachedImages setObject:iconDownloader.downloadedImage forKey:indexPath];
        cell.thumb.animationImages = nil;
        [cell.thumb stopAnimating];
        cell.thumb.contentMode = UIViewContentModeScaleAspectFit;
        cell.thumb.image = iconDownloader.downloadedImage;
        [cell.thumb performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
    }
}

@end
