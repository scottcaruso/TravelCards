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
    whichAchievements = @"All";
    
    citiesPlusCodes = [[NSMutableDictionary alloc] init];
    achievementsByCity = [[NSMutableDictionary alloc] init];
    listOfUnownedCities = [[NSMutableArray alloc] initWithObjects:nil];
    achievementCodes = [[NSMutableArray alloc] initWithObjects:nil];
    dictionaryOfCompleted = [[NSMutableDictionary alloc] init];
    dictionaryOfIncomplete = [[NSMutableDictionary alloc] init];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Antipasto-ExtraBold" size:21],
      NSFontAttributeName, nil]];
    
    [self retrieveAchievements];
    [self setFonts];
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
    if ([whichAchievements isEqualToString:@"All"])
    {
        return [listOfUnownedCities count];
    } else
    {
        return 1;
    }

}

//This creates the rows for the ViewController table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *numberComplete = [achievementStatus allKeysForObject:@"Complete"];
    NSArray *numberIncomplete = [achievementStatus allKeysForObject:@"Not Complete"];
    int complete = [numberComplete count];
    int incomplete = [numberIncomplete count];
    if ([whichAchievements isEqualToString:@"All"])
    {
        if (section < [listOfUnownedCities count])
        {
            return 3;
        } else
        {
            return 0;
        }
    } else if ([whichAchievements isEqualToString:@"Completed"])
    {
        return complete;
    } else if ([whichAchievements isEqualToString:@"Incomplete"])
    {
        return incomplete;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName = @"";
    if ([whichAchievements isEqualToString:@"All"])
    {
        for (int x = 0; x < [listOfUnownedCities count]; x++)
        {
            if (x == section)
            {
                sectionName = [listOfUnownedCities objectAtIndex:x];
            }
        }
    }
    return sectionName;
}

//This feeds the data for the table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UIFont *font = [UIFont fontWithName:@"Antipasto" size:20];
    UIFont *smallerFont = [UIFont fontWithName:@"Antipasto" size:14];
    
    UITableViewCell *thisCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (thisCell == nil)
    {
        thisCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    if ([whichAchievements isEqualToString:@"All"])
    {
        NSString *achievementText;
        NSString *statusText;
        NSString *descriptionText;
        if ([achievementsByCity count] != 0)
        {
            NSString *currentCity = [listOfUnownedCities objectAtIndex:indexPath.section];
            NSString *cityCode = [citiesPlusCodes objectForKey:currentCity];
            NSMutableArray *achievementDetails = [achievementsByCity objectForKey:cityCode];
            NSMutableArray *achievementName = [achievementDetails objectAtIndex:0];
            NSMutableArray *achievementDescriptions = [achievementDetails objectAtIndex:1];
            NSMutableArray *theseAchievements = [achievementDetails objectAtIndex:2];
            achievementText = [achievementName objectAtIndex:indexPath.row];
            descriptionText = [achievementDescriptions objectAtIndex:indexPath.row];
            for (int x = 0; x < [theseAchievements count]; x ++)
            {
                if (x == indexPath.row)
                {
                    NSString *achievementID = [theseAchievements objectAtIndex:x];
                    statusText = [achievementStatus objectForKey:achievementID];
                    if ([statusText isEqualToString:@"Complete"])
                    {
                        NSMutableArray *theseDetails = [[NSMutableArray alloc] initWithObjects:nil];
                        [theseDetails addObject:achievementText];
                        [theseDetails addObject:descriptionText];
                        [dictionaryOfCompleted setValue:theseDetails forKey:achievementID];
                    } else if ([statusText isEqualToString:@"Not Complete"])
                    {
                        NSMutableArray *theseDetails = [[NSMutableArray alloc] initWithObjects:nil];
                        [theseDetails addObject:achievementText];
                        [theseDetails addObject:descriptionText];
                        [dictionaryOfIncomplete setValue:theseDetails forKey:achievementID];
                    }
                }
            }
        } else
        {
            achievementText = @"Placeholder";
            statusText = @"Placeholder";
        }
        thisCell.textLabel.text = achievementText;
        thisCell.textLabel.font = font;
        thisCell.detailTextLabel.text = statusText;
        thisCell.detailTextLabel.font = smallerFont;
        
        return thisCell;
    } else if ([whichAchievements isEqualToString:@"Completed"])
    {
        NSArray *arrayOfKeys = [dictionaryOfCompleted allKeys];
        NSString *thisKey = [arrayOfKeys objectAtIndex:indexPath.row];
        NSMutableArray *thisAchievementObject = [dictionaryOfCompleted objectForKey:thisKey];
        thisCell.textLabel.text = [thisAchievementObject objectAtIndex:0];
        thisCell.textLabel.font = font;
        thisCell.detailTextLabel.text = @"Complete";
        thisCell.detailTextLabel.font = smallerFont;
        
        return thisCell;
    } else if ([whichAchievements isEqualToString:@"Incomplete"])
    {
        NSArray *arrayOfKeys = [dictionaryOfIncomplete allKeys];
        NSString *thisKey = [arrayOfKeys objectAtIndex:indexPath.row];
        NSMutableArray *thisAchievementObject = [dictionaryOfIncomplete objectForKey:thisKey];
        thisCell.textLabel.text = [thisAchievementObject objectAtIndex:0];
        thisCell.textLabel.font = font;
        thisCell.detailTextLabel.text = @"Not Complete";
        thisCell.detailTextLabel.font = smallerFont;
            
        return thisCell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIFont *smallerFont = [UIFont fontWithName:@"Antipasto" size:16];
    NSString *thisDescription;
    if ([whichAchievements isEqualToString:@"All"])
    {
        NSString *cityClicked = [listOfUnownedCities objectAtIndex:indexPath.section];
        NSString *cityCode = [citiesPlusCodes objectForKey:cityClicked];
        NSMutableArray *achievementDetails = [achievementsByCity objectForKey:cityCode];
        NSMutableArray *description = [achievementDetails objectAtIndex:1];
        thisDescription = [description objectAtIndex:indexPath.row];
    } else if ([whichAchievements isEqualToString:@"Completed"])
    {
        NSArray *arrayOfKeys = [dictionaryOfCompleted allKeys];
        NSString *thisKey = [arrayOfKeys objectAtIndex:indexPath.row];
        NSMutableArray *thisAchievementObject = [dictionaryOfCompleted objectForKey:thisKey];
        thisDescription = [thisAchievementObject objectAtIndex:1];
    } else if ([whichAchievements isEqualToString:@"Incomplete"])
    {
        NSArray *arrayOfKeys = [dictionaryOfIncomplete allKeys];
        NSString *thisKey = [arrayOfKeys objectAtIndex:indexPath.row];
        NSMutableArray *thisAchievementObject = [dictionaryOfIncomplete objectForKey:thisKey];
        thisDescription = [thisAchievementObject objectAtIndex:1];
    }
    [achievementDescription setText:thisDescription];
    [achievementDescription setFont:smallerFont];
    [achievementDescription setTextAlignment:NSTextAlignmentCenter];
    [achievementDescription setTextColor:[UIColor colorWithRed:.94f green:.82f blue:.19f alpha:1]];
}


-(void)retrieveAchievements
{
    __block NSMutableArray *unsortedCities = [[NSMutableArray alloc] initWithObjects:nil];
    __block NSMutableArray *unsortedCodes = [[NSMutableArray alloc] initWithObjects:nil];
    PFQuery *cityQuery = [PFQuery queryWithClassName:@"CityNames"];
    cityQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
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
            UIAlertView *errorMsg = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There was a problem retrieving data from the database. Please try again shortly." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            errorMsg.alertViewStyle = UIAlertViewStyleDefault;
            [errorMsg show];
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)putAchievementsIntoDictionary:(NSString*)cityCodeName runTableReload:(bool)reload
{
    PFQuery *query = [PFQuery queryWithClassName:@"Achievements"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
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
            UIAlertView *errorMsg = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There was a problem retrieving data from the database. Please try again shortly." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            errorMsg.alertViewStyle = UIAlertViewStyleDefault;
            [errorMsg show];
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)getAchievementCompletionStatuses
{
    PFQuery *query = [PFQuery queryWithClassName:@"AchievementCompletion"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
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
            [self stopSpinningAndShowUI];
        } else {
            UIAlertView *errorMsg = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There was a problem retrieving data from the database. Please try again shortly." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            errorMsg.alertViewStyle = UIAlertViewStyleDefault;
            [errorMsg show];
        }
    }];
}

-(void)setFonts
{
    UIFont *font = [UIFont fontWithName:@"Antipasto" size:20];
    UIFont *smallerFont = [UIFont fontWithName:@"Antipasto" size:16];
    UIFont *boldFont = [UIFont fontWithName:@"Antipasto-ExtraBold" size:20];
    userName.font = boldFont;
    totalScore.font = font;
    achievementDescription.font = smallerFont;
    leaderboards.titleLabel.font = font;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Antipasto-ExtraBold" size:21],
      NSFontAttributeName, nil]];
    
}

-(void)stopSpinningAndShowUI
{
    [loading stopAnimating];
    achievementTable.hidden = false;
    userName.hidden = false;
    totalScore.hidden = false;
    achievementDescription.hidden = false;
    leaderboards.hidden = false;
    achievementToggle.hidden = false;
}

-(IBAction)clickSegmentControl:(id)sender
{
    if ([achievementToggle selectedSegmentIndex] == 0)
    {
        whichAchievements = @"All";
        [self retrieveAchievements];
    } else if ([achievementToggle selectedSegmentIndex] == 1)
    {
        whichAchievements = @"Completed";
        [self retrieveAchievements];
    } else if ([achievementToggle selectedSegmentIndex] == 2)
    {
        whichAchievements = @"Incomplete";
        [self retrieveAchievements];
    }
}

@end
