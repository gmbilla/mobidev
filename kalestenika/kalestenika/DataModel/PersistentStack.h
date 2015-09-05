//
//  PersistentStack.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 05/08/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PersistentStack : NSObject

@property (strong,nonatomic,readonly) NSManagedObjectContext *managedObjectContext;

+ (instancetype)sharedInstance;
- (NSEntityDescription *)entityDescriptionForEntityNamed:(NSString *)name;
- (NSArray *)executeFetchRequest:(NSFetchRequest *)request error:(NSError *__autoreleasing *)error;
- (id)fetchObjectFromURI:(NSURL *)uri error:(NSError *__autoreleasing *)error;
- (id)fetchObjectFromId:(NSManagedObjectID *)objectId error:(NSError *__autoreleasing *)error;
- (id)insertNewEntityWithName:(NSString *)name;
- (BOOL)saveContext;
- (void)undoContext;

@end
