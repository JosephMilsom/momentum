//
//  SignInOrRegisterController.m
//  Momentum
//
//  Created by Joe on 22/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "SignInOrRegisterController.h"
#import "AuthService.h"
#import <FacebookSDK/FacebookSDK.h>
#import "CoreDataSingleton.h"

@interface SignInOrRegisterController ()

//@property (strong, nonatomic) SignInRegisterView *signInRegister;

-(void) fadeInSignInRegister;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (strong, nonatomic) UIView *dim;
@property (strong, nonatomic) UIActivityIndicatorView *loading;
@property (strong, nonatomic) AuthService *authService;
@property (strong, nonatomic) CoreDataSingleton *coreData;

- (IBAction)signInButton:(id)sender;
- (IBAction)registerButton:(id)sender;
@end

@implementation SignInOrRegisterController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.signInButton.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.signInButton.layer setBorderWidth: 0.5];
    [self.signInButton.layer setCornerRadius:3.0f];
    
    [self.signInButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [self.signInButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpInside];
    [self.signInButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchDragOutside];

    [self.registerButton.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.registerButton.layer setBorderWidth: 0.5];
    [self.registerButton.layer setCornerRadius:3.0f];
    
    [self.registerButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [self.registerButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpInside];
    [self.registerButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchDragOutside];
    
    self.view.alpha = 0;
    self.authService = [AuthService getInstance];
    self.coreData =[CoreDataSingleton new];
}

- (void) viewDidAppear:(BOOL)animated{
    [self fadeInSignInRegister];
    
}


- (IBAction)signInButton:(id)sender {
    [UIView animateWithDuration:1 animations:^{
        self.view.alpha = 0;
    }completion:^(BOOL finished){
        [self.delegate userChoseSignIn:self];
    }];
}

- (IBAction)registerButton:(id)sender {
    [UIView animateWithDuration:1 animations:^{
        self.view.alpha = 0;
    }completion:^(BOOL finished){
        [self.delegate userChoseRegister:self];
    }];
}


-(void) fadeInSignInRegister{
    //create and execute a series of animations
    //which will fade in the buttons
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];

    self.view.alpha = 1;
    
    [UIView commitAnimations];
}

//this will bring up the native facebook login ui/ web client for the ios to login.
//If successful it will save the token to the FBSession for use in authentication
//when connecting to the azure mobile services
- (IBAction)facebookLogin:(id)sender {
    //NSLog(@"LOGIN %@", FBSession.activeSession.accessTokenData.accessToken);
    
    self.dim = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    self.dim.alpha = 0;
    self.dim.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.dim];
    [UIView animateWithDuration:0.3 animations:^{
        self.dim.alpha = 0.4;
    }];
    
    //initialise new activity loading gif
    self.loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loading.center = CGPointMake(160, 530);
    [self.loading startAnimating];
    
    [self.view addSubview:self.loading];
    
    if (FBSession.activeSession.state != FBSessionStateCreatedTokenLoaded) {
        
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"email",@"user_birthday"] allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error){
            if(error){
                NSLog(@"There was an error obtaining the access token");
                //remove the loading views
                [self.dim removeFromSuperview];
                [self.loading removeFromSuperview];
            }else{
                NSLog(@"SUCCESS! Sending facebook token to azure.");
                [self loginWithFacebook];
            }
        }];
    }
}

#pragma mark facebook login logic

-(void) loginWithFacebook{
    
    [self.authService.client loginWithProvider:@"facebook" token:@{@"access_token": [NSString stringWithFormat:@"%@", FBSession.activeSession.accessTokenData.accessToken] } completion:^(MSUser *user, NSError *error) {
        if(error){
            NSLog(@"%@", [error localizedDescription]);
            [UIView animateWithDuration:0.2 animations:^{
                self.loading.alpha = 0;
                self.dim.alpha = 0;
            }completion:^(BOOL finished){
                [self.dim removeFromSuperview];
                [self.loading removeFromSuperview];
            }];
        }
        else{
            self.authService.client.currentUser = user;
            [self.authService saveAuthInfo];
            [self validateFacebookCredentials];
        }
    }];
    
    
}

-(void) validateFacebookCredentials{
    [self.authService.client invokeAPI:@"authprovideridentityget"
                                  body:@{@"access_token" : FBSession.activeSession.accessTokenData.accessToken}
                            HTTPMethod:@"POST"
                            parameters:nil
                               headers:nil
                            completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
                                if(error){
                                    NSLog(@"%@", [error localizedDescription]);
                                    [UIView animateWithDuration:0.2 animations:^{
                                        self.loading.alpha = 0;
                                        self.dim.alpha = 0;
                                    }completion:^(BOOL finished){
                                        [self.dim removeFromSuperview];
                                        [self.loading removeFromSuperview];
                                    }];
                                    
                                    [self.authService killAuthInfo];
                                    [FBSession.activeSession closeAndClearTokenInformation];
                                    [FBSession.activeSession close];
                                    [FBSession setActiveSession:nil];
                                    
                                }else{
                                    NSDictionary *data = result;
                                    //save info into coredata
                                    NSLog(@"%@", data);
                                    [self.coreData saveUserInfo:data];
                                    [self.authService saveAuthInfo];
                                    [self.delegate userDidCompleteRegistration:self];
                                }
                            }];
    
}


- (void) buttonHighlight:(UIButton*)sender{
    sender.backgroundColor = [UIColor whiteColor];
    sender.titleLabel.textColor = [UIColor blackColor];
}

- (void) buttonNormal:(UIButton*)sender{
    sender.backgroundColor = [UIColor clearColor];
    sender.titleLabel.textColor = [UIColor whiteColor];
}


@end
