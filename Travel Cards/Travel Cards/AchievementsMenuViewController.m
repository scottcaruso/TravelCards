//
//  AchievementsMenuViewController.m
//  Travel Cards
//
//  Created by Scott Caruso on 7/9/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import "AchievementsMenuViewController.h"
#import "AchievementTableViewCell.h"
#import <Parse/Parse.h>

@interface AchievementsMenuViewController ()

@end

@implementation AchievementsMenuViewController

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
    [self retrieveUsersFriends];
    addUser.hidden = true;
    [self getOverallLeaderboardNames];
    
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
    return 1;
}

//This creates the rows for the ViewController table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayOfUsers count];
}

//This feeds the data for the table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    AchievementTableViewCell *thisCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (thisCell != nil)
    {
        NSString *ranking = [[NSString alloc] initWithFormat:@"%i",indexPath.row+1];
        thisCell.ranking.text = ranking;
        if ([arrayOfUsers count] > 0)
        {
            thisCell.userName.text = [arrayOfUsers objectAtIndex:indexPath.row];
            NSNumber *score = [arrayOfScores objectAtIndex:indexPath.row];
            thisCell.score.text = [score stringValue];
        }
    }
    return thisCell;
}

-(void)getOverallLeaderboardNames
{
    arrayOfScores = [[NSMutableArray alloc] initWithArray:nil];
    arrayOfUsers = [[NSMutableArray alloc] initWithArray:nil];
    PFQuery *query = [PFQuery queryWithClassName:@"AchievementCompletion"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query orderByDescending:@"score"];
    query.limit = 10;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            for (PFObject *object in objects)
            {
                NSString *thisUserName = [object objectForKey:@"userName"];
                NSNumber *thisScore = [object objectForKey:@"score"];
                [arrayOfUsers addObject:thisUserName];
                if (thisScore != nil)
                {
                    [arrayOfScores addObject:thisScore];
                } else
                {
                    [arrayOfScores addObject:[NSNumber numberWithInt:0]];
                }
            }
            [achievementTable reloadData];
        } else
        {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)getFriendsLeaderboardNames
{
    arrayOfScores = [[NSMutableArray alloc] initWithArray:nil];
    arrayOfUsers = [[NSMutableArray alloc] initWithArray:nil];
    PFQuery *query = [PFQuery queryWithClassName:@"AchievementCompletion"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query whereKey:@"userName" containedIn:arrayOfFriends];
    [query orderByDescending:@"score"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            for (PFObject *object in objects)
            {
                NSString *thisUserName = [object objectForKey:@"userName"];
                NSNumber *thisScore = [object objectForKey:@"score"];
                [arrayOfUsers addObject:thisUserName];
                if (thisScore != nil)
                {
                    [arrayOfScores addObject:thisScore];
                } else
                {
                    [arrayOfScores addObject:[NSNumber numberWithInt:0]];
                }
            }
            [achievementTable reloadData];
        } else
        {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

}

-(IBAction)onSegmentSelect:(id)sender
{
    if (leaderboardSelect.selectedSegmentIndex == 0)
    {
        [self getOverallLeaderboardNames];
        addUser.hidden = true;
    } else if (leaderboardSelect.selectedSegmentIndex == 1)
    {
        [self getFriendsLeaderboardNames];
        addUser.hidden = false;
    }
}

-(IBAction)addFriend:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Friend" message:@"Please enter your friend's username." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Search",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        UITextField *thisTextField = [alertView textFieldAtIndex:0];
        PFQuery *query = [PFQuery queryWithClassName:@"AchievementCompletion"];
        query.cachePolicy = kPFCachePolicyNetworkElseCache;
        [query whereKey:@"userName" equalTo:thisTextField.text];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                //achievementStatus = [[NSMutableDictionary alloc] init];
                if (objects.count == 0)
                {
                    UIAlertView *incorrectUserName = [[UIAlertView alloc] initWithTitle:@"Error" message:@"We did not find that user in the database. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    incorrectUserName.alertViewStyle = UIAlertViewStyleDefault;
                    [incorrectUserName show];
                } else
                {
                    bool friendExists = false;
                    for (PFObject *object in objects)
                    {
                        NSString *thisUserName = [object objectForKey:@"userName"];
                        for (int x = 0; x < [arrayOfFriends count]; x++)
                        {
                            NSString *thisFriend = [arrayOfFriends objectAtIndex:x];
                            if ([thisFriend isEqualToString:thisUserName])
                            {
                                UIAlertView *alreadyExists = [[UIAlertView alloc] initWithTitle:@"Users Already Friends" message:@"The desired user is already friends with you!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                alreadyExists.alertViewStyle = UIAlertViewStyleDefault;
                                [alreadyExists show];
                                friendExists = true;
                                break;
                            }
                        }
                    }
                    if (!friendExists)
                    {
                        [arrayOfFriends addObject:thisTextField.text];
                        [self executeFriendAdd:arrayOfFriends];
                    }
                }
            } else
            {
                UIAlertView *incorrectUserName = [[UIAlertView alloc] initWithTitle:@"Error" message:@"We did not find that user in the database. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                incorrectUserName.alertViewStyle = UIAlertViewStyleDefault;
                [incorrectUserName show];
            }
        }];
    }
}

-(void)retrieveUsersFriends
{
    PFQuery *user = [PFUser query];
    user.cachePolicy = kPFCachePolicyNetworkElseCache;
    [user whereKey:@"userID" equalTo:userID];
    [user findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects)
            {
                arrayOfFriends = [[NSMutableArray alloc] initWithObjects:nil];
                arrayOfFriends = [object objectForKey:@"arrayOfFriends"];
            }
            if (arrayOfFriends == nil)
            {
               arrayOfFriends = [[NSMutableArray alloc] initWithObjects:nil];
            }
        }
    }];
}

-(void)executeFriendAdd:(NSMutableArray*)updatedArray
{
    PFQuery *user = [PFUser query];
    user.cachePolicy = kPFCachePolicyNetworkElseCache;
    [user whereKey:@"userID" equalTo:userID];
    [user findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects)
            {
                object[@"arrayOfFriends"] = arrayOfFriends;
                [object saveInBackground];
                UIAlertView *friendAdd = [[UIAlertView alloc] initWithTitle:@"Friend added!" message:@"The user was added to your friend list!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                friendAdd.alertViewStyle = UIAlertViewStyleDefault;
                [friendAdd show];
            }
        }
    }];
}

@end
