//
//  RegisterController.m
//  Momentum
//
//  Created by Joe on 22/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "RegisterController.h"
#import "RegisterViewContainer.h"

@interface RegisterController ()

@property (strong, nonatomic) RegisterViewContainer *registerContainer;
@property (strong, nonatomic) UIScrollView *scrollView;
-(void) createRegister;
-(void) fadeInRegister;

- (IBAction)backButtonHandler:(id)sender;
- (IBAction)externalRegistrationHandler:(id)sender;
- (IBAction)completeRegistration:(id)sender;

@end

@implementation RegisterController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createRegister];
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
    self.registerContainer.passwordTextField.delegate = self;
    self.registerContainer.emailTextField.delegate = self;
    self.registerContainer.fullNameTextField.delegate = self;

    [self.registerContainer initData];
    
    [self.view addSubview:self.registerContainer];
    
    //initialise the scrollview and its parameters
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    
    //IMPORTANT!! need to set constraints!! do this later...
    //self.scrollView.constraints =
    
    //assign the contentsize for the scrollview so we can
    //do some sweet scrolling
    self.scrollView.contentSize = CGSizeMake(320, 900);
    self.scrollView.bounces = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    
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

//handler for external registration via facebook, google, or linked in at the moment
- (IBAction)externalRegistrationHandler:(id)sender {
    [self.delegate userDidChooseExternalRegistration:self];
}

- (IBAction)completeRegistration:(id)sender {
    [self.delegate userDidCompleteRegistration:self];
}

#pragma mark delegate methods
//trigger when the scroll view has been scrolling
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.registerContainer fadeViews:scrollView];
}

//use this so you can dismiss the textview after pressing done
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
