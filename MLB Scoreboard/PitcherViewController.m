//
//  PitcherViewController.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PitcherViewController.h"
#import "PitcherDetailCell.h"
#import "GameTabBarViewController.h"
#import "GamesViewController.h"

@interface PitcherViewController ()

@end

@implementation PitcherViewController

@synthesize tableView;

@synthesize spinnerView,failView;
@synthesize pitcher;
@synthesize pitcherDetail;
@synthesize photo;
@synthesize afOperation;

@synthesize jerseyNumber,pitcherName,dateOfBirth,weightHeight,throws,age;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"Pitcher Details";
    [self showSpinnerView];
    [self loadPitcherDetail];

    [self.photo loadImageWithObject:self.pitcher mugshot:YES];
//    [TestFlight passCheckpoint:@"Pitcher Detail Viewed"];
    //[FlurryAnalytics logEvent:@"Pitcher Detail" withParameters:[NSDictionary dictionaryWithObject:self.pitcher.name forKey:@"pitcher-name"]];
//    [AdDashDelegate reportCustomEvent:@"Pitcher Detail" withDetail:self.pitcher.name];
}

- (void)viewWillAppear:(BOOL)animated {
    [self hideFailView];
}

-(void)viewDidDisappear:(BOOL)animated {
    if (self.afOperation) {
        [self.afOperation cancel];
        self.afOperation = nil;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) showSpinnerView {
    if (self.spinnerView != nil) {
        return;
    }
    self.spinnerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    self.spinnerView.backgroundColor = [UIColor colorWithRed:78/255.0f green:78/255.0f blue:78/255.0f alpha:1.0f];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(self.spinnerView.frame.size.width/2, self.spinnerView.frame.size.height/2);
    [spinner startAnimating];
    [self.spinnerView addSubview:spinner];
    [self.view addSubview:self.spinnerView];
}

-(void) hideSpinnerView {
    [UIView animateWithDuration:0.5f animations:^{
        self.spinnerView.alpha = 0.0f;
    } completion:^(BOOL completed){
        if(completed) {
            [self.spinnerView removeFromSuperview];
        }
    }];

    self.spinnerView = nil;
}

-(void) showFailView {
    if (self.failView != nil) {
        return;
    }
    self.failView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"data-load-failed.png"]];
    [self.view addSubview:self.failView];
}

-(void) hideFailView {
    if (self.failView) {
        [self.failView removeFromSuperview];
        self.failView = nil;
    }
}


-(void) dealloc {
    if (self.afOperation) {
        [self.afOperation cancel];
        self.afOperation = nil;
    }
}

-(void) loadPitcherDetail {
    NSString *url = [NSString stringWithFormat:@"http://gdx.mlb.com/components/game/mlb/year_%04d/month_%02d/day_%02d/gid_%@/pitchers/%@.xml",self.game.dateComponents.year,self.game.dateComponents.month,self.game.dateComponents.day,self.game.gameday,self.pitcher.pitcherId];
    DebugLog(@"Loading %@",url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:kTimeoutInterval];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setHTTPMethod:@"GET"];
    self.afOperation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {
        XMLParser.delegate = self;
        self.pitcherDetail = [[PitcherDetail alloc] init];
        [XMLParser parse];
        [self performSelectorOnMainThread:@selector(showDetails) withObject:nil waitUntilDone:NO];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParse) {
        DebugLog(@"Error %@ %@",[error localizedDescription],[error userInfo]);
        [self performSelectorOnMainThread:@selector(hideSpinnerView) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(showFailView) withObject:nil waitUntilDone:NO];
    }];

    [self.afOperation start];
}


-(IBAction)followLink:(id)sender {
    NSString *url = [NSString stringWithFormat:@"http://m.mlb.com/player/%i/",[self.pitcher.pitcherId intValue]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url]];
}


-(void) showDetails {
    self.pitcherName.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.pitcherName setTitle:self.pitcherDetail.fullName forState:UIControlStateNormal];
    [self.pitcherName setTitle:self.pitcherDetail.fullName forState:UIControlStateHighlighted];
    self.jerseyNumber.text = [NSString stringWithFormat:@"#%@",self.pitcherDetail.jerseyNumber];
    self.weightHeight.text = [NSString stringWithFormat:@"%@, %@",self.pitcherDetail.height,self.pitcherDetail.weight];
    self.throws.text = self.pitcherDetail.throws;
    self.dateOfBirth.text = self.pitcherDetail.dateOfBirth;
    self.age.text = self.pitcherDetail.age;
    [self hideFailView];
    [self performSelectorOnMainThread:@selector(hideSpinnerView) withObject:nil waitUntilDone:NO];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark -
#pragma mark NSXMLParser delegate methods

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
 namespaceURI:(NSString *)namespaceURI 
qualifiedName:(NSString *)qName 
   attributes:(NSDictionary *)attributeDict {
    NSArray *objectsWeWant = [NSArray arrayWithObjects:@"season",@"career",@"Month",@"Team",@"Empty",@"Men_On",@"RISP",@"Loaded",@"vs_LHB",@"vs_RHB", nil];
    if ([elementName isEqualToString:@"Player"]) {
        self.pitcherDetail.firstName = [attributeDict objectForKey:@"first_name"];
        self.pitcherDetail.lastName = [attributeDict objectForKey:@"last_name"];
        self.pitcherDetail.jerseyNumber = [attributeDict objectForKey:@"jersey_number"];
        self.pitcherDetail.height = [attributeDict objectForKey:@"height"];
        self.pitcherDetail.weight = [attributeDict objectForKey:@"weight"];
        self.pitcherDetail.throws = [attributeDict objectForKey:@"throws"];
        self.pitcherDetail.dateOfBirth = [attributeDict objectForKey:@"dob"];
    } else if ([objectsWeWant containsObject:elementName]) {
        NSArray *names = [NSArray arrayWithObjects:@"Season",@"Career",@"Month",@"Team",@"Empty",@"Men On",@"RISP",@"Loaded",@"Vs LHB",@"Vs RHB", nil];
        NSString *rowName = [names objectAtIndex:[objectsWeWant indexOfObject:elementName]];
        if ([rowName isEqualToString:@"Team"]) {
            rowName = [attributeDict objectForKey:@"des"];
        }
        NSMutableArray *fields = [NSMutableArray arrayWithObjects:@"so",@"bb",@"hr",@"avg",@"ab",nil];
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        if ([rowName length] > 0) {
            [data setObject:rowName forKey:@"name"];
        } else {
            //[FlurryAnalytics logEvent:@"pitcher view parser error"];
            [data setObject:@"error" forKey:@"name"];
        }
        for (NSString *key in fields) {
            NSString *value = [attributeDict objectForKey:key];
            if ([value length] > 0) {
                [data setObject:value forKey:key];
            }
        }
        [self.pitcherDetail.stats addObject:data];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if ([parseError code] != NSXMLParserDelegateAbortedParseError) {
        DebugLog(@"%@",parseError);
        [self performSelectorOnMainThread:@selector(hideSpinnerView) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(showFailView) withObject:nil waitUntilDone:NO];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.pitcherDetail.stats count];
}

- (UITableViewCell *)tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PitcherDetailCell";
    PitcherDetailCell *cell = [pTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSMutableDictionary *dict = [self.pitcherDetail.stats objectAtIndex:indexPath.row];
    cell.name.text = [dict objectForKey:@"name"];
    cell.average.text = [dict objectForKey:@"avg"];
    cell.baseOnBalls.text = [dict objectForKey:@"bb"];
    cell.homeRuns.text = [dict objectForKey:@"hr"];
    cell.strikeOuts.text = [dict objectForKey:@"so"];
    cell.atBats.text = [dict objectForKey:@"ab"];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor whiteColor];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1.0];
    }
}


-(Game*) game {
    if (IS_IPAD()) {
        return [[GamesDataController sharedSingleton] gameForGameday:[[GamesDataController sharedSingleton] selectedGameday]];
    } else {
        GameTabBarViewController *tabController = (GameTabBarViewController*)[[self.navigationController viewControllers] objectAtIndex:1];
        return [[GamesDataController sharedSingleton] gameForGameday:tabController.singleGameDataController.gameday];
    }
}

@end
