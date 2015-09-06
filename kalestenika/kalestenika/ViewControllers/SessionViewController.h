//
//  SessionViewController.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 06/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Workout;

@interface SessionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) Workout *workout;

@property (weak, nonatomic) IBOutlet UILabel *timerMinuteLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerColonLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerSecondLabel;
@property (weak, nonatomic) IBOutlet UILabel *workoutNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDurationLabel;
@property (weak, nonatomic) IBOutlet UITableView *exerciseTableView;

- (IBAction)playPauseBarButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)nextBarButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)stopBarButtonPressed:(UIBarButtonItem *)sender;

@end
