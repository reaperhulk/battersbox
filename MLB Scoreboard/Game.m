//
//  Game.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Game.h"

@implementation Game

@synthesize dateComponents;

@synthesize gameday;

@synthesize gameDescription;
@synthesize status;
@synthesize ind; //short status
@synthesize reason;

@synthesize venue;
@synthesize gameDate;
@synthesize time;
@synthesize ampm;
@synthesize awayCode;
@synthesize awayNameAbbrev;
@synthesize awayTeamName;
@synthesize awayWin;
@synthesize awayLoss;

@synthesize homeCode;
@synthesize homeNameAbbrev;
@synthesize homeTeamName;
@synthesize homeWin;
@synthesize homeLoss;

@synthesize awayTeamRuns;
@synthesize awayTeamHits;
@synthesize awayTeamErrors;

@synthesize homeTeamRuns;
@synthesize homeTeamHits;
@synthesize homeTeamErrors;

@synthesize innings;
@synthesize inning;
@synthesize inningState;
@synthesize runnerOnBaseStatus;
@synthesize outs;
@synthesize balls;
@synthesize strikes;

@synthesize awayPreviewLink;

@synthesize homePreviewLink;

@synthesize currentPitcher;
@synthesize currentBatter;
@synthesize currentOnDeck,currentInHole;
@synthesize lastPlay;

@synthesize winningPitcher, losingPitcher, savePitcher;

@synthesize homeProbablePitcher,awayProbablePitcher;

@synthesize awayRadio,homeRadio,awayTv,homeTv;

-(id) init {
    self = [super init];
    if (self) {
        //must set these to empty strings so we can call stringByAppendingString over in MainScoreboardParser
        self.homeRadio = @"";
        self.homeTv = @"";
        self.awayRadio = @"";
        self.awayTv = @"";
    }
    return self;
}

-(BOOL) beforeFirstPitch {
    if ([self.gameDate compare:[NSDate date]] == NSOrderedDescending) {
        return YES;
    } else {
        return NO;
    }
}

-(NSString*) gameTimeInLocalTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    //doubleheaders are denoted by 3:33 AM ET start time. Yes, it's crazy.
    if ([self.time isEqualToString:@"3:33"]) {
        return @"Game 2";
    } else {
        return [dateFormatter stringFromDate:self.gameDate];
    }
}

-(NSInteger) statusCode {
    if ([self.status isEqualToString:@"Final"] || [self.status isEqualToString:@"Game Over"] || [self.status isEqualToString:@"Completed Early"]) {
        return 2;
    } else if ([self.status isEqualToString:@"In Progress"] || [self.status isEqualToString:@"Replay"]) {
        return 1;
    } else if ([self.status isEqualToString:@"Preview"] || [self.status isEqualToString:@"Pre-Game"] || [self.status isEqualToString:@"Warmup"]) {
        return 0;
    } else if ([self.status isEqualToString:@"Postponed"] || [self.status isEqualToString:@"Delayed"] || [self.status isEqualToString:@"Delayed Start"]) {
        //same status code as unknown, but this way it won't log it as an "unknown status"
        return -1;
    } else {
        DebugLog(@"unknown status: %@",self.status);
        return -1;
    }
}

@end
