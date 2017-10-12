//
//  PreGameCell.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PreGameCell.h"

@implementation PreGameCell

@synthesize homeTeamLabel;
@synthesize awayTeamLabel;
@synthesize awayRecord;
@synthesize homeRecord;
@synthesize statusOrTime;
@synthesize firstPlayer,secondPlayer,firstLabel,secondLabel;
@synthesize pregameView,previewLink,awayTv,homeTv,awayRadio,homeRadio;
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
    
    //set defaults
    self.firstPlayer.text = @"";
    self.secondPlayer.text = @"";
    self.previewLink.hidden = YES;
    self.awayTv.text = (game.awayTv)?game.awayTv:@"";
    self.homeTv.text = (game.homeTv)?game.homeTv:@"";
    self.awayRadio.text = (game.awayRadio)?game.awayRadio:@"";
    self.homeRadio.text = (game.homeRadio)?game.homeRadio:@"";
    self.statusOrTime.text = [game gameTimeInLocalTime];
    if (game.homePreviewLink == nil || [game.homePreviewLink isEqualToString:@""]) {
        self.previewLink.hidden = YES;
    } else {
        self.previewLink.hidden = NO;
    }

    if (![game.awayProbablePitcher.name isEqualToString:@""]) {
        self.firstPlayer.text = game.awayProbablePitcher.name;
    }
    if (![game.homeProbablePitcher.name isEqualToString:@""]) {
        self.secondPlayer.text = game.homeProbablePitcher.name;
    }    
}

//these two IBActions are similar (but not identical) to the methods in GenericDetailViewController
-(IBAction)followPreviewLink {
    NSString *urlPrefix;
    if (IS_IPAD()) {
        urlPrefix = @"http://mlb.mlb.com";
    } else {
        urlPrefix = @"http://m.mlb.com";        
    }
    NSString *previewLinkUrl;
    if (IS_IPAD()) {
        previewLinkUrl = game.awayPreviewLink;
    } else {
        previewLinkUrl = [NSString stringWithFormat:@"/%@",game.gameday];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",urlPrefix,previewLinkUrl]]];
}

@end
