//
//  NewAccountViewController.m
//  Travel Cards
//
//  Created by Scott Caruso on 6/22/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import "NewAccountViewController.h"
#import <Parse/Parse.h>

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
    //Immediately get the number of users so that we can properly assign a UserID.
    PFQuery *query = [PFUser query];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error)
        {
            // The count request succeeded. Log the count
            numberOfUsers = count;
        } else
        {
            //We need to add some error handling in the event that this doesn't work right.
        }
    }];
    
    [self setFonts];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Verify that all of the entered details are valid. If they are, check that the UserName doesn't already exist. If not, go ahead and create the user in the database, assign him a UserID, and also add him to the Achievements table.
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
        int newUserID = numberOfUsers+1;
        NSNumber *newUserNumber = [[NSNumber alloc] initWithInt:newUserID];
        PFUser *user = [PFUser user];
        user.username = enteredUserName;
        user.password = enteredPassword;
        user[@"userID"] = newUserNumber;
        user[@"isPartnerAdmin"] = [NSNumber numberWithInt:0];
        
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [self addUserToAchievementsDatabase:newUserNumber userName:enteredUserName];
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

//Create an entry in the Achievements table for this user. Called during new user creation.
-(void)addUserToAchievementsDatabase:(NSNumber*)userID userName:(NSString*)userName
{
    PFObject *achievements = [PFObject objectWithClassName:@"AchievementCompletion"];
    achievements[@"userID"] = userID;
    achievements[@"userName"] = userName;
    [achievements saveInBackground];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Success!"])
    {
        if (buttonIndex == 0)
        {
            [PFUser logInWithUsernameInBackground:desiredUserName.text password:desiredPassword.text
                                            block:^(PFUser *user, NSError *error)
             {
                 if (user)
                 {
                     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                     //If we decide to ever allow the user to Save Details from this screen, this code is here.
                     /*if ([saveLoginDetails isOn])
                     {
                         [defaults setValue:enteredUserName forKey:@"SavedUserName"];
                         [defaults setValue:enteredPassword forKey:@"SavedPassword"];
                         [defaults setBool:true forKey:@"IsSaved"];
                     }*/
                     NSNumber *userID = [user objectForKey:@"userID"];
                     [defaults setValue:userID forKey:@"SavedUserID"];
                     [defaults synchronize];
                     [self performSegueWithIdentifier:@"CreateUserSuccess" sender:self];
                 } else
                 {
                     UIAlertView *loginFailed = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There was a problem logging you in. Please check your login details and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     loginFailed.alertViewStyle = UIAlertViewStyleDefault;
                     [loginFailed show];
                     NSLog(@"%@",error);
                 }
             }];
        }
    }
}

-(void)setFonts
{
    UIFont *font = [UIFont fontWithName:@"Antipasto" size:20];
    UIFont *boldFont = [UIFont fontWithName:@"Antipasto-ExtraBold" size:20];
    [desiredUserName setFont:font];
    [desiredPassword setFont:font];
    [retypePassword setFont:font];
    submitButton.titleLabel.font = boldFont;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Antipasto-ExtraBold" size:21],
      NSFontAttributeName, nil]];
}

//Dismiss keyboard from textfields.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([desiredUserName isFirstResponder] && [touch view] != desiredUserName)
    {
        [desiredUserName resignFirstResponder];
    } else if ([desiredPassword isFirstResponder] && [touch view] != desiredPassword)
    {
        [desiredPassword resignFirstResponder];
    } else if ([retypePassword isFirstResponder] && [touch view] != retypePassword)
    {
        [retypePassword resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

//Dismiss keyboard.
-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

@end
