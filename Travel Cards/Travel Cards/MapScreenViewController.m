//
//  MapScreenViewController.m
//  Travel Cards
//
//  Created by Scott Caruso on 6/19/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import "MapScreenViewController.h"
#import "PostcardViewController.h"
#import "CollectionsViewController.h"
#import <Parse/Parse.h>

@interface MapScreenViewController ()

@end

@implementation MapScreenViewController
@synthesize city,cityTitle,latitude,longitude,userID;

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
    //Load the saved User ID
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    userID = [defaults objectForKey:@"SavedUserID"];
    
    locationData = [[NSMutableDictionary alloc] init];
    [self.navigationItem setTitle:cityTitle];
    [self getDataForLocation:city];
    [self verifyIfCollectionExistsAndCreateIfNot];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
                NSString *imageURL = [object objectForKey:@"imageURL"];
                NSString *landmarkID = [object objectForKey:@"landmarkID"];
                NSArray *arrayOfData = [[NSArray alloc] initWithObjects:currentLocationDescription,currentLocationLatitude, currentLocationLongitude, imageURL, landmarkID, nil];
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
    mapSpan.latitudeDelta = .08f;
    mapSpan.longitudeDelta = .08f;
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

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    MKPointAnnotation *point = view.annotation;
    NSString *currentTitle = point.title;
    currentlySelectedAnnotation = currentTitle;
}

-(void)verifyIfCollectionExistsAndCreateIfNot
{
    NSString *collectionString = [[NSString alloc] initWithFormat:@"%@Collection",city];
    PFQuery *query = [PFQuery queryWithClassName:collectionString];
    [query whereKey:@"userID" equalTo:userID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (objects.count == 0)
        {
            PFObject *newUser = [PFObject objectWithClassName:collectionString];
            newUser[@"userID"] = userID;
            [newUser saveInBackground];
        }
    }];
}

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"advanceToPostcard"])
    {
        // Get reference to the destination view controller
        PostcardViewController *newView = [segue destinationViewController];
 
        // Pass the city identifier, latitude, and longitude of the current location
        NSArray *thisData = [locationData objectForKey:currentlySelectedAnnotation];
        newView.locationDatabase = city;
        newView.locationName = currentlySelectedAnnotation;
        newView.locationDescription = [thisData objectAtIndex:0];
        newView.imageURL = [thisData objectAtIndex:3];
        newView.landmarkID = [thisData objectAtIndex:4];
    }
    if ([[segue identifier] isEqualToString:@"goToCollection"])
    {
        // Get reference to the destination view controller
        CollectionsViewController *newView = [segue destinationViewController];
        
        // Pass the city identifier, latitude, and longitude of the current location
        newView.cityCodeName = city;
    }
}

@end
