//
//  AbstractChallenge.h
//  Momentum
//
//  Created by Joe on 21/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Charity, Milestones, Sponsor, User;

@interface AbstractChallenge : NSManagedObject

@property (nonatomic, retain) NSData * challengeBottomImage;
@property (nonatomic, retain) NSString * challengeDescription;
@property (nonatomic, retain) NSNumber * challengeID;
@property (nonatomic, retain) NSData * challengeImage;
@property (nonatomic, retain) NSString * challengeName;
@property (nonatomic, retain) NSNumber * challengeType;
@property (nonatomic, retain) NSSet *challengeMilestones;
@property (nonatomic, retain) Sponsor *challengeSponsor;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Charity *charity;
@end

@interface AbstractChallenge (CoreDataGeneratedAccessors)

- (void)addChallengeMilestonesObject:(Milestones *)value;
- (void)removeChallengeMilestonesObject:(Milestones *)value;
- (void)addChallengeMilestones:(NSSet *)values;
- (void)removeChallengeMilestones:(NSSet *)values;

@end
