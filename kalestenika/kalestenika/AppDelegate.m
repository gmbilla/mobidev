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
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "AppDelegate.h"
#import "PersistentStack.h"
#import "User.h"
#import "Exercise.h"
#import "Place.h"
#import "NSManagedObject+Local.h"
#import "NSManagedObject+Remote.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

static NSString *const FacebookURLScheme = @"fb1597125983894421";
static NSString *const GooglePlusClientId = @"750859415890-k7jmp6ipckklqb0t7qd9e8tad0fn9mcq.apps.googleusercontent.com";

+ (void)initialize {
    [FBSDKLoginButton class];
    
    // Fetch new exercises
    // TODO check for modification in exercise
    [Exercise fetchAsync:^(NSArray *items) {
        for (NSDictionary *item in items) {
            if ([Exercise fetchEntityWithFormat:[NSString stringWithFormat:@"name = '%@'", [item valueForKey:kExerciseName]]] == nil) {
                // Create new entity to be inserted in local db
                Exercise *exercise = [Exercise new];
                [exercise populateFromDictionary:item];
                NSLog(@"Got new exercise '%@'!", exercise.name);
            }
        }
        
        [[PersistentStack sharedInstance] saveContext];
    }];
    
    // Fetch new places
    [Place fetchAsync:^(NSArray *items) {
        for (NSDictionary *item in items) {
            if ([Place fetchEntityWithFormat:[NSString stringWithFormat:@"name = '%@'", [item valueForKey:kPlaceName]]] == nil) {
                Place *place = [Place new];
                [place populateFromDictionary:item];
                NSLog(@"Got new place '%@'!", place.name);
            }
        }
        
        [[PersistentStack sharedInstance] saveContext];
    }];
    
    // Check once in app lifetime to have Rest record in db
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults valueForKey:@"init"]) {
        Exercise *rest = [Exercise new];
        rest.name = IdRest;
        [rest save];
        NSLog(@"Inserting REST record: %@", rest);
        
        // Add token for init key
        [userDefaults setBool:YES forKey:@"init"];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // TODO support notifications
    //if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
    //    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    //}
    
    // Set status bar style
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Config Google+ sign in
    GPPSignIn *googlePlusSignIn = [GPPSignIn sharedInstance];
    googlePlusSignIn.clientID = GooglePlusClientId;
    googlePlusSignIn.scopes = @[kGTLAuthScopePlusLogin];
    
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
    // Forward to correct callback handler the URL
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
