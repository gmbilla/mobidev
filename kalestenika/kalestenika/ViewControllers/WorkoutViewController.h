//
//  WorkoutViewController.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 03/08/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WorkoutViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *workoutTableView;

@end
