//
//  LoginController.h
//  Momentum
//
//  Created by Joe on 22/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginControllerDelegate;

@interface LoginController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) id<LoginControllerDelegate> delegate;

@end

@protocol LoginControllerDelegate <NSObject>

@optional

-(void) userDidCancelSignIn:(LoginController *)loginController;
-(void) userDidCompleteLogin:(LoginController *)loginController;

@end
