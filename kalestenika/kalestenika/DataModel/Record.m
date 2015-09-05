//
//  Record.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 04/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "Record.h"
#import "NSManagedObject+Local.h"


static NSString *const KeyExercise = @"exercise";
static NSString *const KeyHits = @"hitsPerRep";
static NSString *const KeyDuration = @"duration";

@implementation Record

@dynamic hitsPerRep;
@dynamic duration;
@dynamic exercise;
@dynamic workout;

/*#pragma mark - Constructors

+ (instancetype)createRecordFromJSONString:(NSString *)string {
    NSError *error;
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    
    if (error) {
        NSLog(@"Error parsing record string: %@", error);
        return nil;
    }
    
    Exercise *exercise = [Exercise fetchEntityWithFormat:[NSString stringWithFormat:@"name = '%@'", [data valueForKey:KeyExercise]]];
    if (exercise == nil)
        return nil;
    return [[Record alloc] initWithExercise:exercise hitsPerRep:[[data valueForKey:KeyHits] intValue] duration:[[data valueForKey:KeyDuration] intValue]];
}*/

+ (instancetype)createRestRecordWithDuration:(int)duration inWorkout:(Workout *)workout{
    // Fetch rest exercise entity
    Exercise *rest = [Exercise fetchEntityWithFormat:[NSString stringWithFormat:@"name = '%@'", IdRest]];
    if (rest == nil)
        return nil;
    return [[Record alloc] initWithExercise:rest hitsPerRep:0 duration:duration inWorkout:workout];
}

- (instancetype)initWithExercise:(Exercise *)exercise hitsPerRep:(int)hits duration:(int)duration inWorkout:(Workout *)workout {
    self = [Record new];
    self.exercise = exercise;
    self.hitsPerRep = [NSNumber numberWithInt:hits];
    self.duration = [NSNumber numberWithInt:duration];
    self.workout = workout;
    
    return self;
}

#pragma mark - Public methods

- (NSString *)toJSONString {
    NSDictionary *variables = @{KeyExercise: self.exercise,
                                KeyExercise: self.hitsPerRep,
                                KeyExercise: self.duration};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:variables options:NSJSONWritingPrettyPrinted error:&error];
    if (error)
        NSLog(@"Error encoding record: %@", error);
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
