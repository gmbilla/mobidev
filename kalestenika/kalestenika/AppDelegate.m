//
//  AppDelegate.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 29/07/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <GooglePlus/GooglePlus.h>
#import "AppDelegate.h"
#import "PersistentStack.h"
#import "User.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

static NSString *const FacebookURLScheme = @"fb1597125983894421";
static NSString *const GooglePlusClientId = @"750859415890-k7jmp6ipckklqb0t7qd9e8tad0fn9mcq.apps.googleusercontent.com";

+ (void)initialize {
    [FBSDKLoginButton class];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Tint status bar
    // [[UINavigationBar appearance] setBarTintColor:ColorTeal];
    // [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    
    // Insert test user
    User *user = [[User alloc] initWithUserId:@"1234" firstName:@"Pippo" lastName:@"Calippo" socialNetworkSite:1 imageURL:@"http://google.com" ];
    [[PersistentStack sharedInstance] insertStorable:user andSave:YES];
    
    
    // Config Google+ sign in
    GPPSignIn *googlePlusSignIn = [GPPSignIn sharedInstance];
    googlePlusSignIn.clientID = GooglePlusClientId;
    googlePlusSignIn.scopes = @[@"profile"];
    
//    return YES;
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Allows connection of app delegate to Facebook SDK
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma URL handling

/**
 * Listen for Facebook and Google+ login response
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"openURL received with url %@, sourceApp %@ and annotation %@", url, sourceApplication, annotation);
    
    if ([[url scheme] isEqualToString:FacebookURLScheme]) {
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
    } else {
        return [GPPURLHandler handleURL:url
                      sourceApplication:sourceApplication
                             annotation:annotation];
    }
}

@end
