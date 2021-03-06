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

-(void)viewWillAppear:(BOOL)animated
{
    //Loading notification
    [loading startAnimating];
    
    //First, check if we are using fake coordinates. This is only used in a testing build in which the user has been able to specify his own latitude and longitude.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool fakeCoordinates = [defaults boolForKey:@"FakeCoordinates"];
    double savedLatitude = [defaults doubleForKey:@"Latitude"];
    double savedLongitude = [defaults doubleForKey:@"Longitude"];
    dictionaryofCoordinates = [[NSMutableDictionary alloc] init];
    dictionaryOfNamesAndClassNames = [[NSMutableDictionary alloc] init];
    dictionaryOfURLs = [[NSMutableDictionary alloc] init];
    if (fakeCoordinates)
    {
        latitude = savedLatitude;
        longitude = savedLongitude;
        [self runGeolocationAndLocationFinding];
    } else
    {
        //Start geolocation services.
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];
        //If these things have been turned off, turn them back on.
        cityName.hidden = false;
        tapImageLabel.hidden = false;
        advanceButton.enabled = true;
    }
    [super viewWillAppear:false];
}

-(void)locationManager:(CLLocationManager *)inManager didFailWithError:(NSError *)inError{
    UIAlertView *gpsOff = [[UIAlertView alloc] initWithTitle:@"GPS is turned off" message:@"Location Services are currently disabled or disallowed. Please enable them to use this application!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    gpsOff.alertViewStyle = UIAlertViewStyleDefault;
    [gpsOff show];
    
    //If GPS is turned off, prevent the dynamic elements from being tappable.
    cityName.hidden = true;
    tapImageLabel.hidden = true;
    advanceButton.enabled = false;
}

- (void)viewDidLoad
{
    [self.navigationItem setHidesBackButton:YES];
    
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
        menuItem = @"Credits";
    } else if (indexPath.row == 3)
    {
        thisCell = [tableView dequeueReusableCellWithIdentifier:@"User"];
        menuItem = @"Log Out";
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

//This happens immediately after we get a latitude and longitude.
-(void)runGeolocationAndLocationFinding
{
    /* This is where the Geolocation will run, along with determining if there is a Travel Cards destination somewhere
     in a reasonable distance near the current location. */
    
    //Step 2 - Parse the Travel Cards location data
    PFQuery *query = [PFQuery queryWithClassName:@"CityNames"];
    [query whereKey:@"isActive" equalTo:@1];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects)
            {
                NSNumber *thisLat = [object objectForKey:@"latitude"];
                NSNumber *thisLon = [object objectForKey:@"longitude"];
                double latDouble = [thisLat doubleValue];
                double lonDouble = [thisLon doubleValue];
                NSString *thisCityCode = [object objectForKey:@"cityClassName"];
                [dictionaryOfNamesAndClassNames setValue:thisCityCode forKey:[object objectForKey:@"cityName"]];
                CLLocation *thisLocation = [[CLLocation alloc] initWithLatitude:latDouble longitude:lonDouble];
                [dictionaryofCoordinates setValue:thisLocation forKey:[object objectForKey:@"cityName"]];
                [dictionaryOfURLs setValue:[object objectForKey:@"imageURL"] forKey:[object objectForKey:@"cityName"]];
            }
        
            CLLocationDistance distance = 10000000000000; //This is merely a default value that's impossibly far away from anything in the United States.
            NSString *nameOfCity;
            CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude]; //This is the CLLocation object for the currently Geolocated location.
            
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
            if (distance > 80467) //This is the approximate value of meters that equals 50 miles.
            {
                [cityName setHidden:true];
                [tapImageLabel setHidden:true];
                [advanceButton setEnabled:false];
                UIAlertView *tooFar = [[UIAlertView alloc] initWithTitle:@"Too far!" message:@"The nearest TravelCards location is over 50 miles from you. Check back soon - we're always adding new landmarks!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                tooFar.alertViewStyle = UIAlertViewStyleDefault;
                [tooFar show];
            }
            cityName.text = nameOfCity;
            cityDataString = [dictionaryOfNamesAndClassNames objectForKey:nameOfCity];
            NSString *imageURL = [dictionaryOfURLs objectForKey:nameOfCity];
            UIImage *mainMenuImage = [self convertURLtoImage:imageURL];
            [advanceButton setBackgroundImage:mainMenuImage forState:UIControlStateNormal];
            [self stopSpinningAndShowUI];
        } else {
            UIAlertView *errorMsg = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There was a problem retrieving data from the database. Please try again shortly." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            errorMsg.alertViewStyle = UIAlertViewStyleDefault;
            [errorMsg show];
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

//We only get a single latitude and longitude. We don't want to be constantly pinging and updating.
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *lastLocation = [locations lastObject];
    longitude = lastLocation.coordinate.longitude;
    latitude = lastLocation.coordinate.latitude;
    [self runGeolocationAndLocationFinding];
    [locationManager stopUpdatingLocation];
    
    //Display the clickable elements once we're sure we've actually updated.
    cityName.hidden = false;
    tapImageLabel.hidden = false;
    advanceButton.enabled = true;
}

//If the Logout button is clicked, this is what we do.
-(void)logUserOut
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removePersistentDomainForName:@"com.fullsail.TestApp.Travel-Cards"];
    [defaults setBool:false forKey:@"FakeCoordinates"];;
    [defaults synchronize];
}

-(void)setFonts
{
    UIFont *font = [UIFont fontWithName:@"Antipasto" size:17];
    //UIFont *boldFont = [UIFont fontWithName:@"Antipasto-ExtraBold" size:20];
    [cityName setFont:font];
    [tapImageLabel setFont:font];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Antipasto-ExtraBold" size:21],
      NSFontAttributeName, nil]];
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

-(UIImage*)convertURLtoImage:(NSString*)url
{
    id path = (NSString*)url;
    NSURL *thisURL = [NSURL URLWithString:path];
    NSData *data = [NSData dataWithContentsOfURL:thisURL];
    UIImage *image = [[UIImage alloc] initWithData:data];
    return image;
}

-(void)stopSpinningAndShowUI
{
    [loading stopAnimating];
    cityName.hidden = false;
    tapImageLabel.hidden = false;
    mainMenuTable.hidden = false;
    advanceButton.hidden = false;
}

@end
