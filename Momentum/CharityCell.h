//
//  CharityCell.h
//  Momentum
//
//  Created by Joe on 13/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CharityCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *cellImage;
@property (strong, nonatomic) UIImage *bottomImage;
@property (strong, nonatomic) NSString *information;
@property (strong, nonatomic) NSString *charityTitle;
@property (strong, nonatomic) NSString *brandImageLocation;

@end
