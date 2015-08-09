//
//  User.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 08/08/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Storable.h"


@interface User : NSManagedObject <Storable>

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * sns;
@property (nonatomic, retain) NSString * userId;

- (instancetype)initWithUserId:(NSString *)userId firstName:(NSString *)fname lastName:(NSString *)lname socialNetworkSite:(int)sns imageURL:(NSString *)image;

@end
