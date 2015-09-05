//
//  PersistentStack.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 05/08/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <UIKit/UIAlertView.h>
#import "PersistentStack.h"


static NSString *const ModelResource = @"Kalestenika";
static NSString *const ModelExtension = @"momd";
static NSString *const SQLiteDbFile = @"Kalestenika.sqlite";


@interface PersistentStack()

@property (strong,nonatomic,readwrite) NSManagedObjectContext *managedObjectContext;
@property (strong,nonatomic,readwrite) NSPersistentStoreCoordinator *coordinator;

@end

@implementation PersistentStack

# pragma mark - Public methods

+ (instancetype)sharedInstance {
    static PersistentStack *_instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        // Alloc a new PersistentStack and initialize CoreData context;
        _instance = [[PersistentStack alloc] init];
        NSLog(@"Setting up managed object context");
        [_instance setupManagedObjectContext];
    });
    
    return _instance;
}

- (NSEntityDescription *)entityDescriptionForEntityNamed:(NSString *)name {
    return [NSEntityDescription entityForName:name inManagedObjectContext:_managedObjectContext];
}

- (NSArray *)executeFetchRequest:(NSFetchRequest *)request error:(NSError *__autoreleasing *)error {
    return [_managedObjectContext executeFetchRequest:request error:error];
}

- (id)fetchObjectFromURI:(NSURL *)uri error:(NSError *__autoreleasing *)error {
    NSManagedObjectID *moid = [_coordinator managedObjectIDForURIRepresentation:uri];
    return [_managedObjectContext existingObjectWithID:moid error:error];
}

- (id)fetchObjectFromId:(NSManagedObjectID *)objectId error:(NSError *__autoreleasing *)error {
    return [_managedObjectContext existingObjectWithID:objectId error:error];
}

- (id)insertNewEntityWithName:(NSString *)name {
    return [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:_managedObjectContext];
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

- (void)undoContext {
    [_managedObjectContext undo];
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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:ModelResource withExtension:ModelExtension];
    NSManagedObjectModel *objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    // URL of the Core Data store file -- stored in a directory named "com.kalestenika.ios" in the application's documents directory
    NSURL *sqliteFileURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:SQLiteDbFile];
    
    
    _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:objectModel];
    NSError *error;
    if (![_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:sqliteFileURL options:nil error:&error]) {
        NSLog(@"Error configuring SQLite persistent store: %@", error);
        
        [[[UIAlertView alloc] initWithTitle:@"Whoops, this is an error!" message:@"Failed to create kalestenika database file. Please close the app, remove it and reinstall it." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    return _coordinator;
}

@end
