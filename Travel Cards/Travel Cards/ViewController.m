//
//  ViewController.m
//  Travel Cards
//
//  Created by Scott Caruso on 6/17/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import "ViewController.h"
#import "Reachability.h"
#import "PartnerAdminViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [self.navigationItem setHidesBackButton:YES]; //We never want to see a back button no matter how we get to this screen.
    
    //Determine if the user has opted to save his login details for faster access to the app.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool savedUser = [defaults valueForKey:@"IsSaved"];
    
    //Confirm that a network connection exists, and stop the user from proceeding if it does not.
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *noNetwork = [[UIAlertView alloc] initWithTitle:@"Poor network conditions" message:@"TravelCards requires a network connection to function. Please try again with a stronger network connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        noNetwork.alertViewStyle = UIAlertViewStyleDefault;
        [noNetwork show];
        submitButton.enabled = false;
        newUserButton.enabled = false;
    } else {
        //if the user is saved, grab his data and log him in automatically.
        if (savedUser)
        {
            NSString *savedUserName = [defaults valueForKey:@"SavedUserName"];
            NSString *savedPassword = [defaults valueForKey:@"SavedPassword"];
            userNameToPass = savedUserName;
            [PFUser logInWithUsernameInBackground:savedUserName password:savedPassword
                                            block:^(PFUser *user, NSError *error)
             {
                 if (user)
                 {
                     if ([user objectForKey:@"isPartnerAdmin"] == [NSNumber numberWithInt:1])
                     {
                        [self performSegueWithIdentifier:@"adminLogin" sender:self];
                     } else
                     {
                        [self performSegueWithIdentifier:@"Login" sender:self];
                     }

                 } else
                 {
                     UIAlertView *loginFailed = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There was a problem logging you in with your saved details. Please re-enter them." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     loginFailed.alertViewStyle = UIAlertViewStyleDefault;
                     [loginFailed show];
                 }
             }];
        }
    }
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Antipasto" size:21],
      NSFontAttributeName, nil]];
    [self setFonts];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//The function handles what happens after the user clicks the submit button. It does some basic error checking before logging the user in.
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
        userNameToPass = enteredUserName;
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
                    if ([user objectForKey:@"isPartnerAdmin"] == [NSNumber numberWithInt:1])
                    {
                        [self performSegueWithIdentifier:@"adminLogin" sender:self];
                    } else
                    {
                        [self performSegueWithIdentifier:@"Login" sender:self];
                    }
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

//Use the custom font on this screen.
-(void)setFonts
{
    UIFont *font = [UIFont fontWithName:@"Antipasto" size:20];
    UIFont *boldFont = [UIFont fontWithName:@"Antipasto-ExtraBold" size:20];
    UIFont *thinFont = [UIFont fontWithName:@"Antipasto-ExtraLight" size:10];
    [userName setFont:font];
    [password setFont:font];
    [saveUser setFont:font];
    [copyright setFont:thinFont];
    submitButton.titleLabel.font = boldFont;
    newUserButton.titleLabel.font = font;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Antipasto-ExtraBold" size:21],
      NSFontAttributeName, nil]];
}

//Dismiss the keyboard.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([userName isFirstResponder] && [touch view] != userName)
    {
        [userName resignFirstResponder];
    } else if ([password isFirstResponder] && [touch view] != password)
    {
        [password resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"adminLogin"])
    {
        PartnerAdminViewController *view = [segue destinationViewController];
        view.username = userNameToPass;
    }
}

//Dismiss the keyboard.
-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

@end
