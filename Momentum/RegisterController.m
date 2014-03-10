//
//  RegisterController.m
//  Momentum
//
//  Created by Joe on 22/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "RegisterController.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "FBCDAppDelegate.h"
#import <Security/Security.h>
#import "AuthService.h"
#import <FacebookSDK/FacebookSDK.h>
#import "CoreDataSingleton.h"


@interface RegisterController ()

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
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

//view for dimming the screen while loading
//activity indicator to show that the communication is loading

@implementation RegisterController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.authService = [AuthService getInstance];
    self.coreData = [[CoreDataSingleton alloc] init];
    self.view.alpha = 0;
    self.emailTextField.backgroundColor = [UIColor whiteColor];
    self.passwordTextField.backgroundColor = [UIColor whiteColor];
    self.firstNameTextField.backgroundColor = [UIColor whiteColor];
    self.lastNameTextField.backgroundColor = [UIColor whiteColor];
    
    
    self.passwordTextField.secureTextEntry = YES;
    
    //method to indent the text
    self.emailTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    self.passwordTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    self.firstNameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    self.lastNameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    
    self.emailTextField.tag = 0;
    self.passwordTextField.tag = 1;
    self.firstNameTextField.tag = 2;
    self.lastNameTextField.tag = 3;
    
    self.emailTextField.tag = 0;
    self.passwordTextField.tag = 1;
    self.firstNameTextField.tag = 2;
    self.lastNameTextField.tag = 3;
    
    [self.emailTextField.layer setBorderWidth: 0.5];
    [self.emailTextField.layer setCornerRadius:3.0f];
    [self.passwordTextField.layer setBorderWidth: 0.5];
    [self.passwordTextField.layer setCornerRadius:3.0f];
    [self.firstNameTextField.layer setBorderWidth: 0.5];
    [self.firstNameTextField.layer setCornerRadius:3.0f];
    [self.lastNameTextField.layer setBorderWidth: 0.5];
    [self.lastNameTextField.layer setCornerRadius:3.0f];
    
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    
    [self.registerButton.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.registerButton.layer setBorderWidth: 0.5];
    [self.registerButton.layer setCornerRadius:3.0f];
    
    [self.registerButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [self.registerButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpInside];
    [self.registerButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchDragOutside];
    
    [self.backButton.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.backButton.layer setBorderWidth: 0.5];
    [self.backButton.layer setCornerRadius:3.0f];
    
    [self.backButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [self.backButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchDragOutside];
}

- (void) viewDidAppear:(BOOL)animated{
    [self fadeInRegister];
}

#pragma mark display methods


//fades in the register
- (void)fadeInRegister{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.8];
    
    //combines the alpha with the black background to dim the image
    self.view.alpha = 1;
    
    [UIView commitAnimations];
}



//goes back to the sign in/register pane. This is done
//by communication with the delegate and then calling the
//appropriate method
- (IBAction)backButtonHandler:(id)sender {
    [UIView animateWithDuration:1 animations:^{
        self.view.alpha = 0;
    }completion:^(BOOL finished){
        [self.delegate userDidCancelRegistration:self];
    }];
}


#pragma mark registration logic
- (IBAction)completeRegistration:(id)sender {
    //set the data you want to send
    self.email = self.emailTextField.text;
    self.firstName = self.firstNameTextField.text;
    self.lastName = self.lastNameTextField.text;
    self.password = self.passwordTextField.text;
    
    //this creates the type of item
    NSDictionary *item = @{ @"firstName" : self.firstName, @"lastName" : self.lastName, @"emailAddress" : self.email, @"password" : self.password, @"Gender_idGender" : @"2", @"birthday" : @"11/11/1988"};
    
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
                
                NSLog(@"%@", JSON);
                
                NSString *s = [[NSString alloc] initWithFormat:@"%@", [JSON valueForKey:@"idUser"]];
                
                MSUser *user = [[MSUser alloc] initWithUserId:s];
                user.mobileServiceAuthenticationToken = [JSON valueForKey:@"token"];
                
                self.authService.client.currentUser = user;
                
                [self.authService saveAuthInfo];
                
                [self.coreData saveUserInfo:JSON];
                
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
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
    //[self.delegate userDidSelectTextBox:self];
    return YES;
}

//use this so you can dismiss the textview after pressing done
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    //if last text field in chain, resign and register.
    if(textField.tag == 3){
        [textField resignFirstResponder];
        //[self.delegate userDidCompleteTextFieldEntry:self];
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

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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
