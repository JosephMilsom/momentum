//
//  Reward.h
//  Momentum
//
//  Created by Joe on 17/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Milestones;

@interface Reward : NSManagedObject

@property (nonatomic, retain) NSSet *milestonesLinkedToReward;
@end

@interface Reward (CoreDataGeneratedAccessors)

- (void)addMilestonesLinkedToRewardObject:(Milestones *)value;
- (void)removeMilestonesLinkedToRewardObject:(Milestones *)value;
- (void)addMilestonesLinkedToReward:(NSSet *)values;
- (void)removeMilestonesLinkedToReward:(NSSet *)values;

@end
