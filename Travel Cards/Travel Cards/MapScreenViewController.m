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

-(void)viewWillAppear:(BOOL)animated
{
    //Load the saved User ID
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    userID = [defaults objectForKey:@"SavedUserID"];
    
    //This is a value that we can change to determine how close the user needs to be in order to check in to a location. In meters.
    defaultCheckinDistance = 750;
    
    locationData = [[NSMutableDictionary alloc] init];
    [self.navigationItem setTitle:cityTitle];
    [self getDataForLocation:city];
    [self verifyIfCollectionExistsAndCreateIfNot];
    
    [super viewWillAppear:false];
}

- (void)viewDidLoad
{
    [loading startAnimating];
    
    [self setFonts];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Retrieve the specific data for the city we have Geolocated to. This includes the images, IDs, and deals. All of this is dynamic from the Parse database. Take all of them and create a dictionary of them so that we can retrieve them whenever an annotation is clicked on.
-(void)getDataForLocation:(NSString*)className
{
    PFQuery *query = [PFQuery queryWithClassName:className];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
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
                NSString *imageCopyright = [object objectForKey:@"photoCredit"];
                NSString *imageYear = [object objectForKey:@"photoYear"];
                NSNumber *isADealAvailable = [object objectForKey:@"dealAvailable"];
                NSNumber *limitedDealAvailable = [object objectForKey:@"dealLimit"];
                NSNumber *numberOfDeals = [object objectForKey:@"numberDealsLeft"];
                if (numberOfDeals == nil)
                {
                    numberOfDeals = [NSNumber numberWithInt:0];
                }
                int deal = [isADealAvailable intValue];
                NSString *currentDealText;
                if (deal == 1)
                {
                    currentDealText = [object objectForKey:@"dealText"];
                } else
                {
                    currentDealText = @"No deal!";
                }
                NSArray *arrayOfData = [[NSArray alloc] initWithObjects:currentLocationDescription,currentLocationLatitude, currentLocationLongitude, imageURL, landmarkID, isADealAvailable, currentDealText, imageCopyright, imageYear, limitedDealAvailable, numberOfDeals, nil];
                [locationData setValue:arrayOfData forKey:currentLocationName];
            }
            [self addAnnotations];
            [self nearbyCheckinPossible];
        } else {
            UIAlertView *errorMsg = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There was a problem retrieving data from the database. Please try again shortly." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            errorMsg.alertViewStyle = UIAlertViewStyleDefault;
            [errorMsg show];
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
    CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    CLLocation *pointLocation = [[CLLocation alloc] initWithLatitude:point.coordinate.latitude longitude:point.coordinate.longitude];
    closeEnoughToCheckIn = [self canWeCheckIn:myLocation landmark:pointLocation];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    MKPinAnnotationView *newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinLocation"];
    
    newAnnotation.canShowCallout = true;
    newAnnotation.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return newAnnotation;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"toPostcard" sender:self];
    
}

-(void)verifyIfCollectionExistsAndCreateIfNot
{
    NSString *collectionString = [[NSString alloc] initWithFormat:@"%@Collection",city];
    PFQuery *query = [PFQuery queryWithClassName:collectionString];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
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
    [self stopSpinningAndShowUI];
}

-(void)setFonts
{
    UIFont *font = [UIFont fontWithName:@"Antipasto" size:20];
    //UIFont *boldFont = [UIFont fontWithName:@"Antipasto-ExtraBold" size:20];
    advanceToCollections.titleLabel.font = font;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Antipasto-ExtraBold" size:21],
      NSFontAttributeName, nil]];
    
}

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toPostcard"])
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
        newView.closeEnoughToCheckIn = closeEnoughToCheckIn;
        newView.isADealAvailable = [thisData objectAtIndex:5];
        newView.dealText = [thisData objectAtIndex:6];
        newView.imageCopyright = [thisData objectAtIndex:7];
        newView.imageYear = [thisData objectAtIndex:8];
        newView.limitedDealStatus = [thisData objectAtIndex:9];
        newView.limitedDealNumber = [thisData objectAtIndex:10];
    }
    if ([[segue identifier] isEqualToString:@"goToCollection"])
    {
        // Get reference to the destination view controller
        CollectionsViewController *newView = [segue destinationViewController];
        
        // Pass the city identifier, latitude, and longitude of the current location
        newView.cityCodeName = city;
        newView.cityName = cityTitle;
    }
    if ([[segue identifier] isEqualToString:@"fromAlertView"])
    {
        // Get reference to the destination view controller
        PostcardViewController *newView = [segue destinationViewController];
        
        // Pass the city identifier, latitude, and longitude of the current location
        NSArray *thisData = [locationData objectForKey:locationFromPopup];
        newView.locationDatabase = city;
        newView.locationName = locationFromPopup;
        newView.locationDescription = [thisData objectAtIndex:0];
        newView.imageURL = [thisData objectAtIndex:3];
        newView.landmarkID = [thisData objectAtIndex:4];
        newView.closeEnoughToCheckIn = true;
        newView.isADealAvailable = [thisData objectAtIndex:5];
        newView.dealText = [thisData objectAtIndex:6];
        newView.imageCopyright = [thisData objectAtIndex:7];
        newView.imageYear = [thisData objectAtIndex:8];
        newView.limitedDealStatus = [thisData objectAtIndex:9];
        newView.limitedDealNumber = [thisData objectAtIndex:10];
    }
}

//Determines if the current annotation is close enough to check in based on the default value set in the top.
-(bool)canWeCheckIn:(CLLocation*)userLocation landmark:(CLLocation*)landmark
{
    CLLocationDistance currentDistance = [userLocation distanceFromLocation:landmark];
    if (currentDistance <= defaultCheckinDistance)
    {
        return TRUE;
    } else
    {
        return FALSE;
    }
}

//Verifies the distance between the current location and the city's landmarks. If there's one close by, we implore the user to view the postcard.
-(void)nearbyCheckinPossible
{
    int numberOfLandmarks = [locationData count];
    NSArray *arrayOfKeys = [locationData allKeys];
    CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    NSString *closestLandmark = @"None";
    double defaultDistance = defaultCheckinDistance;
    for (int x = 0; x < numberOfLandmarks; x++)
    {
        NSString *thisName = [arrayOfKeys objectAtIndex:x];
        NSArray *arrayOfData = [locationData objectForKey:thisName];
        NSNumber *thisLatitude = [arrayOfData objectAtIndex:1];
        NSNumber *thisLongitude = [arrayOfData objectAtIndex:2];
        CLLocation *pointLocation = [[CLLocation alloc] initWithLatitude:[thisLatitude doubleValue] longitude:[thisLongitude doubleValue]];
        CLLocationDistance currentDistance = [myLocation distanceFromLocation:pointLocation];
        if (currentDistance < defaultDistance)
        {
            closestLandmark = thisName;
            defaultDistance = currentDistance;
        }
    }
    if (![closestLandmark isEqualToString:@"None"])
    {
        NSString *checkinText = [[NSString alloc] initWithFormat:@"You are close to %@! Do you want to view its postcard?",closestLandmark];
        UIAlertView *checkinAlert = [[UIAlertView alloc] initWithTitle:@"Nearby Landmark!" message:checkinText delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
        checkinAlert.alertViewStyle = UIAlertViewStyleDefault;
        locationFromPopup = closestLandmark;
        [checkinAlert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Nearby Landmark!"])
    {
        if (buttonIndex == 1)
        {
            [self performSegueWithIdentifier:@"fromAlertView" sender:self];
        }
    }
}

-(void)stopSpinningAndShowUI
{
    [loading stopAnimating];
    locationMap.hidden = false;
    advanceToCollections.hidden = false;
}

@end
