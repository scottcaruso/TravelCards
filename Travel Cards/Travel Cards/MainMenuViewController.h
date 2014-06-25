//
//  MainMenuViewController.h
//  Travel Cards
//
//  Created by Scott Caruso on 6/20/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainMenuViewController : UIViewController <UITableViewDelegate>
{
    IBOutlet UILabel *cityName;
    NSString *cityDataString;
    float latitude;
    float longitude;
}

@property IBOutlet UITableView *mainMenuTable;

-(void)runGeolocationAndLocationFinding;

@end
