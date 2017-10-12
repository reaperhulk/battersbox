//
//  PostGameCell.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PostGameCell.h"
#import "BoxScoreColumn.h"
#import "Inning.h"

@implementation PostGameCell

@synthesize homeTeamLabel;
@synthesize awayTeamLabel;
@synthesize awayRecord;
@synthesize homeRecord;
@synthesize awayTeamRuns;
@synthesize homeTeamRuns;
@synthesize statusOrTime;
@synthesize firstPlayer,secondPlayer,firstLabel,secondLabel;
@synthesize boxScoreView;
@synthesize boxAwayRunsScored,boxHomeRunsScored,boxAwayHits,boxHomeHits,boxAwayErrors,boxHomeErrors;
@synthesize game;

-(void) setNewFrameForLabel:(UILabel*)label {
    UIFont *cellFont = [UIFont systemFontOfSize:15.0];
    CGSize constraintSize = CGSizeMake(MAXFLOAT, 21.0f);
    CGSize labelSize = [label.text sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    CGRect currentRect = label.frame;
    label.frame = CGRectMake(currentRect.origin.x,currentRect.origin.y,labelSize.width,labelSize.height);
}

-(void) configureCellWithGame:(Game*)pGame date:(NSDate*)date {
    self.game = pGame;
    self.awayTeamLabel.text = game.awayTeamName;
    [self setNewFrameForLabel:self.awayTeamLabel];
    
    self.homeTeamLabel.text = game.homeTeamName;
    [self setNewFrameForLabel:self.homeTeamLabel];
    
    if (game.awayWin != nil) {
        self.awayRecord.text = [NSString stringWithFormat:@"(%@-%@)",game.awayWin,game.awayLoss];        
        self.homeRecord.text = [NSString stringWithFormat:@"(%@-%@)",game.homeWin,game.homeLoss];
    } else {
        self.awayRecord.text = @"";
        self.homeRecord.text = @"";
    }
    
    self.statusOrTime.text = game.status;
    
    if (game.winningPitcher.name != nil && ![game.winningPitcher.name isEqualToString:@""]) {
        self.firstLabel.hidden = NO;
        self.firstPlayer.hidden = NO;
        self.firstPlayer.text = game.winningPitcher.name;
    } else {
        self.firstLabel.hidden = YES;
        self.firstPlayer.hidden = YES;
    }
    if (game.savePitcher.name != nil && ![game.savePitcher.name isEqualToString:@""]) {
        self.secondLabel.hidden = NO;
        self.secondPlayer.hidden = NO;
        self.secondLabel.text = @"S:";
        self.secondPlayer.text = game.savePitcher.name;
    } else if (game.losingPitcher.name != nil && ![game.losingPitcher.name isEqualToString:@""]) {
        self.secondLabel.hidden = NO;
        self.secondPlayer.hidden = NO;
        self.secondLabel.text = @"L:";
        self.secondPlayer.text = game.losingPitcher.name;
    } else {
        self.secondLabel.hidden = YES;
        self.secondPlayer.hidden = YES;
    }
    
    self.awayTeamRuns.text = game.awayTeamRuns;
    self.homeTeamRuns.text = game.homeTeamRuns;
    self.boxAwayRunsScored.text = game.awayTeamRuns;
    self.boxHomeRunsScored.text = game.homeTeamRuns;
    self.boxAwayHits.text = game.awayTeamHits;
    self.boxHomeHits.text = game.homeTeamHits;
    self.boxAwayErrors.text = game.awayTeamErrors;
    self.boxHomeErrors.text = game.homeTeamErrors;

    //this is a filthy hack. figure out a way to improve it
    int inningsCount = [game.innings count];
    int fakeInningsCount = inningsCount;
    if (fakeInningsCount < 9) {
        fakeInningsCount = 9;
    }
    for (int i=1;i <= 9; i++) {
        int reverse = fakeInningsCount-i;
        BoxScoreColumn *boxScoreColumn = (BoxScoreColumn*)[self.boxScoreView viewWithTag:i];
        if (inningsCount-1 < reverse) {
            [boxScoreColumn emptyLabels];
            [boxScoreColumn noActive];
            continue;
        }
        Inning *anInning = [game.innings objectAtIndex:reverse];
        if (boxScoreColumn == nil) {
            float offset = 207.0f - 23.0f*i;
            boxScoreColumn = [[BoxScoreColumn alloc] initWithFrame:CGRectMake(offset, 0, 22, 60)];
            boxScoreColumn.tag = i;
            [self.boxScoreView addSubview:boxScoreColumn];
        }
        boxScoreColumn.inningNumber.text = [NSString stringWithFormat:@"%d",anInning.inningNumber];
        boxScoreColumn.away.text = anInning.away;
        boxScoreColumn.home.text = anInning.home;
        if ([game.inning intValue] == anInning.inningNumber && game.statusCode == 1) {
            if ([game.inningState isEqualToString:@"Top"]) {
                [boxScoreColumn awayActive];
            } else if ([game.inningState isEqualToString:@"Bottom"]) {
                [boxScoreColumn homeActive];
            }
        } else {
            [boxScoreColumn noActive];
        }
    }
}

@end
