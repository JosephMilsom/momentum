//
//  Sponsor.h
//  Momentum
//
//  Created by Joe on 17/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AbstractChallenge;

@interface Sponsor : NSManagedObject

@property (nonatomic, retain) NSSet *sponsorsChallenges;
@end

@interface Sponsor (CoreDataGeneratedAccessors)

- (void)addSponsorsChallengesObject:(AbstractChallenge *)value;
- (void)removeSponsorsChallengesObject:(AbstractChallenge *)value;
- (void)addSponsorsChallenges:(NSSet *)values;
- (void)removeSponsorsChallenges:(NSSet *)values;

@end
