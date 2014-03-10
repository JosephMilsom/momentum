//
//  Circle.m
//  Momentum
//
//  Created by Joe on 24/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "Circle.h"

@implementation Circle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
 // Do any additional setup after loading the view.
 // Get the current graphics context
 // (ie. where the drawing should appear)
 CGContextRef context = UIGraphicsGetCurrentContext();
 
 // Set the width of the line
 CGContextSetLineWidth(context, 1.5);
 

 CGContextBeginPath(context);
 CGContextAddArc(context, 160, 150, 100, 0, 2*M_PI, YES);
 CGContextClosePath(context);
 

 CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.0); //blue
 CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0); //red
 

 
 //Fill/Stroke the path
 CGContextDrawPath(context, kCGPathFillStroke);
}


@end
