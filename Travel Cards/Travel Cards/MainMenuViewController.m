//
//  MainMenuViewController.m
//  Travel Cards
//
//  Created by Scott Caruso on 6/20/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import "MainMenuViewController.h"
#import "MapScreenViewController.h"
#import <Parse/Parse.h>

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

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
    [self.navigationItem setHidesBackButton:YES];
    
    dictionaryofCoordinates = [[NSMutableDictionary alloc] init];
    
    //Step 1 - Start Geolocating user
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    //When we load the view, we are going to run the Geolocation functions. For now, we are spoofing the
    //data so that we can test the application as if we are in the New York area.
    //[self runGeolocationAndLocationFinding];
    
    cityName.text = @"New York, NY";
    cityDataString = @"NewYork";
    //latitude = 40.748f;
    //longitude = -73.99f;
    
    [self setFonts];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//This creates the rows for the ViewController table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

//This feeds the data for the table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Cell";
    NSString *menuItem;
    
    UITableViewCell *thisCell;
    if (indexPath.row == 0)
    {
        thisCell = [tableView dequeueReusableCellWithIdentifier:@"Collections"];
        menuItem = @"Collections";
    } else if (indexPath.row == 1)
    {
        thisCell = [tableView dequeueReusableCellWithIdentifier:@"Achievements"];
        menuItem = @"Achicevements";
    } else if (indexPath.row == 2)
    {
        thisCell = [tableView dequeueReusableCellWithIdentifier:@"Settings"];
        menuItem = @"Settings";
    } else if (indexPath.row == 3)
    {
        thisCell = [tableView dequeueReusableCellWithIdentifier:@"User"];
        menuItem = @"User Control";
    }
    if (thisCell == nil)
    {
        thisCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    UIFont *font = [UIFont fontWithName:@"Antipasto" size:20];
    thisCell.textLabel.text = menuItem;
    thisCell.textLabel.font = font;
    thisCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return thisCell;
}

-(void)runGeolocationAndLocationFinding
{
    /* This is where the Geolocation will run, along with determining if there is a Travel Cards destination somewhere
     in a reasonable distance near the current location. */
    
    //Step 2 - Parse the Travel Cards location data
    PFQuery *query = [PFQuery queryWithClassName:@"CityNames"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects)
            {
                NSNumber *thisLat = [object objectForKey:@"latitude"];
                NSNumber *thisLon = [object objectForKey:@"longitude"];
                double latDouble = [thisLat doubleValue];
                double lonDouble = [thisLon doubleValue];
                CLLocation *thisLocation = [[CLLocation alloc] initWithLatitude:latDouble longitude:lonDouble];
                [dictionaryofCoordinates setValue:thisLocation forKey:[object objectForKey:@"cityName"]];
            }
            CLLocationDistance distance = 10000000000000;
            NSString *nameOfCity;
            CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            //Step 3 - Compare current location to other locations to find out which, if any, is closest
            for (int x = 0; x < [dictionaryofCoordinates count]; x++)
            {
                NSArray *arrayOfKeys = [dictionaryofCoordinates allKeys];
                CLLocation *locationToCheck = [dictionaryofCoordinates objectForKey:[arrayOfKeys objectAtIndex:x]];
                CLLocationDistance currentDistance = [currentLocation distanceFromLocation:locationToCheck];
                if (currentDistance < distance)
                {
                    distance = currentDistance;
                    nameOfCity = [arrayOfKeys objectAtIndex:x];
                }
            }
            //THIS IS A DEBUG POPUP FOR TESTING PURPOSES. WILL BE REMOVED IN FINAL UI
            NSString *alertString = [[NSString alloc] initWithFormat:@"The location nearest to you is %@, which is %f meters away.",nameOfCity,distance];
            UIAlertView *closestLocation = [[UIAlertView alloc] initWithTitle:@"PLACEHOLDER" message:alertString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            closestLocation.alertViewStyle = UIAlertViewStyleDefault;
            [closestLocation show];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    //Step 4 - Determine if this location is within X distance of current location -- NOT SURE THAT I WANT TO DO THIS
    //Step 5 - Update Main Menu accordingly and set instance variables
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *lastLocation = [locations lastObject];
    longitude = lastLocation.coordinate.longitude;
    latitude = lastLocation.coordinate.latitude;
    NSLog(@"latitude:%f,longitude:%f",latitude,longitude);
    [self runGeolocationAndLocationFinding];
    [locationManager stopUpdatingLocation];
}

-(void)logUserOut
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removePersistentDomainForName:@"com.fullsail.TestApp.Travel-Cards"];
    [defaults synchronize];
}

-(void)setFonts
{
    UIFont *font = [UIFont fontWithName:@"Antipasto" size:20];
    //UIFont *boldFont = [UIFont fontWithName:@"Antipasto-ExtraBold" size:20];
    [cityName setFont:font];
    [tapImageLabel setFont:font];
}

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if ([[segue identifier] isEqualToString:@"mapPush"])
     {
         // Get reference to the destination view controller
         MapScreenViewController *newView = [segue destinationViewController];
     
         // Pass the city identifier, latitude, and longitude of the current location
         newView.city = cityDataString;
         newView.cityTitle = cityName.text;
         newView.latitude = latitude;
         newView.longitude = longitude;
     }
     if ([[segue identifier] isEqualToString:@"Logout"])
     {
         [self logUserOut];
     }
 }

@end
