//
//  Pedometer.m
//  Momentum
//
//  Created by Joe on 25/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "Pedometer.h"
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>


@interface Pedometer()

@property (nonatomic, retain) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSMutableArray *accelSamples;
@property (nonatomic, strong) AVAudioPlayer *audio;



@end

CMMotionManager *motionManager;
CMMotionActivityManager *activityType;


float accelX;
float accelY;
float accelZ;
float lastX=1;
float lastY=1;
float lastZ=1;

float thresh;

int steps;

BOOL waitStep = YES;
BOOL firstFlag= NO;

BOOL hasChanged = NO;
BOOL isStep = NO;

BOOL canUpdate = NO;

@implementation Pedometer

- (NSOperationQueue *)operationQueue
{
    if (_operationQueue == nil)
    {
        _operationQueue = [NSOperationQueue new];
    }
    return _operationQueue;
}

- (void)startPedometer
{
    steps = 0;
    
    motionManager = [[CMMotionManager alloc] init];
    motionManager.showsDeviceMovementDisplay = YES;
    motionManager.deviceMotionUpdateInterval = 1.0/50.0;
    
    activityType = [[CMMotionActivityManager alloc] init];
    
    //store the samples for the acceleration
    self.accelSamples = [[NSMutableArray alloc] init];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    UIApplication* app = [UIApplication sharedApplication];
    
    UIBackgroundTaskIdentifier bgTask = 0;
    
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        __block bgTask = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CMDeviceMotionHandler  motionHandler = ^ (CMDeviceMotion *motion, NSError *error) {
            accelX = ABS(motionManager.deviceMotion.userAcceleration.x + motionManager.deviceMotion.gravity.x);
            accelY = ABS(motionManager.deviceMotion.userAcceleration.y + motionManager.deviceMotion.gravity.y);
            accelZ = ABS(motionManager.deviceMotion.userAcceleration.z + motionManager.deviceMotion.gravity.z);
            [self handleSteps];
        };
        
        //self.operationQueue = [self operationQueue];
        //NSLog(@"%d", (int)[app backgroundTimeRemaining]);
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:motionHandler];
    });

}

-(void) handleSteps{
    thresh = 1;
    if(self.accelSamples.count == 8){
        float sum = 0;
        for(NSNumber *n in self.accelSamples){
            sum += [n doubleValue];
        }
        thresh = sum/8;
        [self.accelSamples removeObjectAtIndex:0];
        
    }
    
    double oldValue = ((lastX * accelX) + (lastY * accelY)) + (lastZ * accelZ);
    double oldValueSqrt = ABS(sqrtf((double) (((lastX * lastX) + (lastY * lastY)) + (lastZ * lastZ))));
    double newValue = ABS(sqrtf((double) (((accelX * accelX) + (accelY * accelY)) + (accelZ * accelZ))));
    
    oldValue /= oldValueSqrt * newValue;
    
    NSNumber *num = [[NSNumber alloc] initWithDouble:oldValue];
    [self.accelSamples addObject:num];
    
    //NSLog(@"%f", thresh);
    
    //should be thresh??
    //0.998??
    if ((thresh) < 0.998 && (thresh > 0.9))
    {
        if (!hasChanged && waitStep)
        {
            hasChanged = YES;
            
            //this is just for the first time,
            //get rid of that annoying first step
            if(firstFlag == YES)
                isStep = YES;
           
            firstFlag = YES;
        }
    }
    else {
        hasChanged = NO;
    }
    
    if(isStep == YES && waitStep == YES && hasChanged == YES){
        isStep = NO;
        waitStep = NO;
        
        
        NSLog(@"%f",[[UIApplication sharedApplication] backgroundTimeRemaining]);
        
        [self updateSteps];
        
        NSLog(@"%f", thresh);
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(wakeUp) userInfo:NO repeats:NO];
        
    }
    
    lastX = accelX;
    lastY = accelY;
    lastZ = accelZ;
}

- (void) wakeUp{
    waitStep = YES;
}


- (void) updateSteps{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateSteps" object:nil ];
}


@end
