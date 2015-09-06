//
//  WorkoutDetailViewController.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 06/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "WorkoutDetailViewController.h"
#import "SessionViewController.h"
#import "Constants.h"
#import "Workout.h"
#import "Record.h"


@implementation WorkoutDetailViewController

- (void)viewDidLoad {
//    NSLog(@"Detail for workout: %@", self.workout);
    
    // Setup view
    [self.nameLabel setText:self.workout.name];
    NSMutableArray *scheduledDays = [NSMutableArray new];
    NSArray *weekdays = @[@"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Sat"];
    for (int i = 0; i < 7; i++)
        if (((NSNumber *)self.workout.schedule[i]).boolValue)
            [scheduledDays addObject:weekdays[i]];
    [self.scheduleLabel setText:[scheduledDays componentsJoinedByString:@", "]];
    [self.exerciseNumberLabel setText:[NSString stringWithFormat:@"%d exercises", self.workout.nrOfExercise.intValue]];
    [self.durationLabel setText:[NSString stringWithFormat:@"~%@", [Constants secondsToString:self.workout.estimatedDuration.intValue]]];
    // Register data source cell classes
    [self.requirementsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"RequirementCell"];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"sending workout");
    ((SessionViewController *)[segue destinationViewController]).workout = self.workout;
}

#pragma mark - UITableView data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.workout.exerciseList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    // Display correct for for exercise or rest
    Record *record = self.workout.exerciseList[indexPath.row];
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
    if ([((Record *)self.workout.exerciseList[indexPath.row]).exercise.name isEqualToString:IdRest])
        return 27.0;
    else
        return 44.0;
}

#pragma mark - UICollectionView data source

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // Rows
    return 1;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    // Columns
    return [self.workout.requirements count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self.requirementsCollectionView dequeueReusableCellWithReuseIdentifier:@"RequirementCell" forIndexPath:indexPath];
    
    //    NSLog(@"Setting image for requirement #%ld", (long)indexPath.section);
    NSString *req = [self.workout.requirements[indexPath.section] lowercaseString];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"requirement_%@", req]]];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setFrame:cell.contentView.frame];
    [cell.contentView addSubview:imageView];
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(36.0, 36.0);
}

@end
