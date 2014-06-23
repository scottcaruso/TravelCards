//
//  MapScreenViewController.m
//  Travel Cards
//
//  Created by Scott Caruso on 6/19/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import "MapScreenViewController.h"

@interface MapScreenViewController ()

@end

@implementation MapScreenViewController

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

-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    MKCoordinateSpan mapSpan; //default span that all of these locations use
    mapSpan.latitudeDelta = 1.5f;
    mapSpan.longitudeDelta = 1.5f;
    CLLocationCoordinate2D mapCenter;
    mapCenter.latitude = 30.4500f;
    mapCenter.longitude = -91.1400f;
    MKCoordinateRegion mapRegion;
    mapRegion.span = mapSpan;
    mapRegion.center = mapCenter;
    [mapView setRegion:mapRegion];
    [self addAnnotations:mapCenter.latitude longitude:mapCenter.longitude];
    
}

-(void)addAnnotations:(float)lat longitude:(float)lon
{
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D coord;
    coord.latitude = lat;
    coord.longitude = lon;
    point.coordinate = coord;
    [locationMap addAnnotation:point];
}

@end
