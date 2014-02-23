//
//  ResultsViewController.m
//  Momentum
//
//  Created by Joe on 21/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "ResultsViewController.h"
#import "ResultsTest.h"
#import "AuthService.h"
#import "CoreDataSingleton.h"
#import "User.h"
#import "SoloChallenge.h"
#import "Charity.h"


@interface ResultsViewController()

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (nonatomic) NSInteger index;
@property (strong, nonatomic) AuthService *authService;
@property (strong, nonatomic) CoreDataSingleton *coreData;

@end


@implementation ResultsViewController

- (void) viewDidLoad{
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    NSArray* arr = @[[[ResultsTest alloc] initWithIndex:0]];
    
    [self.pageViewController setViewControllers:arr direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    self.authService = [AuthService getInstance];
    CoreDataSingleton *coreData = [CoreDataSingleton getInstance];
    
    User*user = [coreData getUserInfo];
    
    
    NSLog(@"%@",user.userChallenge.challengeName);
    NSLog(@"%@", user.userChallenge.charity.charityName);

//    var item = {
//        User_idUser : request.body.User_idUser,
//        soloChallenge_idsoloChallenge : request.body.idsoloChallenge,
//        steps : request.body.steps,
//        walkD : request.body.walkD,
//        runD : request.body.runD,
//        cycleD : request.body.cycleD,
//        challengeComplete : request.body.challengeComplete,
//        sChallengeType_idsChallengeType : request.body.sChallengeType_idsChallengeType,
//        sChallengeAmountRaised : request.body.amountRaised
//    };

    NSDictionary *dict = @{@"User_idUser" : user.idUser, @"soloChallenge_idsoloChallenge": user.userChallenge.challengeID, @"steps": user.totalSteps, @"walkD": user.totalWalkingDist, @"runD": user.totalRunningDist, @"cycleD": user.totalCyclingDist, @"challengeComplete": @0, @"sChallengeAmountRaised" : user.totalAmountRaised};
   
    [self.authService.client invokeAPI:@"soloprogressupdate" body:dict HTTPMethod:@"POST" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
        if(error){
            NSLog(@"%@", [error localizedDescription]);
        }
        else{
            NSLog(@"%@", result);
        }
    }];
    
//    [self addChildViewController:self.pageViewController];
//    [self.view addSubview:self.pageViewController.view];
//    [self.pageViewController didMoveToParentViewController:self];
    
}


-(UIViewController *) pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSInteger index = ((ResultsTest*)viewController).index;
    
    NSLog(@"%ld", (long)index);

    //dont think you need this??
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == 2) {
        return nil;
    }
    return [[ResultsTest alloc] initWithIndex:index];
}


-(UIViewController * )pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSInteger index = ((ResultsTest*)viewController).index;

    NSLog(@"%ld", (long)index);
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    return [[ResultsTest alloc] initWithIndex:index];
}

-(NSInteger) presentationCountForPageViewController:(UIPageViewController *)pageViewController{
    return 2;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}


@end
