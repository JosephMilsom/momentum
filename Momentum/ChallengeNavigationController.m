//
//  ChallengeNavigationController.m
//  Momentum
//
//  Created by Joe on 24/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "ChallengeNavigationController.h"

@interface ChallengeNavigationController ()

@end

@implementation ChallengeNavigationController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UINavigationBar *bar = self.navigationBar;
    [bar setBackgroundImage:[UIImage imageNamed:@"NavBar2.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.title = @"CHALLENGES";
    //[bar se];
   
}

- (void) viewDidAppear:(BOOL)animated{
    
    
}



@end
