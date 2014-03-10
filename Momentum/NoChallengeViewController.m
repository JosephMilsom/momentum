//
//  NoChallengeViewController.m
//  Momentum
//
//  Created by Joe on 26/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "NoChallengeViewController.h"

@interface NoChallengeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *chooseChallengeButton;
@property (weak, nonatomic) IBOutlet UILabel *noChallengeLabel;
- (IBAction)goToChallenges:(id)sender;

@end

@implementation NoChallengeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.chooseChallengeButton.alpha = 0;
    self.noChallengeLabel.alpha = 0;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.chooseChallengeButton.alpha = 0.6;
        self.noChallengeLabel.alpha = 0.6;
    }];
    
    [self.chooseChallengeButton.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.chooseChallengeButton.layer setBorderWidth: 0.5];
    [self.chooseChallengeButton.layer setCornerRadius:3.0f];
    
    [self.chooseChallengeButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [self.chooseChallengeButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpInside];
    [self.chooseChallengeButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchDragOutside];
}

- (IBAction)goToChallenges:(id)sender {
    [self.parentViewController performSegueWithIdentifier:@"ChallengePageSegue" sender:self];
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
