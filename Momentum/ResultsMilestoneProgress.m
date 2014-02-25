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

@interface ResultsMilestoneProgress ()
@property (strong, nonatomic) IBOutlet UILabel *challengeName;
@property (weak, nonatomic) IBOutlet UILabel *currentMilestone;
@property (weak, nonatomic) IBOutlet UILabel *currentPercentage;
@property (weak, nonatomic) IBOutlet UILabel *amountRaised;
@property (weak, nonatomic) IBOutlet UILabel *progress;
@property (strong, nonatomic) Pedometer *pedometer;


@end

@implementation ResultsMilestoneProgress



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pedometer = [[Pedometer alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStepsLabel) name:@"UpdateSteps" object:nil];
    [self.pedometer startPedometer];
}

- (void)viewDidAppear:(BOOL)animated{
    CoreDataSingleton *coreData = [CoreDataSingleton new];
    User *user = [coreData getUserInfo];
    self.challengeName.text = user.userChallenge.challengeName;
    NSLog(@"%@",user.userChallenge.challengeName);
}

- (void) updateStepsLabel{
    NSInteger i = [self.progress.text integerValue];
    i++;
    self.progress.text = [NSString stringWithFormat:@"%ld", (long)i];
}



@end
