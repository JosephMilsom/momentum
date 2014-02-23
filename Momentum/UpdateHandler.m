//
//  UpdateHandler.m
//  Momentum
//
//  Created by Joe on 24/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "UpdateHandler.h"
#import "CoreDataSingleton.h"
#import "SoloChallenge.h"
#import "AuthService.h"

@interface UpdateHandler()
@property (strong, nonatomic) AuthService *authService;
@property (strong, nonatomic) CoreDataSingleton *coreData;
@property (strong, nonatomic) NSOperationQueue *loadFromServer;

@end

@implementation UpdateHandler

- (UpdateHandler *) init{
    self = [super init];
    
    self.authService = [AuthService getInstance];
    self.coreData = [CoreDataSingleton new];
    
    self.loadFromServer = [NSOperationQueue new];
    
    return self;
}

- (void) challengeUpdateWithCompletion:(void (^)(void))completion{
    
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
            //result is an array of dictionaries
            NSArray *challenges = result;
            
            NSMutableArray *paths = [NSMutableArray new];
            
            //an async task to fetch data from the server
            self.loadFromServer = [[NSOperationQueue alloc] init];
            self.loadFromServer.name = @"loadImagesFromServer";
            
            for (int i = 0; i < challenges.count; i++) {
                //add to the list of index paths for the tableview insert row method,
                //creates a new row at the end and will add it
                
                //add the challenge dict(from the results) to the array of challenges
                NSDictionary *challengeData = challenges[i];
                
                //add new challenges to coredata
                [self.coreData addSoloChallenge:challengeData];
                
                //asynchronous fetch for the images
                [self.loadFromServer addOperationWithBlock:^{
                    //image for the challenge
                    NSURL *url = [NSURL URLWithString:[challenges[i] valueForKey:@"sChallengeImage"]];
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    
                    //image for the bottom image
                    NSURL *urlBottom = [NSURL URLWithString:[challenges[i] valueForKey:@"sChallengeImageBtm"]];
                    NSData *dataBottom = [NSData dataWithContentsOfURL:urlBottom];
                    
                    //update the ui
                    [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                        //set the data for the image in core data
                        [self.coreData addChallengeImageData:data andBottomImageData:dataBottom forChallenge:[challenges[i] valueForKey:@"sChallengeName"]];
                        
                    }];
                }];
            }
        }
        
    }];
    
}


-(void) charityUpdate{
    
    
}
@end














