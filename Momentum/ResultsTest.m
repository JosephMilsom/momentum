//
//  ResultsTest.m
//  Momentum
//
//  Created by Joe on 21/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "ResultsTest.h"

@implementation ResultsTest

- (void) viewDidLoad{
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, 100, 100)];
    label.text = @"IT WORKS";
    [self.view addSubview:label];
    
}

-(ResultsTest *) initWithIndex:(NSInteger)index{
    ResultsTest *t =[super init];
    t.index = index;
    return t;
}

@end

