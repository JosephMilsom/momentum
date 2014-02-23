//
//  Charity.h
//  Momentum
//
//  Created by Joe on 21/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AbstractChallenge;

@interface Charity : NSManagedObject

@property (nonatomic, retain) NSData * charityBottomImage;
@property (nonatomic, retain) NSString * charityDescription;
@property (nonatomic, retain) NSNumber * charityID;
@property (nonatomic, retain) NSData * charityImage;
@property (nonatomic, retain) NSString * charityName;
@property (nonatomic, retain) AbstractChallenge *challenge;

@end
