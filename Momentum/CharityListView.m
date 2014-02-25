//
//  CharityListView.m
//  Momentum
//
//  Created by Joe on 13/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "CharityListView.h"
#import "CharityCell.h"
#import "AuthService.h"
#import "CoreDataSingleton.h"
#import "Charity.h"

@interface CharityListView ()
@property (weak, nonatomic) IBOutlet UITableView *charityList;
@property (weak, nonatomic) IBOutlet UILabel *charityLabel;
@property (weak, nonatomic) IBOutlet UITextView *information;
@property (weak, nonatomic) IBOutlet UIImageView *charityImage;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImageView;

@property (strong, nonatomic) AuthService *authService;
@property (strong, nonatomic) NSOperationQueue *lazyLoad;
@property (nonatomic) NSInteger numberOfRows;

@property (strong, nonatomic) CoreDataSingleton *coreData;

@property (strong, nonatomic) NSArray* charityArray;
@property (weak, nonatomic) IBOutlet UIButton *startChallengeButton;
@property (strong, nonatomic) UIActivityIndicatorView *loading;

- (IBAction)startChallenge:(id)sender;

@end

@implementation CharityListView


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"%@", self.selectedChallenge.challengeName);
    
    self.charityList.delegate = self;
    self.charityList.dataSource = self;
   
    //hide the default ui button
    self.navigationItem.hidesBackButton=YES;
    
    //set the new back button
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    //adjust the insets to move to the correct position
    [backButton setContentEdgeInsets:UIEdgeInsetsMake(-2.5, 0, 0, 0)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15.0];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem* backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
    
    self.charityList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.charityList.showsHorizontalScrollIndicator = NO;
    self.charityList.showsVerticalScrollIndicator = NO;
    self.charityList.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
    
    self.authService = [AuthService getInstance];
    self.coreData = [[CoreDataSingleton alloc] init];
    
    [self.startChallengeButton.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.startChallengeButton.layer setBorderWidth: 1.0];
    
    
    
    //[self.coreData deleteAllEntitiesOfType:@"Charity"];
    //[self.coreData deleteSpecificChallenge:@"Charity"];
    
    [self.coreData purgeBrokenCharities];
    
    [self getCharityData];
    
    [self downloadCharityData];
}


//fetches challenge data from core data. The data is assigned in
//cellForIndexPath

- (void) getCharityData{
    //update the number of rows currently stored in coredata
    self.charityArray = [self.coreData fetchEntitiesOfType:@"Charity"];
    self.numberOfRows = self.charityArray.count;
    self.bottomImageView.alpha = 1;
    
    if(self.charityArray.count != 0){
        [self tableView:self.charityList didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
}

- (void) downloadCharityData{
    /*FOR GETTING A LIST TO SEND TO THE SERVER*/
    
    //get the list of challenges that are stored in coredata, we send this
    //data to the service to check for updates
    NSArray *charities = [self.coreData fetchEntitiesOfType:@"Charity"];
    NSMutableArray *charityNames = [NSMutableArray new];
    
    for(int i = 0; i < charities.count; i++){
        Charity *c = charities[i];
        //NSLog(@"%@", c.charityName);
        [charityNames addObject:c.charityName];
    }
    
    if(charities.count == 0){
        self.loading =[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.loading.center = CGPointMake(160, 250);
        [self.view addSubview:self.loading];
        [self.loading startAnimating];
    }
    
    NSDictionary *storedCharities = [[NSDictionary alloc] initWithObjectsAndKeys:charityNames, @"charitynames", nil];
    
    [self.authService.client invokeAPI:@"charityupdate" body:storedCharities HTTPMethod:@"POST" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
        if(error){
            NSLog(@"%@", [error localizedDescription]);
        }
        else{
            //these are the indices of the rows to add to the table
            NSMutableArray* rows = [NSMutableArray new];
            
            //result is an array of dictionaries
            NSArray *charities = result;
            //NSLog(@"%@", result);
            //an async task to fetch data from the server
            self.lazyLoad = [[NSOperationQueue alloc] init];
            self.lazyLoad.name = @"loadCharImagesFromServer";
            
            for (int i = 0; i < charities.count; i++) {
                //add to the list of index paths for the tableview insert row method,
                //creates a new row at the end and will add it
                NSIndexPath *path = [NSIndexPath indexPathForRow:self.numberOfRows inSection:0];
                [rows addObject:path];
                
                //add the challenge dict(from the results) to the array of challenges
                NSDictionary *charityData = charities[i];
                
                //add new challenges to coredata
                [self.coreData addCharity:charityData];
                
                //increment number of rows for the table view
                self.numberOfRows++;
                
                //asynchronous fetch for the images
                [self.lazyLoad addOperationWithBlock:^{
                    //image for the challenge
                    NSURL *url = [NSURL URLWithString:[charities[i] valueForKey:@"charityImage"]];
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    
                    //image for the bottom image
                    NSURL *urlBottom = [NSURL URLWithString:[charities[i] valueForKey:@"charityImgBtm"]];
                    NSData *dataBottom = [NSData dataWithContentsOfURL:urlBottom];
                    
                    /*NOTE: cell is used here since we want to fade in images, otherwise use reloadData which is much nicer*/
                    //get the cell to assign
                    CharityCell *cell = (CharityCell *)[self.charityList cellForRowAtIndexPath:path];
                    
                    //NSLog(@"%@", cell.challengeTitle);
                    //update the ui
                    [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                        //set this here as we want to fade in the images
                        cell.cellImage.alpha = 0;
                        cell.bottomImage = [UIImage imageWithData:dataBottom];
                        
                        cell.cellImage.image = [UIImage imageWithData:data];
                        
                        //set the data for the image in core data
                        [self.coreData addCharityImageData:data andBottomImageData:dataBottom forCharity:[charities[i] valueForKey:@"charityName"]];
                        
                        //set the background image
                        if([self.charityList indexPathForSelectedRow].row == path.row){
                            self.bottomImageView.image = [UIImage imageWithData:dataBottom];
                            //bottom image alpha 0 for fade in
                            self.bottomImageView.alpha = 0;
                        }
                        
                        [UIView animateWithDuration:0.3 animations:^{
                            cell.cellImage.alpha = 1;
                            self.bottomImageView.alpha = 1;
                        }];
                    }];
                }];
            }
            
            //refresh the challenge array to
            //update the number of cells, takes the count from the fetch results
            self.charityArray = [self.coreData fetchEntitiesOfType:@"Charity"];
            self.numberOfRows = self.charityArray.count;
            
            
            //insert the new rows into the table
            [self.charityList insertRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationTop];
            
            if([self.charityList indexPathForSelectedRow] == nil){
            //select the first row after download
            [self tableView:self.charityList didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            }
            
            [self.loading removeFromSuperview];
        }
    }];
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView selectRowAtIndexPath:indexPath
                           animated:YES
                     scrollPosition:UITableViewScrollPositionMiddle];
    CharityCell *cell = (CharityCell *)[self tableView:self.charityList cellForRowAtIndexPath:indexPath];
    self.bottomImageView.image = cell.bottomImage;
    self.charityLabel.text = cell.charityTitle;
    self.information.selectable = YES;
    //set information text here
    self.information.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:13.0];
    self.information.text = cell.information;
    self.information.selectable = NO;

}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"Cell";
    
    CharityCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CharityCell" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (CharityCell *)currentObject;
                break;
            }
        }
    }
    
    //for data loaded from core data
    Charity *c = self.charityArray[indexPath.row];
    
    cell.cellImage.image = [UIImage imageWithData:c.charityImage];
    cell.bottomImage = [UIImage imageWithData:c.charityBottomImage];
    cell.charityTitle = c.charityName;
    cell.information = c.charityDescription;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.numberOfRows;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150.0;
}


- (IBAction)startChallenge:(id)sender {
    Charity *c = self.charityArray[[self.charityList indexPathForSelectedRow].row];

    
    //get the users info
    User *currentUser = [self.coreData getUserInfo];
    
    //send data to update the users current challenge
    [self.authService.client invokeAPI:@"selectsolochallenge" body:@{@"soloChallenge_idsoloChallenge": self.selectedChallenge.challengeID, @"User_idUser": currentUser.idUser} HTTPMethod:@"POST" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
        if(error){
            NSLog(@"%@", [error localizedDescription]);
        }
        else{
            //if the update is successful, update the users current charity
            NSLog(@"%ld", (long)response.statusCode);
            NSLog(@"%@", result);

            
            [self.authService.client invokeAPI:@"selectcharity" body:@{@"Charity_idCharity": c.charityID, @"User_idUser": currentUser.idUser} HTTPMethod:@"POST" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
                if(error){
                    NSLog(@"%@", [error localizedDescription]);
                }else{
                    NSLog(@"%ld", (long)response.statusCode);
                    NSLog(@"%@", result);
                    
                    //set the user challenges to the selected challenge
                    [self.coreData setCurrentChallenge:self.selectedChallenge];
                    [self.coreData setCurrentCharity:c];

                    //if updating the user charity is successful, go to the results screen
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
        }
    }];
}

-(void) backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
