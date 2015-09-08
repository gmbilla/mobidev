//
//  PlacesViewController.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 01/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import "PlacesViewController.h"
#import "PlaceAnnotation.h"
#import "Place.h"
#import "User.h"
#import "NSManagedObject+Local.h"


static float DistanceThreshold = 0.001;
static int tAddPlaceAlertView = 113;

@interface PlacesViewController ()

@end

@implementation PlacesViewController {
    CLLocationManager *locationManager;
    UISearchBar *searchBar;
    CLLocation *userLocation, *lastLocation;
    NSString *address;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.mapView setShowsUserLocation:YES];
    
    // Set search bar in navigation bar
    searchBar = [UISearchBar new];
    [searchBar setDelegate:self];
    [searchBar setPlaceholder:@"Search places"];
    self.navigationItem.titleView = searchBar;
    
    locationManager = [CLLocationManager new];
    [locationManager setDelegate:self];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    // Load all stored places and add a pin for each
    for (Place *p in [Place fetchAll]) {
        NSLog(@"Adding annotation for place %@", p.name);
        [self.mapView addAnnotation:[[PlaceAnnotation alloc] initWithPlace:p]];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    // Request location update
    NSLog(@"Map appear");
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        NSLog(@"Authorized, starting update");
        // Start requesting location if got permission
        [locationManager startUpdatingLocation];
    } else {
        // If in iOS 8 request user permission
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [locationManager requestWhenInUseAuthorization];
            NSLog(@"Requesting user permission");
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"Map disappear");
    
    [locationManager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBActions

- (IBAction)userPositionBarButtonPressed:(UIBarButtonItem *)sender {
    [self updateUserLocationWithLastLocation];
}

- (IBAction)addPlaceBarButtonPressed:(UIBarButtonItem *)sender {    
    CLGeocoder *geocoder = [CLGeocoder new];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error || placemarks == nil) {
            [[[UIAlertView alloc] initWithTitle:@"Geocoding service unavailable" message:@"There was an error retrieving the position address. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        
        CLPlacemark *placemark = [placemarks lastObject];
        if (placemark) {
            address = [NSString stringWithFormat:@"%@, %@ %@ - %@ %@",
                       [placemark.addressDictionary valueForKey:kABPersonAddressStreetKey],
                       [placemark.addressDictionary valueForKey:kABPersonAddressZIPKey],
                       [placemark.addressDictionary valueForKey:kABPersonAddressCityKey],
                       [placemark.addressDictionary valueForKey:kABPersonAddressStateKey],
                       [placemark.addressDictionary valueForKey:kABPersonAddressCountryKey]];
            UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:@"Add Place" message:[NSString stringWithFormat:@"Set a name for address: %@", address] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
            [dialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[dialog textFieldAtIndex:0] setText:placemark.name];
            [dialog setTag:tAddPlaceAlertView];
            [dialog show];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Add Place" message:@"Whoops! Nothing found here :(" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
        }
    }];
}

#pragma mark - MKMapView delegate

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSLog(@"Region did change");
    // Close search bar when moving map
    [searchBar resignFirstResponder];
    
    if (fabs(lastLocation.coordinate.latitude - self.mapView.centerCoordinate.latitude) < DistanceThreshold / 100 && fabs(lastLocation.coordinate.longitude - self.mapView.centerCoordinate.longitude) < DistanceThreshold / 100) {
        [self.userPositionBarButton setTintColor:[UIColor orangeColor]];
    } else {
        [self.userPositionBarButton setTintColor:[UIColor whiteColor]];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    NSLog(@"View for annotation %@", NSStringFromClass([annotation class]));
    if ([annotation isKindOfClass:[PlaceAnnotation class]]) {
        MKPinAnnotationView *view = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:PlaceAnnotationId];
        if (view == nil) {
            view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PlaceAnnotationId];
            [view setEnabled:YES];
            [view setCanShowCallout:YES];
            [view setPinColor:MKPinAnnotationColorRed];
//            [view setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
        } else {
            [view setAnnotation:annotation];
        }
        
        return view;
    }
    
    return nil;
}

#pragma mark - CLLocationManager delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"auth changed to: %d", status);
    
    // If status disabled ask user to enable in settings
    switch (status) {
        case kCLAuthorizationStatusDenied:
            [[[UIAlertView alloc] initWithTitle:@"Location disabled" message:@"kalestenika can't access location. If you wanna use location service please enable location \"While Using the App\" in Settings" delegate:nil cancelButtonTitle:@"Cencel" otherButtonTitles:nil] show];
            break;
        
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"Authorized");
            [locationManager startUpdatingLocation];
            break;
        
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"Authorized");
            [locationManager startUpdatingLocation];
            break;
            
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    lastLocation = [locations lastObject];
    
    // Move map to new user location if it changed significantly
    if (userLocation == nil || (fabs(lastLocation.coordinate.latitude - userLocation.coordinate.latitude) > DistanceThreshold || fabs(lastLocation.coordinate.longitude - userLocation.coordinate.longitude) > DistanceThreshold)) {
        [self updateUserLocationWithLastLocation];
        
    }
}

#pragma mark - UISearchBar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)sender {
    NSString *addressQuery = searchBar.text;
    
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder geocodeAddressString:addressQuery completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error || placemarks == nil) {
            NSLog(@"Geocoding failed with error: %@", error);
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Address not found! Try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        
        NSLog(@"Got placemarks: %@", [placemarks lastObject]);
        
        CLPlacemark *placemark = [placemarks lastObject];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(placemark.location.coordinate, 250.0, 250.0);
        [self.mapView setRegion:region animated:YES];
    }];
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex {
    if (alertView.tag == tAddPlaceAlertView && address != nil && buttonIndex == 1) {
        NSString *name = [alertView textFieldAtIndex:0].text;
        NSLog(@"Save new address '%@' named: %@", address, name);
        if (name == nil) {
            [[[UIAlertView alloc] initWithTitle:@"Add Place Error" message:@"Please provide a valid name!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            Place *place = [Place new];
            place.name = name;
            place.address = address;
            place.creator = [User fetchCurrentUser];
            place.latitude = [NSNumber numberWithDouble:self.mapView.centerCoordinate.latitude];
            place.longitude = [NSNumber numberWithDouble:self.mapView.centerCoordinate.longitude];
            
            [place save];
            
            [self.mapView addAnnotation:[[PlaceAnnotation alloc] initWithPlace:place]];
        }
    }
}

#pragma mark - Private methods

- (void)updateUserLocationWithLastLocation {
    userLocation = lastLocation;
    NSLog(@"New user location: %f", userLocation.coordinate.latitude);
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 250.0, 250.0);
    [self.mapView setRegion:region animated:YES];
}

@end
