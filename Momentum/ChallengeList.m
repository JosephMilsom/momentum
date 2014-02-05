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
@property (strong, nonatomic) IBOutlet UITableView *challengeList;

@end

@implementation ChallengeList


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.challengeList.delegate = self;
    self.challengeList.dataSource = self;
    //self.challengeList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    //[self.challengeList setFrame:CGRectMake(0, 0, 50, 50)];

    self.challengeList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.challengeList.showsVerticalScrollIndicator = NO;
    self.challengeList.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
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
    if([indexPath row] == 0)
    cell.imageBackground.image = [UIImage imageNamed:@"waitakere.jpg"];
    if([indexPath row] == 1)
        cell.imageBackground.image = [UIImage imageNamed:@"tourdefrance.png"];
    if([indexPath row] == 2)
        cell.imageBackground.image = [UIImage imageNamed:@"riseandshine.png"];
    if([indexPath row] == 3)
        cell.imageBackground.image = [UIImage imageNamed:@"riseandshine.png"];
    if([indexPath row] == 4)
        cell.imageBackground.image = [UIImage imageNamed:@"waitakere.jpg"];
    if([indexPath row] == 5)
        cell.imageBackground.image = [UIImage imageNamed:@"tourdefrance.png"];
    if([indexPath row] == 6)
        cell.imageBackground.image = [UIImage imageNamed:@"riseandshine.png"];
    if([indexPath row] == 7)
        cell.imageBackground.image = [UIImage imageNamed:@"waitakere.jpg"];
    if([indexPath row] == 8)
        cell.imageBackground.image = [UIImage imageNamed:@"tourdefrance.png"];
    if([indexPath row] == 9)
        cell.imageBackground.image = [UIImage imageNamed:@"riseandshine.png"];
    if([indexPath row] == 10)
        cell.imageBackground.image = [UIImage imageNamed:@"waitakere.jpg"];
    if([indexPath row] == 11)
        cell.imageBackground.image = [UIImage imageNamed:@"tourdefrance.png"];
    if([indexPath row] == 12)
        cell.imageBackground.image = [UIImage imageNamed:@"riseandshine.png"];
    if([indexPath row] == 13)
        cell.imageBackground.image = [UIImage imageNamed:@"waitakere.jpg"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 14;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 200.0;
}

@end
