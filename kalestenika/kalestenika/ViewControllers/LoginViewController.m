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
#import "PersistentStack.h"
#import "User.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Config login buttons
    self.facebookLoginButton.readPermissions = @[@"public_profile"];
    self.facebookLoginButton.delegate = self;
    GPPSignIn *googlePlusSignIn = [GPPSignIn sharedInstance];
    googlePlusSignIn.shouldFetchGooglePlusUser = YES;
    googlePlusSignIn.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark IB actions

- (IBAction)continueAsGuestButtonPressed:(UIButton *)sender {
    // Get guest user and dismiss modal VC
    User *user = [User getOrCreateGuestUser:YES];
    NSLog(@"Guest user: %@", user);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Facebook

- (void) loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    NSLog(@"Facebook login callback");
    
    if (error) {
        NSLog(@"Facebook login failed with error: %@", error);
        // Show the user an alert
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitleFacebookLoginError", nil)
                                    message:NSLocalizedString(@"AlertMessageFacebookLoginError", nil)
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
            // Store the user object and show home
            [User createUserFromFacebookProfile:nil];
//            [self performSegueWithIdentifier:@"HomeSegue" sender:self];
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitleFacebookLoginError", nil)
                                        message:NSLocalizedString(@"AlertMessageFacebookLoginMissingPermission", nil)
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil]
             show];
        }
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    NSLog(@"User logged out");
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

#pragma mark - private methods

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
