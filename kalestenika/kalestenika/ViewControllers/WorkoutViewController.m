//
//  WorkoutViewController.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 03/08/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "WorkoutViewController.h"
#import "WorkoutCell.h"

static NSString * const WorkoutCellIdentifier = @"WorkoutCell";

@interface WorkoutViewController ()

@end

@implementation WorkoutViewController {
    NSArray *workouts;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    workouts = @[@"Test 1", @"My strong workout", @"porco dio"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UITableView protocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
    [cell.titleLabel setText:item];
    [cell.subtitleLabel setText:[NSString stringWithFormat:@"Subtitle for cell %lu, with title %@", indexPath.row, item]];
}

/**
 * Helper method to compute custom table cell height
 */
- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static WorkoutCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
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
