//
//  Workout.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 04/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class Record, User;

@interface Workout : NSManagedObject

@property (nonatomic, retain) NSDate *dateCreated;
@property (nonatomic, retain) NSNumber *estimatedDuration;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *nrOfExercise;
@property (nonatomic, retain) id requirements;
@property (nonatomic, retain) id schedule;
@property (nonatomic, retain) User *creator;
@property (nonatomic, retain) NSOrderedSet *exerciseList;

@end

@interface Workout (CoreDataGeneratedAccessors)

- (void)insertObject:(Record *)value inExerciseListAtIndex:(NSUInteger)idx;
- (void)removeObjectFromExerciseListAtIndex:(NSUInteger)idx;
- (void)insertExerciseList:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeExerciseListAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInExerciseListAtIndex:(NSUInteger)idx withObject:(Record *)value;
- (void)replaceExerciseListAtIndexes:(NSIndexSet *)indexes withExerciseList:(NSArray *)values;
- (void)addExerciseListObject:(Record *)value;
- (void)removeExerciseListObject:(Record *)value;
- (void)addExerciseList:(NSOrderedSet *)values;
- (void)removeExerciseList:(NSOrderedSet *)values;

@end

/**
 * Transformable interface mapping object to NSMutableArray
 */
@interface MutableList : NSValueTransformer

@end