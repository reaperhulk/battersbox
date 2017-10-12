//
//  LinescoreParser.m
//  Batter's Box
//
//  Created by Paul Kehrer on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LinescoreParser.h"

@implementation LinescoreParser

@synthesize afOperation,delegate,game;

-(id) initWithDelegate:(id<LinescoreParserDelegate>)pDelegate game:(Game *)pGame {
    self = [super init];
    if (self) {
        self.delegate = pDelegate;
        self.game = pGame;
        if (self.game.statusCode != 2) {
            [self.delegate linescoreLoadFailed];
        } else {
            [self loadXml];
        }
    }
    return self;
}

-(void) loadXml {
    NSString *url = [NSString stringWithFormat:@"http://gdx.mlb.com/components/game/mlb/year_%04d/month_%02d/day_%02d/gid_%@/linescore.xml",self.game.dateComponents.year,self.game.dateComponents.month,self.game.dateComponents.day,self.game.gameday];
    DebugLog(@"Loading %@",url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:kTimeoutInterval];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setHTTPMethod:@"GET"];
    //execute this on the main thread since it's so lightweight
    self.afOperation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {
        [XMLParser setDelegate:self];
        [XMLParser parse];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParse) {
        [(NSObject*)self.delegate performSelectorOnMainThread:@selector(linescoreLoadFailed) withObject:nil waitUntilDone:NO];
        #ifdef DEBUG
        NSLog(@"Error %@ %@",[error localizedDescription],[error userInfo]);
        #endif
    }];
    self.afOperation.successCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
    self.afOperation.failureCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
    [self.afOperation start];
}

-(void) cancel {
    DebugLog(@"aborting async request");
    if (self.afOperation != nil) {
        [self.afOperation cancel];
    }
}

-(void) lineScoreLoaded:(NSDictionary*)linkDict {
    NSString *awayRecapLink = [linkDict objectForKey:@"awayRecapLink"];
    NSString *homeRecapLink = [linkDict objectForKey:@"homeRecapLink"];
    [self.delegate linescoreLoaded:awayRecapLink homeLink:homeRecapLink];
}

#pragma mark -
#pragma mark NSXMLParser delegate methods

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
                                       namespaceURI:(NSString *)namespaceURI 
                                      qualifiedName:(NSString *)qName 
                                         attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"game"]) {
        NSMutableDictionary *wrapper = [NSMutableDictionary dictionary];
        NSString *awayRecapLink = [[attributeDict valueForKey:@"away_recap_link"] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        if ([awayRecapLink length] > 0) {
            [wrapper setObject:awayRecapLink forKey:@"awayRecapLink"];
        }
        NSString *homeRecapLink = [[attributeDict valueForKey:@"home_recap_link"] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        if ([homeRecapLink length] > 0) {
            [wrapper setObject:homeRecapLink forKey:@"homeRecapLink"];
        }
        [self performSelectorOnMainThread:@selector(lineScoreLoaded:) withObject:wrapper waitUntilDone:NO];
        //we got we wanted, let's stop
        [parser abortParsing];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if ([parseError code] != NSXMLParserDelegateAbortedParseError) {
        DebugLog(@"%@",parseError);
        [(NSObject*)self.delegate performSelectorOnMainThread:@selector(linescoreLoadFailed) withObject:nil waitUntilDone:NO];
    }
}



@end
