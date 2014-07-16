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
    arrayOfScores = [[NSMutableArray alloc] initWithArray:nil];
    arrayOfUsers = [[NSMutableArray alloc] initWithArray:nil];
    
    [self getLeaderboardNames];
    
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

-(void)getLeaderboardNames
{
    PFQuery *query = [PFQuery queryWithClassName:@"AchievementCompletion"];
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

@end
