//
//  CollectionsViewController.m
//  Travel Cards
//
//  Created by Scott Caruso on 6/23/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import "CollectionsViewController.h"
#import "CustomCollectionViewCell.h"
#import "PostcardViewController.h"
#import <Parse/Parse.h>

@interface CollectionsViewController ()

@end

@implementation CollectionsViewController
@synthesize cityCodeName,cityName,userID;

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
    listOfLandmarks = [[NSMutableArray alloc] initWithObjects:nil];
    listOfURLs = [[NSMutableArray alloc] initWithObjects:nil];
    listOfDescriptions = [[NSMutableArray alloc] initWithObjects:nil];
    listOfLandmarkCodes = [[NSMutableArray alloc] initWithObjects:nil];
    collectionStatus = [[NSMutableArray alloc] initWithObjects:nil];
    [self retrieveNumberOfLandmarks];
    
    [self setTitle:cityName];
    
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

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [listOfLandmarks count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    UIImage *thisImage = [self convertURLtoImage:[listOfURLs objectAtIndex:indexPath.row]];
    if (cell != nil)
    {
        cell.locationName.text = [listOfLandmarks objectAtIndex:indexPath.row];
        [cell.backgroundImage setImage:thisImage];
    }
    if ([collectionStatus count] > 0)
    {
        NSString *thisStatus = [collectionStatus objectAtIndex:indexPath.row];
        if ([thisStatus isEqualToString:@"No"])
        {
            cell.backgroundImage.layer.opacity = 0.3f;
        } else
        {
            cell.backgroundImage.layer.opacity = 1.0f;
        }
    }
    return cell;
}

-(void)retrieveNumberOfLandmarks
{
    PFQuery *query = [PFQuery queryWithClassName:cityCodeName];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query orderByAscending:@"landmark"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            for (PFObject *object in objects)
            {
                NSString *currentLocationName = [object objectForKey:@"landmark"];
                NSString *imageURL = [object objectForKey:@"imageURL"];
                NSString *currentDescription = [object objectForKey:@"description"];
                NSString *currentLandmarkCode = [object objectForKey:@"landmarkID"];
                [listOfLandmarks addObject:currentLocationName];
                [listOfURLs addObject:imageURL];
                [listOfDescriptions addObject:currentDescription];
                [listOfLandmarkCodes addObject:currentLandmarkCode];
            }
            [self retrieveCollectionStatus];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)retrieveCollectionStatus
{
    NSString *queryString = [[NSString alloc] initWithFormat:@"%@Collection",cityCodeName];
    PFQuery *query = [PFQuery queryWithClassName:queryString];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            for (PFObject *object in objects)
            {
                if (userID == [object objectForKey:@"userID"])
                {
                    for (int x = 0; x < [listOfLandmarkCodes count]; x++)
                    {
                        NSString *currentLandmark = [listOfLandmarkCodes objectAtIndex:x];
                        NSString *landmarkOwned = [object objectForKey:currentLandmark];
                        if (landmarkOwned != nil)
                        {
                            [collectionStatus addObject:@"Yes"];
                        } else
                        {
                            [collectionStatus addObject:@"No"];
                        }
                    }
                }
            }
            collectionExists = true;
            [collectionView reloadData];
        } else
        {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(UIImage*)convertURLtoImage:(NSString*)url
{
    id path = (NSString*)url;
    NSURL *thisURL = [NSURL URLWithString:path];
    NSData *data = [NSData dataWithContentsOfURL:thisURL];
    UIImage *image = [[UIImage alloc] initWithData:data];
    return image;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PostcardFromCollection"])
    {
        NSIndexPath *selectedIndexPath = [collectionView indexPathForCell:sender];
        CustomCollectionViewCell *cell = (CustomCollectionViewCell*)[collectionView cellForItemAtIndexPath:selectedIndexPath];
        PostcardViewController *newView = [segue destinationViewController];
        newView.locationDatabase = cityCodeName;
        newView.locationName = cell.locationName.text;
        newView.locationDescription = [listOfDescriptions objectAtIndex:selectedIndexPath.row];
        newView.imageURL = [listOfURLs objectAtIndex:selectedIndexPath.row];
        //newView.landmarkID = [thisData objectAtIndex:4];
    }
}

-(void)verifyIfCollectionExistsAndCreateIfNot
{
    NSString *collectionString = [[NSString alloc] initWithFormat:@"%@Collection",cityCodeName];
    PFQuery *query = [PFQuery queryWithClassName:collectionString];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query whereKey:@"userID" equalTo:userID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (objects.count == 0)
         {
             PFObject *newUser = [PFObject objectWithClassName:collectionString];
             newUser[@"userID"] = userID;
             [newUser saveInBackground];
         }
     }];
}

@end
