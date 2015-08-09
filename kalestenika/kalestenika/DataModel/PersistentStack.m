//
//  PersistentStack.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 05/08/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <UIKit/UIAlertView.h>
#import "PersistentStack.h"


#define MODEL_RESOURCE  "Kalestenika"
#define MODEL_EXTENSION "momd"
#define SQLITE_DB_FILE  "Kalestenika.sqlite"


@interface PersistentStack()

@property (strong,nonatomic,readwrite) NSManagedObjectContext *managedObjectContext;
@property (strong,nonatomic,readwrite) NSPersistentStoreCoordinator *coordinator;

@end

@implementation PersistentStack

# pragma mark - Public methods

+ (instancetype)sharedInstance {
    static PersistentStack *_instance = nil;
    static dispatch_once_t *predicate;
    dispatch_once(predicate, ^{
        // Alloc a new PersistentStack and initialize CoreData context;
        _instance = [[PersistentStack alloc] init];
        NSLog(@"Setting up managed object context");
        [_instance setupManagedObjectContext];
    });
    
    return _instance;
}

- (BOOL)insertStorable:(id <Storable>)entity andSave:(BOOL)save {
    if (![entity conformsToProtocol:@protocol(Storable)]) {
        NSLog(@"Class %@ doesn't conform to Storable protocol", NSStringFromClass([entity class]));
        return NO;
    }
    
    NSLog(@"Inserting entity %@", [entity entityName]);
    NSEntityDescription *description = [self populateDescriptionFromObject:entity];
    
    if (save)
        return description != nil && [self saveContext];
    else
        return description != nil;
}

- (BOOL)saveContext {
    if (_managedObjectContext != nil && [_managedObjectContext hasChanges]) {
        NSError *error;
        if (![_managedObjectContext save:&error]) {
            NSLog(@"Error saving CoreData context: %@", error);
            return NO;
        }
    }
    
    return YES;
}

# pragma mark - Private methods

/**
 * Create a managed object context for the main queue
 */
- (void)setupManagedObjectContext {
    // Initialize the context
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    // Set store coordinator
    [_managedObjectContext setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    
    self.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
}

/**
 * Initialize (if necessary) and return the SQLite persistent store coordinator
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_coordinator != nil)
        return _coordinator;
    
    // Init the app managed object model
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@MODEL_RESOURCE withExtension:@MODEL_EXTENSION];
    NSManagedObjectModel *objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    // URL of the Core Data store file -- stored in a directory named "com.kalestenika.ios" in the application's documents directory
    NSURL *sqliteFileURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@SQLITE_DB_FILE];
    
    
    _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:objectModel];
    NSError *error;
    if (![_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:sqliteFileURL options:nil error:&error]) {
        NSLog(@"Error configuring SQLite persistent store: %@", error);
        
        [[[UIAlertView alloc] initWithTitle:@"Whoops, this is an error!" message:@"Failed to create kalestenika database file. Please close the app, remove it and reinstall it." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    return _coordinator;
}

- (NSEntityDescription *)populateDescriptionFromObject:(id<Storable>)object {
    NSEntityDescription *entity = [NSEntityDescription entityForName:[object entityName] inManagedObjectContext:_managedObjectContext];

    SEL selector;
    for (NSString *attribute in [object entityAttributes]) {
        selector = NSSelectorFromString([NSString stringWithFormat:@"get%@", [attribute capitalizedString]]);
        NSLog(@"Performing %@: %@", [NSString stringWithFormat:@"get%@", [attribute capitalizedString]], [object performSelector:selector]);
        [entity setValue:[object performSelector:selector] forKey:attribute];
    }
    
    return entity;
}

@end
