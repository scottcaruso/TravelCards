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
    numberOfRows = 0;
    listOfCities = [[NSMutableArray alloc] initWithObjects:nil];
    citiesPlusCodes = [[NSMutableDictionary alloc] init];
    [self retrieveNumberOfRowsAndCities];
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
    return numberOfRows; //This is just placeholder!
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
    NSString *collectionItem = [listOfCities objectAtIndex:indexPath.row];
    thisCell.textLabel.text = collectionItem;
    return thisCell;
}

-(void)retrieveNumberOfRowsAndCities
{
    __block NSMutableArray *unsortedCities = [[NSMutableArray alloc] initWithObjects:nil];
    PFQuery *query = [PFQuery queryWithClassName:@"CityNames"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            numberOfRows = objects.count;
            for (PFObject *object in objects)
            {
                [unsortedCities addObject:[object objectForKey:@"cityName"]];
                [citiesPlusCodes setValue:[object objectForKey:@"cityClassName"] forKey:[object objectForKey:@"cityName"]];
            }
            listOfCities = (NSMutableArray*)[unsortedCities sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
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
