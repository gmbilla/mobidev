//
//  ProgressTableViewController.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 01/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "ProgressViewController.h"
#import "ProgressCell.h"
#import "Session.h"
#import "Workout.h"
#import "NSManagedObject+Local.h"


@interface ProgressViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ProgressViewController {
//    NSMutableDictionary *workoutSessions;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    workoutSessions = [NSMutableDictionary new];
//    // Fetche workout list
//    NSArray *workouts = [Workout fetchAll];
//
//    for (Workout *w in workouts) {
//        NSLog(@"%d session found for workout %@", (int)[w.sessionList count], w.name);
//        // Store all session for current workout
//        [workoutSessions setValue:[w.sessionList allObjects] forKey:w.name];
//    }
    
    // Fetch workout with at least one session
    self.fetchedResultsController = [Workout fetchResultsControllerWithDelegate:self queryPredicateFormat:@"sessionList.@count > 0" sortingBy:kWorkoutDateCreated ascending:YES limit:@(10)];
    if (self.fetchedResultsController == nil) {
        [[[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"There was an error fetching workouts." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        // TODO don't use abort() in prod!!!
        abort();
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSFetchedResultsController delegate

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            Workout *workout = (Workout *)[self.fetchedResultsController objectAtIndexPath:indexPath];
            [((ProgressCell *)[self.tableView cellForRowAtIndexPath:indexPath]) populateFromArray:[workout.sessionList allObjects] forWorkout:workout];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProgressCell *cell = [tableView dequeueReusableCellWithIdentifier:kProgressCellId];
    
    Workout *workout = (Workout *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell populateFromArray:[workout.sessionList allObjects] forWorkout:workout];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 280.0;
}

@end
