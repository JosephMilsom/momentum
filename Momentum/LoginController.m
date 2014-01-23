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

@interface LoginController ()

@property (strong, nonatomic) SignInView *signInContainer;


-(void) createSignIn;
-(void) fadeInSignIn;
- (IBAction)backButtonHandler:(id)sender;
- (IBAction)completeLogin:(id)sender;

@end

@implementation LoginController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createSignIn];
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
    self.signInContainer.passwordTextField.delegate = self;
    self.signInContainer.emailTextField.delegate = self;
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
    [self.delegate userDidCompleteLogin:self];
}

//use this so you can dismiss the textview after pressing done
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
