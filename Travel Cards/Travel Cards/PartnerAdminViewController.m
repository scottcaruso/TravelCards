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
                [cities addObject:[object objectForKey:@"cityClassName"]];
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
                                allowedLandmarks = [object objectForKey:cityCode];
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
        return [allowedCities count];
    } else if ([pickerClicked isEqualToString:@"Landmark"])
    {
        NSString *city = cityName.titleLabel.text;
        NSMutableArray *thisCity = [citiesAndLandmarks objectForKey:city];
        return [thisCity count];
    } else
    {
        return 0;
    }
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if ([pickerClicked isEqualToString:@"City"])
    {
        NSString *city = [allowedCities objectAtIndex:row];
        return city;
    } else if ([pickerClicked isEqualToString:@"Landmark"])
    {
        NSString *city = cityName.titleLabel.text;
        NSMutableArray *thisCity = [citiesAndLandmarks objectForKey:city];
        NSString *landmark = [thisCity objectAtIndex:row];
        return landmark;
    } else
    {
        return nil;
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([pickerClicked isEqualToString:@"City"])
    {
        NSString *text = [allowedCities objectAtIndex:row];
        [cityName setTitle:text forState:UIControlStateNormal];
        [landmarkName setHidden:false];
        [landmarkName setEnabled:true];
    } else if ([pickerClicked isEqualToString:@"Landmark"])
    {
        NSString *city = cityName.titleLabel.text;
        NSMutableArray *thisCity = [citiesAndLandmarks objectForKey:city];
        NSString *landmark = [thisCity objectAtIndex:row];
        [landmarkName setTitle:landmark forState:UIControlStateNormal];
        PFQuery *query = [PFQuery queryWithClassName:city];
        [query whereKey:@"landmark" equalTo:landmark];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error)
            {
                PFObject *object = [objects objectAtIndex:0];
                NSNumber *dealAvailability = [object objectForKey:@"dealAvailable"];
                NSString *dealText = [object objectForKey:@"dealText"];
                NSNumber *dealLimitActive = [object objectForKey:@"dealLimit"];
                NSNumber *numberDealsLeft = [object objectForKey:@"numberDealsLeft"];
                if ([dealAvailability isEqualToNumber:[NSNumber numberWithInt:1]])
                {
                    [onOff setOn:true];
                    textField.hidden = false;
                    textField.text = dealText;
                } else
                {
                    [onOff setOn:false];
                    textField.hidden = true;
                    textField.text = @"";
                }
                if ([dealLimitActive isEqualToNumber:[NSNumber numberWithInt:1]])
                {
                    [yesNo setOn:true];
                    numberOfDeal.hidden = false;
                    numberOfDeal.text = [numberDealsLeft stringValue];
                } else
                {
                    [yesNo setOn:false];
                    numberOfDeal.hidden = true;
                    numberOfDeal.text = @"";
                }
            } else
            {
                UIAlertView *errorMsg = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There was a problem retrieving data from the database. Please try again shortly." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                errorMsg.alertViewStyle = UIAlertViewStyleDefault;
                [errorMsg show];
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    [picker setHidden:true];
}

-(IBAction)chooseCity:(id)sender
{
    pickerClicked = @"City";
    [picker reloadAllComponents];
    [picker setHidden:false];
}

-(IBAction)chooseLandmark:(id)sender
{
    pickerClicked = @"Landmark";
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
