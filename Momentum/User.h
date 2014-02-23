//
//  User.h
//  Momentum
//
//  Created by Joe on 21/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AbstractChallenge;

@interface User : NSManagedObject

@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * totalCyclingDist;
@property (nonatomic, retain) NSNumber * totalRunningDist;
@property (nonatomic, retain) NSNumber * totalSteps;
@property (nonatomic, retain) NSNumber * totalWalkingDist;
@property (nonatomic, retain) NSNumber * idUser;
@property (nonatomic, retain) NSNumber * totalAmountRaised;
@property (nonatomic, retain) AbstractChallenge *userChallenge;

@end
