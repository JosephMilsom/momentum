//
//  ResultsViewController.m
//  Momentum
//
//  Created by Joe on 21/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "ResultsViewController.h"
#import "ResultsMilestoneProgress.h"
#import "AuthService.h"
#import "CoreDataSingleton.h"
#import "User.h"
#import "SoloChallenge.h"
#import "Charity.h"
#import "UIImage+animatedGIF.h"


@interface ResultsViewController()

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (nonatomic) NSInteger index;
@property (strong, nonatomic) AuthService *authService;
@property (strong, nonatomic) CoreDataSingleton *coreData;
@property (strong, nonatomic) UIStoryboard *layoutStoryboard;
@property (strong, nonatomic) ResultsMilestoneProgress *results;
@property (weak, nonatomic) IBOutlet UIImageView *resultsBackground;

//these are test buttons
@property (weak, nonatomic) IBOutlet UIButton *progressButton;
@property (weak, nonatomic) IBOutlet UIButton *challengeButton;


- (IBAction)soloProgUpdate:(id)sender;

@end


@implementation ResultsViewController

- (void) viewDidLoad{
    UIImage *img = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:@"http://media3.giphy.com/media/kIi56vFHsAlb2/giphy.gif"]];
    
    self.resultsBackground.image = img;
    
    self.layoutStoryboard = [UIStoryboard storyboardWithName:@"ResultsStoryboard" bundle:[NSBundle mainBundle]];
    self.results = [self.layoutStoryboard instantiateViewControllerWithIdentifier:@"ResultsMilestoneProgress"];
    
    [self addChildViewController:self.results];
    [self.results didMoveToParentViewController:self];
    
    //these are for testing
    [self.results.view addSubview:self
     .progressButton];
    [self.results.view addSubview:self
     .challengeButton];
    [self.view addSubview:self.results.view];
    
    self.authService = [AuthService getInstance];

}

-(void) viewDidAppear:(BOOL)animated{
    //this is here as the frame is resized after view did load
    //else we would have the frame 
    CGRect frame = self.results.view.frame;
    frame.size.height = self.view.frame.size.height;
    self.results.view.frame = frame;
    
}


- (IBAction)soloProgUpdate:(id)sender {
    CoreDataSingleton *coreData = [[CoreDataSingleton alloc] init];
    
    User*user = [coreData getUserInfo];
    
    
    NSLog(@"%@",user.userChallenge.challengeName);
    NSLog(@"%@", user.userChallenge.charity.charityName);
    NSDictionary *dict = @{@"User_idUser" : user.idUser, @"soloChallenge_idsoloChallenge": user.userChallenge.challengeID, @"steps": @"0", @"walkD": user.totalWalkingDist, @"runD": user.totalRunningDist, @"cycleD": @"200", @"challengeComplete": @"1", @"sChallengeAmountRaised" : @"10"};
    //user.totalAmountRaised
    
    [self.authService.client invokeAPI:@"soloprogressupdate" body:dict HTTPMethod:@"POST" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
        if(error){
            NSLog(@"%@", [error localizedDescription]);
        }
        else{
            NSLog(@"Success");
            NSLog(@"%@", result);
        }
    }];
}
@end
