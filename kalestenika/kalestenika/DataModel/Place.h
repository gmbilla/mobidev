//
//  Place.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 07/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ApiDelegate.h"


static NSString *const kPlaceName = @"name";
static NSString *const kPlaceAddress = @"address";
static NSString *const kPlacePosition = @"position";
static NSString *const kPlaceCreateor = @"creator";
@class User;

@interface Place : NSManagedObject <ApiDelegate>

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) User *creator;

@end
