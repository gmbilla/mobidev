//
//  SaveSessionViewController.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 07/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "SaveSessionViewController.h"
#import "HCSStarRatingView.h"
#import "PlaceAnnotation.h"
#import "Constants.h"
#import "Session.h"
#import "Workout.h"
#import "Place.h"
#import "NSManagedObject+Local.h"


@implementation SaveSessionViewController {
    UIButton *calloutButton;
    Place *selectedPlace;
    NSString *chosePlacePlaceholderText;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup views
    [self.workoutNameLabel setText:self.session.workout.name];
    [self.durationLabel setText:[Constants secondsToHhMmSs:self.session.duration.intValue]];
    [self.completionLabel setText:[NSString stringWithFormat:@"%d%%", self.session.completion.intValue]];
    chosePlacePlaceholderText = self.chosenPlaceLabel.text;
    [self.ratingView addTarget:self action:@selector(ratingChanged:) forControlEvents:UIControlEventValueChanged];

    
    // Init annotation callout button
    calloutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [calloutButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    
    // Load all stored places and add a pin for each
    for (Place *p in [Place fetchAll]) {
        NSLog(@"Adding annotation for place %@", p.name);
        [self.mapView addAnnotation:[[PlaceAnnotation alloc] initWithPlace:p]];
    }
}

#pragma mark - IBactions

- (IBAction)removeButtonPressed:(id)sender {
    [self.removePlaceButton setHidden:YES];
    [self.chosenPlaceLabel setTextColor:[UIColor lightGrayColor]];
    [self.chosenPlaceLabel setText:chosePlacePlaceholderText];
    selectedPlace = nil;
}

- (IBAction)saveButtonPressed:(id)sender {
    [self.session setRankFromInt:(int)self.ratingView.value - 1];
    
    // TODO Share on socials
    
    [self.session save];
}

#pragma mark - MKMapView delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    NSLog(@"View for annotation %@", NSStringFromClass([annotation class]));
    if ([annotation isKindOfClass:[PlaceAnnotation class]]) {
        MKPinAnnotationView *view = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:PlaceAnnotationId];
        if (view == nil) {
            view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PlaceAnnotationId];
            [view setEnabled:YES];
            [view setCanShowCallout:YES];
            [view setPinColor:MKPinAnnotationColorRed];
            [view setRightCalloutAccessoryView:calloutButton];
        } else {
            [view setAnnotation:annotation];
        }
        
        return view;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if ([view.annotation isKindOfClass:[PlaceAnnotation class]]) {
        selectedPlace = ((PlaceAnnotation *)view.annotation).place;
        [self.chosenPlaceLabel setText:selectedPlace.name];
        [self.removePlaceButton setHidden:NO];
        [self.chosenPlaceLabel setTextColor:[UIColor darkGrayColor]];
    }
}

#pragma mark - Callback

- (void)ratingChanged:(id)sender {
    [self.saveButton setEnabled:self.ratingView.value > 0];
}

@end
