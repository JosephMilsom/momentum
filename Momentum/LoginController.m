//
//  LoginController.m
//  Momentum
//
//  Created by Joe on 22/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "LoginController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AuthService.h"

@interface LoginController ()

-(void) createSignIn;
-(void) fadeInSignIn;
- (IBAction)backButtonHandler:(id)sender;
- (IBAction)completeLogin:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (strong, nonatomic) AuthService *authService;

@end

@implementation LoginController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createSignIn];
    self.authService = [AuthService getInstance];
    [self.signInButton.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.signInButton.layer setBorderWidth: 0.5];
    [self.signInButton.layer setCornerRadius:3.0f];
    
    [self.signInButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [self.signInButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpInside];
    [self.signInButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchDragOutside];
    
    [self.backButton.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.backButton.layer setBorderWidth: 0.5];
    [self.backButton.layer setCornerRadius:3.0f];
    
    [self.backButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [self.backButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchDragOutside];
    
    [self.emailTextField.layer setBorderWidth: 0.5];
    [self.emailTextField.layer setCornerRadius:3.0f];
    [self.passwordTextField.layer setBorderWidth: 0.5];
    [self.passwordTextField.layer setCornerRadius:3.0f];

}

- (void) viewDidAppear:(BOOL)animated{
    [self fadeInSignIn];
}

#pragma mark display logic
-(void) createSignIn{


    self.view.alpha = 0;

    //set the textfields delegate to the current view controller
    //so we can dismiss the box/handle the data
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    //assign the tags for moving to next textfield
    self.emailTextField.tag = 0;
    self.passwordTextField.tag = 1;
    
    //method to indent the text
    self.emailTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    self.passwordTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    
    self.emailTextField.backgroundColor = [UIColor whiteColor];
    self.passwordTextField.backgroundColor = [UIColor whiteColor];
    
}

- (void)fadeInSignIn{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.8];
    
    //combines the alpha with the black background to dim the image
    self.view.alpha = 1;
    
    [UIView commitAnimations];
}

- (IBAction)backButtonHandler:(id)sender {
    [UIView animateWithDuration:1 animations:^{
        self.view.alpha = 0;
    }completion:^(BOOL finished){
        [self.delegate userDidCancelSignIn:self];
    }];
}

#pragma mark login logic
- (IBAction)completeLogin:(id)sender {
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;

    //data to send through to the custom api
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
    [self.authService loginAccount:item completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
        if(error){
            NSLog(@"%@", [error localizedDescription]);
        }
        else{
            //get the result from the request and assign to dictionary
            NSDictionary *login = result;
            //NSLog(@"%@", [login valueForKey:@"userId"]);

            //create a new user and assign the token to the user and then
            //save the info to the keychain

            MSUser *user = [[MSUser alloc] initWithUserId:[login valueForKey:@"userId"]];
            user.mobileServiceAuthenticationToken = [login valueForKey:@"token"];
            self.authService.client.currentUser = user;

            [self.authService saveAuthInfo];

            [self.delegate userDidCompleteLogin:self];
        }

        //fade out the loading view and get rid of dim
        [UIView animateWithDuration:0.2 animations:^{
            loading.alpha = 0;
            dim.alpha = 0;
        }completion:^(BOOL finished){
            [loading removeFromSuperview];
            [dim removeFromSuperview];
        }];
    }];
}




//use this so you can dismiss the textview after pressing done
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    if(textField.tag == 1){
    [textField resignFirstResponder];
        [self completeLogin:nil];
//    [self.delegate userDidCompleteTextFieldEntry:self];
    }
    else{
        NSInteger index = textField.tag;
        UITextField *nextField = (UITextField *)[self.view viewWithTag:index+1];
        [nextField becomeFirstResponder];
    }
   return YES;
}

////#pragma mark delegate methods
//-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
//    [self.delegate userDidSelectTextBox:self];
//    return YES;
//}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
    [self.delegate userDidCompleteTextFieldEntry:self];
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
