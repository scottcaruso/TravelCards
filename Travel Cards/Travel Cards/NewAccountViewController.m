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
        PFUser *user = [PFUser user];
        user.username = enteredUserName;
        user.password = enteredPassword;
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSString *successString = [NSString stringWithFormat:@"The account %@ was successfully created.",enteredUserName];
                UIAlertView *success = [[UIAlertView alloc] initWithTitle:@"Success!" message:successString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                success.alertViewStyle = UIAlertViewStyleDefault;
                [success show];
            } else {
                NSString *errorString = [error userInfo][@"error"];
                UIAlertView *accountCreateError = [[UIAlertView alloc] initWithTitle:@"Oops!" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                accountCreateError.alertViewStyle = UIAlertViewStyleDefault;
                [accountCreateError show];
            }
        }];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Success!"])
    {
        if (buttonIndex == 0)
        {
            [self performSegueWithIdentifier:@"CreateUserSuccess" sender:self];
        }
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
