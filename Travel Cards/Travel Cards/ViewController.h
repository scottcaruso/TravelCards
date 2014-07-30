//
//  ViewController.h
//  Travel Cards
//
//  Created by Scott Caruso on 6/17/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ViewController : UIViewController
{
    IBOutlet UITextField *userName;
    IBOutlet UITextField *password;
    IBOutlet UILabel *copyright;
    IBOutlet UILabel *saveUser;
    IBOutlet UIButton *submitButton;
    IBOutlet UIButton *newUserButton;
    IBOutlet UISwitch *saveLoginDetails;
    
    NSString *userNameToPass;
}

-(IBAction)clickSubmitButton:(id)sender;
-(IBAction)textFieldReturn:(id)sender;

@end
