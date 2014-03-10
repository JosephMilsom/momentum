//
//  ChallengeProgress.h
//  Momentum
//
//  Created by Joe on 27/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AbstractChallenge;

@interface ChallengeProgress : NSManagedObject

@property (nonatomic, retain) NSNumber * stepsDone;
@property (nonatomic, retain) AbstractChallenge *challenge;

@end
