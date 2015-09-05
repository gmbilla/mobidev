//
//  Record.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 04/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Exercise.h"


@class Workout;

@interface Record : NSManagedObject

@property (nonatomic, retain) NSNumber *hitsPerRep;
@property (nonatomic, retain) NSNumber *duration;
@property (nonatomic, retain) Exercise *exercise;
@property (nonatomic, retain) Workout *workout;

/**
 * Parse JSON and fetch exercise from given name.
 * Should be used only to parse API response (i.e. experts only some properties).
 * @return the created record if the exercise was found in local db, nil otherwise
 */
//+ (instancetype)createRecordFromJSONString:(NSString *)string;
/**
 * Helper to create a record with rest exercise
 */
+ (instancetype)createRestRecordWithDuration:(int)duration inWorkout:(Workout *)workout;
/**
 * All arguments constructor
 */
- (instancetype)initWithExercise:(Exercise *)exercise hitsPerRep:(int)hits duration:(int)duration inWorkout:(Workout *)workout;

/**
 * Encode properties to JSON. Should be used only for API request (i.e. will only output required properties).
 */
- (NSString *)toJSONString;

@end
