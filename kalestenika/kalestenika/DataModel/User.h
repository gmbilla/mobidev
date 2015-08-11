//
//  User.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 08/08/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSNumber *sns;
@property (nonatomic, retain) NSString *userId;

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
+ (instancetype)insertUserWithUserId:(NSString *)userId firstName:(NSString *)fname lastName:(NSString *)lname signUpSns:(int)sns imageURL:(NSString *)image thenSaveIt:(BOOL)save;
/**
 * Call Facebook GraphAPI to get user info and create a new user. If given, call the block after creating the user callback
 */
+ (void)createUserFromFacebookProfile:(void (^)(User *))created;

/**
 * Save the current user objectID
 */
- (void)storeObjectID;

@end
