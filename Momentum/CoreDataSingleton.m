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
#import "Milestones.h"
#import "ChallengeProgress.h"


@interface CoreDataSingleton()

/**
 *  this is the managed object context which is used to save information
 */
    @property (strong, nonatomic) NSManagedObjectContext *context;
@end

@implementation CoreDataSingleton

/**
 *  override the init method
 *
 *  @return new instance of the core data class
 */
- (CoreDataSingleton*) init{
    self = [super init];
    
    if (self) {
        self.context = [(FBCDAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    return self;
}

#pragma mark challenge core data methods
/**
 *  add a new solo challenge to core data
 *
 *  @param data nsdictionary of what has been returned from the server
 */
- (void) addSoloChallenge:(NSDictionary *)data{
    //create a new solo challenge, and initialise with data from the server
    SoloChallenge *challenge = [NSEntityDescription insertNewObjectForEntityForName:@"SoloWalkingChallenge" inManagedObjectContext:self.context];
    challenge.challengeDescription = [data valueForKey:@"sChallengeDesc"];
    challenge.challengeName = [data valueForKey:@"sChallengeName"];
    challenge.challengeID = [data valueForKey:@"idsoloChallenge"];
    challenge.challengeType = [data valueForKey:@"sChallengeType_idsChallengeType"];
    
    //get the milestones associated with the challenge
    NSArray *milestones = [data objectForKey:@"milestones"];
    
    //set the number of milestones in the app
    challenge.numberOfMilestones = [[NSNumber alloc] initWithInteger:milestones.count];
    NSLog(@"Number of milestones %lu", (unsigned long)milestones.count);
    
    //go through each of the milestones, and for each milestone set the
    //challenge that it is associated with to the challenge
    for(int i = 0; i < milestones.count; i++){
        NSDictionary *milestone = milestones[i];
        Milestones *m = [NSEntityDescription insertNewObjectForEntityForName:@"Milestones" inManagedObjectContext:self.context];
        m.sequenceNum = [milestone objectForKey:@"sMilestoneSeq"];
        m.target = [milestone objectForKey:@"sTarget"];
        m.numStepsDone = [[NSNumber alloc] initWithInt:0];
        m.milestoneDesc = [milestone objectForKey:@"sMilestoneDesc"];
        m.userChallenge = challenge;
    }
    
    //set the current milestone of the challenge to one, start at the beginning!!
    challenge.currentMilestone = [[NSNumber alloc] initWithInt:1];
    
    //also initialise a challenge progress entity, this is so that if the
    //user leaves the challenge then his progress is removed
    ChallengeProgress *progress = [NSEntityDescription insertNewObjectForEntityForName:@"ChallengeProgress" inManagedObjectContext:self.context];
    progress.challenge = challenge;
    
    //save the information into the context
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Error saving: %@", [error localizedDescription]);
    }
}

/**
    Set the current challenge to the user. Also handles
    situation if the user is already part of a challenge
    and it resets all the progress
 *
 *  @param challenge the users new challenge
 */
- (void) setCurrentChallenge:(AbstractChallenge *)challenge{
    User *currentUser = [self getUserInfo];
    
    if(currentUser.userChallenge != nil){
        [self removeCurrentChallenge];
    }
    
    currentUser.userChallenge = challenge;
    
    
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Error saving: %@", [error localizedDescription]);
    }
}

/**
    removes the current challenge and it will reset all
    the progress that has been done ie by removing the challenge
    progress from the total step count as well as resetting all the 
    milestones to 0
 */
- (void) removeCurrentChallenge{
    User *currentUser = [self getUserInfo];
    
    //get progress of the current challenge
    ChallengeProgress *progress = currentUser.userChallenge.challengeProgress;
    
    //reset the total steps counted to what was before the challenge started
    currentUser.totalSteps = [[NSNumber alloc] initWithInteger:[currentUser.totalSteps integerValue] - [progress.stepsDone integerValue]];
    progress.stepsDone = 0;
    
    //reset the number of milestones done in each milestone to 0
    for(Milestones *m in currentUser.userChallenge.challengeMilestones){
        m.numStepsDone = 0;
    }
    
    //reset the current milestone of the challenge to the first one
    currentUser.userChallenge.currentMilestone = [[NSNumber alloc] initWithInteger:1];
    
    //save the information to the context
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Error saving: %@", [error localizedDescription]);
    }
}

/**
 *  Method for getting the users current challenge
 *
 *  @return the users current challenge
 */
- (AbstractChallenge *) getCurrentChallenge{
    User *currentUser = [self getUserInfo];
    return currentUser.userChallenge;
}

/**
 *  This will add image data from the challenges to core data
 
 *
 *  @param chalImg   data for the challenge image
 *  @param btmImg    data for the bottom image
 *  @param challenge the challenge to save the information
 */
- (void) addChallengeImageData:(NSData *)chalImg andBottomImageData:(NSData *)btmImg forChallenge:(NSString *)challenge{
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SoloWalkingChallenge" inManagedObjectContext:self.context];
    [request setEntity:entity];
    [request setPredicate:[NSPredicate predicateWithFormat:@"challengeName==%@", challenge]];
    
    NSError *e = nil;
    NSArray *fetchResults = [self.context executeFetchRequest:request error:&e];
    
    for(SoloChallenge *s in fetchResults){
        s.challengeImage = chalImg;
        s.challengeBottomImage = btmImg;
    }
    
    if (![self.context save:&e]) {
        NSLog(@"Error saving: %@", [e localizedDescription]);
    }
}

#pragma mark charity methods
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

    //needs this, else error thrown by wrong type by register
    NSNumber *num = [[NSNumber alloc] initWithInt:(int)[data valueForKey:@"Gender_idGender"]];
    
    user.gender = num;
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

/**
    Return the number of steps that have been done in the
    current milestone.
 
    @return NSInteger number of steps
 */
- (NSInteger) getSteps{
    User *user = [self getUserInfo];
    
    AbstractChallenge *currentChallenge = user.userChallenge;
    
    Milestones *currentMilestone;
    
    for(Milestones *m in [currentChallenge challengeMilestones]){
        if(m.sequenceNum == currentChallenge.currentMilestone){
            currentMilestone = m;
        }
    }
    
    NSError *e = nil;
    
    if (![self.context save:&e]) {
        NSLog(@"Error saving: %@", [e localizedDescription]);
    }
    
    return [currentMilestone.numStepsDone integerValue];
}


/**
    Increment the number of steps in both the current milestone
    and the total number of steps done.
 
    @return the new value of steps for the current milestone
 */
- (NSInteger) countSteps{
    User *user = [self getUserInfo];
    
    //get the current challenge the user is a part of
    AbstractChallenge *currentChallenge = user.userChallenge;
    
    //get the total progress for the challenge
    ChallengeProgress *progress = user.userChallenge.challengeProgress;
    
    //get the current milestone, and its associated progress, to increment
    Milestones *currentMilestone;
    
    for(Milestones *m in [currentChallenge challengeMilestones]){
        if(m.sequenceNum == currentChallenge.currentMilestone){
            currentMilestone = m;
        }
    }
    
    //get number of steps done for this milestone, increment it and set the new value
    NSInteger mSteps = [currentMilestone.numStepsDone integerValue];
    mSteps++;
    currentMilestone.numStepsDone = [[NSNumber alloc] initWithInteger:mSteps];
    
    //get number of steps done in total, increment it and set the new value
    NSInteger totSteps = [user.totalSteps integerValue];
    totSteps++;
    user.totalSteps = [[NSNumber alloc] initWithInteger:totSteps];
    
    //increment the total challenge progress, per challenge.
    //useful if user quits challenge, this will remove all the
    //steps done, (if we want to do it this way)
    NSInteger progSteps = [progress.stepsDone integerValue];
    progSteps++;
    progress.stepsDone = [[NSNumber alloc] initWithInteger:progSteps];
    
    NSError *e = nil;
    
    if (![self.context save:&e]) {
        NSLog(@"Error saving: %@", [e localizedDescription]);
    }
    
    return [currentMilestone.numStepsDone integerValue];
}
@end


