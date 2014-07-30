//
//  PartnerAdminViewController.m
//  Travel Cards
//
//  Created by Scott Caruso on 7/28/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import "PartnerAdminViewController.h"
#import <Parse/Parse.h>

@interface PartnerAdminViewController ()

@end

@implementation PartnerAdminViewController
@synthesize username;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    cities = [[NSMutableArray alloc] initWithObjects:nil];
    allowedCities = [[NSMutableArray alloc] initWithObjects:nil];
    citiesAndLandmarks = [[NSMutableDictionary alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:@"CityNames"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query whereKey:@"isActive" equalTo:[NSNumber numberWithInt:1]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            for (PFObject *object in objects)
            {
                [cities addObject:[object objectForKey:@"cityName"]];
            }
            PFQuery *query = [PFQuery queryWithClassName:@"Partners"];
            [query whereKey:@"username" equalTo:username];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error)
                {
                    int numberOfCitiesToCheck = [cities count];
                    for (PFObject *object in objects)
                    {
                        for (int x = 0; x < numberOfCitiesToCheck; x++)
                        {
                            NSMutableArray *allowedLandmarks = [[NSMutableArray alloc] initWithObjects:nil];
                            NSString *cityCode = [cities objectAtIndex:x];
                            if ([object objectForKey:cityCode] != nil)
                            {
                                [allowedCities addObject:cityCode];
                                [allowedLandmarks addObject:[object objectForKey:cityCode]];
                            }
                            [citiesAndLandmarks setValue:allowedLandmarks forKey:cityCode];
                        }
                    }
                } else
                {
                    UIAlertView *errorMsg = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There was a problem retrieving data from the database. Please try again shortly." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    errorMsg.alertViewStyle = UIAlertViewStyleDefault;
                    [errorMsg show];
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        } else
        {
            UIAlertView *errorMsg = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There was a problem retrieving data from the database. Please try again shortly." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            errorMsg.alertViewStyle = UIAlertViewStyleDefault;
            [errorMsg show];
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    [super viewWillAppear:false];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerClicked isEqualToString:@"City"])
    {
        return [cities count];
    } else
    {
        
    }
    return 0;
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if ([pickerClicked isEqualToString:@"City"])
    {
        NSString *city = [cities objectAtIndex:row];
        return city;
    } else
    {
        
    }
    return nil;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([pickerClicked isEqualToString:@"City"])
    {
        NSString *text = [cities objectAtIndex:row];
        [cityName setTitle:text forState:UIControlStateNormal];
    } else
    {
        
    }
    [picker setHidden:true];
}

-(IBAction)chooseCity:(id)sender
{
    pickerClicked = @"City";
    [picker reloadAllComponents];
    [picker setHidden:false];
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
