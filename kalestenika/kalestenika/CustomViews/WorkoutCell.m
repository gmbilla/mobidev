//
//  WorkoutCell.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 31/07/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "WorkoutCell.h"
#import "Workout.h"
#import "Constants.h"


@implementation WorkoutCell {
    NSArray *requirements;
}

- (void)populateFromWorkout:(Workout *)workout atIndexPath:(NSIndexPath *)indexPath {
    self.nameLabel.text = workout.name;
    [self.startWorkoutButton setHidden:indexPath.row != 0];
        
    [self.startWorkoutButton setBackgroundColor:[UIColor orangeColor]];
    self.startWorkoutButton.layer.cornerRadius = 16.0;
    self.exerciseNrLabel.text = [NSString stringWithFormat:@"%@ exercises", workout.nrOfExercise.stringValue];
    self.durationLabel.text = [NSString stringWithFormat:@"~%@", [Constants secondsToString:workout.estimatedDuration.intValue]];
    
    requirements = workout.requirements;
    if ([requirements count] == 0) {
        [self.requirementsCollectionView removeFromSuperview];
    } else {
        [self.requirementsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"RequirementCell"];
    }
}

#pragma mark - UICollectionView stuff

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // Rows
    return 1;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    // Columns
    return [requirements count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self.requirementsCollectionView dequeueReusableCellWithReuseIdentifier:@"RequirementCell" forIndexPath:indexPath];
    
//    NSLog(@"Setting image for requirement #%ld", (long)indexPath.section);
    NSString *req = [requirements[indexPath.section] lowercaseString];
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
