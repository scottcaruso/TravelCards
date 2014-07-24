//
//  AchievementsMenuViewController.h
//  Travel Cards
//
//  Created by Scott Caruso on 7/9/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AchievementsMenuViewController : UIViewController <UITableViewDelegate>
{
    NSMutableArray *arrayOfUsers;
    NSMutableArray *arrayOfScores;
    
    IBOutlet UITableView *achievementTable;
    
    IBOutlet UISegmentedControl *leaderboardSelect;
    IBOutlet UIButton *addUser;
}

-(IBAction)onSegmentSelect:(id)sender;

@end
