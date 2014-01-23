//
//  ChallengeList.m
//  Momentum
//
//  Created by Joe on 10/01/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "ChallengeList.h"
#import "ChallengeCell.h"

@interface ChallengeList ()
@property (weak, nonatomic) IBOutlet UITableView *challengeList;

@end

@implementation ChallengeList


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.challengeList.delegate = self;
    self.challengeList.dataSource = self;
    self.challengeList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.challengeList.showsVerticalScrollIndicator = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    if([indexPath row] == 3){
        [self performSegueWithIdentifier:@"MoonPageTest" sender:nil];
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    static NSString *CellIdentifier = @"Cell";
    
    ChallengeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ChallengeCell" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (ChallengeCell *)currentObject;
                break;
            }
        }
    }
    if([indexPath row] == 0 )
    cell.imageBackground.image = [UIImage imageNamed:@"WalkWaitakere.png"];
    if([indexPath row] == 1 )
        cell.imageBackground.image = [UIImage imageNamed:@"TourFrance.png"];
    if([indexPath row] == 2 )
        cell.imageBackground.image = [UIImage imageNamed:@"Sunrise.png"];
    if([indexPath row] == 3 )
        cell.imageBackground.image = [UIImage imageNamed:@"Moon.png"];
    if([indexPath row] == 4 )
        cell.imageBackground.image = [UIImage imageNamed:@"WalkWaitakere.png"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 120.0;
}

@end
