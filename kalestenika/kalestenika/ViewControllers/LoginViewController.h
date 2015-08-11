//
//  ViewController.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 29/07/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <GooglePlus/GooglePlus.h>

@class GPPSignInButton;

@interface LoginViewController : UIViewController <FBSDKLoginButtonDelegate, GPPSignInDelegate>

@property (weak, nonatomic) IBOutlet GPPSignInButton *googlePlusSignInButton;
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *facebookLoginButton;

- (IBAction)continueAsGuestButtonPressed:(UIButton *)sender;

@end

