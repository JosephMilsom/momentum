//
//  CoreDataSingleton.m
//  Momentum
//
//  Created by Joe on 14/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "CoreDataSingleton.h"
#import "FBCDAppDelegate.h"
#import "SoloChallenge.h"
#import "Charity.h"
#import "User.h"

@interface CoreDataSingleton()
    @property (strong, nonatomic) NSManagedObjectContext *context;
@end

@implementation CoreDataSingleton

static CoreDataSingleton *singletonInstance;

+(CoreDataSingleton*) getInstance{
    
    if(singletonInstance == nil){
        CoreDataSingleton* cds = [[super alloc] init];
        return cds;
     }
    return singletonInstance;
}

- (CoreDataSingleton*) init{
    self = [super init];
    
    if (self) {
        self.context = [(FBCDAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    return self;
}


- (void) addSoloChallenge:(NSDictionary *)data{
    SoloChallenge *challenge = [NSEntityDescription insertNewObjectForEntityForName:@"SoloWalkingChallenge" inManagedObjectContext:self.context];
    challenge.challengeDescription = [data valueForKey:@"sChallengeDesc"];
    challenge.challengeName = [data valueForKey:@"sChallengeName"];
    challenge.challengeID = [data valueForKey:@"idsoloChallenge"];
    challenge.challengeType = [data valueForKey:@"sChallengeType_idsChallengeType"];
    
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Error saving: %@", [error localizedDescription]);
    }
}

- (void) setCurrentChallenge:(AbstractChallenge *)challenge{
    User *currentUser = [self getUserInfo];
    currentUser.userChallenge = challenge;
    
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Error saving: %@", [error localizedDescription]);
    }
}

- (void) removeCurrentChallenge{
    User *currentUser = [self getUserInfo];
    currentUser.userChallenge = nil;
    
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Error saving: %@", [error localizedDescription]);
    }
}

- (AbstractChallenge *) getCurrentChallenge{
    User *currentUser = [self getUserInfo];
    return currentUser.userChallenge;
}


- (void) addChallengeImageData:(NSData *)chalImg andBottomImageData:(NSData *)btmImg forChallenge:(NSString *)challenge{
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SoloWalkingChallenge" inManagedObjectContext:self.context];
    [request setEntity:entity];
    [request setPredicate:[NSPredicate predicateWithFormat:@"challengeName==%@", challenge]];
    
    NSError *e = nil;
    NSArray *fetchResults = [self.context executeFetchRequest:request error:&e];
    
    for(SoloChallenge *s in fetchResults){
        //NSLog(@"%@", s.challengeName);
        s.challengeImage = chalImg;
        s.challengeBottomImage = btmImg;
    }
    
    if (![self.context save:&e]) {
        NSLog(@"Error saving: %@", [e localizedDescription]);
    }
}


- (void) addCharity:(NSDictionary *)data{
    Charity *charity = [NSEntityDescription insertNewObjectForEntityForName:@"Charity" inManagedObjectContext:self.context];
    charity.charityDescription = [data valueForKey:@"charityDesc"];
    charity.charityName = [data valueForKey:@"charityName"];
    charity.charityID = [data valueForKey:@"idCharity"];
    
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Error saving: %@", [error localizedDescription]);
    }
}

- (void) setCurrentCharity:(Charity *)charity{
    User *currentUser = [self getUserInfo];
    currentUser.userChallenge.charity = charity;
    
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Error saving: %@", [error localizedDescription]);
    }
}

- (void) removeCurrentCharity{
    User *currentUser = [self getUserInfo];
    currentUser.userChallenge.charity = nil;
    
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Error saving: %@", [error localizedDescription]);
    }
}

//add image data for charities
- (void) addCharityImageData:(NSData *)charImg andBottomImageData:(NSData *)btmImg forCharity:(NSString *)charity{
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Charity" inManagedObjectContext:self.context];
    [request setEntity:entity];
    [request setPredicate:[NSPredicate predicateWithFormat:@"charityName==%@", charity]];
    
    NSError *e = nil;
    NSArray *fetchResults = [self.context executeFetchRequest:request error:&e];
    
    for(Charity *c in fetchResults){
        //NSLog(@"%@", c.charityName);
        c.charityImage = charImg;
        c.charityBottomImage = btmImg;
    }
    
    if (![self.context save:&e]) {
        NSLog(@"Error saving: %@", [e localizedDescription]);
    }
}

//return the list of entities
-(NSArray *) fetchEntitiesOfType:(NSString *)entityName{
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:self.context];
    [request setEntity:entity];
    //[request set]
    NSError *e = nil;
    NSArray *fetchResults = [self.context executeFetchRequest:request error:&e];
    
    return fetchResults;
}

//make generic
-(void) deleteAllEntitiesOfType:(NSString *)entityName{
    NSArray *toDel = [self fetchEntitiesOfType:entityName];
    
    for (NSManagedObject *s in toDel){
        [self.context deleteObject:s];
    }
    
    NSError *e = nil;

    if (![self.context save:&e]) {
        NSLog(@"Error saving: %@", [e localizedDescription]);
    }
}

-(void) deleteSpecificChallenge:(NSString *)entityName{
    NSArray *toDel = [self fetchEntitiesOfType:entityName];
    
    int c = 1;
    for (NSManagedObject *s in toDel){
        if(c == toDel.count){
            [self.context deleteObject:s];
            break;
        }
        c++;
    }
    
    NSError *e = nil;
    
    if (![self.context save:&e]) {
        NSLog(@"Error saving: %@", [e localizedDescription]);
    }
}

//need a purge
/**
 *  Method that gets rid of malformed challenges
 */
- (void) purgeBrokenChallenges{
    NSArray *broken = [self fetchEntitiesOfType:@"SoloWalkingChallenge"];
    
    for(SoloChallenge *s in broken){
        if(s.challengeImage == nil || s.challengeBottomImage==nil){
            [self.context deleteObject:s];
        }
    }
}


- (void) purgeBrokenCharities{
    NSArray *broken = [self fetchEntitiesOfType:@"Charity"];
    
    for(Charity *s in broken){
        if(s.charityImage == nil || s.charityBottomImage==nil){
            [self.context deleteObject:s];
        }
    }
}

- (void) saveUserInfo:(NSDictionary *)data{
    User *user = (User*)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.context];
    NSLog(@"%@", [data valueForKey:@"firstName"]);
    user.firstName = [data valueForKey:@"firstName"];
    user.lastName = [data valueForKey:@"lastName"];
    user.idUser = [data valueForKey:@"idUser"];
    user.emailAddress = [data valueForKey:@"emailAddress"];
    user.gender = [data valueForKey:@"Gender_idGender"];
    user.totalAmountRaised = [data valueForKey:@"totalAmountRaised"];
    user.totalCyclingDist = [data valueForKey:@"totalCycleDist"];
    user.totalRunningDist = [data valueForKey:@"totalRunDist"];
    user.totalWalkingDist = [data valueForKey:@"totalWalkDist"];
    user.totalSteps = [data valueForKey:@"totalSteps"];
    
    NSError *e = nil;
    if(![self.context save:&e]){
        NSLog(@"error : %@", [e localizedDescription]);
    }
}

- (void) deleteUserInfo{
    NSArray *user = [self fetchEntitiesOfType:@"User"];
    
    for(User *u in user){
        [self.context deleteObject:u];
    }
    
    NSError *e = nil;
    if(![self.context save:&e]){
        NSLog(@"error : %@", [e localizedDescription]);
    }
}

- (User *) getUserInfo{
    NSArray *user = [self fetchEntitiesOfType:@"User"];
    
    if(user.count > 0){
        if(user[0] != nil){
        return user[0];
        }
    }
    
    return nil;
}
@end


