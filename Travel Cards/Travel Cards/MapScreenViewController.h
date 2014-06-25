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
    NSMutableDictionary *locationData;
}

@property NSString *city;
@property float latitude;
@property float longitude;

-(void)addAnnotations;
-(void)getDataForLocation:(NSString*)className;

@end
