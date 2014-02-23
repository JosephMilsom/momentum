//
//  FacebookSingleton.m
//  Momentum
//
//  Created by Joe on 3/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "FacebookSingleton.h"

@implementation FacebookSingleton

//create a static instance of the class for reuse
static FacebookSingleton *instance;

//class method, it will return the instance if it exists
//else it creates
+ (FacebookSingleton *) getInstance{
    if(instance == nil){
        instance = [[super alloc] init];
    }
    return instance;
}


@end


