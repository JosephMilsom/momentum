//
//  ResultsMilestoneProgress.m
//  Momentum
//
//  Created by Joe on 24/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "ResultsMilestoneProgress.h"
#import <QuartzCore/QuartzCore.h>
#import "CoreDataSingleton.h"
#import "User.h"
#import "Pedometer.h"
#import <CoreMotion/CoreMotion.h>
#import "ChallengeProgress.h"
//#import <CoreLocation/CoreLocation.h>

@interface ResultsMilestoneProgress ()
@property (strong, nonatomic) IBOutlet UILabel *challengeName;
@property (weak, nonatomic) IBOutlet UILabel *currentMilestone;
@property (weak, nonatomic) IBOutlet UILabel *currentPercentage;
@property (weak, nonatomic) IBOutlet UILabel *amountRaised;
@property (weak, nonatomic) IBOutlet UILabel *progress;
@property (strong, nonatomic) Pedometer *pedometer;
@property (strong, nonatomic) CLLocationManager *locManager;

@end

@implementation ResultsMilestoneProgress



- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.pedometer = [[Pedometer alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStepsLabel) name:@"UpdateSteps" object:nil];
        
    [self.pedometer startPedometer];
    
    //refresh text label information
    CoreDataSingleton *coreData = [CoreDataSingleton new];
    User *user = [coreData getUserInfo];
    self.challengeName.text = user.userChallenge.challengeName;
    self.progress.text = [NSString stringWithFormat:@"%ld", (long)[coreData getSteps]];
    
    self.locManager = [CLLocationManager new];
    [self.locManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];
    self.locManager.delegate = self;
    [self.locManager startUpdatingLocation];
    
}

- (void)viewDidAppear:(BOOL)animated{
    CoreDataSingleton *coreData = [CoreDataSingleton new];
    User *user = [coreData getUserInfo];
    self.challengeName.text = user.userChallenge.challengeName;
    self.progress.text = [NSString stringWithFormat:@"%ld", (long)[coreData getSteps]];

    
}

- (void) updateStepsLabel{
    CoreDataSingleton *coreData = [CoreDataSingleton new];
    User *user = [coreData getUserInfo];
    
    NSInteger i = [coreData countSteps];
    
    NSLog(@"%ld", (long)i);
    
    self.progress.text = [NSString stringWithFormat:@"%ld", (long)i];
    //[self.progress setNeedsDisplay];
    
    NSLog(@"%@",self.progress.text);
//
//
//    NSLog(@"Total Steps: %ld",(long)[user.totalSteps integerValue]);
//    NSLog(@"Challenge Progress: %ld",(long)[user.userChallenge.challengeProgress.stepsDone integerValue]);
//    NSLog(@"Milestones Progress: %ld",(long)[coreData getSteps]);

}

-(void) applicationDidEnterBackground:(UIApplication *)application{
    
    
}

- (void) killPedometer{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateSteps" object:nil];
}


@end
