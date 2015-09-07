//
//  Workout.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 04/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "Workout.h"
#import "Record.h"
#import "Session.h"
#import "User.h"


@implementation Workout

@dynamic dateCreated;
@dynamic estimatedDuration;
@dynamic name;
@dynamic nrOfExercise;
@dynamic requirements;
@dynamic schedule;
@dynamic creator;
@dynamic exerciseList;
@dynamic sessionList;

@end

@implementation MutableList

+ (Class)transformedValueClass {
    return [NSMutableArray class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    // Converts the NSMutableArray into NSData
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value {
    // Converts NSData to an NSMutableArray
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end
