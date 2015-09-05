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
static NSString *const GuestUserId = @"guest";


@implementation User

static User *_current = nil;

@dynamic firstName;
@dynamic imageURL;
@dynamic lastName;
@dynamic sns;
@dynamic userId;
@dynamic workoutList;

#pragma mark - Constructors

+ (instancetype)fetchCurrentUser {
    // Try to avoid useless fetches
    if (_current != nil) {
        NSLog(@"Already got current user: %@", _current);
        return _current;
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *uri = [defaults URLForKey:ObjectIdKey];
    NSError *error;
    if (uri != nil)
        _current = [[PersistentStack sharedInstance] fetchObjectFromURI:uri error:&error];
    else {
        error = [[NSError alloc] initWithDomain:@"kalestenika" code:500 userInfo:@{NSLocalizedDescriptionKey: @"No user objectID found in NSUserDefaults"}];
    }
    
    if (error) {
        NSLog(@"Error fetching user (%@) from local memory: %@", uri, [error localizedDescription]);
        
        // Try to fetch last inserted user
        NSManagedObjectContext *context = [PersistentStack sharedInstance].managedObjectContext;
        NSArray *users = [context executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:EntityName] error:nil];
        
        if ([users count] > 0) {
            NSLog(@"Returning last found user");
            _current = [users lastObject];
        } else if ([FBSDKAccessToken currentAccessToken] != nil) {
            // Look for a valid Facebook or Google+ token
            _current = [User fetchUserWithUserId:[[FBSDKAccessToken currentAccessToken] userID]];
        }
        
        // TODO check for Google+ token
    }
    
    return _current;
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

+ (instancetype)getOrCreateGuestUser:(BOOL)save {
    // Check if guest user already exists
    User *user = [self fetchUserWithUserId:GuestUserId];
    
    if (user != nil)
        // And store its objectID
        [user storeObjectID];
    else
        // Create it otherwise
        user = [self insertUserWithUserId:GuestUserId firstName:NSLocalizedString(@"GuestFirstName", nil) lastName:@"" signUpSns:none imageURL:nil thenSaveIt:save];
    
    return user;
}

+ (instancetype)insertUserWithUserId:(NSString *)userId firstName:(NSString *)fname lastName:(NSString *)lname signUpSns:(SNS)sns imageURL:(NSString *)image thenSaveIt:(BOOL)save {
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
    // Store inserted user as current user
    _current = user;
    
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
                 User *user = [User insertUserWithUserId:result[@"id"] firstName:result[@"first_name"] lastName:result[@"last_name"] signUpSns:facebook imageURL:result[@"picture"][@"data"][@"url"] thenSaveIt:YES];
                 
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
    // Save user objectID to NSUserDefaults for faster retrieval
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setURL:[[self objectID] URIRepresentation] forKey:ObjectIdKey];
    [defaults synchronize];
    
    // Try to avoid useless fetches by setting current user
    _current = self;
}

@end
