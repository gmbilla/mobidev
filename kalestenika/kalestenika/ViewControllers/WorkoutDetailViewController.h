//
//  WorkoutDetailViewController.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 06/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Workout;

@interface WorkoutDetailViewController : UIViewController <UITableViewDataSource, UITabBarDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) Workout *workout;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *scheduleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *requirementsCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *exerciseNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UITableView *exerciseTableView;

@end
