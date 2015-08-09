//
//  PersistentStack.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 05/08/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Storable.h"

@interface PersistentStack : NSObject

@property (strong,nonatomic,readonly) NSManagedObjectContext *managedObjectContext;

+ (instancetype)sharedInstance;
- (BOOL)saveContext;
- (BOOL)insertStorable:(id <Storable>)entity andSave:(BOOL)save;

@end
