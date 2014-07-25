//
//  SettingsViewController.m
//  Travel Cards
//
//  Created by Scott Caruso on 7/15/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

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
    UIFont *font = [UIFont fontWithName:@"Antipasto" size:15];
    [textView setFont:font];
    [textView setTextAlignment:NSTextAlignmentCenter];
    [textView setTextColor:[UIColor colorWithRed:.94f green:.82f blue:.19f alpha:1]];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)switchFlipped:(id)sender
{
    if ([debugSwitch isOn])
    {
        [latitudeField setEnabled:true];
        [longitudeField setEnabled:true];
    } else
    {
        [latitudeField setEnabled:false];
        [longitudeField setEnabled:false];
    }
}

-(IBAction)saveDebugSetting:(id)sender
{
    double latitude = [latitudeField.text doubleValue];
    double longitude = [longitudeField.text doubleValue];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool savedCoordinates;
    if ([debugSwitch isOn])
    {
        savedCoordinates = true;
    } else
    {
        savedCoordinates = false;
    }
    [defaults setBool:savedCoordinates forKey:@"FakeCoordinates"];
    [defaults setDouble:latitude forKey:@"Latitude"];
    [defaults setDouble:longitude forKey:@"Longitude"];
    [defaults synchronize];
    UIAlertView *saveDetails = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your debug settings were saved successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    saveDetails.alertViewStyle = UIAlertViewStyleDefault;
    [saveDetails show];
    
}

@end
