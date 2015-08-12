//
//  WorkoutViewController.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 03/08/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "WorkoutViewController.h"
#import "WorkoutCell.h"
#import "User.h"


static NSString * const WorkoutCellIdentifier = @"WorkoutCell";

@interface WorkoutViewController ()

@end

@implementation WorkoutViewController {
    NSArray *workouts;
    User *user;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // TODO remove debug stuff
    NSLog(@"WorkoutVC did LOAD");
    workouts = @[@"Test 1", @"My strong workout", @"Corri porco!!"];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"WorkoutViewController fetching user");
    user = [User fetchCurrentUser];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UITableView protocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Got the user? %@", (user != nil)? @"YAAY!!" : @"nope");
    if (user == nil)
        return 0;
    return [workouts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self basicCellAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForBasicCellAtIndexPath:indexPath];
}

#pragma UITableView helpers

/**
 * Helper method to dequeue a custom cell for the UITableView
 */
- (WorkoutCell *)basicCellAtIndexPath:(NSIndexPath *)indexPath {
    WorkoutCell *cell = [self.workoutTableView dequeueReusableCellWithIdentifier:WorkoutCellIdentifier forIndexPath:indexPath];
    [self configureBasicCell:cell atIndexPath:indexPath];
    return cell;
}

/**
 * Helper method to configure the content of the custom cell
 */
- (void)configureBasicCell:(WorkoutCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSString *item = workouts[indexPath.row];
    [cell.nameLabel setText:item];
    [cell.durationLabel setText:[NSString stringWithFormat:@"1m : %lus", (indexPath.row * 15) % 60]];
    [cell.exerciseNrLabel setText:[NSString stringWithFormat:@"%lu", indexPath.row]];
}

/**
 * Helper method to compute custom table cell height
 */
- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static WorkoutCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"Getting a test cell to compute the size");
        sizingCell = [self.workoutTableView dequeueReusableCellWithIdentifier:WorkoutCellIdentifier];
    });
    
    [self configureBasicCell:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

/**
 * Helper method to calculate the real size from auto layout contraints
 */
- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    NSLog(@"Computed cell height: %f", size.height);
    return size.height + 1.0f; // Add 1.0f for the cell separator height
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
