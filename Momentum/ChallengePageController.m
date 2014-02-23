//
//  ChallengePageController.m
//  Momentum
//
//  Created by Joe on 22/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "ChallengePageController.h"

@interface ChallengePageController ()
- (IBAction)back:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textDescription;

@end

@implementation ChallengePageController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSString *text = @"Location : Worldwide\nDistance: 384400 km\nActivity: Run or Walk\n\nJoin a community of like minded people to collaboratively walk the distance from earth to the moon. By combining the efforts of each individual, together we can reach the moon.\n\nThis challenge is sponsored by ADIDAS. ADIDAS has paired up with many organisations to promote charity giving. To find out more, visit the ADIDAS website, www.adidas.com";
    self.textDescription.text = text;
    self.textDescription.selectable = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
