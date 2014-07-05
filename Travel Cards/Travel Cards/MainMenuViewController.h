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
    NSString *cityDataString;
    CLLocationManager *locationManager;
    float latitude;
    float longitude;
}

@property IBOutlet UITableView *mainMenuTable;

-(void)logUserOut;
-(void)runGeolocationAndLocationFinding;

@end
