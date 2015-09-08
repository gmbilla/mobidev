//
//  Place.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 07/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "Place.h"
#import "User.h"


@implementation Place

@dynamic name;
@dynamic latitude;
@dynamic address;
@dynamic longitude;
@dynamic creator;

- (void)populateFromDictionary:(NSDictionary *)dictionary {
    self.name = [dictionary valueForKey:kPlaceName];
    self.address = [dictionary valueForKey:kPlaceAddress];
    self.creator = [User fetchUserWithUserId:[dictionary valueForKey:kPlaceCreateor]];
    NSDictionary *position = [dictionary valueForKey:kPlacePosition];
    self.latitude = [position valueForKey:kPlaceLatitude];
    self.longitude = [position valueForKey:kPlaceLongitude];
}

@end
