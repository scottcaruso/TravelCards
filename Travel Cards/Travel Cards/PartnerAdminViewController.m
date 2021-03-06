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
    [self setFonts];
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
                [onOff setHidden:false];
                [yesNo setHidden:false];
                [availability setHidden:false];
                [limitedDeal setHidden:false];
                [yesLabel setHidden:false];
                [noLabel setHidden:false];
                [onLabel setHidden:false];
                [offLabel setHidden:false];
                [maxViews setHidden:false];
                textField.text = @"Enter deal text here.";
                numberOfDeal.text = @"1";
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
                }
                [saveButton setHidden:false];
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
    [saveButton setHidden:true];
    [landmarkName setHidden:true];
    [onOff setHidden:true];
    [yesNo setHidden:true];
    [availability setHidden:true];
    [limitedDeal setHidden:true];
    [yesLabel setHidden:true];
    [noLabel setHidden:true];
    [onLabel setHidden:true];
    [offLabel setHidden:true];
    [maxViews setHidden:true];
    [textField setHidden:true];
    [numberOfDeal setHidden:true];
    [saveButton setHidden:true];
    landmarkName.titleLabel.text = @"Choose a landmark";
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

-(IBAction)dealActiveClick:(id)sender
{
    if (onOff.on == true)
    {
        textField.hidden = false;
    } else
    {
        textField.hidden = true;
    }
}

-(IBAction)setLimitClick:(id)sender
{
    if (yesNo.on == true)
    {
        numberOfDeal.hidden = false;
    } else
    {
        numberOfDeal.hidden  = true;
    }
}

-(IBAction)saveButtonClick:(id)sender
{
    PFQuery *query = [PFQuery queryWithClassName:cityName.titleLabel.text];
    [query whereKey:@"landmark" equalTo:landmarkName.titleLabel.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            [onOff setHidden:true];
            [yesNo setHidden:true];
            [availability setHidden:true];
            [limitedDeal setHidden:true];
            [yesLabel setHidden:true];
            [noLabel setHidden:true];
            [onLabel setHidden:true];
            [offLabel setHidden:true];
            [maxViews setHidden:true];
            [textField setHidden:true];
            [numberOfDeal setHidden:true];
            [saveButton setHidden:true];
            PFObject *object = [objects objectAtIndex:0];
            NSNumber *dealStatus = [NSNumber numberWithInt:0];
            NSNumber *dealLimit = [NSNumber numberWithInt:0];
            if ([yesNo isOn] == true)
            {
                dealStatus = [NSNumber numberWithInt:1];
            }
            if ([onOff isOn] == true)
            {
                dealLimit = [NSNumber numberWithInt:1];
            }
            NSString *dealLimitString = numberOfDeal.text;
            int intOfDeals = [dealLimitString intValue];
            NSNumber *numberOfDeals = [NSNumber numberWithInt:intOfDeals];
            object[@"dealAvailable"] = dealStatus;
            object[@"dealText"] = textField.text;
            object[@"dealLimit"] = dealLimit;
            object[@"numberDealsLeft"] = numberOfDeals;
            [object saveInBackground];
            [landmarkName setHidden:true];
            [cityName setTitle:@"Select a city" forState:UIControlStateNormal];
            UIAlertView *newDetails = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have successfully updated the database." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            newDetails.alertViewStyle = UIAlertViewStyleDefault;
            [newDetails show];
        } else
        {
            UIAlertView *errorMsg = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There was a problem retrieving data from the database. Please try again shortly." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            errorMsg.alertViewStyle = UIAlertViewStyleDefault;
            [errorMsg show];
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([textField isFirstResponder] && [touch view] != textField)
    {
        [textField resignFirstResponder];
    } else if ([numberOfDeal isFirstResponder] && [touch view] != numberOfDeal)
    {
        [numberOfDeal resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

-(void)setFonts
{
    UIFont *font = [UIFont fontWithName:@"Antipasto" size:20];
    UIFont *thinFont = [UIFont fontWithName:@"Antipasto-ExtraLight" size:14];
    [availability setFont:font];
    [onLabel setFont:font];
    [offLabel setFont:font];
    [noLabel setFont:font];
    [yesLabel setFont:font];
    [limitedDeal setFont:font];
    [maxViews setFont:font];
    [textField setFont:thinFont];
    [numberOfDeal setFont:font];
    cityName.titleLabel.font = font;
    landmarkName.titleLabel.font = font;
    saveButton.titleLabel.font = font;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Antipasto-ExtraBold" size:21],
      NSFontAttributeName, nil]];
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
