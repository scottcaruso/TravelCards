//
//  CollectionListViewController.m
//  Travel Cards
//
//  Created by Scott Caruso on 6/20/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import "CollectionListViewController.h"
#import "CollectionsViewController.h"
#import <Parse/Parse.h>

@interface CollectionListViewController ()

@end

@implementation CollectionListViewController

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
    
    numberOfUnownedRows = 0;
    numberOfOwnedRows = 0;
    listOfUnownedCities = [[NSMutableArray alloc] initWithObjects:nil];
    citiesPlusCodes = [[NSMutableDictionary alloc] init];
    ownedCities = [[NSMutableArray alloc] initWithObjects:nil];
    [self retrieveNumberOfRowsAndCities];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Antipasto-ExtraBold" size:21],
      NSFontAttributeName, nil]];
    
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
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"Active Collections";
            break;
        case 1:
            sectionName = @"Not Started Collections";
            break;
        default:
            sectionName = @"Collections";
            break;
    }
    return sectionName;
}

//This creates the rows for the ViewController table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows;
    switch (section)
    {
        case 0:
            numberOfRows = [ownedCities count];
            break;
        case 1:
            numberOfRows = [listOfUnownedCities count];
            break;
        default:
            numberOfRows = 0;
            break;
    }
    return numberOfRows;
}

//This feeds the data for the table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *thisCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (thisCell == nil)
    {
        thisCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSString *collectionItem;
    if (indexPath.section == 0)
    {
        collectionItem = [ownedCities objectAtIndex:indexPath.row];
    } else
    {
        collectionItem = [listOfUnownedCities objectAtIndex:indexPath.row];
    }
    UIFont *font = [UIFont fontWithName:@"Antipasto" size:20];
    thisCell.textLabel.text = collectionItem;
    thisCell.textLabel.font = font;
    return thisCell;
}

-(void)retrieveNumberOfRowsAndCities
{
    __block NSMutableArray *unsortedCities = [[NSMutableArray alloc] initWithObjects:nil];
    __block NSMutableArray *arrayOfCollections = [[NSMutableArray alloc] initWithObjects:nil];
    PFQuery *user = [PFUser query];
    [user whereKey:@"userID" equalTo:userID];
    [user findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects)
            {
                arrayOfCollections = [object objectForKey:@"arrayOfCollections"];
            }
            if ([arrayOfCollections count] > 0)
            {
                for (int x = 0; x < [arrayOfCollections count]; x++)
                {
                    [ownedCities addObject:[arrayOfCollections objectAtIndex:x]];
                }
            }
        }
    }];
    
    PFQuery *query = [PFQuery queryWithClassName:@"CityNames"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            numberOfUnownedRows = objects.count;
            for (PFObject *object in objects)
            {
                [unsortedCities addObject:[object objectForKey:@"cityName"]];
                [citiesPlusCodes setValue:[object objectForKey:@"cityClassName"] forKey:[object objectForKey:@"cityName"]];
            }
            listOfUnownedCities = (NSMutableArray*)[unsortedCities sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            [collectionTable reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"selectedCity"])
    {
        NSIndexPath *selectedIndexPath = [collectionTable indexPathForCell:sender];
        UITableViewCell *cell = [collectionTable cellForRowAtIndexPath:selectedIndexPath];
        NSString *cityName = cell.textLabel.text;
        NSString *cityCodeName = [citiesPlusCodes objectForKey:cityName];
        CollectionsViewController *newView = [segue destinationViewController];
        newView.cityCodeName = cityCodeName;
    }
}

@end
