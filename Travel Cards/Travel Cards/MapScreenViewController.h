//
//  MapScreenViewController.h
//  Travel Cards
//
//  Created by Scott Caruso on 6/19/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapScreenViewController : UIViewController <MKMapViewDelegate>
{
    IBOutlet MKMapView *locationMap;
}

@end
