//
//  PlacesViewController.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 01/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@class Place;

@interface PlacesViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *userPositionBarButton;

- (IBAction)userPositionBarButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)addPlaceBarButtonPressed:(UIBarButtonItem *)sender;

@end
