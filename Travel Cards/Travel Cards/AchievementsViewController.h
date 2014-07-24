//
//  AchievementsViewController.h
//  Travel Cards
//
//  Created by Scott Caruso on 6/20/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AchievementsViewController : UIViewController <UITableViewDelegate,UIAlertViewDelegate>
{
    IBOutlet UITableView *achievementTable;
    IBOutlet UILabel *userName;
    IBOutlet UILabel *totalScore;
    IBOutlet UITextView *achievementDescription;
    IBOutlet UIButton *leaderboards;
    IBOutlet UIActivityIndicatorView *loading;
    
    int numberOfAchievementCategories;
    NSNumber *userID;
    NSString *thisUserName;
    NSNumber *thisScore;
    NSString *otherUserName;
    NSString *otherScore;
    bool viewingAppUser;
    
    NSMutableArray *achievementCodes;
    NSMutableDictionary *citiesPlusCodes;
    NSMutableArray *listOfUnownedCities;
    NSMutableDictionary *achievementsByCity;
    NSMutableArray *collectedOrNot;
    
    NSMutableDictionary *achievementStatus;
}

@end
