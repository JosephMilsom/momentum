//
//  RegisterController.h
//  Momentum
//
//  Created by Joe on 22/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RegisterControllerDelegate;

@interface RegisterController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) id<RegisterControllerDelegate> delegate;

@end

@protocol RegisterControllerDelegate <NSObject>

@optional

-(void) userDidCancelRegistration:(RegisterController *) registerController;
-(void) userDidChooseExternalRegistration:(RegisterController *)registerController;
-(void) userDidCompleteRegistration:(UIViewController *)registerController;
-(void) userDidSelectTextBox:(UIViewController *)registerController;
-(void) userDidCompleteTextFieldEntry:(UIViewController *)registerController;



@end