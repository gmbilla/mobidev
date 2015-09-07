//
//  WorkoutCell.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 31/07/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Workout;

static NSString *const kWorkoutCellId = @"WorkoutCell";

@interface WorkoutCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *exerciseNrLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *requirementsCollectionView;

- (void)populateFromWorkout:(Workout *)workout;

@end
