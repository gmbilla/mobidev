//
//  NSManagedObject+Local.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 03/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <CoreData/CoreData.h>


/**
 * Category holding some helper methods to create and save entities
 */
@interface NSManagedObject (Local)

/** Wrapper method to create a new entity (to be stored in CoreData). */
+ (instancetype)new;
/** Creates an entity for the current class */
+ (NSEntityDescription *)newEntity;
+ (NSString *)entityName;
+ (NSArray *)fetchAll;
+ (NSArray *)fetchAllSortingBy:(NSString *)key ascending:(BOOL)ascending;
+ (id)fetchEntityForId:(NSManagedObjectID *)objectId;
+ (instancetype)fetchEntityWithFormat:(NSString *)format;
//+ (instancetype)fetchEntityWithPredicate:(NSPredicate *)predicate;

// /** Discard all changes to object and destroy it */
// - (void)discardChanges;
- (void)delete;
/** Undo all unsaved changes on the object */
- (void)undoChanges;
- (void)save;

@end
