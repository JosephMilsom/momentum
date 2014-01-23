//
//  RegisterViewContainer.m
//  Momentum
//
//  Created by Joe on 17/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "RegisterViewContainer.h"

@interface RegisterViewContainer()

- (IBAction)selectButton:(id)sender;


//login via these 3 options
@property (weak, nonatomic) IBOutlet UIButton *facebook;
@property (weak, nonatomic) IBOutlet UIButton *google;
@property (weak, nonatomic) IBOutlet UIButton *linkedin;


//label for signin
@property (weak, nonatomic) IBOutlet UILabel *signInRegisterLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

/**OUTLET COLLECTIONS FOR THE VIEWS**/
//these are the views to fade in at the start

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *interestRow1;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *interestRow2;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *interestRow3;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelRow1;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelRow2;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelRow3;
@property (weak, nonatomic) IBOutlet UILabel *interestsLabel;



@end


@implementation RegisterViewContainer


- (void)initData{
    
    self.emailTextField.backgroundColor = [UIColor whiteColor];
    self.passwordTextField.backgroundColor = [UIColor whiteColor];
    self.fullNameTextField.backgroundColor = [UIColor whiteColor];

    
    self.passwordTextField.secureTextEntry = YES;
    
    //method to indent the text
    self.emailTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    self.passwordTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    self.fullNameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);

}


-(void) fadeViews:(UIScrollView *)scrollView{
    
    float alphaSignIn = (1-((scrollView.contentOffset.y)/30)) + 0.5;
    
    self.signInRegisterLabel.alpha = alphaSignIn;
    self.backButton.alpha = alphaSignIn+1.0;
    
    float alphaIcons = (1-((scrollView.contentOffset.y)/30)) + 2.8;
    
    
    self.facebook.alpha = alphaIcons;
    self.google.alpha = alphaIcons;
    self.linkedin.alpha = alphaIcons;
    
    float emailBoxAlpha = (1-((scrollView.contentOffset.y)/30)) + 5.2;
    float passwordBoxAlpha = (1-((scrollView.contentOffset.y)/30)) + 6.4;
    float fullNameBoxAlpha = (1-((scrollView.contentOffset.y)/30)) + 7.6;

    
    if(emailBoxAlpha > 0.7){
        emailBoxAlpha = 0.7;
    }
    if(passwordBoxAlpha > 0.7){
        passwordBoxAlpha = 0.7;
    }
    if(fullNameBoxAlpha > 0.7){
        fullNameBoxAlpha = 0.7;
    }
    
    self.emailTextField.alpha = emailBoxAlpha;
    self.passwordTextField.alpha = passwordBoxAlpha;
    self.fullNameTextField.alpha = fullNameBoxAlpha;

    
    float interestLabelAlpha = (1-((scrollView.contentOffset.y)/30)) + 11.2;
    
    self.interestsLabel.alpha = interestLabelAlpha;
    
    float interestRow1Alpha = (1-((scrollView.contentOffset.y)/30)) + 12.5;
    float interestRow2Alpha = (1-((scrollView.contentOffset.y)/30)) + 14.5;
    float interestRow3Alpha = (1-((scrollView.contentOffset.y)/30)) + 16.5;
    float labelRow1Alpha = (1-((scrollView.contentOffset.y)/30)) + 13.5;
    float labelRow2Alpha = (1-((scrollView.contentOffset.y)/30)) + 15.5;
    float labelRow3Alpha = (1-((scrollView.contentOffset.y)/30)) + 17.5;
    
    for(int i  = 0; i < 3; i++){
        UIButton *row1 = self.interestRow1[i];
        UIButton *row2 = self.interestRow2[i];
        UIButton *row3 = self.interestRow3[i];
        UILabel *lab1 = self.labelRow1[i];
        UILabel *lab2 = self.labelRow2[i];
        UILabel *lab3 = self.labelRow3[i];
        row1.alpha = interestRow1Alpha;
        row2.alpha = interestRow2Alpha;
        row3.alpha = interestRow3Alpha;
        lab1.alpha = labelRow1Alpha;
        lab2.alpha = labelRow2Alpha;
        lab3.alpha = labelRow3Alpha;
    }
    
}

- (IBAction)selectButton:(id)sender {
    UIButton *button = (UIButton*)sender;
    
    if(button.isSelected == NO){
        [button setSelected:YES];
    }
    else{
        [button setSelected:NO];
    }
}




@end
