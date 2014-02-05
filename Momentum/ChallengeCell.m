//
//  ChallengeCell.m
//  Momentum
//
//  Created by Joe on 10/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "ChallengeCell.h"

@implementation ChallengeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (id) initWithFrame:(CGRect)frame{
//    if ((self = [super initWithFrame:frame]))
//    {
//        self.horizontalTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kCellHeight, kTableLength)] autorelease];
//        self.horizontalTableView.showsVerticalScrollIndicator = NO;
//        self.horizontalTableView.showsHorizontalScrollIndicator = NO;
//        self.horizontalTableView.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
//        [self.horizontalTableView setFrame:CGRectMake(kRowHorizontalPadding * 0.5, kRowVerticalPadding * 0.5, kTableLength - kRowHorizontalPadding, kCellHeight)];
//        
//        self.horizontalTableView.rowHeight = kCellWidth;
//        self.horizontalTableView.backgroundColor = kHorizontalTableBackgroundColor;
//        
//        self.horizontalTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//        self.horizontalTableView.separatorColor = [UIColor clearColor];
//        
//        self.horizontalTableView.dataSource = self;
//        self.horizontalTableView.delegate = self;
//        [self addSubview:self.horizontalTableView];
//    }
//    
//    return self;
//}

@end
