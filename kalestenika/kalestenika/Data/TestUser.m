//
//  User.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 04/08/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "TestUser.h"

#define kUserKey        @"user"
#define kUserIdKey      @"id"
#define kFirstNameKey   @"fname"
#define kLastNameKey    @"lname"
#define kSnsKey         @"sns"
#define kImageURLKey    @"image"

static NSString *const PathToLocalDataFile = @"user.plist";
NSString *const Sns_toString[] = {
    [None] = @"None",
    [Facebook] = @"Facebook",
    [GooglePlus] = @"Google+"
};

@implementation TestUser {
    Sns _sns;
}

+ (TestUser *)sharedInstance {
    static TestUser *_instance = nil;
    static dispatch_once_t oncePredictate;
    
    dispatch_once(&oncePredictate, ^{
        _instance = [[TestUser alloc] initFromLocal]; // [[User alloc] init];
    });
    
    return _instance;
}

#pragma mark Constructors

- (id)init {
    self = [super init];
    
    _sns = None;
    
    return self;
}

- (id)initWithId:(NSString *)userId {
    self = [super init];
    
    if (self) {
        _userId = userId;
    }
    
    return self;
}

- (id)initWithId:(NSString *)userId firstName:(NSString *)firstName lastName:(NSString *)lastName fromSns:(Sns)sns userImage:(NSURL *)image {
    self = [super init];
    
    if (self) {
        _userId = userId;
        _firstName = firstName;
        _lastName = lastName;
        _sns = sns;
        _imageURL = image;
    }
    
    return self;
}

- (id)initFromLocal {
//    NSData *userData = [[NSUserDefaults standardUserDefaults] objectForKey:kUserKey];
//    User *_instance = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
////    NSLog(@"Loaded user: %@", _instance);
//    
//    if (!_instance) {
//        NSLog(@"Error decoding archive file for user");
//        _instance = [[User alloc] init];
//    }
//    
//    return _instance;
    
    NSData *codedData = [[NSData alloc] initWithContentsOfFile:PathToLocalDataFile];
    if (codedData == nil)
        return [[TestUser alloc] init];
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
    TestUser *_instance = [unarchiver decodeObjectForKey:kUserKey];
    [unarchiver finishDecoding];
    NSLog(@"Unarchived user: %@", _instance);
    
    return _instance;
    
    //    if (self) {
    //        // Try to load data from local file
    //        NSData *codedData = [[NSData alloc] initWithContentsOfFile:PathToLocalDataFile];
    //        if (codedData == nil) {
    //            NSLog(@"Failed to fetch user from local file");
    //            return self;
    //        }
    //
    //        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
    //        User *u = [unarchiver decodeObjectForKey:kUserKey];
    //        u.userId;
    //        _data = [[unarchiver decodeObjectForKey:kDataKey] retain];
    //        [unarchiver finishDecoding];
    //    }
    //
    //    return self;
}

#pragma mark NSCoding

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_userId forKey:kUserIdKey];
    [encoder encodeObject:_firstName forKey:kFirstNameKey];
    [encoder encodeObject:_lastName forKey:kLastNameKey];
    [encoder encodeInt:_sns forKey:kSnsKey];
    [encoder encodeObject:_imageURL forKey:kImageURLKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if (self) {
        _userId = [decoder decodeObjectForKey:kUserIdKey];
        _firstName = [decoder decodeObjectForKey:kFirstNameKey];
        _lastName = [decoder decodeObjectForKey:kLastNameKey];
        _sns = [decoder decodeIntForKey:kSnsKey];
        _imageURL = [decoder decodeObjectForKey:kImageURLKey];
    }
    
    return self;
}

#pragma mark Public methods

/**
 * Save current User instance to disk
 */
- (void)save {
    NSLog(@"Saving user %@", self);
    
//    NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:self];
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:userData forKey:kUserKey];
//    [userDefaults synchronize];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self forKey:kUserKey];
    [archiver finishEncoding];
    [data writeToFile:PathToLocalDataFile atomically:YES];
}

/**
 * Delete the local file in which the user is stored
 */
- (void)remove {
    
}

- (BOOL)isLoggedIn {
    return _userId != nil && [_userId length] > 0;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ - %@ ID: %@", _firstName, _lastName, Sns_toString[_sns], _userId];
}

- (void)setSns:(Sns)sns {
    _sns = sns;
}

- (Sns)getSns {
    return _sns;
}

#pragma mark Private methods

//- (void)getLocalPath {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Private Documents"];
//    
//    NSError *error;
//    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
//    
//    return documentsDirectory;
//}

@end
