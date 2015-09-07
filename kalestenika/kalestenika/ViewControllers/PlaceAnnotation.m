//
//  PlaceAnnotation.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 07/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "PlaceAnnotation.h"
#import "Place.h"


@implementation PlaceAnnotation {
    CLLocationCoordinate2D _position;
    Place *_place;
}

- (instancetype)initWithPlace:(Place *)place {
    self = [super init];
    
    if (self) {
        _position = CLLocationCoordinate2DMake(place.latitude.doubleValue, place.longitude.doubleValue);
        _place = place;
    }
    
    return self;
}

- (CLLocationCoordinate2D)coordinate {
    return _position;
}

- (Place *)place {
    return _place;
}

- (NSString *)title {
    return _place.name;
}

- (NSString *)subtitle {
    return _place.address;
}

@end
