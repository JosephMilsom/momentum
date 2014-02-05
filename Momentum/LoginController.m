//
//  LoginController.m
//  Momentum
//
//  Created by Joe on 22/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "LoginController.h"
#import "SignInRegisterView.h"
#import "SignInView.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AuthService.h"

@interface LoginController ()

- (IBAction)facebookLogin:(id)sender;
@property (strong, nonatomic) SignInView *signInContainer;


-(void) createSignIn;
-(void) fadeInSignIn;
- (IBAction)backButtonHandler:(id)sender;
- (IBAction)completeLogin:(id)sender;

@property (strong, nonatomic) AuthService *authService;

@end

@implementation LoginController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createSignIn];
    self.authService = [AuthService getInstance];
}

- (void) viewDidAppear:(BOOL)animated{
    [self fadeInSignIn];
}

-(void) createSignIn{
    //load up the register view container from the xib file
    NSArray *registerNib = [[NSBundle mainBundle] loadNibNamed:@"SignInView" owner:self options:nil];
    self.signInContainer = [registerNib objectAtIndex:0];
    
    //set the y origin of the register frame
    CGRect registerBounds = self.signInContainer.frame;
    registerBounds.origin.y = 170;
    self.signInContainer.frame = registerBounds;
    
    self.signInContainer.alpha = 0;

    //set the textfields delegate to the current view controller
    //so we can dismiss the box/handle the data
    self.signInContainer.emailTextField.delegate = self;
    self.signInContainer.passwordTextField.delegate = self;
    
    //assign the tags for moving to next textfield
    self.signInContainer.emailTextField.tag = 0;
    self.signInContainer.passwordTextField.tag = 1;
    
    [self.signInContainer initData];
    
    [self.view addSubview:self.signInContainer];
}

- (void)fadeInSignIn{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.8];
    
    //combines the alpha with the black background to dim the image
    self.signInContainer.alpha = 1;
    
    [UIView commitAnimations];
}

- (IBAction)backButtonHandler:(id)sender {
    [UIView animateWithDuration:1 animations:^{
        self.signInContainer.alpha = 0;
    }completion:^(BOOL finished){
        [self.delegate userDidCancelSignIn:self];
    }];
}

- (IBAction)completeLogin:(id)sender {
    NSString *email = self.signInContainer.emailTextField.text;
    NSString *password = self.signInContainer.passwordTextField.text;

    NSDictionary *item = @{@"emailAddress" : email, @"password" : password};
    
    //dim the background to emphasise the loading
    UIView *dim = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    dim.alpha = 0;
    dim.backgroundColor = [UIColor blackColor];
    [self.view addSubview:dim];
    [UIView animateWithDuration:0.3 animations:^{
        dim.alpha = 0.4;
    }];
    
    //initialise new activity loading gif
    UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loading.center = CGPointMake(160, 520);
    [loading startAnimating];
    
    
    [self.view addSubview:loading];
    
    //attempt to login to the account, if successful go to the next screen
    [self.authService loginAccount:item completion:^(NSString *string){
        if([string isEqualToString:@"SUCCESS"]){
            NSLog(@"SUCCESS");
            [loading removeFromSuperview];
            [self.delegate userDidCompleteLogin:self];
        }
    }];
    
    //uses an nsnotification here to see that it is a bad request
    //and therefore the login process returned an error
    [[NSNotificationCenter defaultCenter] addObserverForName:@"401" object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note){
        [UIView animateWithDuration:0.2 animations:^{
            loading.alpha = 0;
            dim.alpha = 0;
        }completion:^(BOOL finished){
            [loading removeFromSuperview];
            [dim removeFromSuperview];
            //MAY NEED TO REMOVE OBSERVER HERE
            //[[NSNotificationCenter defaultCenter] rem];
        }];
    }] ;
    
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
    [self.delegate userDidSelectTextBox:self];
    return YES;
}

//use this so you can dismiss the textview after pressing done
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    if(textField.tag == 1){
    [textField resignFirstResponder];
    [self.delegate userDidCompleteTextFieldEntry:self];
    }
    else{
        NSInteger index = textField.tag;
        UITextField *nextField = (UITextField *)[self.view viewWithTag:index+1];
        [nextField becomeFirstResponder];
    }
    return YES;
}

- (IBAction)facebookLogin:(id)sender {
        //not sure if this needs to be here at the moment??
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"] allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error){
            [self.delegate userDidCompleteLogin:self];
        }];
    
}
@end
