//
//  BatterViewController.m
//  MLB Scoreboard
//
//  Created by Paul Kehrer on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BatterViewController.h"
#import "BatterDetailCell.h"
#import "GameTabBarViewController.h"
#import "GamesViewController.h"

@interface BatterViewController ()

@end

@implementation BatterViewController

@synthesize tableView;

@synthesize spinnerView,failView;
@synthesize batter;
@synthesize batterDetail;
@synthesize photo;
@synthesize afOperation;

@synthesize jerseyNumber,batterName,dateOfBirth,weightHeight,throws,bats,age,position;

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
    self.navigationItem.title = @"Batter Details";
    [self showSpinnerView];
    [self loadBatterDetail];
    
    [self.photo loadImageWithObject:self.batter mugshot:YES];
//    [TestFlight passCheckpoint:@"Batter Detail Viewed"];
//    [AdDashDelegate reportCustomEvent:@"Batter Detail" withDetail:self.batter.name];
//    //[FlurryAnalytics logEvent:@"Batter Detail" withParameters:[NSDictionary dictionaryWithObject:self.batter.name forKey:@"batter-name"]];
}

- (void)viewWillAppear:(BOOL)animated {
    [self hideFailView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void) viewDidDisappear:(BOOL)animated {
    if (self.afOperation) {
        [self.afOperation cancel];
        self.afOperation = nil;
    }
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

-(void) dealloc {
    if (self.afOperation) {
        [self.afOperation cancel];
        self.afOperation = nil;
    }
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

-(void) loadBatterDetail {
    NSString *url = [NSString stringWithFormat:@"http://gdx.mlb.com/components/game/mlb/year_%04d/month_%02d/day_%02d/gid_%@/batters/%@.xml",self.game.dateComponents.year,self.game.dateComponents.month,self.game.dateComponents.day,self.game.gameday,self.batter.batterId];
    DebugLog(@"Loading %@",url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:kTimeoutInterval];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setHTTPMethod:@"GET"];
    self.afOperation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {
        XMLParser.delegate = self;
        self.batterDetail = [[BatterDetail alloc] init];
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
    NSString *url = [NSString stringWithFormat:@"http://m.mlb.com/player/%i/",[self.batter.batterId intValue]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url]];
}


-(void) showDetails {
    self.batterName.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.batterName setTitle:self.batterDetail.fullName forState:UIControlStateNormal];
    [self.batterName setTitle:self.batterDetail.fullName forState:UIControlStateHighlighted];
    self.position.text = self.batter.position;
    self.bats.text = self.batterDetail.bats;
    self.jerseyNumber.text = [NSString stringWithFormat:@"#%@",self.batterDetail.jerseyNumber];
    self.weightHeight.text = [NSString stringWithFormat:@"%@, %@",self.batterDetail.height,self.batterDetail.weight];
    self.throws.text = self.batterDetail.throws;
    self.dateOfBirth.text = self.batterDetail.dateOfBirth;
    self.age.text = self.batterDetail.age;
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
    NSArray *objectsWeWant = [NSArray arrayWithObjects:@"season",@"career",@"month",@"Team",@"Empty",@"Men_On",@"RISP",@"Loaded",@"vs_LHP",@"vs_RHP", nil];
    if ([elementName isEqualToString:@"Player"]) {
        self.batterDetail.firstName = [attributeDict objectForKey:@"first_name"];
        self.batterDetail.lastName = [attributeDict objectForKey:@"last_name"];
        self.batterDetail.jerseyNumber = [attributeDict objectForKey:@"jersey_number"];
        self.batterDetail.height = [attributeDict objectForKey:@"height"];
        self.batterDetail.weight = [attributeDict objectForKey:@"weight"];
        self.batterDetail.bats = [attributeDict objectForKey:@"bats"];
        self.batterDetail.throws = [attributeDict objectForKey:@"throws"];
        self.batterDetail.dateOfBirth = [attributeDict objectForKey:@"dob"];
    } else if ([objectsWeWant containsObject:elementName]) {
        NSArray *names = [NSArray arrayWithObjects:@"Season",@"Career",@"Month",@"Team",@"Empty",@"Men On",@"RISP",@"Loaded",@"Vs LHP",@"Vs RHP", nil];
        NSString *rowName = [names objectAtIndex:[objectsWeWant indexOfObject:elementName]];
        if ([rowName isEqualToString:@"Team"]) {
            rowName = [attributeDict objectForKey:@"des"];
        }
        NSMutableArray *fields = [NSMutableArray arrayWithObjects:@"ab",@"avg",@"hr",@"rbi",@"ops",nil];
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        if ([rowName length] > 0) {
            [data setObject:rowName forKey:@"name"];
        }
        for (NSString *key in fields) {
            NSString *value = [attributeDict objectForKey:key];
            if ([value length] > 0) {
                [data setObject:value forKey:key];
            }
        }
        [self.batterDetail.stats addObject:data];
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
    return [self.batterDetail.stats count];
}

- (UITableViewCell *)tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BatterDetailCell";
    BatterDetailCell *cell = [pTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSMutableDictionary *dict = [self.batterDetail.stats objectAtIndex:indexPath.row];
    cell.name.text = [dict objectForKey:@"name"];
    cell.atBats.text = [dict objectForKey:@"ab"];
    cell.average.text = [dict objectForKey:@"avg"];
    cell.homeRuns.text = [dict objectForKey:@"hr"];
    cell.runsBattedIn.text = [dict objectForKey:@"rbi"];
    cell.ops.text = [dict objectForKey:@"ops"];
    
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
