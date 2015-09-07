//
//  PlaceAnnotation.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 07/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@class Place;

static NSString *const PlaceAnnotationId = @"PlaceAnnotationId";

@interface PlaceAnnotation : NSObject <MKAnnotation>

@property (nonatomic, weak, readonly) Place *place;

- (instancetype)initWithPlace:(Place *)place;

@end
