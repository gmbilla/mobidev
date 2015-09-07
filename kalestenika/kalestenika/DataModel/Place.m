//
//  Place.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 07/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "Place.h"
#import "User.h"


static NSString *const Separator = @",";

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
    NSArray *components = [[dictionary valueForKey:kPlacePosition] componentsSeparatedByString:Separator];
    if ([components count] == 2) {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        self.latitude = [formatter numberFromString:components[0]];
        self.longitude = [formatter numberFromString:components[1]];
    }
}

@end
