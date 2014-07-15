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

@end
