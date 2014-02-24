//
//  CharityListView.h
//  Momentum
//
//  Created by Joe on 13/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoloChallenge.h"

@interface CharityListView : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) SoloChallenge *selectedChallenge;

@end
