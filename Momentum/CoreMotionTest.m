//
//  CoreMotionTest.m
//  Momentum
//
//  Created by Joe on 14/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "CoreMotionTest.h"
#import <CoreMotion/CoreMotion.h>

@interface CoreMotionTest ()

@property (strong, nonatomic) UILabel *stepsCountingLabel;
@property (nonatomic, strong) CMStepCounter *cmStepCounter;
@property (nonatomic, retain) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSMutableArray *accelSamples;

@end

CMMotionManager *motionManager;

float accelX;
float accelY;
float accelZ;
float lastX;
float lastY;
float lastZ;

CMAcceleration preAccel;
int steps;

int countTroughs = 0;
int countPeaks = 0;


BOOL peak = NO;
BOOL trough = NO;

BOOL waitStep = YES;

float maxAvg = -10000;
float minAvg = 10000;
float oldAvg = 0;
float newAvg = 0;
float avgThresh = 1/8192;

float max = -99;
float min = 99;



int stepFlag = 2;

int numSamples = 0;

@implementation CoreMotionTest

//what is up with this code???? Maybe it is automatically
//linked to the variable and returns??
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
    self.stepsCountingLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 200, 200, 100)];
    self.stepsCountingLabel.font = [UIFont systemFontOfSize:100];
    [self.view addSubview:self.stepsCountingLabel];
    
    
    motionManager = [[CMMotionManager alloc] init];
    motionManager.showsDeviceMovementDisplay = YES;
    motionManager.deviceMotionUpdateInterval = 1.0/20.0;
    
    //store the samples for the acceleration
    self.accelSamples = [[NSMutableArray alloc] init];
    
   // peaks = [[NSMutableArray alloc] init];
   // troughs = [[NSMutableArray alloc] init];
    
    //motion handler will only work if there is the acceleration being called in the
    //handler block
    
    CMDeviceMotionHandler  motionHandler = ^ (CMDeviceMotion *motion, NSError *error) {
        accelX = motionManager.deviceMotion.userAcceleration.x;
        accelY = motionManager.deviceMotion.userAcceleration.y;
        accelZ = motionManager.deviceMotion.userAcceleration.z;
        [self handleSteps];
    };
    
    [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:motionHandler];
}

-(void) handleSteps{
    
    if(self.accelSamples.count == 8){
        oldAvg = newAvg;
        newAvg -= [[self.accelSamples objectAtIndex:self.accelSamples.count-1] floatValue];
        [self.accelSamples removeObjectAtIndex:self.accelSamples.count-1];
    }

    //just using x and y in this implementation
    
    float d = sqrtf((float)ABS(accelX * accelX + accelY*accelY)/16.0);
    
    
    NSNumber *num = [[NSNumber alloc] initWithFloat:d];

    
    //NSLog(@"%f", d);
    

    
    [self.accelSamples insertObject:num atIndex:0];
    

    
    newAvg += d;
    
    if(ABS(newAvg - oldAvg) < avgThresh){
        newAvg = oldAvg;
    }
    NSLog(@"%f", oldAvg);
    
    if([self isStepWithNewAvg:newAvg oldAvg:oldAvg] && waitStep == YES){
        [self updateLabelWithStepCount];
        waitStep = NO;
        [self performSelector:@selector(wakeUp) withObject:nil afterDelay:0.2];
        maxAvg = -99.0;
        minAvg = 99.0;
    }
    
   // lastX = accelX;
   // lastY = accelY;
   // lastZ = accelZ;
}

-(void)wakeUp{
    waitStep = YES;
}

-(void) updateLabelWithStepCount{
     steps++;
     self.stepsCountingLabel.text = [[NSString alloc] initWithFormat:@"%d",steps];
}

-(BOOL)isStepWithNewAvg:(float)avg oldAvg:(float)oldAvg{
    float stepThresh = 5.0/8192.0;
    
    //NSLog(@"%f", avg);
    //NSLog(@"%d", stepFlag);
    
    if (stepFlag == 2)
    {
        if (avg > (oldAvg + stepThresh))
            stepFlag = 1;
        if (avg < (oldAvg - stepThresh))
            stepFlag = 0;
        return NO;
    } // first time through this function
    
    if (stepFlag == 1)
    {
        if ((maxAvg > minAvg) && (avg >
                                  ((maxAvg+minAvg)/2)) &&
            (oldAvg < ((maxAvg+minAvg/2))))
            return YES;
        if (avg < (oldAvg - stepThresh))
        {
            stepFlag = 0;
            if (oldAvg > maxAvg)
                maxAvg = oldAvg;
        } // slope has turned down
        return NO;
    } // slope has been up
    
    if (stepFlag == 0)
    {
        if (avg > (oldAvg + stepThresh))
        {
            stepFlag = 1;
            if (oldAvg < minAvg)
                minAvg = oldAvg;
        } // slope has turned up
        return NO;
    } // slope has been down
    
    return 0;


    return NO;
}


@end
