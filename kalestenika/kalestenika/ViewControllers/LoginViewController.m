//
//  ViewController.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 29/07/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import "LoginViewController.h"
#import "TestUser.h"
#import "PersistentStack.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[PersistentStack sharedInstance] managedObjectContext];
    
    TestUser *user = [TestUser sharedInstance];
    NSLog(@"Got user: %@", user);
    if ([user isLoggedIn]) {
        NSLog(@"User already logged in");
    } else {
        // Show login buttons
        self.facebookLoginButton.readPermissions = @[@"public_profile"];
        self.facebookLoginButton.delegate = self;
        GPPSignIn *googlePlusSignIn = [GPPSignIn sharedInstance];
        googlePlusSignIn.shouldFetchGooglePlusUser = YES;
        googlePlusSignIn.delegate = self;
    }
    
    /*
    // Add Facebook button
    FBSDKLoginButton *facebookLoginButton = [[FBSDKLoginButton alloc] init];
    [facebookLoginButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    facebookLoginButton.readPermissions = @[@"public_profile"];
    facebookLoginButton.delegate = self;
    [self.view addSubview:facebookLoginButton];
    
    // Add Google+ login button
    GPPSignIn *googlePlusSignIn = [GPPSignIn sharedInstance];
    googlePlusSignIn.shouldFetchGooglePlusUser = YES;
    googlePlusSignIn.delegate = self;
    GPPSignInButton *googlePlusSignInButton = [[GPPSignInButton alloc] init];
    [googlePlusSignInButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:googlePlusSignInButton];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(facebookLoginButton, googlePlusSignInButton);
    
    // Add constraints to Facebook login button
    NSMutableArray *facebookLoginButtonConstraints = [NSMutableArray arrayWithArray:
    [NSLayoutConstraint constraintsWithVisualFormat:@"|-[facebookLoginButton]-|"
                                            options:NSLayoutFormatAlignAllBottom
                                            metrics:nil
                                              views:viewsDictionary]];
    [facebookLoginButtonConstraints addObject:[NSLayoutConstraint constraintWithItem:facebookLoginButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-20.0]];
    [self.view addConstraints:facebookLoginButtonConstraints];
    
    // Add constraints to Google+ login button
    NSArray *googleLoginButtonConstraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"|-[googlePlusSignInButton]-|"
                                            options:NSLayoutFormatAlignAllBottom
                                            metrics:nil
                                              views:viewsDictionary];
    [self.view addConstraints:googleLoginButtonConstraints];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[googlePlusSignInButton]-[facebookLoginButton]" options:0 metrics:nil views:viewsDictionary]];
    
    */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Facebook

- (void) loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    NSLog(@"Facebook login callback");
    
    if (error) {
        NSLog(@"Facebook login failed with error: %@", error);
        // Show the user an alert
        [[[UIAlertView alloc] initWithTitle:@"Facebook login error"
                                    message:@"There was an error in the Facebook login procedure! Please try again."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil]
         show];
    } else if (result.isCancelled) {
        // Request cancelled
    } else {
        NSLog(@"User logged in with Facebook, granted permission: %@", result.grantedPermissions);
        
        // Check for requested permissions
        if ([result.grantedPermissions containsObject:@"public_profile"]) {
            [self fetchFacebookUserDetails];
        }
        
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    NSLog(@"User logged out");
}

- (void)fetchFacebookUserDetails {
    NSLog(@"AccessToken: %@", [FBSDKAccessToken currentAccessToken]);
    
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"Requesting user info");
        
        NSLog(@"Current profile: %@", [FBSDKProfile currentProfile]);
        
        NSDictionary *params = @{@"fields": @"id,first_name,last_name,picture.width(200).height(200)"};
//        vc.request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/taggable_friends?limit=100"
//                                                       parameters:@{ @"fields" : @"id,name,picture.width(100).height(100)"
//                                                                     }];
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:params]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"fetched user:%@", result);
                 
                 TestUser *user = [TestUser sharedInstance];
                 [user setUserId:result[@"id"]];
                 [user setSns:Facebook];
                 [user setFirstName:result[@"first_name"]];
                 [user setLastName:result[@"last_name"]];
                 [user setImageURL:result[@"picture"][@"data"][@"url"]];
                 
                 NSLog(@"Saving user to disk: %@", user);
                 
                 [user save];
                 
                 TestUser *loadedUser = [[TestUser alloc] initFromLocal];
                 NSLog(@"User loaded from disk: %@", loadedUser);
             }
         }];
    }
}

#pragma mark Google+ sign in delegate

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *) error {
    NSLog(@"Received error %@ and auth object %@", error, auth);
    
    if (error) {
        NSLog(@"Google+ sign in failed with error: %@", error);
        // Show the user an alert
        [[[UIAlertView alloc] initWithTitle:@"Google+ sign in error"
                                    message:@"There was an error in the Google+ sign in procedure! Please try again."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil]
         show];
    }
}

#pragma mark private methods

- (BOOL) checkIfUserIsLoggedIn {
    // TODO try to fetch locally stored user
    
    // Check Facebook token
    if ([FBSDKAccessToken currentAccessToken])
        return YES;
    
    // Check Google+ token
    // Try to login the user if she's already authorized the app
    [[GPPSignIn sharedInstance] trySilentAuthentication];
    
    return NO;
}

@end
