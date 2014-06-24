//
//  AchievementsViewController.h
//  Travel Cards
//
//  Created by Scott Caruso on 6/20/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AchievementsViewController : UIViewController <UITableViewDelegate>
{
    IBOutlet UITableView *achievementTable;
    int numberOfAchievementCategories;
}

@end
