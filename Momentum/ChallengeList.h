//
//  ChallengeList.h
//  Momentum
//
//  Created by Joe on 10/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//


#import <UIKit/UIKit.h>

/**
 *  ChallengeList is a view controller that shows the user the current list of challenges.
    Within it, there are 3 main aspects:
                    - the table view
                    - the name of the challenge
                    - information on the challenge
 
    Data is stored in coredata, and every time the ChallengeList is entered it checks for 
    any updates by sending a list of its stored challenges to the server. If the server 
    has any new challenges, it will return these after the custom api call.
 */

@interface ChallengeList : UIViewController <UITableViewDataSource, UITableViewDelegate>

@end
