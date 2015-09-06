//
//  SessionViewController.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 06/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "SessionViewController.h"
#import "Constants.h"
#import "Workout.h"
#import "Record.h"


@implementation SessionViewController {
    NSMutableArray *doneExercise, *upcomingExercise;
    Record *currentExercise;
    UIColor *doneBackgroundColor, *currentBackgroundColor, *upcomingBackgroundColor;
    UIFont *doneFont, *currentFont, *upcomingFont;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"SEssion for workout: %@", self.workout);
    
    // Setup required stuff
    doneBackgroundColor = ColorTeal; // [UIColor darkGrayColor];
    currentBackgroundColor = [UIColor orangeColor];
    upcomingBackgroundColor = [UIColor clearColor];
    doneFont = [UIFont systemFontOfSize:17.0 weight:UIFontWeightUltraLight];
    currentFont = [UIFont systemFontOfSize:17.0 weight:UIFontWeightBlack];
    upcomingFont = [UIFont systemFontOfSize:17.0 weight:UIFontWeightMedium];
    doneExercise = [NSMutableArray new];
    upcomingExercise = [NSMutableArray arrayWithArray:[self.workout.exerciseList array]];
    currentExercise = [upcomingExercise objectAtIndex:0];
    [upcomingExercise removeObjectAtIndex:0];
    
    // Setup view
    [self.workoutNameLabel setText:self.workout.name];
    [self updateTimer];

    NSLog(@"SessionViewController viewDidLoad");
}

#pragma mark - Interface Builder actions

- (IBAction)playPauseBarButtonPressed:(UIBarButtonItem *)sender {
}

- (IBAction)nextBarButtonPressed:(UIBarButtonItem *)sender {
    if (![self nextExercise]) {
        NSLog(@"END!!");
        [self animateDone];
    } else {
        [self updateTimer];
    }
}

- (IBAction)stopBarButtonPressed:(UIBarButtonItem *)sender {
    [[[UIAlertView alloc] initWithTitle:@"Stop" message:@"Are you sure you wanna stop the session? All you progress will be lost." delegate:self cancelButtonTitle:@"Nope" otherButtonTitles:@"Yes", nil] show];
}

#pragma mark - UITableView data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [doneExercise count] == 0 ? 1 : [doneExercise count];
            break;
        case 1:
            return 1;
            break;
        case 2:
            return [upcomingExercise count];
            break;
            
        default:
            return 0;
            break;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self createHeaderLabelWithText:@"Done"];
            break;
        case 1:
            return [self createHeaderLabelWithText:@"Current"];
            break;
        case 2:
            return [self createHeaderLabelWithText:@"Upcoming"];
            break;
            
        default:
            return nil;
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SessionCell"];
    Record *record;
    switch (indexPath.section) {
        case 0:
            [cell setBackgroundColor:doneBackgroundColor];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.textLabel setFont:doneFont];
            [cell.detailTextLabel setFont:doneFont];
            if ([doneExercise count] == 0) {
                [cell.textLabel setText:@"-"];
                return cell;
            }
            record = [doneExercise objectAtIndex:indexPath.row];
            break;
        case 1:
            [cell setBackgroundColor:currentBackgroundColor];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.textLabel setFont:currentFont];
            [cell.detailTextLabel setFont:currentFont];
            [cell.detailTextLabel setTextColor:[UIColor whiteColor]];
            record = currentExercise;
            break;
        case 2:
            [cell setBackgroundColor:upcomingBackgroundColor];
            [cell.textLabel setFont:upcomingFont];
            [cell.detailTextLabel setFont:upcomingFont];
            record = [upcomingExercise objectAtIndex:indexPath.row];
            break;
            
        default:
            break;
    }
    
    // Populate cell
    [cell.textLabel setText:record.exercise.name];
    NSString *detail = (record.hitsPerRep.intValue > 0 ?
                        [NSString stringWithFormat:@"x%@", record.hitsPerRep.stringValue] :
                        [Constants secondsToString:record.duration.intValue]);
    [cell.detailTextLabel setText:detail];
    
    return cell;
}

#pragma mark UITableView delegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (2 == indexPath.section) {
        Record *record = [upcomingExercise objectAtIndex:indexPath.row];
        if (nil != record.exercise.exerciseDescription)
            [[[UIAlertView alloc] initWithTitle:record.exercise.name message:record.exercise.exerciseDescription delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
    }
}

/*-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}*/

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (1 == buttonIndex)
        [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private methods

- (void)animateDone {
    CGRect frame = CGRectMake(self.exerciseTableView.frame.origin.x, self.exerciseTableView.frame.size.height, self.exerciseTableView.frame.size.width, 0);
    
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        // Collapse exercise List
        self.exerciseTableView.frame = frame;
        self.exerciseTableView.alpha = 0.0;
    } completion:nil];
}

- (UILabel *)createHeaderLabelWithText:(NSString *)text {
    UILabel *headerLabel = [UILabel new];
    UIFont *font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightThin];
    [headerLabel setFont:font];
    [headerLabel setTextAlignment:NSTextAlignmentRight];
    [headerLabel setBackgroundColor:[UIColor whiteColor]];
    [headerLabel setTextColor:[UIColor blackColor]];
    [headerLabel setText:text];

    return headerLabel;
}

- (BOOL)nextExercise {
    if ([upcomingExercise count] == 0)
        return NO;
    
    Record *new = [upcomingExercise objectAtIndex:0];
    [upcomingExercise removeObjectAtIndex:0];
    [doneExercise addObject:currentExercise];
    currentExercise = new;
    
    [self.exerciseTableView reloadData];
    
    [self.exerciseTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    return YES;
}

- (void)updateTimer {
    if (0 != currentExercise.hitsPerRep.intValue) {
        [self.timerColonLabel setHidden:YES];
        [self.timerSecondLabel setText:@"x"];
        [self.timerMinuteLabel setText:currentExercise.hitsPerRep.stringValue];
    } else {
        [self.timerColonLabel setHidden:NO];
        int duration = currentExercise.duration.intValue;
        if (duration > 60)
            [self.timerMinuteLabel setText:[self addLeadingZero:duration / 60]];
        else
            [self.timerMinuteLabel setText:@"00"];
        [self.timerSecondLabel setText:[self addLeadingZero:duration % 60]];
    }
}

- (NSString *)addLeadingZero:(int)base60 {
    return [NSString stringWithFormat:@"%@%d", base60 < 10 ? @"0" : @"", base60];
}

@end
