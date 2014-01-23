//
//  CoreMotionTest.m
//  Momentum
//
//  Created by Joe on 14/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "CoreMotionTest.h"
#import <CoreMotion/CMStepCounter.h>

@interface CoreMotionTest ()

@property (strong, nonatomic) UILabel *stepsCountingLabel;
@property (nonatomic, strong) CMStepCounter *cmStepCounter;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation CoreMotionTest

- (NSOperationQueue *)operationQueue
{
    if (_operationQueue == nil)
    {
        _operationQueue = [NSOperationQueue new];
    }
    return _operationQueue;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([CMStepCounter isStepCountingAvailable])
    {
        self.cmStepCounter = [[CMStepCounter alloc] init];
        [self.cmStepCounter startStepCountingUpdatesToQueue:self.operationQueue updateOn:1 withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error)
         {
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                 [self updateStepCounterLabelWithStepCounter:numberOfSteps];
             }];
         }];
    }
    self.stepsCountingLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 50, 50)];
    [self.view addSubview:self.stepsCountingLabel];
}

- (void)updateStepCounterLabelWithStepCounter:(NSInteger)countedSteps
{
    self.stepsCountingLabel.text = [NSString stringWithFormat:@"%ld", (long)countedSteps];
}



@end
