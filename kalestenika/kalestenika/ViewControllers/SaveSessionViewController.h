//
//  SaveSessionViewController.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 07/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@class HCSStarRatingView, Session;

static NSString *const SaveSessionSegueId = @"SaveSessionSegue";

@interface SaveSessionViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, weak) Session *session;

@property (weak, nonatomic) IBOutlet UILabel *workoutNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *completionLabel;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;
@property (weak, nonatomic) IBOutlet UISwitch *facebookShareSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *googlePlusShareSwitch;
@property (weak, nonatomic) IBOutlet UILabel *chosenPlaceLabel;
@property (weak, nonatomic) IBOutlet UIButton *removePlaceButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

- (IBAction)removeButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;

@end
