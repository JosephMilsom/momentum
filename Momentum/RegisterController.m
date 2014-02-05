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


@property (strong, nonatomic) AuthService* authService;

@end


@implementation RegisterController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createRegister];
    self.authService = [AuthService getInstance];
    // Whenever a person opens the app, check for a cached session
    
}

- (void) viewDidAppear:(BOOL)animated{
    [self fadeInRegister];
}

-(void) createRegister{
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
    
    //IMPORTANT!! need to set constraints!! do this later...
    //self.scrollView.constraints =
    
    //assign the contentsize for the scrollview so we can
    //do some sweet scrolling
    self.scrollView.contentSize = CGSizeMake(320, 966);
    self.scrollView.bounces = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.delaysContentTouches = NO;
    
    self.scrollView.alpha = 0;
    
    //add the view controller and scrollview to the scrollviewcontainer
    [self.scrollView addSubview:self.registerContainer];
    [self.view addSubview:self.scrollView];
    

}

- (void)fadeInRegister{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.8];
    
    //combines the alpha with the black background to dim the image
    self.scrollView.alpha = 1;
    
    [UIView commitAnimations];
}

- (IBAction)backButtonHandler:(id)sender {
    [UIView animateWithDuration:1 animations:^{
        self.registerContainer.alpha = 0;
    }completion:^(BOOL finished){
        [self.delegate userDidCancelRegistration:self];
    }];
}

#pragma mark registration logic

/***NOTE: This should only be able to be clicked once***/
- (IBAction)completeRegistration:(id)sender {
    UIView *dim;
    UIActivityIndicatorView *loading;
    
    //set the data you want to send
    self.email = self.registerContainer.emailTextField.text;
    self.firstName = self.registerContainer.firstNameTextField.text;
    self.lastName = self.registerContainer.lastNameTextField.text;
    self.password = self.registerContainer.passwordTextField.text;
    
    //this creates the type of item
    NSDictionary *item = @{ @"firstName" : self.firstName, @"lastName" : self.lastName, @"emailAddress" : self.email, @"password" : self.password};
    
    //check the data to ensure everything is filled out correctly
    if([self checkData] == NO){
        NSLog(@"ERROR fill out all fields correctly");
    }
    else{
        //dim the background to emphasise the loading
         dim = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
        dim.alpha = 0;
        dim.backgroundColor = [UIColor blackColor];
        [self.view addSubview:dim];
        [UIView animateWithDuration:0.3 animations:^{
            dim.alpha = 0.4;
        }];
        
        //initialise new activity loading gif
        loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        loading.center = CGPointMake(160, 530);
        [loading startAnimating];
        
        [self.view addSubview:loading];
        
        //this takes the data, connects to the database, and then
        //registers. if successful then it returns an authentication
        //token where you save it using the keychain
        [self.authService registerAccount:item completion:^(NSString* string){
            if ([string isEqualToString:@"SUCCESS"]) {
                [self.delegate userDidChooseExternalRegistration:self];
                [dim removeFromSuperview];
                [loading removeFromSuperview];
            } else {
                NSLog(@"ERROR");
                [UIView animateWithDuration:0.2 animations:^{
                    loading.alpha = 0;
                    dim.alpha = 0;
                }completion:^(BOOL finished){
                    [dim removeFromSuperview];
                    [loading removeFromSuperview];
                    //MAY NEED TO REMOVE OBSERVER HERE
                    //[[NSNotificationCenter defaultCenter] rem];
                }];
            }
        }];
        
//        //this will listen out for a bad request ie from the register
//        //controller not sending through the right data
//        [[NSNotificationCenter defaultCenter] addObserverForName:@"401" object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note){
//            [UIView animateWithDuration:0.2 animations:^{
//                loading.alpha = 0;
//                dim.alpha = 0;
//            }completion:^(BOOL finished){
//                [dim removeFromSuperview];
//                [loading removeFromSuperview];
//                //MAY NEED TO REMOVE OBSERVER HERE
//                //[[NSNotificationCenter defaultCenter] rem];
//            }];
//        }];
    }
}

//this will bring up the native facebook login ui/ web client for the ios to login.
//If successful it will save the token to the FBSession for use in authentication
//when connecting to the azure mobile services
- (IBAction)facebookLogin:(id)sender {
    
    NSLog(@"LOGIN %@", FBSession.activeSession.accessTokenData.accessToken);
    
    if (FBSession.activeSession.state != FBSessionStateCreatedTokenLoaded) {
        
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"email"] allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error){
            if(error){
                NSLog(@"There was an error obtaining the access token");
            }else{
                [self loginWithFacebook];
            }
        }];
    }
}

#pragma mark login logic

//method that will login with the associated provider
//NOTE: need to make general
-(void) loginWithFacebook{
    
    /***TO FIX***/
    //returning null on the second time for some reason???
    NSLog(@"LOGIN %@", FBSession.activeSession.accessTokenData.accessToken);
    
    //choose the provider to login to, and also send through the token to
    //the server where azure will automatically handle the authentication
    //process
    [self.authService.client loginWithProvider:@"facebook" token:@{@"access_token" : FBSession.activeSession.accessTokenData.accessToken} completion:^(MSUser *user, NSError *error){
        
        if(error){
            NSLog(@"Authentication error : %@", error.localizedDescription);
        }
        else {
            //save the data to the phone and go to the first screen
            //of the app
            [self.authService saveAuthInfo];
            [self readAuthData];
        }
    }];
}

//rename this method
-(void) readAuthData{
    MSTable *usersTable = [self.authService.client tableWithName:@"Users"];
    
    NSDictionary *item = @{@"provider" : @"true"};
    NSDictionary *params = @{ @"provider" : @"true" };
    
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error){
        
        NSLog(@"%@", [user objectForKey:@"email"]);
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"emailAddress == %@", [user objectForKey:@"email"]];
        
        NSLog(@"%@", predicate.description);
        
        MSQuery *query = [usersTable queryWithPredicate:predicate];
        query.selectFields = @[@"emailAddress"];
        query.fetchOffset = 0;
        query.fetchLimit = 1;
        query.includeTotalCount = YES;
        
        NSLog(@"%@", self.authService.client.currentUser.userId);
        [query readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
    
            if(error){
                NSLog(@"%@", error.localizedDescription);
            }
            else{
                NSLog(@"%ld", (long)totalCount);
                if(totalCount == 1){
                    NSLog(@"Facebook Account already exists. Logging in");
                   [self.delegate userDidCompleteRegistration:self];
                }
                else{
                    [usersTable insert:item parameters:params completion:^(NSDictionary *item, NSError *error){
                        if(error){
                            NSLog(@"Error : %@", error.localizedDescription);
                        }
                        else{
                            NSLog(@"Success");
                            [self.delegate userDidCompleteRegistration:self];
                        }
                    }];
                }
            }
        }];
        
        
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
    //if last text field in chain, resign.
    if(textField.tag == 3){
        [textField resignFirstResponder];
        [self.delegate userDidCompleteTextFieldEntry:self];
        return YES;
    }else{
        //else set the next text field as the active field
        NSInteger index = textField.tag;
        UITextField *nextField = (UITextField *)[self.view viewWithTag:index+1];
        [nextField becomeFirstResponder];
    }
    return NO;

}

@end
