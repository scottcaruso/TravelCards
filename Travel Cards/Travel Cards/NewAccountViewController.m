//
//  NewAccountViewController.m
//  Travel Cards
//
//  Created by Scott Caruso on 6/22/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import "NewAccountViewController.h"

@interface NewAccountViewController ()

@end

@implementation NewAccountViewController

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

-(IBAction)clickNewAccountButton:(id)sender
{
    NSString *enteredUserName = desiredUserName.text;
    NSString *enteredPassword = desiredPassword.text;
    NSString *confirmedPassword = retypePassword.text;
    if ([enteredUserName isEqualToString:@""] || [enteredPassword isEqualToString:@""] || [confirmedPassword isEqualToString:@""])
    {
        UIAlertView *checkEntry = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"It looks like you've left one of the fields blank. Please try again!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        checkEntry.alertViewStyle = UIAlertViewStyleDefault;
        [checkEntry show];
    } else if (![enteredPassword isEqualToString:confirmedPassword])
    {
        UIAlertView *noMatch = [[UIAlertView alloc] initWithTitle:@"Password mismatch" message:@"Your password entries do not match! Please try again!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        noMatch.alertViewStyle = UIAlertViewStyleDefault;
        [noMatch show];
    } else
    {
        //Run creation code
    }
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
