//
//  MapScreenViewController.h
//  Travel Cards
//
//  Created by Scott Caruso on 6/19/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapScreenViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
{
    IBOutlet MKMapView *locationMap;
    IBOutlet UIButton *advanceToPostcard;
    IBOutlet UIButton *advanceToCollections;
    
    NSMutableDictionary *locationData;
    NSString *currentlySelectedAnnotation;
    
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
