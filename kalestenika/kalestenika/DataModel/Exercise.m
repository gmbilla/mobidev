//
//  Exercise.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 03/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "Exercise.h"
#import "PersistentStack.h"


@implementation Exercise

@dynamic exerciseDescription;
@dynamic name;
@dynamic requirement;
@dynamic estimatedDuration;

- (void)populateFromDictionary:(NSDictionary *)dictionary {
    self.name = [dictionary valueForKey:kExerciseName];
    self.exerciseDescription = [dictionary valueForKey:kExerciseDescription];
    self.requirement = [dictionary valueForKey:kExerciseRequirement];
    self.estimatedDuration = [dictionary valueForKey:kExerciseEstimatedDuration];
    
//    NSLog(@"New values:\n\tname: %@\n\tdescription: %@\n\trequirement: %@\n\testDur: %@", self.name, self.exerciseDescription, self.requirement, self.estimatedDuration);
}

+ (NSArray *)fetchAll {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Exercise"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name != %@", IdRest]];
    [request setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]]];
    NSError *error;
    NSArray *entities = [[PersistentStack sharedInstance] executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"Error fetching exercise list: %@", error);
        return nil;
    }
    
    return entities;
}

@end
