//
//  SessionViewController.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 06/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "SessionViewController.h"
#import "SaveSessionViewController.h"
#import "Constants.h"
#import "Workout.h"
#import "Session.h"
#import "Record.h"
#import "User.h"
#import "NSManagedObject+Local.h"


@class Exercise;

static NSString *const kExerciseDuration = @"duration";

@implementation SessionViewController {
    Session *session;
    NSMutableArray *doneExercise, *upcomingExercise;
    Record *currentExercise;
    UIColor *doneBackgroundColor, *currentBackgroundColor, *upcomingBackgroundColor;
    UIFont *doneFont, *currentFont, *upcomingFont;
    NSTimer *workoutTimer;
    int currentExerciseDuration, currentExerciseHits, totalDuration;
    BOOL started, playing;
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
    started = NO;
    playing = NO;
    [self.nextExerciseBarButton setEnabled:NO];
    
    // Setup view
    [self.workoutNameLabel setText:self.workout.name];
}

- (void)viewDidAppear:(BOOL)animated {
    if (playing)
        [self play];
}

- (void)viewWillDisappear:(BOOL)animated {
    // If the session is ongoing, pause it and post a notification to get back to it
    if (playing) {
        [self pause];
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate date];
        notification.alertBody = [NSString stringWithFormat:@"%@ %@ remaining", currentExercise.exercise.name, (currentExerciseDuration > 0 ? [NSString stringWithFormat:@"%d sec", currentExerciseDuration] : currentExercise.hitsPerRep)];
        notification.alertTitle = self.workout.name;
        notification.alertAction = @"get back to work!";
        
        // Post notification
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SaveSessionSegueId])
        ((SaveSessionViewController *) segue.destinationViewController).session = session;
}

#pragma mark - Interface Builder actions

- (IBAction)playPauseBarButtonPressed:(UIBarButtonItem *)sender {
    if (playing)
        [self pause];
    else
        [self play];
}

- (IBAction)nextBarButtonPressed:(UIBarButtonItem *)sender {
    [self nextExercise];
}

- (IBAction)stopBarButtonPressed:(UIBarButtonItem *)sender {
    if (!started) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    // Pause workout and ask user what to do
    [self pause];
    [[[UIAlertView alloc] initWithTitle:@"Stop" message:[NSString stringWithFormat:@"Are you sure you wanna stop the session? Current progress %d%%.", [self completionPercentage]] delegate:self cancelButtonTitle:@"Nope" otherButtonTitles:@"Yes", @"Discard session", nil] show];
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
    if (0 == buttonIndex) {
        // Nope, keep working!
        [self play];
    } else if (1 == buttonIndex) {
        // Stop session, save progress
        [self workoutDone];
    } else if (2 == buttonIndex) {
        // Discard session
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Private methods

/**
 * According to the missing exercises return an estimation of the completion percentage of the workout
 */
- (int)completionPercentage {
    // Check if workout is complete
    if ([self isWorkoutComplete])
        return 100;
    
    int percentage = totalDuration * 100 / self.workout.estimatedDuration.intValue;
    // TODO consider number of exercise for a better estimation
    return percentage < 100 ? percentage : 100;
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

- (BOOL)isWorkoutComplete {
    // Check if there are any more exercise and if current was completed
    return [upcomingExercise count] == 0 && currentExercise == nil;
}

- (void)nextExercise {
    if ([upcomingExercise count] == 0) {
        currentExercise = nil;
        currentExerciseDuration = -1;
        currentExerciseHits = -1;
        [self workoutDone];
        return;
    }
    
    Record *new = [upcomingExercise objectAtIndex:0];
    [upcomingExercise removeObjectAtIndex:0];
    [doneExercise addObject:currentExercise];
    currentExercise = new;
    
    if (0 != currentExercise.hitsPerRep.intValue) {
        currentExerciseDuration = -1;
        currentExerciseHits = currentExercise.hitsPerRep.intValue;
    } else {
        currentExerciseDuration = currentExercise.duration.intValue;
        currentExerciseHits = -1;
    }
    
    [self.exerciseTableView reloadData];
    
    [self.exerciseTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    NSLog(@"going to next exercise");
    [self updateView];
}

- (void)pause {
    NSLog(@"PAUSE");
    playing = NO;
    // Stops timer
    [workoutTimer invalidate];
    // Update toolbar icon
    [self.playPauseBarButton setImage:[UIImage imageNamed:@"play"]];
}

- (void)play {
    NSLog(@"PLAY");
    // Only the first time set the session started
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        started = YES;
        
        if (0 != currentExercise.hitsPerRep.intValue) {
            currentExerciseDuration = -1;
            currentExerciseHits = currentExercise.hitsPerRep.intValue;
        } else {
            currentExerciseDuration = currentExercise.duration.intValue;
            currentExerciseHits = -1;
        }
    });
    
    // Start workout
    playing = YES;
    [self updateView];
    // Start timer
    workoutTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                    target:self
                                                  selector:@selector(timerTriggered:)
                                                  userInfo:nil
                                                   repeats:YES];
    // Update toolbar icon
    [self.playPauseBarButton setImage:[UIImage imageNamed:@"pause"]];
}

- (void)timerTriggered:(NSTimer*)timer {
    // Check if countdown terminated
    if (currentExerciseDuration == 0) {
        NSLog(@"Countdown for exercise finished");
        [self nextExercise];
    } else if (currentExerciseDuration > 0) {
        // Update duration
        currentExerciseDuration--;
        NSLog(@"countdown: %d", currentExerciseDuration);
        
        // Update view
        if (currentExerciseDuration > 60)
            [self.timerMinuteLabel setText:[Constants addLeadingZero:currentExerciseDuration / 60]];
        else
            [self.timerMinuteLabel setText:@"00"];
        [self.timerSecondLabel setText:[Constants addLeadingZero:currentExerciseDuration % 60]];
    }
    
    // Increase total duration
    totalDuration++;
    [self.totalDurationLabel setText:[Constants secondsToHhMmSs:totalDuration]];
}

- (void)updateView {
    if (currentExerciseDuration == -1 && currentExerciseHits > 0) {
        NSLog(@"HITS exercise");
        [self.timerColonLabel setHidden:YES];
        [self.timerSecondLabel setText:@(currentExerciseHits).stringValue];
        [self.timerMinuteLabel setText:@"x"];
        
        [self.nextExerciseBarButton setEnabled:YES];
    } else {
        NSLog(@"TIME exercise");
        [self.timerColonLabel setHidden:NO];
        int duration = currentExerciseDuration;
        if (duration > 60)
            [self.timerMinuteLabel setText:[Constants addLeadingZero:duration / 60]];
        else
            [self.timerMinuteLabel setText:@"00"];
        [self.timerSecondLabel setText:[Constants addLeadingZero:duration % 60]];
        
        [self.nextExerciseBarButton setEnabled:NO];
    }
}

- (void)workoutDone {
    // Pause workout
    [self pause];
    
    // Save session
    session = [Session new];
    session.workout = self.workout;
    session.duration = [NSNumber numberWithInt:totalDuration];
    session.completion = [NSNumber numberWithInt:[self completionPercentage]];
    session.when = [NSDate date];
    session.user = [User fetchCurrentUser];
    
    // Show SaveSessionVC to insert vote and place
    [self performSegueWithIdentifier:SaveSessionSegueId sender:self];
}

@end
