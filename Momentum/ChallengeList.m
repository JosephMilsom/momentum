//
//  ChallengeList.m
//  Momentum
//
//  Created by Joe on 10/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "ChallengeList.h"
#import "ChallengeCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AuthService.h"
#import "CoreDataSingleton.h"
#import "SoloChallenge.h"
#import "CharityListView.h"

@interface ChallengeList ()

//main challenge list
@property (strong, nonatomic) IBOutlet UITableView *challengeList;

//image views for the sponsor logos and bottom images
@property (weak, nonatomic) IBOutlet UIImageView *sponsorLogo;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImage;

//these describe the challenge
@property (weak, nonatomic) IBOutlet UILabel *challengeNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;

@property (weak, nonatomic) IBOutlet UIButton *acceptChallengeButton;

@property (strong, nonatomic) NSArray* challengeArray;

@property NSInteger numberOfRows;
@property NSOperationQueue *imgDownloadQueue;

@property (strong, nonatomic) AuthService* authService;
@property (strong, nonatomic) CoreDataSingleton *coreData;
@property (strong, nonatomic) SoloChallenge* currentChallenge;

@property (strong, nonatomic) UIActivityIndicatorView *loadingView;

- (IBAction)AcceptChallenge:(id)sender;

@end

@implementation ChallengeList


/**
 *  ChallengeList's implementation of view did load deals with several factors.
     - 
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //hide the default ui button
    self.navigationItem.hidesBackButton=YES;
    
    //creates a new back button to replace the navigation controller one
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setContentEdgeInsets:UIEdgeInsetsMake(-2.5, 0, 0, 0)];
    backButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15.0];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem* backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
    
    /**challenge list set up**/
    self.challengeList.delegate = self;
    self.challengeList.dataSource = self;
    
    //initialise display for the tableview
    self.challengeList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.challengeList.showsVerticalScrollIndicator = NO;
    self.challengeList.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
   
    //add a border around the button
    [self.acceptChallengeButton.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.acceptChallengeButton.layer setBorderWidth: 1.0];
    
    //initialise variables
    self.authService = [AuthService getInstance];
    self.coreData = [[CoreDataSingleton alloc] init];
    
    [self.coreData deleteAllEntitiesOfType:@"SoloWalkingChallenge"];
    //[self.coreData deleteSpecificChallenge:@"SoloWalkingChallenge"];
    
    //if at some point, img data has been malformed, remove this data from the database.
    //will only really need to be done if user exits the app while imaegs are downloading
    [self.coreData purgeBrokenChallenges];
    
    [self setChallengesFromCoreData];

    [self downloadChallengeData];
    
}


-(void) downloadChallengeData{

    NSDictionary *storedChallenges = [self getStoredChallenges];
    
    [self.authService.client invokeAPI:@"challengeupdate" body:storedChallenges HTTPMethod:@"POST" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
        if(error){
            NSLog(@"%@", [error localizedDescription]);
        }
        else{
            //result is an array of dictionaries
            NSArray *challenges = result;
            
            //these are the indices of the rows to add to the table
            NSMutableArray* rows = [NSMutableArray new];
        
            //an async task to fetch data from the server
            self.imgDownloadQueue = [[NSOperationQueue alloc] init];
            
            for (int i = 0; i < challenges.count; i++) {
                //add to the list of index paths for the tableview insert row method,
                //creates a new row at the end and will add it
                NSIndexPath *path = [NSIndexPath indexPathForRow:self.numberOfRows inSection:0];
                [rows addObject:path];
                
                //add the challenge dict(from the results) to the array of challenges
                NSDictionary *challengeData = challenges[i];
                
                //add new challenges to coredata
                [self.coreData addSoloChallenge:challengeData];
                
                //increment number of rows for the table view
                self.numberOfRows++;
                
                [self downloadAndSetChallengeImages:challengeData withChallengePath:path];
            }
            
            //refresh the challenge array to
            //update the number of cells, takes the count from the fetch results
            self.challengeArray = [self.coreData fetchEntitiesOfType:@"SoloWalkingChallenge"];
            self.numberOfRows = self.challengeArray.count;
            
            //insert the new rows into the table
            [self.challengeList insertRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationTop];
            
            //select the first row after download, if there are no rows that are selected
            if([self.challengeList indexPathForSelectedRow] == nil){
            [self tableView:self.challengeList didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            }
            
            [self.loadingView removeFromSuperview];
        }
    }];    
}

- (NSDictionary *) getStoredChallenges{
    //get the list of challenges that are stored in coredata, we send this
    //data to the service to check for updates
    NSArray *challenges = [self.coreData fetchEntitiesOfType:@"SoloWalkingChallenge"];
    NSMutableArray *challengeNames = [NSMutableArray new];
    
    for(int i = 0; i < challenges.count; i++){
        SoloChallenge *s = challenges[i];
        [challengeNames addObject:s.challengeName];
    }
    
    //dictionary containing all the stored challenges
    //to send to server
    NSDictionary *storedChallenges = [[NSDictionary alloc] initWithObjectsAndKeys:challengeNames,@"challengenames", nil];
    
    //if there are no stored challenges we need a loading
    //gif, so add this to the view/plain white background
    if(challengeNames.count == 0){
        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.loadingView.center = CGPointMake(160, 250);
        [self.view addSubview:self.loadingView];
        [self.loadingView startAnimating];
    }
    
    return storedChallenges;
}

-(void) downloadAndSetChallengeImages:(NSDictionary *) challenge withChallengePath:(NSIndexPath*) path{
    //asynchronous fetch for the images
    [self.imgDownloadQueue addOperationWithBlock:^{
        //image for the challenge
        NSURL *url = [NSURL URLWithString:[challenge valueForKey:@"sChallengeImage"]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        //image for the bottom image
        NSURL *urlBottom = [NSURL URLWithString:[challenge valueForKey:@"sChallengeImageBtm"]];
        NSData *dataBottom = [NSData dataWithContentsOfURL:urlBottom];
        
        //get the cell to assign
        ChallengeCell *cell = (ChallengeCell *)[self.challengeList cellForRowAtIndexPath:path];
        
        //update the ui
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
            self.challengeList.backgroundColor = [UIColor blackColor];
            
            //set this here as we want to fade in the images
            cell.imageBackground.alpha = 0;
            cell.bottomImage = [UIImage imageWithData:dataBottom];
            
            cell.imageBackground.image = [UIImage imageWithData:data];
            
            //set the data for the image in core data
            [self.coreData addChallengeImageData:data andBottomImageData:dataBottom forChallenge:[challenge valueForKey:@"sChallengeName"]];
            
            //set the background image
            if([self.challengeList indexPathForSelectedRow].row == path.row){
                self.bottomImage.image = [UIImage imageWithData:dataBottom];
                //bottom image alpha 0 for fade in
                self.bottomImage.alpha = 0;
            }
            
            [UIView animateWithDuration:0.3 animations:^{
                cell.imageBackground.alpha = 1;
                self.bottomImage.alpha = 1;
            }];
            
        }];
    }];
}


- (void) setChallengesFromCoreData{
    //update the number of rows currently stored in coredata
    self.challengeArray = [self.coreData fetchEntitiesOfType:@"SoloWalkingChallenge"];
    self.numberOfRows = self.challengeArray.count;
    self.bottomImage.alpha = 1;
    
    if(self.challengeArray.count != 0){
        [self tableView:self.challengeList didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView selectRowAtIndexPath:indexPath
                           animated:YES
                     scrollPosition:UITableViewScrollPositionMiddle];

    //set the appropriate information by the cell that has been selected
    ChallengeCell *cell = (ChallengeCell*)[tableView cellForRowAtIndexPath:indexPath];
    self.infoTextView.text = cell.information;
    self.infoTextView.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:13.0];
    self.challengeNameLabel.text = cell.challengeTitle;
    self.bottomImage.image = cell.bottomImage;
    
}

#pragma mark cell for row at index path
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    ChallengeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ChallengeCell" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (ChallengeCell *)currentObject;
                break;
            }
        }
    }
    
    //uses the data from core data
    SoloChallenge *s = self.challengeArray[indexPath.row];

    cell.imageBackground.image = [UIImage imageWithData:s.challengeImage];
    cell.bottomImage = [UIImage imageWithData:s.challengeBottomImage];
    cell.challengeTitle = s.challengeName;
    cell.information = s.challengeDescription;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.numberOfRows;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150.0;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"ChallengesToCharities"]){
        CharityListView *controller = (CharityListView *)segue.destinationViewController;
        controller.selectedChallenge = self.currentChallenge;
    }
}

- (IBAction)AcceptChallenge:(id)sender {
    SoloChallenge *s = self.challengeArray[[self.challengeList indexPathForSelectedRow].row];
    self.currentChallenge = s;
    
    //just a temporary test
    User *u = [self.coreData getUserInfo];
    u.userChallenge = s;
    //temporary transition to the charity page
    [self performSegueWithIdentifier:@"ChallengesToCharities" sender:self];
}

-(void) backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
