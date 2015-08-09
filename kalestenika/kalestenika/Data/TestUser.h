//
//  User.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 04/08/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, Sns) {
    None        = 0,
    Facebook    = 1,
    GooglePlus  = 2
};
extern NSString *const Sns_toString[];

@interface TestUser : NSObject <NSCoding>

@property (weak, nonatomic) NSString *userId;
@property (weak, nonatomic) NSString *firstName;
@property (weak, nonatomic) NSString *lastName;
@property (weak, nonatomic) NSURL *imageURL;

+ (TestUser *)sharedInstance;
- (id)initFromLocal;
- (void)save;
- (void)remove;
- (BOOL)isLoggedIn;
- (void)setSns:(Sns)sns;
- (Sns)getSns;

@end
