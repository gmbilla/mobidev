//
//  User.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 08/08/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "User.h"
#import "PersistentStack.h"


static NSString *const EntityName = @"User";
static NSString *const ObjectIdKey = @"userObjectId";


@implementation User

@dynamic firstName;
@dynamic imageURL;
@dynamic lastName;
@dynamic sns;
@dynamic userId;

#pragma mark - Constructors

+ (instancetype)fetchCurrentUser {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *uri = [defaults URLForKey:ObjectIdKey];
    // Check if objectID URI is defined
    if (uri == nil)
        return nil;
    NSLog(@"Fetching user from URI %@", uri);
    NSError *error;
    User *user = [[PersistentStack sharedInstance]fetchObjectFromURI:uri error:&error];
    
    if (error) {
        NSLog(@"Error fetching user (%@) from local memory: %@", user, [error localizedDescription]);
        
        // Try to fetch last inserted user
        NSManagedObjectContext *context = [PersistentStack sharedInstance].managedObjectContext;
        NSArray *users = [context executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:EntityName] error:nil];
        
        if ([users count] > 0) {
            NSLog(@"Returning last found user");
            return [users lastObject];
        }
        
        // Look for a valid Facebook or Google+ token
        if ([FBSDKAccessToken currentAccessToken] != nil) {
            user = [User fetchUserWithUserId:[[FBSDKAccessToken currentAccessToken] userID]];
        }
        
        // TODO check for Google+ token
    }
    
    return user;
}

+ (instancetype)fetchUserWithUserId:(NSString *)userId {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:EntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"userId = %@", userId];
    NSError *error;
    NSArray *entities = [[PersistentStack sharedInstance] executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"Error fetching User with ID %@: %@", userId, error);
        return nil;
    }
    
    return [entities lastObject];
}

+ (instancetype)insertUserWithUserId:(NSString *)userId firstName:(NSString *)fname lastName:(NSString *)lname signUpSns:(int)sns imageURL:(NSString *)image thenSaveIt:(BOOL)save {
    // Check if given user ID was already saved, and use it if so
    User *user = [self fetchUserWithUserId:userId];
    
    if (user == nil)
        // Insert a new User entity in application MOC
        user = [[PersistentStack sharedInstance] insertNewEntityWithName:EntityName];
    
    user.userId = userId;
    user.firstName = fname;
    user.lastName = lname;
    user.sns = [NSNumber numberWithInt:sns];
    user.imageURL = image;
    // Store the user objectID for faster retrieval
    [user storeObjectID];
    
    if (save)
        [[PersistentStack sharedInstance] saveContext];
    
    return user;
}

# pragma mark SNS fetching

+ (void)createUserFromFacebookProfile:(void (^)(User *))created {
    NSLog(@"Fetching user data from Facebook with AccessToken: %@", [FBSDKAccessToken currentAccessToken]);
    
    if ([FBSDKAccessToken currentAccessToken]) {
        NSDictionary *params = @{@"fields": @"id,first_name,last_name,picture.width(200).height(200)"};
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:params]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"[DEBUG] Fetched stuff:%@", result);
                 
                 // Save logged in user
                 User *user = [User insertUserWithUserId:result[@"id"] firstName:result[@"first_name"] lastName:result[@"last_name"] signUpSns:1 imageURL:result[@"picture"][@"data"][@"url"] thenSaveIt:YES];
                 
                 NSLog(@"[DEBUG] Saving user to disk: %@", user);
                 
                 if (created)
                     created(user);
             }
         }];
    }
}

# pragma mark - Public methods

- (NSString *)description {
    return [NSString stringWithFormat:@"User %@: %@ %@ (%@)", self.userId, self.firstName, self.lastName, self.imageURL];
}

- (void)storeObjectID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setURL:[[self objectID] URIRepresentation] forKey:ObjectIdKey];
    [defaults synchronize];
}

@end
