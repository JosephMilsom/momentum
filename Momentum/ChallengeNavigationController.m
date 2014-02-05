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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UINavigationBar *bar = self.navigationBar;
    [bar setBackgroundImage:[UIImage imageNamed:@"NavBar.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.title = @"CHALLENGES";
    //[bar se];
   
}

- (void) viewDidAppear:(BOOL)animated{
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
