//
//  RegisterViewContainer.h
//  Momentum
//
//  Created by Joe on 17/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewContainer : UIView

//textfields for input by the user
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;


-(void) initData;
-(void) fadeViews:(UIScrollView *) scrollView;

@end
