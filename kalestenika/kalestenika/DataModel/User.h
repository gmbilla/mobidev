//
//  User.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 08/08/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


typedef enum {
    none = 0,
    facebook = 1,
    googlePlus = 2
} SNS;

@class Session, Workout;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSNumber *sns;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSSet *workoutList;
@property (nonatomic, retain) NSSet *sessionList;

/**
 * Fetch user from the stored user objectID
 */
+ (instancetype)fetchCurrentUser;
/**
 * Query the SQLite db for a user with given user ID
 */
+ (instancetype)fetchUserWithUserId:(NSString *)userId;
/**
 * Try to fetch guest user, and insert it if it doesn't exists
 */
+ (instancetype)getOrCreateGuestUser:(BOOL)save;
/**
 * Store locally (in SQLite) a new user
 */
+ (instancetype)insertUserWithUserId:(NSString *)userId firstName:(NSString *)fname lastName:(NSString *)lname signUpSns:(SNS)sns imageURL:(NSString *)image thenSaveIt:(BOOL)save;
/**
 * Call Facebook GraphAPI to get user info and create a new user. If given, call the block after creating the user callback
 */
+ (void)createUserFromFacebookProfile:(void (^)(User *))created;

+ (void)createUserFromGooglePlusProfile:(void (^)(User *))created;

/**
 * Save the current user objectID
 */
- (void)storeObjectID;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addWorkoutListObject:(Workout *)value;
- (void)removeWorkoutListObject:(Workout *)value;
- (void)addWorkoutList:(NSSet *)values;
- (void)removeWorkoutList:(NSSet *)values;

- (void)addSessionListObject:(Session *)value;
- (void)removeSessionListObject:(Session *)value;
- (void)addSessionList:(NSSet *)values;
- (void)removeSessionList:(NSSet *)values;

@end
