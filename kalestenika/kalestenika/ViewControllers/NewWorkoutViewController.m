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
    UIButton *footerAddExerciseButton;
    float scheduleViewHeightCollapsed, scheduleViewHeightExpanded;
    NSMutableArray *scheduledDays;
    UITapGestureRecognizer *tapGesture;
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
    
    // Scroll of 1 point to force footer view position refresh
    [self.exerciseTableView setContentOffset:CGPointMake(0, self.exerciseTableView.contentOffset.y + 1) animated:NO];
    
    [self enableSaveButton];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Set origin to have back data
    ((AddExerciseViewController *) [segue destinationViewController]).origin = self;
}

#pragma mark - UITableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    // Display correct for for exercise or rest
    Record *record = recordList[indexPath.row];
    if ([record.exercise.name isEqualToString:IdRest]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"RestCell"];
        [cell.textLabel setText:[NSString stringWithFormat:@"%@s", [record.duration stringValue]]];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ExerciseCell"];
        NSLog(@"Exercise %@ - hits %@ - duration %@", record.exercise.name, record.hitsPerRep, record.duration);
        [cell.textLabel setText:record.exercise.name];
        NSString *detail = (record.hitsPerRep.intValue > 0 ?
                            [NSString stringWithFormat:@"%@x", [record.hitsPerRep stringValue]] :
                            [NSString stringWithFormat:@"%@s", [record.duration stringValue]]);
        [cell.detailTextLabel setText:detail];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numberOfRowsInSection: %ld", (long)[recordList count]);
    return [recordList count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Height for %@", ((Record *)recordList[indexPath.row]).exercise);
    if ([((Record *)recordList[indexPath.row]).exercise.name isEqualToString:IdRest])
        return 27.0;
    else
        return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return footerAddExerciseButton;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 44.0;
}

#pragma mark - Interface Builder actions

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonPressed:(id)sender {
    NSLog(@"save");
    
    Workout *workout = [Workout new];
    workout.name = [self.workoutNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    workout.dateCreated = [NSDate date];
    for (Record *r in recordList)
        r.workout = workout;
    workout.exerciseList = [[NSOrderedSet alloc] initWithArray:recordList];
    workout.schedule = scheduledDays;
    workout.creator = [User fetchCurrentUser];
    
    // Compute derivated properties
    workout.nrOfExercise = [NSNumber numberWithInteger:[recordList count]];
    // Create a set of requirements from the exercise list
    //  && Compute the extimated total duration
    NSMutableSet *requirementSet = [NSMutableSet new];
    int totalDuration = 0;
    for (Record *r in recordList) {
        NSLog(@"Requirement: %@ - totalDuration: %d", r.exercise.requirement, totalDuration);
        if (nil != r.exercise.requirement)
            [requirementSet addObject:r.exercise.requirement];
        // Add to total duration either the exercise duration or the estimated duration for the number of hits
        totalDuration += r.hitsPerRep > 0 ? [r.hitsPerRep intValue] * [r.exercise.estimatedDuration intValue] : [r.duration intValue];
    }
    workout.requirements = [requirementSet allObjects];
    NSLog(@"Requirement list: %@", [[requirementSet allObjects] componentsJoinedByString:@", "]);
    workout.estimatedDuration = [NSNumber numberWithInt:totalDuration];
    NSLog(@"Estimated duration: %d", totalDuration);
    
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

#pragma mark - Private methods

- (void)addExercisePressed:(id)sender {
    [self performSegueWithIdentifier:@"AddExerciseSegue" sender:self];
}

- (void)addRestPressed:(id)sender {
    NSLog(@"Add Rest");
    
//    [self performSegueWithIdentifier:@"AddExerciseSegue" sender:self];
}


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

- (void)setupFooterView {
    // Create button to add exercise
    footerAddExerciseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [footerAddExerciseButton addTarget:self action:@selector(addExercisePressed:) forControlEvents:UIControlEventTouchUpInside];
    [footerAddExerciseButton setTitle:NSLocalizedString(@"ButtonAddExercise", nil) forState:UIControlStateNormal];
    [footerAddExerciseButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    // Add left padding to text
    [footerAddExerciseButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)];
//    footerAddExerciseButton.frame = CGRectOffset(footerAddExerciseButton.frame, 0, 32.0);
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

@end
