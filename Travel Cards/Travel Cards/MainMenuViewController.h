//
//  MainMenuViewController.h
//  Travel Cards
//
//  Created by Scott Caruso on 6/20/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MainMenuViewController : UIViewController <UITableViewDelegate, CLLocationManagerDelegate>
{
    IBOutlet UILabel *cityName;
    IBOutlet UILabel *tapImageLabel;
    IBOutlet UITableView *mainMenuTable;
    IBOutlet UIButton *advanceButton;
    IBOutlet UIActivityIndicatorView *loading;
    
    NSString *cityDataString;
    CLLocationManager *locationManager;
    float latitude;
    float longitude;
    
    NSMutableDictionary *dictionaryofCoordinates; //Used to store Parse data so we can figure out which location is the closest.
    NSMutableDictionary *dictionaryOfNamesAndClassNames;
}



-(void)logUserOut;
-(void)runGeolocationAndLocationFinding;

@end
