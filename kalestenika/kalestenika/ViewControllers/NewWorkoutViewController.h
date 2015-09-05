//
//  AddWorkoutViewController.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 02/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaitingData.h"


@interface NewWorkoutViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, WaitingData>

@property (weak, nonatomic) UIViewController <WaitingData> *origin;

@property (weak, nonatomic) IBOutlet UITextField *workoutNameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *scheduleSwitch;
@property (weak, nonatomic) IBOutlet UIView *scheduleView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewConstraintHeight;
@property (weak, nonatomic) IBOutlet UITableView *exerciseTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)scheduleSwitchChanged:(id)sender;
- (IBAction)scheduleDayButtonPressed:(UIButton *)sender;
- (IBAction)workoutNameEditingDidBegin:(UITextField *)sender;

@end
