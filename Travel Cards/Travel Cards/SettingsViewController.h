//
//  SettingsViewController.h
//  Travel Cards
//
//  Created by Scott Caruso on 7/15/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController
{
    IBOutlet UISwitch *debugSwitch;
    IBOutlet UITextField *latitudeField;
    IBOutlet UITextField *longitudeField;
    IBOutlet UIButton *saveSettings;
    IBOutlet UITextView *textView;
}

@end
