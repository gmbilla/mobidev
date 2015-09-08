//
//  ProgressCell.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 08/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <UIKit/UIKit.h>


@class LineChartView, Workout;

static NSString *const kProgressCellId = @"ProgressCell";

@interface ProgressCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *workoutNameLabel;
@property (weak, nonatomic) IBOutlet LineChartView *chartView;
@property (weak, nonatomic) IBOutlet UILabel *lastPlayLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgDurationLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxDurationLabel;

- (void)populateFromArray:(NSArray *)items forWorkout:(Workout *)workout;

@end
