//
//  SplashToFirstViewSegue.m
//  Momentum
//
//  Created by Joe on 14/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "SplashToFirstViewSegue.h"

@implementation SplashToFirstViewSegue

- (void)perform{
    
    //getthe source and the destination view controllers to transistion between
    UIViewController *srcViewController = (UIViewController *) self.sourceViewController;
    UIViewController *destViewController = (UIViewController *) self.destinationViewController;
    
    //define the transition between the views
    CATransition *transition = [CATransition animation];
   
    //transition time for the segue
    transition.duration = 0.5;
    
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [srcViewController.view.window.layer addAnimation:transition forKey:nil];
    
    [srcViewController presentViewController:destViewController animated:NO completion:nil];
}


@end


