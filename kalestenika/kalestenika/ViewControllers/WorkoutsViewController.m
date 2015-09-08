//
//  WorkoutViewController.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 03/08/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "WorkoutsViewController.h"
#import "NewWorkoutViewController.h"
#import "WorkoutDetailViewController.h"
#import "SessionViewController.h"
#import "Constants.h"
#import "WorkoutCell.h"
#import "User.h"
#import "Workout.h"
#import "NSManagedObject+Local.h"


static NSString * const WorkoutCellIdentifier = @"WorkoutCell";

@interface WorkoutsViewController ()

@end

@implementation WorkoutsViewController {
    NSMutableArray *workouts;
    UILongPressGestureRecognizer *longPressGestureRecognizer;
    UITapGestureRecognizer *tapGestureRecognizer;
    Workout *selectedWorkout;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    workouts = [NSMutableArray arrayWithArray:[Workout fetchAllSortingBy:@"dateCreated" ascending:NO]];
    [self swapTodayWorkout];
    
    [self hideShowEmptyView];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)unwindToWorkoutList:(UIStoryboardSegue *)unwindSegue {
    NSLog(@"Unwind");
    // Change selected VC to dashboard
    [self.tabBarController setSelectedIndex:1];
}

#pragma mark - Table view stuff

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [workouts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WorkoutCell *cell = [tableView dequeueReusableCellWithIdentifier:kWorkoutCellId];
    
    if (cell == nil) {
        cell = [WorkoutCell new];
    }
    [cell populateFromWorkout:workouts[indexPath.row] atIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [((Workout *)workouts[indexPath.row]).requirements count] > 0 ? 134.0 : 90.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedWorkout = workouts[indexPath.row];
    [self performSegueWithIdentifier:WorkoutDetailSegueId sender:self];
    
    [self.workoutTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Table view editing

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view -- must be there otherwise the actions method isn't working
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Workout *workout = workouts[indexPath.row];
        [workout delete];
        [workout save];
        [workouts removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self hideShowEmptyView];
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    NSLog(@"tableView moveRowAtIndexPath from %lu to %lu", (long)fromIndexPath.row, (long)toIndexPath.row);
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    return proposedDestinationIndexPath;
}


#pragma mark - Navigation

- (void)sendBackData:(NSArray *)items {
    // Store new workout in first position
    [workouts insertObject:[items objectAtIndex:0] atIndex:0];
    
    // Show table if hidden
    [self hideShowEmptyView];
    
    // Animate insertion of new row in UITableView
    [self.workoutTableView beginUpdates];
    [self.workoutTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    [self.workoutTableView endUpdates];
    
    [self swapTodayWorkout];
    [self.workoutTableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:NewWorkoutSegueId])
        // Set origin to have back data
        ((NewWorkoutViewController *)[[segue destinationViewController] topViewController]).origin = self;
    else if ([segue.identifier isEqualToString:WorkoutDetailSegueId])
        ((WorkoutDetailViewController *)[segue destinationViewController]).workout = selectedWorkout;
    else if ([segue.identifier isEqualToString:SessionSegueId])
        ((SessionViewController *)[segue destinationViewController]).workout = workouts[0];
}

#pragma mark - Private methods

- (void)hideShowEmptyView {
    if ([workouts count] == 0) {
        [self.workoutTableView setHidden:YES];
        [self.emptyView setHidden:NO];
    } else {
        [self.workoutTableView setHidden:NO];
        [self.emptyView setHidden:YES];
        
        [self setupGestures];
    }
}

/**
 * Initial setup of gestures
 */
- (void)setupGestures {
    // Run only once this code
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        // Long press gesture
        longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tableRowLongPressed:)];
        [longPressGestureRecognizer setDelegate:self];
        [longPressGestureRecognizer setMinimumPressDuration:1.5];
        // Single tap gesture
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableRowTapped:)];
        [tapGestureRecognizer setDelegate:nil];
        
        // Enable the right gesture
        [self updateGestures];
    });
}

/**
 * Check if there's a workout scheduled for today and put it in the first position
 */
- (void)swapTodayWorkout {
    NSMutableArray *schedule;
    int weekDay = [[Constants weekDayFormatter] stringFromDate:[NSDate date]].intValue - 1;
    NSLog(@"Searching workout scheduled for %d", weekDay);
    for (int i = 0; i < [workouts count]; i++) {
        schedule = ((Workout *)workouts[i]).schedule;
        NSLog(@"'%@' schedule: %@ -> %@", ((Workout *)workouts[i]).name, [schedule componentsJoinedByString:@", "], [schedule[weekDay] stringValue]);
        if ([schedule[weekDay] boolValue]) {
            NSLog(@"Workout '%@' schedule for today!", ((Workout *)workouts[i]).name);
            if (i > 0) {
                NSLog(@"Switching %@ with %@", ((Workout *)workouts[0]).name, ((Workout *)workouts[i]).name);
                Workout *tmp = workouts[0];
                workouts[0] = workouts[i];
                workouts[i] = tmp;

                // Refresh the list
                [self.workoutTableView reloadData];
            }
            break;
        }
    }
}

/**
 * Update gesture according to table state
 */
- (void)updateGestures {
    if ([self.workoutTableView isEditing]) {
        // If table is in edit mode disable long press
        [self.workoutTableView removeGestureRecognizer:longPressGestureRecognizer];
        [self.workoutTableView addGestureRecognizer:tapGestureRecognizer];
    } else {
        // Otherwise enable long press and disable single tap
        [self.workoutTableView removeGestureRecognizer:tapGestureRecognizer];
        [self.workoutTableView addGestureRecognizer:longPressGestureRecognizer];
    }
}

- (void)tableRowLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    // Only react when gesture begins
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        [self.workoutTableView setEditing:YES animated:YES];
        [self updateGestures];
        NSLog(@"Long PRESS");
    }
}

- (void)tableRowTapped:(UITapGestureRecognizer *)gestureRecognizer {
    [self.workoutTableView setEditing:NO animated:YES];
    
    [self updateGestures];
    NSLog(@"Single TAP");
}

@end
