//
//  User.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 08/08/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "User.h"


@implementation User

@dynamic firstName;
@dynamic imageURL;
@dynamic lastName;
@dynamic sns;
@dynamic userId;

- (instancetype)initWithUserId:(NSString *)userId firstName:(NSString *)fname lastName:(NSString *)lname socialNetworkSite:(int)sns imageURL:(NSString *)image {
    self = [super init];
    self.userId = userId;
    self.firstName = fname;
    self.lastName = lname;
    self.sns = [NSNumber numberWithInt:sns];
    self.imageURL = image;
    
    return self;
}

- (NSString *)entityName {
    return @"User";
}

- (NSArray *)entityAttributes {
    return @[@"userId", @"firstName", @"lastName", @"sns", @"imageURL"];
}

@end
