//
//  AddExerciseViewController.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 03/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "AddExerciseViewController.h"
#import "Exercise.h"
#import "NSManagedObject+Local.h"
#import "Record.h"


@implementation AddExerciseViewController {
    NSArray *exerciseList;
    BOOL editingText;
    UITextField *editingField;
    UITapGestureRecognizer *tapGesture;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup view
    [self.doneBarButton setEnabled:NO];
    [self repsStepperAction:nil];
    editingText = NO;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTouched)];
    // Set listener for text changes
    [self.hitsPerRepEditText addTarget:self action:@selector(editTextValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.durationEditText addTarget:self action:@selector(editTextValueChanged:) forControlEvents:UIControlEventEditingChanged];
    
    // Fetch exercises
    exerciseList = [Exercise fetchAll];
}

#pragma mark - UIPicker delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [exerciseList count] + 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (0 == row)
        return @"-";
    return [(Exercise *)exerciseList[row - 1] name];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self enableDoneBarButton];
}

#pragma mark - Interface Builder actions

- (IBAction)cancelBarButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneBarButtonPressed:(id)sender {
    // TODO Save exercise in workout
    NSLog(@"DONE");
    
    // Create records from user selection
    NSMutableArray *records = [NSMutableArray new];
    Exercise *exercise = exerciseList[[self.exercisePicker selectedRowInComponent:0] - 1];
    int hitsPerRep, duration;
    int reps = [self.numberOfRepsLabel.text intValue];
    int restBtwRep = [self.restEditText.text intValue];
    hitsPerRep = [self.hitsPerRepEditText.text intValue];
    duration = [self.durationEditText.text intValue];
    NSLog(@"Creating record for exercise %@, hits %d, duration %d - rest btw %d", exercise.name, hitsPerRep, duration, restBtwRep);
    // Create a record for each rep and rest
    for (int i = 0; i < reps; i++) {
        [records addObject:[[Record alloc] initWithExercise:exercise hitsPerRep:hitsPerRep duration:duration inWorkout:nil]];
        if (restBtwRep > 0) {
            [records addObject:[Record createRestRecordWithDuration:restBtwRep inWorkout:nil]];
        }
    }
    NSLog(@"Passing back %lu record(s)", (unsigned long)[records count]);
    
    // Pass back data
    [self.origin sendBackData:records];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)repsStepperAction:(id)sender {
    [self.numberOfRepsLabel setText:[NSString stringWithFormat:@"%.f", self.numberOfRepsStepper.value]];
}

- (IBAction)editTextEditingDidBegin:(UITextField *)sender {
    NSLog(@"editing %ld", (long)sender.tag);

    // Stuff required for keyboard handling
    if (!editingText) {
        // Add tag gesture for keyboard dismiss
        [self.view addGestureRecognizer:tapGesture];
    }
    editingText = YES;
    editingField = sender;
    [self moveTextField:sender up:YES];
}

#pragma mark - Private methods

- (void)editTextValueChanged:(UITextField *)sender {
    NSLog(@"value changed %ld", (long)sender.tag);
    
    if (sender.text.length == 0)
        [(sender.tag == 0 ? self.durationEditText : self.hitsPerRepEditText) setEnabled:YES];
    else
        [(sender.tag == 0 ? self.durationEditText : self.hitsPerRepEditText) setEnabled:NO];
    
    [self enableDoneBarButton];
}

/** Check required fields to enable/disable "Done" bar button */
- (void)enableDoneBarButton {
    if ([self.exercisePicker selectedRowInComponent:0] > 0
        && (self.hitsPerRepEditText.text.length > 0 || self.durationEditText.text.length > 0)) {
        [self.doneBarButton setEnabled:YES];
    } else {
        [self.doneBarButton setEnabled:NO];
    }
}

- (void)moveTextField:(UITextField *)field up:(BOOL)up {
    // Store once main view frame for animation
    static dispatch_once_t predicate;
    static CGRect mainViewFrame;
    static BOOL animate;
    dispatch_once(&predicate, ^{
        mainViewFrame = self.view.frame;
        animate = [UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad;
    });
    if (animate) {
        // Animate view origin Y according to current field
        int y = field.tag < 2 ? 80 : 140;
        [UIView animateWithDuration:0.3 animations:^{
            mainViewFrame.origin.y = up ? -y : 0.0;
            self.view.frame = mainViewFrame;
        }];
    }
}

- (void)viewTouched {
    // If a UITextField was editing
    if (editingText && editingField) {
        // Dismiss keyboard
        [editingField resignFirstResponder];
        // Move back main view at its original place
        [self moveTextField:editingField up:NO];
        editingField = nil;
        editingText = NO;
        
        // Remove tap gesture
        [self.view removeGestureRecognizer:tapGesture];
    }
}

@end
