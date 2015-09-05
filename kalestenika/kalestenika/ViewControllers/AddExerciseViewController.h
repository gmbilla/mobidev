//
//  AddExerciseViewController.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 03/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaitingData.h"


@interface AddExerciseViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) UIViewController <WaitingData> *origin;

@property (weak, nonatomic) IBOutlet UIPickerView *exercisePicker;
@property (weak, nonatomic) IBOutlet UILabel *numberOfRepsLabel;
@property (weak, nonatomic) IBOutlet UIStepper *numberOfRepsStepper;
@property (weak, nonatomic) IBOutlet UITextField *hitsPerRepEditText;
@property (weak, nonatomic) IBOutlet UITextField *durationEditText;
@property (weak, nonatomic) IBOutlet UITextField *restEditText;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;

- (IBAction)cancelBarButtonPressed:(id)sender;
- (IBAction)doneBarButtonPressed:(id)sender;
- (IBAction)repsStepperAction:(id)sender;
- (IBAction)editTextEditingDidBegin:(UITextField *)sender;
- (IBAction)editTextValueChanged:(UITextField *)sender;

@end
