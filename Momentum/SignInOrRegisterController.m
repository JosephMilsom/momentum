//
//  SignInOrRegisterController.m
//  Momentum
//
//  Created by Joe on 22/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "SignInOrRegisterController.h"
#import "SignInRegisterView.h"


@interface SignInOrRegisterController ()

@property (strong, nonatomic) SignInRegisterView *signInRegister;

-(void) createSignInRegister;
-(void) fadeInSignInRegister;

- (IBAction)signInButton:(id)sender;
- (IBAction)registerButton:(id)sender;
@end

@implementation SignInOrRegisterController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createSignInRegister];
}

- (void) viewDidAppear:(BOOL)animated{
    [self fadeInSignInRegister];
    
}

- (IBAction)signInButton:(id)sender {
    [UIView animateWithDuration:1 animations:^{
        self.signInRegister.alpha = 0;
    }completion:^(BOOL finished){
        [self.delegate userChoseSignIn:self];
    }];
}

- (IBAction)registerButton:(id)sender {
    [UIView animateWithDuration:1 animations:^{
        self.signInRegister.alpha = 0;
    }completion:^(BOOL finished){
        [self.delegate userChoseRegister:self];
    }];
}

-(void) createSignInRegister{
	// Do any additional setup after loading the view.
    NSArray *signInNib = [[NSBundle mainBundle] loadNibNamed:@"SignInRegisterView" owner:self options:nil];
    self.signInRegister = [signInNib objectAtIndex:0];
    self.signInRegister.alpha = 0;
    CGRect frame = self.signInRegister.frame;
    frame.origin.y = 200;
    self.signInRegister.frame = frame;
    [self.view addSubview:self.signInRegister];
}

-(void) fadeInSignInRegister{
    //create and execute a series of animations
    //which will fade in the buttons
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];

    self.signInRegister.alpha = 1;
    
    [UIView commitAnimations];
}




@end
