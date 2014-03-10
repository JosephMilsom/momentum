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
#import "Flurry.h"
#import "ResultsViewController.h"

@interface ChallengeList ()

/**
 *  This is the main tableview
 */
@property (strong, nonatomic) IBOutlet UITableView *challengeList;

//image views for the sponsor logos and bottom images
@property (weak, nonatomic) IBOutlet UIImageView *sponsorLogo;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImage;

//these describe the challenge
@property (weak, nonatomic) IBOutlet UILabel *challengeNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;

@property (weak, nonatomic) IBOutlet UIButton *acceptChallengeButton;

/**
    this is the main container for all the challenges in the table view
    but it is a pretty gross way of doing it. Must be a better way??
 */
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


#pragma mark view did load
/**
     ChallengeList's implementation of view did load deals with several factors.
     - method for initialising display is called, which initialises a custom button
     - delegate for challenge list is assigned as well as attributes set appropirately
     - authservice and coredata are initialised
     - methods for fetching challenges from coredata and downloading challenges from the server
     are called
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //challenge list set up delegate
    self.challengeList.delegate = self;
    self.challengeList.dataSource = self;
    
    //initialise the display elements, kept in it's own method
    //as it involves a lot of tedious code
    [self initDisplay];
    
    //initialise variables
    self.authService = [AuthService getInstance];
    self.coreData = [[CoreDataSingleton alloc] init];
    
    //[self.coreData deleteAllEntitiesOfType:@"SoloWalkingChallenge"];
    //[self.coreData deleteSpecificChallenge:@"SoloWalkingChallenge"];
    
    UIColor *colour = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.4];
    self.acceptChallengeButton.backgroundColor = colour;
    
    //if at some point, img data has been malformed, remove this data from the database.
    //will only really need to be done if user exits the app while imaegs are downloading
    [self.coreData purgeBrokenChallenges];
    
    //populate the challenge list.
    // TO DO: How can we change this so that it loads upon first load??
    [self setChallengesFromCoreData];
    [self downloadChallengeData];
    
}

/**
    Init display is just a helper class that initialises and customises all the
    display elements. Quite nice to keep seperated from the rest of the code
 */
- (void) initDisplay{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    //hide the default ui button
    self.navigationItem.hidesBackButton=YES;
    
    //creates a new back button to replace the navigation controller one.
    //suprisingly difficult, THANKS APPLE
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setContentEdgeInsets:UIEdgeInsetsMake(-2.5, 0, 0, 0)];
    backButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15.0];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem* backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
    
    //initialise display for the tableview
    self.challengeList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.challengeList.showsVerticalScrollIndicator = NO;
    //actually rotate the tableview. Hilarious!
    self.challengeList.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
    
    //add a border around the button
    [self.acceptChallengeButton.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.acceptChallengeButton.layer setBorderWidth: 0.5];
    [self.acceptChallengeButton.layer setCornerRadius:3.0f];
    
    //initialise selector methods for the button for creating the correct highlighted button
    //effects
    [self.acceptChallengeButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [self.acceptChallengeButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpInside];
    [self.acceptChallengeButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchDragOutside];
}

#pragma mark load challenges from core data
/**
 *  If there are any challenges contained within core data, load them up from the store.
 */
- (void) setChallengesFromCoreData{
    //update the number of rows currently stored in coredata
    self.challengeArray = [self.coreData fetchEntitiesOfType:@"SoloWalkingChallenge"];
    self.numberOfRows = self.challengeArray.count;
    self.bottomImage.alpha = 1;
    
    if(self.challengeArray.count != 0){
        [self tableView:self.challengeList didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
}

#pragma mark download challenges from the server
/**
    Method that deals with downloading the challenge data from the database
    The custom API challengeupdate is called, which takes an NSDictionary as
    a parameter containing the names of the challenges stored in coredata.
    The api then returns the challenges that are not in this list, which are
    then saved to the phone.
 
    Based on the number of challenges returned number of rows are incremented,
    and a new index path is also created per new challenge, for inserting once
    completed. The index path is determined by the value of numberOfRows at the
    time of use.
*/
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

/**
 *  Create a new request 
 *
 *  @param challenge nsdictionary for the challenge that has been downloaded from the server
 *  @param path      <#path description#>
 */
-(void) downloadAndSetChallengeImages:(NSDictionary *) challenge withChallengePath:(NSIndexPath*) path{
    //an async task to fetch data from the server
    self.imgDownloadQueue = [[NSOperationQueue alloc] init];
    
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
                self.acceptChallengeButton.alpha = 1;
                
            }];
            
        }];
    }];
}

/**
    Method that returns the names of challenges stored on the
    phone as an array.
 
   @return array of challenge names stored on the phone
 */
- (NSDictionary *) getStoredChallenges{
    //get the list of challenges that are stored in coredata, we send this
    //data to the service to check for updates
    NSArray *challenges = [self.coreData fetchEntitiesOfType:@"SoloWalkingChallenge"];
    NSMutableArray *challengeIDs = [NSMutableArray new];
    
    for(int i = 0; i < challenges.count; i++){
        SoloChallenge *s = challenges[i];
        [challengeIDs addObject:s.challengeID];
    }
    
    //dictionary containing all the stored challenges
    //to send to server
    NSDictionary *storedChallenges = [[NSDictionary alloc] initWithObjectsAndKeys:challengeIDs,@"challengeID", nil];
    
    //if there are no stored challenges we need a loading
    //gif, so add this to the view/plain white background
    if(challengeIDs.count == 0){
        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.loadingView.center = CGPointMake(160, 250);
        [self.view addSubview:self.loadingView];
        [self.loadingView startAnimating];
        
        self.acceptChallengeButton.alpha = 0;

    }
    
    return storedChallenges;
}


#pragma mark table view delegate methods
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

/**
 *  In this cellForRowAtIndexPath implementation, all the data for the cells are assigned from the 
    data that is in
 *
 *  @param tableView the challenge list
 *  @param indexPaths to be reloaded
 *
 *  @return the cell that is to be reloaded
 */
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


#pragma mark other methods
/**
 *  Prepare for segue is needed here as we need to let the charity know what
    challenge has been selected.
 *
 *  @param segue  segue (always going to be challengestocharities)
 *  @param sender sender is going to be the accept button
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"ChallengesToCharities"]){
        CharityListView *controller = (CharityListView *)segue.destinationViewController;
        controller.selectedChallenge = self.currentChallenge;
    }
}


/**
 *  This button action handles the transition to the charity list, pushing onto the navigation stack
 *
 *  @param sender the accept challenge button
 */
- (IBAction)AcceptChallenge:(id)sender {
    SoloChallenge *s = self.challengeArray[[self.challengeList indexPathForSelectedRow].row];
    self.currentChallenge = s;

    //temporary transition to the charity page
    [self performSegueWithIdentifier:@"ChallengesToCharities" sender:self];
}


/**
 *  return to the root view which is the results page
 *
 *  @param sender the back button
 */
-(void) backButtonAction:(id)sender
{
    if([self.coreData getCurrentChallenge] == nil){
    [self.navigationController setNavigationBarHidden: YES animated:YES];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  This changes the colour of the buttons background to white when the user presses down on the button
 *
 *  @param sender the accept challenge button
 */
- (void) buttonHighlight:(UIButton*)sender{
    sender.backgroundColor = [UIColor whiteColor];
    sender.titleLabel.textColor = [UIColor blackColor];
}

/**
 *  This changes it back to normal, after the user either drags outside the button, or touches up
 *
 *  @param sender the accept challenge button
 */
- (void) buttonNormal:(UIButton*)sender{
    UIColor *colour = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.4];
    sender.backgroundColor = colour;
    sender.titleLabel.textColor = [UIColor whiteColor];
}

@end
