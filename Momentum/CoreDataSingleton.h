//
//  CoreDataSingleton.h
//  Momentum
//
//  Created by Joe on 14/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "AbstractChallenge.h"

@interface CoreDataSingleton : NSObject

- (void) addSoloChallenge:(NSDictionary * )data;

- (void) setCurrentChallenge:(AbstractChallenge *)challenge;

- (void) removeCurrentChallenge;

- (AbstractChallenge *) getCurrentChallenge;

- (void) addCharity:(NSDictionary * )data;

- (void) setCurrentCharity:(Charity *)charity;

- (void) removeCurrentCharity;

//USER
- (void) saveUserInfo:(NSDictionary *)data;

- (void) deleteUserInfo;

- (User *) getUserInfo;


-(NSArray *) fetchEntitiesOfType:(NSString *)entityName;

- (void) addChallengeImageData:(NSData *)chalImg andBottomImageData:(NSData *)btmImg forChallenge:(NSString *)challenge;

- (void) addCharityImageData:(NSData *)charImg andBottomImageData:(NSData *)btmImg forCharity:(NSString *)charity;

- (void) deleteAllEntitiesOfType:(NSString *)entityName;


- (void) purgeBrokenChallenges;

- (void) purgeBrokenCharities;

- (NSInteger) countSteps;

- (NSInteger) getSteps;


//TEST FUNCTION
- (void) deleteSpecificChallenge:(NSString *)entityName;


@end
