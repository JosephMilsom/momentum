//
//  SplashScreen.h
//  Momentum
//
//  Created by Joe on 9/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignInOrRegisterController.h"
#import "RegisterController.h"
#import "ExternalLoginAndRegister.h"
#import "LoginController.h"

@interface SplashScreen : UIViewController <SignUpOrRegisterDelegate, LoginControllerDelegate, RegisterControllerDelegate>

@end

//needs this 
BOOL firstTime = YES;