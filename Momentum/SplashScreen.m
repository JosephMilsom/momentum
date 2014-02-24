//
//  SplashScreen.m
//  Momentum
//
//  Created by Joe on 9/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//
//
//*****DATA FOR ******//

#import "FBCDAppDelegate.h"
#import "SplashScreen.h"
#import <QuartzCore/QuartzCore.h>
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "AuthService.h"
#import <FacebookSDK/FacebookSDK.h>
#import "CoreDataSingleton.h"

@interface SplashScreen ()


//the logo and background image
//@property (weak, nonatomic) IBOutlet UIImageView *momentumLogo;
@property (strong, nonatomic) UIImageView *momentumLogo;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImg;

//scrollview containers for the sign up stuff
@property (weak, nonatomic) IBOutlet UIView *scrollViewContainer;

//needs a strong reference, else the controller gets released
@property (strong, nonatomic) UIViewController *currentController;

@property (strong, nonatomic) AuthService *authService;


//custom methods for the ui elements, fancy stuff like
//fading in views and junk
-(void) createSignInRegister;
-(void) createAndAnimateLogo;
-(void) removeCurrentControllerFromContainer;



@end

@implementation SplashScreen

-(void) viewDidLoad{
    
    self.authService = [AuthService getInstance];
    CoreDataSingleton *coreData = [CoreDataSingleton new];
    
    //if there is no user info stored in coredata, clear all
    //possible authentication data
    if(coreData.getUserInfo == nil){
        [coreData deleteUserInfo];
        [self.authService killAuthInfo];
        [FBSession.activeSession closeAndClearTokenInformation];
        [FBSession.activeSession close];
        [FBSession setActiveSession:nil];
    }

}



//this is where all the view data logic will be handled, as the view
//needs to be loaded for this stuff to happened
- (void) viewDidAppear:(BOOL)animated{
    //automatically transition to the next screen if
    //there is an authentication token
    if(self.authService.client.currentUser.userId){
        [self performSegueWithIdentifier:@"ResultsSegue" sender:nil];
    }
    else{
        if(firstTime){
            [self createAndAnimateLogo];
            //ignore the warning, it still runs
            //NOTE SHOULD BE 4
            NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self
                                                            selector: @selector(initViewController) userInfo: nil repeats: NO];
            firstTime = NO;
        }
    }
 }


//method to do some sweet animation for the logo by moving
//it around and whatever
-(void) createAndAnimateLogo{
    //need to declare the logo here as it will not reset the position like it would
    //if you define in the interface builder
    self.momentumLogo = [[UIImageView alloc] initWithFrame:CGRectMake(80, 134, 161, 171)];
    self.momentumLogo.image = [UIImage imageNamed:@"LogoLarge.png"];
    [self.scrollViewContainer addSubview:self.momentumLogo];

    //grab the frame for the logo image so we can
    //animate that biatch!!
    CGRect logoFrame = self.momentumLogo.frame;
    
    //create and execute animation that moves up the
    //logo to the top of the screen
    //NOTE: ACTUAL DELAY IS 3, DURATION IS 2
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelay:0];
    [UIView setAnimationDuration:1];
    logoFrame.origin.x = 110;
    logoFrame.origin.y = 60;
    logoFrame.size.height = 100;
    logoFrame.size.width = 100;
    
    self.momentumLogo.frame = logoFrame;
    [UIView commitAnimations];
}


#pragma mark fadeinlogic
//method that will create and fade in the sign in/register buttons
-(void) initViewController{
    
    //create and execute a series of animations
    //which will fade in the button
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.8];
    
    //combines the alpha with the black background to dim the image
    self.backgroundImg.alpha = 0.5;
    
    [UIView commitAnimations];
    
    [self createSignInRegister];
}

-(void) createSignInRegister{
    SignInOrRegisterController *controller = [[SignInOrRegisterController alloc] init];
    controller.delegate = self;
    
    self.currentController = controller;
    
    self.currentController.view.frame = self.scrollViewContainer.bounds;
    [self addChildViewController:controller];
    NSLog(@"%@",[controller parentViewController]);
    
    [self.scrollViewContainer addSubview:self.currentController.view];
    
    [self.currentController didMoveToParentViewController:self];
}


-(void) userChoseSignIn:(SignInOrRegisterController *)signUpOrRegister{
    
    [self removeCurrentControllerFromContainer];
    
    LoginController *controller = [[LoginController alloc] init];
    
    self.currentController = controller;
    controller.delegate = self;
    
    self.currentController.view.frame = self.scrollViewContainer.bounds;
    
    [self.scrollViewContainer addSubview:self.currentController.view];
    
    [self.currentController didMoveToParentViewController:self];
}

-(void) userChoseRegister:(SignInOrRegisterController *)signUpOrRegister{
    
    [self removeCurrentControllerFromContainer];
    
    RegisterController *controller = [[RegisterController alloc] init];
    controller.delegate = self;
    
    self.currentController = controller;
    
    self.currentController.view.frame = self.scrollViewContainer.bounds;
    
    [self.scrollViewContainer addSubview:self.currentController.view];
    
    [self.currentController didMoveToParentViewController:self];
}

//removes the current controller from the view container
-(void) removeCurrentControllerFromContainer{
    [self.currentController willMoveToParentViewController:nil];
    
    [self.currentController.view removeFromSuperview];
    
    [self.currentController removeFromParentViewController];
}

-(void) userDidCancelRegistration:(RegisterController *)registerController{
    [self removeCurrentControllerFromContainer];
    [self createSignInRegister];
}

-(void) userDidCancelSignIn:(LoginController *)loginController{
    [self removeCurrentControllerFromContainer];
    [self createSignInRegister];
}



-(void) userDidCompleteRegistration:(RegisterController *)registerController{
    [self performSegueWithIdentifier:@"ResultsSegue" sender:nil];
}

-(void) userDidCompleteLogin:(LoginController *)loginController{
    [self performSegueWithIdentifier:@"ResultsSegue" sender:nil];
}


/***NOTE THAT THIS IS NOT USE OF PROPER DELEGATION, THERE ARE 2 DELEGATE METHODS REFERRING TO THE SAME METHOD***/

-(void) userDidSelectTextBox:(UIViewController *)Controller{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.35];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    self.view.center = CGPointMake(160, 68);
    
    [UIView commitAnimations];
    
}

-(void) userDidCompleteTextFieldEntry:(UIViewController *)controller{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.275];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    self.view.center = CGPointMake(160, 568/2);
    
    [UIView commitAnimations];
    
}

@end
