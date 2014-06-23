//
//  NewAccountViewController.h
//  Travel Cards
//
//  Created by Scott Caruso on 6/22/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface NewAccountViewController : UIViewController
{
    IBOutlet UITextField *desiredUserName;
    IBOutlet UITextField *desiredPassword;
    IBOutlet UITextField *retypePassword;
}

-(IBAction)clickNewAccountButton:(id)sender;

@end
