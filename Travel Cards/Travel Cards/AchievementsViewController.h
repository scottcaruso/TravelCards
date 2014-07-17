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
    IBOutlet UIButton *compareToFriend;
    IBOutlet UILabel *userName;
    IBOutlet UILabel *totalScore;
    IBOutlet UIImageView *achievementImage;
    IBOutlet UITextView *achievementDescription;
    
    int numberOfAchievementCategories;
    NSNumber *userID;
    
    NSMutableArray *achievementCodes;
    NSMutableDictionary *citiesPlusCodes;
    NSMutableArray *listOfUnownedCities;
    NSMutableDictionary *achievementsByCity;
    NSMutableArray *collectedOrNot;
    
    NSMutableArray *achievementStatus;
}

@end
