//
//  RegisterController.m
//  Momentum
//
//  Created by Joe on 22/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "RegisterController.h"
#import "RegisterViewContainer.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "FBCDAppDelegate.h"
#import <Security/Security.h>
#import "AuthService.h"
#import <FacebookSDK/FacebookSDK.h>
#import "CoreDataSingleton.h"


@interface RegisterController ()

@property (strong, nonatomic) RegisterViewContainer *registerContainer;
@property (strong, nonatomic) UIScrollView *scrollView;
-(void) createRegister;
-(void) fadeInRegister;

- (IBAction)backButtonHandler:(id)sender;
- (IBAction)completeRegistration:(id)sender;
- (IBAction)facebookLogin:(id)sender;

//contains the data that needs to be sent
@property (strong, nonatomic) NSMutableArray *registrationData;

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *password;
@property (strong , nonatomic) UIView *dim;
@property (strong , nonatomic) UIActivityIndicatorView *loading;

@property (strong, nonatomic) CoreDataSingleton *coreData;
@property (strong, nonatomic) AuthService* authService;

@end

//view for dimming the screen while loading
//activity indicator to show that the communication is loading

@implementation RegisterController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createRegister];
    self.authService = [AuthService getInstance];
    self.coreData = [[CoreDataSingleton alloc] init];
}

- (void) viewDidAppear:(BOOL)animated{
    [self fadeInRegister];
}

#pragma mark display methods

//creates the actual register
- (void) createRegister{
    //load up the register view container from the xib file
    NSArray *registerNib = [[NSBundle mainBundle] loadNibNamed:@"RegisterViewContainer" owner:self options:nil];
    self.registerContainer = [registerNib objectAtIndex:0];
    
    //set the y origin of the register frame
    CGRect registerBounds = self.registerContainer.frame;
    registerBounds.origin.y = 170;
    self.registerContainer.frame = registerBounds;
    
    //set the textfields delegate to the current view controller
    //so we can dismiss the box/handle the data
    self.registerContainer.emailTextField.delegate = self;
    self.registerContainer.passwordTextField.delegate = self;
    self.registerContainer.firstNameTextField.delegate = self;
    self.registerContainer.lastNameTextField.delegate = self;

    //assign tags to the text field for logging in
    self.registerContainer.emailTextField.tag = 0;
    self.registerContainer.passwordTextField.tag = 1;
    self.registerContainer.firstNameTextField.tag = 2;
    self.registerContainer.lastNameTextField.tag = 3;
    
    [self.registerContainer initData];
    
    [self.view addSubview:self.registerContainer];
    
    
    //initialise the scrollview and its parameters
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    
    //assign the contentsize for the scrollview so we can
    //do some sweet scrolling
    self.scrollView.contentSize = CGSizeMake(320, 966);
    self.scrollView.bounces = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.delaysContentTouches = NO;
    
    //set up a gesture recognizer that tells when the outside of
    //a scrollview has been touched, used for closing the text field
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured)];
    [self.scrollView addGestureRecognizer:singleTap];
    
    self.scrollView.alpha = 0;
    
    //add the view controller and scrollview to the scrollviewcontainer
    [self.scrollView addSubview:self.registerContainer];
    [self.view addSubview:self.scrollView];
    

}

//fades in the register
- (void)fadeInRegister{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.8];
    
    //combines the alpha with the black background to dim the image
    self.scrollView.alpha = 1;
    
    [UIView commitAnimations];
}

//goes back to the sign in/register pane. This is done
//by communication with the delegate and then calling the
//appropriate method
- (IBAction)backButtonHandler:(id)sender {
    [UIView animateWithDuration:1 animations:^{
        self.registerContainer.alpha = 0;
    }completion:^(BOOL finished){
        [self.delegate userDidCancelRegistration:self];
    }];
}


#pragma mark registration logic
- (IBAction)completeRegistration:(id)sender {
    //set the data you want to send
    self.email = self.registerContainer.emailTextField.text;
    self.firstName = self.registerContainer.firstNameTextField.text;
    self.lastName = self.registerContainer.lastNameTextField.text;
    self.password = self.registerContainer.passwordTextField.text;
    
    //this creates the type of item
    NSDictionary *item = @{ @"firstName" : self.firstName, @"lastName" : self.lastName, @"emailAddress" : self.email, @"password" : self.password, @"Gender_idGender" : @"2", @"age" : @"25"};
    
    //check the data to ensure everything is filled out correctly
    if([self checkData] == NO){
        NSLog(@"ERROR fill out all fields correctly");
    }
    else{
        //dim the background to emphasise the loading
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
        
        //this takes the data, connects to the database, and then
        //registers. if successful then it returns an authentication
        //token where you save it using the keychain
        [self.authService registerAccount:item completion:^(id result, NSHTTPURLResponse *response, NSError *error){
            if(error){
                NSLog(@"%@", [error localizedDescription]);
                
                //remove the loading view and dim

            }
            //if successful
            else{
                NSLog(@"%ld", (long)response.statusCode);
                NSLog(@"%@", (NSString *)result);
                NSLog(@"SUCCESS");
                
                NSDictionary *JSON = result;
                
                NSLog(@"%@", [JSON valueForKey:@"token"]);
                MSUser *user = [[MSUser alloc] initWithUserId:[JSON valueForKey:@"userId"]];
                user.mobileServiceAuthenticationToken = [JSON valueForKey:@"token"];
                
                self.authService.client.currentUser = user;
                
                [self.authService saveAuthInfo];
                
                [self.delegate userDidCompleteRegistration:self];
            }
            
            [UIView animateWithDuration:0.2 animations:^{
                self.loading.alpha = 0;
                self.dim.alpha = 0;
            }completion:^(BOOL finished){
                [self.dim removeFromSuperview];
                [self.loading removeFromSuperview];
            }];
        }];
    }
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
                [self loginWithFacebook];
            }
        }];
    }
}

#pragma mark facebook login logic

-(void) loginWithFacebook{
        
    [self.authService.client loginWithProvider:@"facebook" token:@{@"access_token": [NSString stringWithFormat:@"%@", FBSession.activeSession.accessTokenData.accessToken] } completion:^(MSUser *user, NSError *error) {
        if(error){
            NSLog(@"%@", error);
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
                                    [self.coreData saveUserInfo:data];
                                    [self.authService saveAuthInfo];
                                    [self.delegate userDidCompleteRegistration:self];
                                }
                            }];
    

}


#pragma mark login logic

//check the data to see if ok and fields filled out correctly
-(BOOL) checkData{
    //this needs to be refined, just simple for now
    if ([self.email length] < 3 || [self.firstName length] < 3 || [self.lastName length] < 3 || [self.password length] < 7) {
        return NO;
    }
    
    return YES;
}

#pragma mark delegate methods
//trigger when the scroll view has been scrolling
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.registerContainer fadeViews:scrollView];
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
    [self.delegate userDidSelectTextBox:self];
    return YES;
}

//use this so you can dismiss the textview after pressing done
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    //if last text field in chain, resign and register.
    if(textField.tag == 3){
        [textField resignFirstResponder];
        [self.delegate userDidCompleteTextFieldEntry:self];
        [self completeRegistration:nil];
        return YES;
    }else{
        //else set the next text field as the active field
        NSInteger index = textField.tag;
        UITextField *nextField = (UITextField *)[self.view viewWithTag:index+1];
        [nextField becomeFirstResponder];
    }
    return NO;

}

//tell the view that there was a touch outside of
//the scrollview, so that it knows to close the textfield
-(void) singleTapGestureCaptured{
    [self.view endEditing:YES];
    [self.delegate userDidCompleteTextFieldEntry:self];
}


@end
