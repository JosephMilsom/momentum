//
//  SignInView.h
//  Momentum
//
//  Created by Joe on 17/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInView : UIView

//textfields for input by the user
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

-(void) initData;

@end
