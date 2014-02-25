//
//  Milestones.h
//  Momentum
//
//  Created by Joe on 25/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AbstractChallenge, Reward;

@interface Milestones : NSManagedObject

@property (nonatomic, retain) NSNumber * numStepsDone;
@property (nonatomic, retain) NSNumber * sequenceNum;
@property (nonatomic, retain) NSNumber * target;
@property (nonatomic, retain) Reward *rewardLinkedToMilestones;
@property (nonatomic, retain) AbstractChallenge *userChallenge;

@end
