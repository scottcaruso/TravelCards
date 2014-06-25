//
//  MapScreenViewController.m
//  Travel Cards
//
//  Created by Scott Caruso on 6/19/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import "MapScreenViewController.h"
#import <Parse/Parse.h>

@interface MapScreenViewController ()

@end

@implementation MapScreenViewController
@synthesize city,latitude,longitude;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    locationData = [[NSMutableDictionary alloc] init];
    [self getDataForLocation:city];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)getDataForLocation:(NSString*)className
{
    PFQuery *query = [PFQuery queryWithClassName:className];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            //Retrieve the city's landmarks from the cloud.
            for (PFObject *object in objects)
            {
                NSString *currentLocationName = [object objectForKey:@"landmark"];
                NSString *currentLocationDescription = [object objectForKey:@"description"];
                NSNumber *currentLocationLatitude = [object objectForKey:@"latitude"];
                NSNumber *currentLocationLongitude = [object objectForKey:@"longitude"];
                NSArray *arrayOfData = [[NSArray alloc] initWithObjects:currentLocationDescription,currentLocationLatitude, currentLocationLongitude, nil];
                [locationData setValue:arrayOfData forKey:currentLocationName];
            }
            [self addAnnotations];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    //So, now we take the data we just got from the previous view to help set our mapview.
    
    MKCoordinateSpan mapSpan;
    mapSpan.latitudeDelta = .5f;
    mapSpan.longitudeDelta = .5f;
    CLLocationCoordinate2D mapCenter;
    mapCenter.latitude = latitude;
    mapCenter.longitude = longitude;
    MKCoordinateRegion mapRegion;
    mapRegion.span = mapSpan;
    mapRegion.center = mapCenter;
    [mapView setRegion:mapRegion];
}

-(void)addAnnotations
{
    //Adding annotations for all of the places within this given location, based on the data we've pulled for it.
    
    //We count the number of landmarks in the city based on the locationData we just pulled.
    //We get an array of the key names to cycle through.
    //Using those key names, we grab latitude and longitude for each name.
    //We plot an annotation at each location based on the real-world data.
    
    int numberOfLandmarks = [locationData count];
    NSArray *arrayOfKeys = [locationData allKeys];
    for (int x = 0; x < numberOfLandmarks; x++)
    {
        NSString *thisName = [arrayOfKeys objectAtIndex:x];
        NSArray *arrayOfData = [locationData objectForKey:thisName];
        NSNumber *thisLatitude = [arrayOfData objectAtIndex:1];
        NSNumber *thisLongitude = [arrayOfData objectAtIndex:2];
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        CLLocationCoordinate2D coord;
        coord.latitude = [thisLatitude doubleValue];
        coord.longitude = [thisLongitude doubleValue];
        point.coordinate = coord;
        point.title = thisName;
        [locationMap addAnnotation:point];
    }
}

@end
