//
//  AddWorkoutViewController.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 02/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "NewWorkoutViewController.h"
#import "AddExerciseViewController.h"
#import "Constants.h"
#import "Workout.h"
#import "NSManagedObject+Local.h"
#import "Record.h"
#import "User.h"


@interface NewWorkoutViewController ()

@end

@implementation NewWorkoutViewController {
    NSMutableArray *recordList;
    UILabel *footerView;
    UIAlertView *addRestAlert;
    float scheduleViewHeightCollapsed, scheduleViewHeightExpanded;
    NSMutableArray *scheduledDays;
    UITapGestureRecognizer *tapGesture;
    int totalExerciseNr, totalDuration;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Store exercise list locally
    recordList = [NSMutableArray new];
    scheduledDays = [NSMutableArray arrayWithArray:@[@NO, @NO, @NO, @NO, @NO, @NO, @NO]];
    
    // Setup view
    scheduleViewHeightCollapsed = 2.0;
    scheduleViewHeightExpanded = self.separatorViewConstraintHeight.constant;
    [self setupAddRestAlert];
    [self setupFooterView];
    [self.scheduleSwitch setOn:NO];
    [self collapseScheduleView];
    [self.workoutNameTextField addTarget:self action:@selector(workoutNameChanged:) forControlEvents:UIControlEventEditingChanged];
    // Setup tap gesture on main view to dismiss kayboard
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTouched)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)sendBackData:(NSArray *)items {
    NSLog(@"Got some data (%ld)!!", (long)[items count]);
    
    // Store new records in workout
    int oldRecords = (int)[recordList count];
    int newRecords = (int)[items count];
    [recordList addObjectsFromArray:items];

    NSLog(@"Updating exercise list: from %d to %d", oldRecords, newRecords);

    // Animate insertion of new row in UITableView
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (int i = oldRecords; i < oldRecords + newRecords; i ++)
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    
    [self.exerciseTableView beginUpdates];
    [self.exerciseTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.exerciseTableView endUpdates];
    
    [self updateFooterRecap];
    
    [self enableSaveButton];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Set origin to have back data
    ((AddExerciseViewController *) [segue destinationViewController]).origin = self;
    // Scroll to bottom to show animation of new records
    //[self.exerciseTableView setContentOffset:CGPointMake(0, MAXFLOAT) animated:NO];
}

#pragma mark - UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [recordList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    // Display correct for for exercise or rest
    Record *record = recordList[indexPath.row];
    if ([record.exercise.name isEqualToString:IdRest]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"RestCell"];
        [cell.textLabel setText:[Constants secondsToString:[record.duration intValue]]];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ExerciseCell"];
        [cell.textLabel setText:record.exercise.name];
        NSString *detail = (record.hitsPerRep.intValue > 0 ?
                            [NSString stringWithFormat:@"x%@", [record.hitsPerRep stringValue]] :
                            [Constants secondsToString:[record.duration intValue]]);
        [cell.detailTextLabel setText:detail];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([((Record *)recordList[indexPath.row]).exercise.name isEqualToString:IdRest])
        return 27.0;
    else
        return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([recordList count] == 0)
        return nil;
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([recordList count] == 0)
        return 0.0;
    return 20.0;
}

#pragma mark - UITableView editing

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view -- must be there otherwise the actions method isn't working
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [recordList removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self updateFooterRecap];
    }
}

//- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
//        [recordList removeObjectAtIndex:indexPath.row];
//        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        
//        [self updateFooterRecap];
//    }];
//    
//    return @[deleteAction];
//}

#pragma mark - UIAlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        int duration = [[addRestAlert textFieldAtIndex:0].text intValue];
        NSLog(@"Rest with duration *duration");
        [self sendBackData:@[[Record createRestRecordWithDuration:duration inWorkout:nil]]];
    }
}

#pragma mark - Interface Builder actions

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonPressed:(id)sender {
    NSLog(@"save");
    
    Workout *workout = [Workout new];
    workout.name = [self.workoutNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"Removing whitespace from string '%@': '%@'", self.workoutNameTextField.text, [self.workoutNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]);
    workout.dateCreated = [NSDate date];
    for (Record *r in recordList)
        r.workout = workout;
    workout.exerciseList = [[NSOrderedSet alloc] initWithArray:recordList];
    workout.schedule = scheduledDays;
    workout.creator = [User fetchCurrentUser];
    
    // Compute derivated properties
    workout.nrOfExercise = [NSNumber numberWithInteger:totalExerciseNr];
    // Create a set of requirements from the exercise list
    //  && Compute the extimated total duration
    NSMutableSet *requirementSet = [NSMutableSet new];
    for (Record *r in recordList)
        if (nil != r.exercise.requirement)
            [requirementSet addObject:r.exercise.requirement];
    workout.requirements = [requirementSet allObjects];
    workout.estimatedDuration = [NSNumber numberWithInt:totalDuration];
    
    [workout save];
    // Send back to caller VC the new workout
    [self.origin sendBackData:@[workout]];
    // Dismiss VC
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)scheduleSwitchChanged:(id)sender {
    if ([self.scheduleSwitch isOn])
        [self expandScheduleView];
    else
        [self collapseScheduleView];
}

- (IBAction)scheduleDayButtonPressed:(UIButton *)sender {
    [sender setSelected:![sender isSelected]];
    
    scheduledDays[sender.tag] = [sender isSelected] ? @YES : @NO;
}

- (IBAction)workoutNameEditingDidBegin:(UITextField *)sender {
    [self.view addGestureRecognizer:tapGesture];
}

- (IBAction)addExerciseBarButtonPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"AddExerciseSegue" sender:self];
}

- (IBAction)addRestBarButtonPressed:(UIBarButtonItem *)sender {
    NSLog(@"Add Rest");
    
    [addRestAlert show];
}

#pragma mark - Private methods


- (void)collapseScheduleView {
    [self.view layoutIfNeeded];
    
    self.separatorViewConstraintHeight.constant = scheduleViewHeightCollapsed;
    [UIView animateWithDuration:0.75 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        [self.view layoutIfNeeded];
        for (UIButton *button in self.scheduleView.subviews)
            button.alpha = 0.0;
    } completion:nil];
}

- (void)expandScheduleView {
    [self.view layoutIfNeeded];
    
    self.separatorViewConstraintHeight.constant = scheduleViewHeightExpanded;
    [UIView animateWithDuration:0.75 animations:^{
        [self.view layoutIfNeeded];
        for (UIButton *button in self.scheduleView.subviews)
            button.alpha = 1.0;
    }];
}

/** Check required fields to enable/disable "Done" bar button */
- (void)enableSaveButton {
    if (self.workoutNameTextField.text.length > 0 && [recordList count])
        [self.saveButton setEnabled:YES];
    else
        [self.saveButton setEnabled:NO];
}

- (void)setupAddRestAlert {
    addRestAlert = [[UIAlertView alloc] initWithTitle:@"Add rest" message:@"Set rest duration (in seconds)" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    addRestAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[addRestAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
}

- (void)setupFooterView {
    footerView = [UILabel new];
    [footerView setFont:[UIFont systemFontOfSize:12.0]];
    [footerView setBackgroundColor:ColorTeal];
    [footerView setTextColor:[UIColor whiteColor]];
    [footerView setTextAlignment:NSTextAlignmentCenter];
}

- (void)workoutNameChanged:(id)sender {
    [self enableSaveButton];
}

- (void)viewTouched {
    // Dismiss keyboard
    [self.workoutNameTextField resignFirstResponder];
    
    // Remove tap gesture
    [self.view removeGestureRecognizer:tapGesture];
}

- (void)updateFooterRecap {
    [self updateTotals];
    footerView.text = [NSString stringWithFormat:@"%d exercise%@, ~%@", totalExerciseNr, totalExerciseNr > 1 ? @"s" : @"", [Constants secondsToString:totalDuration]];
//    [self.exerciseTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    // Scroll 1 point to allow footer refresh
    [self.exerciseTableView setContentOffset:CGPointMake(0, self.exerciseTableView.contentOffset.y + 1) animated:NO];
}

- (void)updateTotals {
    totalDuration = 0;
    totalExerciseNr = 0;
    for (Record *r in recordList) {
        // Add to total duration either the exercise duration or the estimated duration for the number of hits
        totalDuration += [r.hitsPerRep intValue] > 0 ? [r.hitsPerRep intValue] * [r.exercise.estimatedDuration intValue] : [r.duration intValue];
        // Increment count only for exercises, not rests
        if (![r.exercise.name isEqualToString:IdRest]) totalExerciseNr++;
    }
}

@end
