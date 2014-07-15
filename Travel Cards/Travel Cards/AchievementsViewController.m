//
//  AchievementsViewController.m
//  Travel Cards
//
//  Created by Scott Caruso on 6/20/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import "AchievementsViewController.h"
#import <Parse/Parse.h>

@interface AchievementsViewController ()

@end

@implementation AchievementsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    userID = [defaults objectForKey:@"SavedUserID"];
    
    numberOfAchievementCategories = 1; //This is just placeholder for now. It will be generated from the dynamic data.
    
    citiesPlusCodes = [[NSMutableDictionary alloc] init];
    achievementsByCity = [[NSMutableDictionary alloc] init];
    listOfUnownedCities = [[NSMutableArray alloc] initWithObjects:nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Antipasto-ExtraBold" size:21],
      NSFontAttributeName, nil]];
    
    [self retrieveAchievements];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //This returns the number of Achievement categories as stored in Parse
    return numberOfAchievementCategories;
}

//This creates the rows for the ViewController table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //We should create a dictionary or something similar that matches up the ID of the section with the number of achievements in it. In this case, we will simply use a static value.
    if (section < numberOfAchievementCategories)
    {
        return 3;
    } else
    {
    return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"New York";
            break;
        default:
            sectionName = @"Collections";
            break;
    }
    return sectionName;
}

//This feeds the data for the table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *thisCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (thisCell == nil)
    {
        thisCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    NSString *achievementText;
    if ([achievementsByCity count] != 0)
    {
        NSMutableArray *thisCityAchievements = [achievementsByCity objectForKey:@"NewYork"];
        achievementText = [thisCityAchievements objectAtIndex:indexPath.row];
    } else
    {
        achievementText = @"Placeholder";
    }
    thisCell.textLabel.text = achievementText;
    thisCell.detailTextLabel.text = [achievementStatus objectAtIndex:indexPath.row];
    return thisCell;
}

-(void)retrieveAchievements
{
    __block NSMutableArray *unsortedCities = [[NSMutableArray alloc] initWithObjects:nil];
    PFQuery *cityQuery = [PFQuery queryWithClassName:@"CityNames"];
    [cityQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects)
            {
                [unsortedCities addObject:[object objectForKey:@"cityName"]];
                [citiesPlusCodes setValue:[object objectForKey:@"cityClassName"] forKey:[object objectForKey:@"cityName"]];
            }
            listOfUnownedCities = (NSMutableArray*)[unsortedCities sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            [self putAchievementsIntoDictionary];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)putAchievementsIntoDictionary
{
    PFQuery *query = [PFQuery queryWithClassName:@"Achievements"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            achievementCodes = [[NSMutableArray alloc] initWithObjects:nil];
            NSMutableArray *achievementNames = [[NSMutableArray alloc] initWithObjects:nil];
            for (PFObject *object in objects)
            {
                [achievementCodes addObject:object.objectId];
                NSString *achievementCity = [object objectForKey:@"achievementCategory"];
                if ([achievementCity isEqualToString:@"NewYork"])
                {
                    [achievementNames addObject:[object objectForKey:@"achievementName"]];
                    [achievementsByCity setValue:achievementNames forKey:achievementCity];
                }
            }
            [self getAchievementCompletionStatuses];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)getAchievementCompletionStatuses
{
    PFQuery *query = [PFQuery queryWithClassName:@"AchievementCompletion"];
    [query whereKey:@"userID" equalTo:userID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            achievementStatus = [[NSMutableArray alloc] initWithObjects:nil];
            for (PFObject *object in objects)
            {
                for (int x = 0; x < [achievementCodes count]; x++)
                {
                    NSNumber *collectedStatus = [object objectForKey:[achievementCodes objectAtIndex:x]];
                    if (collectedStatus)
                    {
                        [achievementStatus addObject:@"Complete"];
                    } else
                    {
                        [achievementStatus addObject:@"Not Complete"];
                    }
                }
            }
        }
        [achievementTable reloadData];
    }];
}

@end
