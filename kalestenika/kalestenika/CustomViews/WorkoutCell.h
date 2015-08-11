//
//  WorkoutCell.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 31/07/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkoutCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *exerciseNrLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *requirementsScrollView;
@property (weak, nonatomic) IBOutlet UIView *testRequirementView;

@end
