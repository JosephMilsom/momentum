//
//  SignInView.m
//  Momentum
//
//  Created by Joe on 17/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "SignInView.h"

@interface SignInView()

@end

@implementation SignInView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



- (void)initData{
    
    self.emailTextField.backgroundColor = [UIColor whiteColor];
    self.passwordTextField.backgroundColor = [UIColor whiteColor];
    
    self.passwordTextField.secureTextEntry = YES;
    
    //method to indent the text
    self.emailTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    self.passwordTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
}

@end
