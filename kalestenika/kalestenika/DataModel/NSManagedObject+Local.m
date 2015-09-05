//
//  NSManagedObject+Local.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 03/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "NSManagedObject+Local.h"
#import "PersistentStack.h"


@implementation NSManagedObject (Local)

+ (instancetype)new {
    return [[PersistentStack sharedInstance] insertNewEntityWithName:[self entityName]];
}

+ (NSEntityDescription *)newEntity {
    return [[PersistentStack sharedInstance] entityDescriptionForEntityNamed:[self entityName]];
}

+ (NSString *)entityName {
    return NSStringFromClass([self class]);
}

/**
 * Fetch all stored entity of the current class type.
 * @return a list of all the stored object of the given entity type.
 */
+ (NSArray *)fetchAll {
    NSLog(@"Fetching all %@", [self entityName]);
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    NSError *error;
    NSArray *entities = [[PersistentStack sharedInstance] executeFetchRequest:request error:&error];
    
    if (error)
        NSLog(@"Error fetching Workouts: %@", error);
    
    return entities;
}

+ (NSArray *)fetchAllSortingBy:(NSString *)key ascending:(BOOL)ascending {
    NSLog(@"Fetching all %@", [self entityName]);
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    [request setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:key ascending:ascending]]];
    NSError *error;
    NSArray *entities = [[PersistentStack sharedInstance] executeFetchRequest:request error:&error];
    
    if (error)
        NSLog(@"Error fetching Workouts: %@", error);
    
    return entities;
}

+ (id)fetchEntityForId:(NSManagedObjectID *)objectId {
    NSError *error;
    id entity = [[PersistentStack sharedInstance] fetchObjectFromId:objectId error:&error];
    
    if (error)
        NSLog(@"Error fetching %@ for ID %@: %@", [self entityName], objectId, error);
    
    return entity;
}

+ (instancetype)fetchEntityWithFormat:(NSString *)format {
    NSLog(@"Fetching %@ with format: %@", [self entityName], format);
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    [request setPredicate:[NSPredicate predicateWithFormat:format]];
    NSError *error;
    NSArray *entities = [[PersistentStack sharedInstance] executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"Error fetching %@ with format '%@': %@", [self entityName], format, error);
        return nil;
    }
    
    return [entities lastObject];
}

//- (void)discardChanges {
//    [self.managedObjectContext refreshObject:self mergeChanges:NO];
//}
- (void)undoChanges {
    [self.managedObjectContext undo];
}

- (void)save {
    [[PersistentStack sharedInstance] saveContext];
}

- (void)delete {
    [[PersistentStack sharedInstance].managedObjectContext deleteObject:self];
}

@end
