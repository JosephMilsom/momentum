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

@interface ChallengeList ()
//define iboutlets
@property (strong, nonatomic) IBOutlet UITableView *challengeList;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImage;
@property (weak, nonatomic) IBOutlet UIButton *acceptChallengeButton;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
@property (weak, nonatomic) IBOutlet UILabel *challengeNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sponsorLogo;

@property (strong, nonatomic) NSArray* challengeArray;

@property NSInteger numberOfRows;
@property NSOperationQueue *lazyLoad;

@property (strong, nonatomic) AuthService* authService;
@property (strong, nonatomic) CoreDataSingleton *coreData;

- (IBAction)AcceptChallenge:(id)sender;

@end

@implementation ChallengeList


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.challengeList.delegate = self;
    self.challengeList.dataSource = self;
    
    //initialise display for the tableview
    self.challengeList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.challengeList.showsVerticalScrollIndicator = NO;
    self.challengeList.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
   
    //remove annoying touch content delay
    self.infoTextView.delaysContentTouches = NO;
    
    //add a border around the button
    [self.acceptChallengeButton.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.acceptChallengeButton.layer setBorderWidth: 1.0];
    
    //initialise variables
    self.authService = [AuthService getInstance];
    self.coreData = [[CoreDataSingleton alloc] init];
    
//    [self.coreData deleteAllEntitiesOfType:@"SoloWalkingChallenge"];
//    [self.coreData deleteSpecificChallenge:@"SoloWalkingChallenge"];
    
    //purge any challenges that have no image data,
    //redownload again
    [self.coreData purgeBrokenChallenges];
    
    [self getChallengeData];

    [self downloadChallengeData];
}

-(void) downloadChallengeData{
    /*FOR GETTING A LIST TO SEND TO THE SERVER*/
    
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
    
    
    [self.authService.client invokeAPI:@"challengeupdate" body:storedChallenges HTTPMethod:@"POST" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
        if(error){
            NSLog(@"%@", [error localizedDescription]);
        }
        else{
            //NSLog(@"%@", result);
            
            //result is an array of dictionaries
            NSArray *challenges = result;
            
            //these are the indices of the rows to add to the table
            NSMutableArray* rows = [NSMutableArray new];
        
            //an async task to fetch data from the server
            self.lazyLoad = [[NSOperationQueue alloc] init];
            self.lazyLoad.name = @"loadImagesFromServer";
            
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
                
                //asynchronous fetch for the images
                [self.lazyLoad addOperationWithBlock:^{
                    //image for the challenge
                    NSURL *url = [NSURL URLWithString:[challenges[i] valueForKey:@"sChallengeImage"]];
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    
                    //image for the bottom image
                    NSURL *urlBottom = [NSURL URLWithString:[challenges[i] valueForKey:@"sChallengeImageBtm"]];
                    NSData *dataBottom = [NSData dataWithContentsOfURL:urlBottom];
                    
                    /*NOTE: cell is used here since we want to fade in images, otherwise use reloadData which is much nicer*/
                    //get the cell to assign
                    ChallengeCell *cell = (ChallengeCell *)[self.challengeList cellForRowAtIndexPath:path];
                    
                    //NSLog(@"%@", cell.challengeTitle);
                    //update the ui
                    [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                        //set this here as we want to fade in the images
                        cell.imageBackground.alpha = 0;
                        cell.bottomImage = [UIImage imageWithData:dataBottom];
                        
                        cell.imageBackground.image = [UIImage imageWithData:data];
                        
                        //set the data for the image in core data
                        [self.coreData addChallengeImageData:data andBottomImageData:dataBottom forChallenge:[challenges[i] valueForKey:@"sChallengeName"]];
                        
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
        }
    }];    
}

//fetches challenge data from core data. The data is assigned in
//cellForIndexPath
- (void) getChallengeData{
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
    
    ChallengeCell *cell = (ChallengeCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    self.infoTextView.selectable = YES;
    self.infoTextView.text = cell.information;
    self.challengeNameLabel.text = cell.challengeTitle;
    self.infoTextView.selectable = NO;
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
    
    //for data loaded from core data
    SoloChallenge *s = self.challengeArray[indexPath.row];

    cell.imageBackground.image = [UIImage imageWithData:s.challengeImage];
    cell.bottomImage = [UIImage imageWithData:s.challengeBottomImage];
    cell.challengeTitle = s.challengeName;
    cell.information = s.challengeDescription;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark number of rows in section
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.numberOfRows;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150.0;
}

- (IBAction)AcceptChallenge:(id)sender {
    SoloChallenge *s = self.challengeArray[[self.challengeList indexPathForSelectedRow].row];
    //NSLog(@"%@", s.challengeName);
    [self.coreData setCurrentChallenge:s];
    //temporary transition to the charity page
    [self performSegueWithIdentifier:@"ChallengesToCharities" sender:nil];
}
@end
