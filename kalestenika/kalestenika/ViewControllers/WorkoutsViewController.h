//
//  WorkoutViewController.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 03/08/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaitingData.h"


@interface WorkoutsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, WaitingData>

@property (weak, nonatomic) IBOutlet UITableView *workoutTableView;
@property (weak, nonatomic) IBOutlet UIView *emptyView;

- (IBAction)unwindToWorkoutList:(UIStoryboardSegue *)unwindSegue;

@end
