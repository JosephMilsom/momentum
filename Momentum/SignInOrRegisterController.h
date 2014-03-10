//
//  SignInOrRegisterController.h
//  Momentum
//
//  Created by Joe on 22/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SignUpOrRegisterDelegate;

@interface SignInOrRegisterController : UIViewController

@property (nonatomic, weak) id<SignUpOrRegisterDelegate> delegate;

@end

@protocol SignUpOrRegisterDelegate <NSObject>

@optional

-(void) userChoseSignIn:(SignInOrRegisterController *)signUpOrRegister;
-(void) userChoseRegister:(SignInOrRegisterController *)signUpOrRegister;
-(void) userDidCompleteRegistration:(UIViewController * ) signUpOrRegister;

@end