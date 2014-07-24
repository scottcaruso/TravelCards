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
    
    citiesPlusCodes = [[NSMutableDictionary alloc] init];
    achievementsByCity = [[NSMutableDictionary alloc] init];
    listOfUnownedCities = [[NSMutableArray alloc] initWithObjects:nil];
    achievementCodes = [[NSMutableArray alloc] initWithObjects:nil];
    
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
    return [listOfUnownedCities count];
}

//This creates the rows for the ViewController table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < [listOfUnownedCities count])
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
    for (int x = 0; x < [listOfUnownedCities count]; x++)
    {
        if (x == section)
        {
            sectionName = [listOfUnownedCities objectAtIndex:x];
        }
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
    NSString *statusText;
    if ([achievementsByCity count] != 0)
    {
        NSString *currentCity = [listOfUnownedCities objectAtIndex:indexPath.section];
        NSString *cityCode = [citiesPlusCodes objectForKey:currentCity];
        NSMutableArray *achievementDetails = [achievementsByCity objectForKey:cityCode];
        NSMutableArray *achievementName = [achievementDetails objectAtIndex:0];
        NSMutableArray *theseAchievements = [achievementDetails objectAtIndex:2];
        achievementText = [achievementName objectAtIndex:indexPath.row];
        for (int x = 0; x < [theseAchievements count]; x ++)
        {
            if (x == indexPath.row)
            {
                NSString *achievementID = [theseAchievements objectAtIndex:x];
                statusText = [achievementStatus objectForKey:achievementID];
            }
        }
    } else
    {
        achievementText = @"Placeholder";
        statusText = @"Placeholder";
    }
    thisCell.textLabel.text = achievementText;
    thisCell.detailTextLabel.text = statusText;
    return thisCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cityClicked = [listOfUnownedCities objectAtIndex:indexPath.section];
    NSString *cityCode = [citiesPlusCodes objectForKey:cityClicked];
    NSMutableArray *achievementDetails = [achievementsByCity objectForKey:cityCode];
    NSMutableArray *description = [achievementDetails objectAtIndex:1];
    NSString *thisDescription = [description objectAtIndex:indexPath.row];
    achievementDescription.text = thisDescription;
}

-(void)retrieveAchievements
{
    __block NSMutableArray *unsortedCities = [[NSMutableArray alloc] initWithObjects:nil];
    __block NSMutableArray *unsortedCodes = [[NSMutableArray alloc] initWithObjects:nil];
    PFQuery *cityQuery = [PFQuery queryWithClassName:@"CityNames"];
    [cityQuery whereKey:@"isActive" equalTo:@1];
    [cityQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects)
            {
                [unsortedCities addObject:[object objectForKey:@"cityName"]];
                [unsortedCodes addObject:[object objectForKey:@"cityClassName"]];
                [citiesPlusCodes setValue:[object objectForKey:@"cityClassName"] forKey:[object objectForKey:@"cityName"]];
            }
            listOfUnownedCities = (NSMutableArray*)[unsortedCities sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            for (int x = 0; x < [unsortedCodes count]; x++)
            {
                if (x != [unsortedCodes count] - 1)
                {
                    [self putAchievementsIntoDictionary:[unsortedCodes objectAtIndex:x] runTableReload:false];
                } else
                {
                    [self putAchievementsIntoDictionary:[unsortedCodes objectAtIndex:x] runTableReload:true];
                }

            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)putAchievementsIntoDictionary:(NSString*)cityCodeName runTableReload:(bool)reload
{
    PFQuery *query = [PFQuery queryWithClassName:@"Achievements"];
    [query whereKey:@"achievementCategory" equalTo:cityCodeName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *achievementNames = [[NSMutableArray alloc] initWithObjects:nil];
            NSMutableArray *achievementDescriptions = [[NSMutableArray alloc] initWithObjects:nil];
            NSMutableArray *thisLocationsAchievements = [[NSMutableArray alloc] initWithObjects:nil];
            for (PFObject *object in objects)
            {
                [achievementCodes addObject:object.objectId];
                [achievementNames addObject:[object objectForKey:@"achievementName"]];
                [achievementDescriptions addObject:[object objectForKey:@"achievementDescription"]];
                [thisLocationsAchievements addObject:object.objectId];
            }
            NSMutableArray *achievementDetails = [[NSMutableArray alloc] initWithObjects:nil];
            [achievementDetails addObject:achievementNames];
            [achievementDetails addObject:achievementDescriptions];
            [achievementDetails addObject:thisLocationsAchievements];
            [achievementsByCity setValue:achievementDetails forKey:cityCodeName];
            if (reload)
            {
                [self getAchievementCompletionStatuses];
            }
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
        if (!error)
        {
            achievementStatus = [[NSMutableDictionary alloc] init];
            for (PFObject *object in objects)
            {
                thisUserName = [object objectForKey:@"userName"];
                thisScore = [object objectForKey:@"score"];
                userName.text = thisUserName;
                if (thisScore != nil)
                {
                    //do nothing
                } else
                {
                    thisScore = [NSNumber numberWithInt:0];
                }
                NSString *scoreString = [[NSString alloc] initWithFormat:@"Total Score: %@",thisScore];
                totalScore.text = scoreString;
                for (int x = 0; x < [achievementCodes count]; x++)
                {
                    NSString *achievementCode = [achievementCodes objectAtIndex:x];
                    NSNumber *collectedStatus = [object objectForKey:achievementCode];
                    if (collectedStatus)
                    {
                        [achievementStatus setValue:@"Complete" forKey:achievementCode];
                    } else
                    {
                        [achievementStatus setValue:@"Not Complete" forKey:achievementCode];
                    }
                }
            }
            [achievementTable reloadData];
            viewingAppUser = true;
            [compareToFriend setTitle:@"Compare To Friend" forState:UIControlStateNormal];
        }
    }];
}

@end
