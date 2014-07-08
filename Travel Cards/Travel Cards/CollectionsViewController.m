//
//  CollectionsViewController.m
//  Travel Cards
//
//  Created by Scott Caruso on 6/23/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import "CollectionsViewController.h"
#import "CustomCollectionViewCell.h"
#import <Parse/Parse.h>

@interface CollectionsViewController ()

@end

@implementation CollectionsViewController
@synthesize cityCodeName;

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
    [self retrieveNumberOfLandmarks];
    
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
    return cell;
}

-(void)retrieveNumberOfLandmarks
{
    PFQuery *query = [PFQuery queryWithClassName:cityCodeName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            for (PFObject *object in objects)
            {
                NSString *currentLocationName = [object objectForKey:@"landmark"];
                NSString *imageURL = [object objectForKey:@"imageURL"];
                [listOfLandmarks addObject:currentLocationName];
                [listOfURLs addObject:imageURL];
            }
            [collectionView reloadData];
        } else {
            // Log details of the failure
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
