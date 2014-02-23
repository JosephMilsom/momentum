//
//  UpdateHandler.h
//  Momentum
//
//  Created by Joe on 24/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateHandler : NSObject

-(void) challengeUpdateWithCompletion:(void (^)(void))completion;
-(void) charityUpdate;

@end
