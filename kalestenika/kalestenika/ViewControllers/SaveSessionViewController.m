//
//  SaveSessionViewController.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 07/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "SaveSessionViewController.h"
#import "HCSStarRatingView.h"
#import "PlaceAnnotation.h"
#import "Constants.h"
#import "Session.h"
#import "Workout.h"
#import "Place.h"
#import "NSManagedObject+Local.h"


@interface SaveSessionViewController () <GPPSignInDelegate, GPPShareDelegate>

@end

@implementation SaveSessionViewController {
    CLLocationManager *locationManager;
    UIButton *calloutButton;
    Place *selectedPlace;
    NSString *chosePlacePlaceholderText;
    BOOL shareOnFacebook, shareOnGooglePlus;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup views
    [self.workoutNameLabel setText:self.session.workout.name];
    [self.durationLabel setText:[Constants secondsToHhMmSs:self.session.duration.intValue]];
    [self.completionLabel setText:[NSString stringWithFormat:@"%d%%", self.session.completion.intValue]];
    chosePlacePlaceholderText = self.chosenPlaceLabel.text;
    
    // Init annotation callout button
    calloutButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [calloutButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    
    // Setup map
    [self.mapView setShowsUserLocation:YES];
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
    [locationManager stopUpdatingLocation];
}

#pragma mark - IBactions

- (IBAction)removeButtonPressed:(id)sender {
    [self.removePlaceButton setHidden:YES];
    [self.chosenPlaceLabel setTextColor:[UIColor lightGrayColor]];
    [self.chosenPlaceLabel setText:chosePlacePlaceholderText];
    selectedPlace = nil;
}

- (IBAction)saveButtonPressed:(id)sender {
    [self.session setRank:[NSNumber numberWithInt:(int)self.ratingView.value]];
    [self.session setPlace:selectedPlace];
    [self.session save];
    
    // Share
    shareOnFacebook = [self.facebookShareSwitch isOn];
    shareOnGooglePlus = [self.googlePlusShareSwitch isOn];
    [self shareWorkoutAndExit];
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

#pragma mark - CLLocationManager delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"auth changed to: %d", status);
    
    // If status disabled ask user to enable in settings
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [locationManager startUpdatingLocation];
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            [locationManager startUpdatingLocation];
            break;
            
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // Move map to new location
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(((CLLocation *)[locations lastObject]).coordinate, 250.0, 250.0);
    [self.mapView setRegion:region animated:YES];
    
    // Update location only once
    [locationManager stopUpdatingLocation];
}
    
#pragma mark - Google+ stuff
    
- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    NSLog(@"finishedWithAuth:error - %@", error);
    
    // If user logged in post, otherwise skip it
    if (!error) {
        id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
        // TODO add kalestenika website URL (for title, description, and thumbnail parsing)
        // [shareBuilder setURLToShare:[NSURL URLWithString:@"https://www.example.com/restaurant/sf/1234567/"]];
        [shareBuilder setPrefillText:@"Just completed a workout on #kalestenika"];
        if (![shareBuilder open])
            [self showGooglePlusError:YES];
    } else {
        [self showGooglePlusError:NO];
        if (!shareOnFacebook)
            [self performSegueWithIdentifier:@"UnwindToWorkoutListSegue" sender:self];
    }
}

- (void)finishedSharing:(BOOL)shared {
    NSLog(@"finishedSharing - %d", shared);
    if (!shared)
        [self showGooglePlusError:YES];
    
    if (shareOnFacebook)
        [self shareWorkoutOnFacebook];
    else
        [self performSegueWithIdentifier:@"UnwindToWorkoutListSegue" sender:self];
}

- (void)finishedSharingWithError:(NSError *)error {
    NSLog(@"finishedSharingWithError - %@", error);
    
    if (error) {
        NSLog(@"Error posting on Google+: %@", error.localizedDescription);
        [self showGooglePlusError:YES];
    }
    
    if (shareOnFacebook)
        [self shareWorkoutOnFacebook];
    else
        [self performSegueWithIdentifier:@"UnwindToWorkoutListSegue" sender:self];
}

- (void)showGooglePlusError:(BOOL)whilePosting {
    if (whilePosting)
        [[[UIAlertView alloc] initWithTitle:@"Google+ Sharing Error" message:@"There was a problem sharing on Google+. Activity not posted!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    else
        [[[UIAlertView alloc] initWithTitle:@"Google+ Login Error" message:@"There was a problem logging you in on Google+. Activity not posted!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}
    
#pragma mark - Facebook stuff

- (void)loginAndShareOnFacebook {
    if ([FBSDKAccessToken currentAccessToken]) {
        [self shareWorkoutOnFacebook];
    } else {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithReadPermissions: @[@"public_profile"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                [[[UIAlertView alloc] initWithTitle:@"Facebook Login Error" message:@"There was an error while logging you in with Facebook" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                NSLog(@"Facebook login error: %@ (%@)", error, error.localizedDescription);

                [self performSegueWithIdentifier:@"UnwindToWorkoutListSegue" sender:self];
            } else if (result.isCancelled) {
                NSLog(@"Facebook login cancelled");
                
                [self performSegueWithIdentifier:@"UnwindToWorkoutListSegue" sender:self];
            } else {
                [self shareWorkoutOnFacebook];
            }
        }];
    }
}

- (void)shareWorkoutOnFacebook {
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        
        NSLog(@"Got publish_actions, publishing!");
        
        // Create an object with the object type kalestenika:workout and set the properties on that object
        NSDictionary *properties = @{
         @"og:type": @"kalestenika:workout",
         @"og:title": @"Workout completed!",
         @"og:image": @"https://scontent-mxp1-1.xx.fbcdn.net/hphotos-xlt1/v/t1.0-9/12002087_10153148862547496_3586614011549804860_n.jpg?oh=fe3e8c68772d4a4a0acbdb9d2994c1e2&oe=5665F579",
         @"kalestenika:workout_name": self.session.workout.name,
         @"kalestenika:duration": [Constants secondsToHhMmSs:self.session.duration.intValue],
         @"kalestenika:percentage": [NSString stringWithFormat:@"%@%%", self.session.completion],
        };
        
        /*
         * The SDK appears to be buggy! It posts 4 times for each request???
         *
        FBSDKShareOpenGraphObject *workoutObject = [FBSDKShareOpenGraphObject objectWithProperties:properties];
   
        // create an action and link the object to the action
        FBSDKShareOpenGraphAction *action = [[FBSDKShareOpenGraphAction alloc] init];
        action.actionType = @"kalestenika:work_out";
        [action setObject:workoutObject forKey:@"workout"];
        [action setString:@"true" forKey:@"fb:explicitly_shared"];

        // Create the content model to represent the Open Graph story
        FBSDKShareOpenGraphContent *content = [[FBSDKShareOpenGraphContent alloc] init];
        content.action = action;
        content.previewPropertyName = @"workout";
        
        // Share the action
        [[FBSDKShareAPI shareWithContent:content delegate:self] share];
         */
        
        // Use standard graph API request
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:properties options:NSJSONWritingPrettyPrinted error:nil];
        NSDictionary *parameters = @{@"workout": [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding],
                                     @"fb:explicitly_shared": @"true"};
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/kalestenika:work_out" parameters:parameters HTTPMethod:@"POST"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            // Handle the result
            NSLog(@"Request result: %@", result);
            
            if (error)
                NSLog(@"GraphAPI request error: %@ (%@)", error.description, error.localizedDescription);
            
            // Unwind in any case
            [self performSegueWithIdentifier:@"UnwindToWorkoutListSegue" sender:self];
        }];
        NSLog(@"Sharing on Facebook");
        
    } else {
        // Try to login user
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logInWithPublishPermissions:@[@"publish_actions"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                [[[UIAlertView alloc] initWithTitle:@"Facebook Login Error" message:@"There was an error logging you in on Facebook. Can't share last completed workout!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                return;
            }
            
            [self shareWorkoutOnFacebook];
        }];
    }
}

/*
#pragma mark Facebook Share delegate

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    NSLog(@"Facebook results: %@", results);
    
//    [[[UIAlertView alloc] initWithTitle:@"Facebook Sharing" message:@"Workout completed shared on Facebook!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    [self performSegueWithIdentifier:@"UnwindToWorkoutListSegue" sender:self];
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:@"Facebook Sharing Error" message:@"There was an error while sharing on Facebook the last completed workout!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    NSLog(@"Facebook sharing failed: %@ (%@)", error, error.localizedDescription);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    [[[UIAlertView alloc] initWithTitle:@"Facebook Sharing Cancelled" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}
*/

#pragma mark - Private methods

- (void)shareWorkoutAndExit {
    if (shareOnGooglePlus || (shareOnGooglePlus && shareOnFacebook)) {
        [self showLoading];
        
        // First post on G+ then on Fb
        GPPSignIn *signIn = [GPPSignIn sharedInstance];
        signIn.delegate = self;
        [[GPPShare sharedInstance] setDelegate:self];
        // If user alread sign in once, authenticate her (and call finishedWithAuth:error)
        if (![signIn trySilentAuthentication]) {
            // User not logged in, show login
            [signIn authenticate];
            NSLog(@"Showing G+ login");
        }
    } else if (shareOnFacebook) {
        [self showLoading];
    
        [self loginAndShareOnFacebook];
    } else
        [self performSegueWithIdentifier:@"UnwindToWorkoutListSegue" sender:self];
}

- (void)showLoading {
    [self.view bringSubviewToFront:self.loadingView];
    [self.loadingView setHidden:NO];
}

@end
