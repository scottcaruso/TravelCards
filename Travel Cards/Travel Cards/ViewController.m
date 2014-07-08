//
//  ViewController.m
//  Travel Cards
//
//  Created by Scott Caruso on 6/17/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [self.navigationItem setHidesBackButton:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool savedUser = [defaults valueForKey:@"IsSaved"];
    if (savedUser)
    {
        NSString *savedUserName = [defaults valueForKey:@"SavedUserName"];
        NSString *savedPassword = [defaults valueForKey:@"SavedPassword"];
        [PFUser logInWithUsernameInBackground:savedUserName password:savedPassword
                                        block:^(PFUser *user, NSError *error)
         {
             if (user)
             {
                 [self performSegueWithIdentifier:@"Login" sender:self];
             } else
             {
                 UIAlertView *loginFailed = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There was a problem logging you in with your saved details. Please re-enter them." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 loginFailed.alertViewStyle = UIAlertViewStyleDefault;
                 [loginFailed show];
             }
         }];
    }
    
    [self setFonts];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)clickSubmitButton:(id)sender
{
    NSString *enteredUserName = userName.text;
    NSString *enteredPassword = password.text;
    if ([enteredUserName isEqualToString:@""] || [enteredPassword isEqualToString:@""])
    {
        UIAlertView *checkEntry = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"It looks like you've left the User Name or Password field blank. Please try again!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        checkEntry.alertViewStyle = UIAlertViewStyleDefault;
        [checkEntry show];
    } else
    {
        [PFUser logInWithUsernameInBackground:enteredUserName password:enteredPassword
            block:^(PFUser *user, NSError *error)
            {
                if (user)
                {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    if ([saveLoginDetails isOn])
                    {
                        [defaults setValue:enteredUserName forKey:@"SavedUserName"];
                        [defaults setValue:enteredPassword forKey:@"SavedPassword"];
                        [defaults setBool:true forKey:@"IsSaved"];
                    }
                    NSNumber *userID = [user objectForKey:@"userID"];
                    [defaults setValue:userID forKey:@"SavedUserID"];
                    [defaults synchronize];
                    [self performSegueWithIdentifier:@"Login" sender:self];
                } else
                {
                    NSLog(@"%@",error);
                    UIAlertView *loginFailed = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There was a problem logging you in. Please check your login details and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        loginFailed.alertViewStyle = UIAlertViewStyleDefault;
                        [loginFailed show];
                }
                }];
    }
}

-(void)setFonts
{
    UIFont *font = [UIFont fontWithName:@"Antipasto" size:20];
    UIFont *boldFont = [UIFont fontWithName:@"Antipasto-ExtraBold" size:20];
    [userName setFont:font];
    [password setFont:font];
    [saveUser setFont:font];
    submitButton.titleLabel.font = boldFont;
    newUserButton.titleLabel.font = font;
}

@end
