//
//  PartnerAdminViewController.h
//  Travel Cards
//
//  Created by Scott Caruso on 7/28/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PartnerAdminViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
{
    IBOutlet UILabel *availability;
    IBOutlet UILabel *onLabel;
    IBOutlet UILabel *offLabel;
    IBOutlet UILabel *noLabel;
    IBOutlet UILabel *yesLabel;
    IBOutlet UILabel *limitedDeal;
    IBOutlet UILabel *maxViews;
    IBOutlet UITextView *textField;
    IBOutlet UIButton *cityName;
    IBOutlet UIButton *landmarkName;
    IBOutlet UISwitch *onOff;
    IBOutlet UISwitch *yesNo;
    IBOutlet UITextField *numberOfDeal;
    IBOutlet UIPickerView *picker;
    
    NSString *pickerClicked;
    
    NSMutableArray *cities;
    NSMutableArray *allowedCities;
    NSMutableDictionary *citiesAndLandmarks;
}

@property NSString *username;

@end
