//
//  ChallengeCell.h
//  Momentum
//
//  Created by Joe on 10/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChallengeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageBackground;
@property (strong, nonatomic) NSString *information;
@property (strong, nonatomic) NSString *challengeTitle;
@property (strong, nonatomic) NSString *brandImageLocation;
@property (strong, nonatomic) UIImage *bottomImage;

@end
