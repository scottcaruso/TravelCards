//
//  MapScreenViewController.h
//  Travel Cards
//
//  Created by Scott Caruso on 6/19/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapScreenViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>
{
    IBOutlet MKMapView *locationMap;
    IBOutlet UIButton *advanceToCollections;
    
    NSMutableDictionary *locationData;
    NSString *currentlySelectedAnnotation;
    NSString *locationFromPopup; //Used when the user tries to check in from the AlertView
    
    double defaultCheckinDistance; //Application defined default for how close the user needs to be to check in to a place.
    
    bool closeEnoughToCheckIn; //a boolean that tells the postcard view if the user is close enough to perform a check-in action
}

@property NSString *city;
@property NSString *cityTitle;
@property float latitude;
@property float longitude;
@property NSNumber *userID;

-(void)addAnnotations;
-(void)getDataForLocation:(NSString*)className;
-(void)verifyIfCollectionExistsAndCreateIfNot;

@end
