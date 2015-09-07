//
//  ScheduleViewController.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 01/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "ScheduleViewController.h"
#import "WorkoutDetailViewController.h"
#import "Constants.h"
#import "Workout.h"
#import "NSManagedObject+Local.h"

#define DAYS 24*60*60


static NSString *const WorkoutCellId = @"WorkoutNameCell";

@interface ScheduleViewController ()

@end

@implementation ScheduleViewController {
    NSArray *scheduledDays;
    NSMutableArray *haveSchedule;
    NSDate *today, *dateSelected, *minDate, *maxDate;
    NSDateFormatter *weekDayFormatter;
    Workout *selectedWorkout;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Fetch workout schedule
    scheduledDays = @[[NSMutableArray new],
                      [NSMutableArray new],
                      [NSMutableArray new],
                      [NSMutableArray new],
                      [NSMutableArray new],
                      [NSMutableArray new],
                      [NSMutableArray new]];
    haveSchedule = [NSMutableArray arrayWithArray:@[@NO, @NO, @NO, @NO, @NO, @NO, @NO]];
    NSArray *workouts = [Workout fetchAll];
    NSLog(@"Found %d workouts", [workouts count]);
    for (Workout *w in workouts)
        for (int day = 0; day < 7; day++)
            if ([w.schedule[day] boolValue]) {
                NSLog(@"'%@' scheduled on day %d", w.name, day);
                [scheduledDays[day] addObject:w];
                haveSchedule[day] = @YES;
            }
    NSLog(@"Schedule: %@", [haveSchedule componentsJoinedByString:@", "]);
    
    // Setup calendar stuff
    today = [NSDate date];
    dateSelected = today;
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"us_US"];
    weekDayFormatter = [NSDateFormatter new];
    [weekDayFormatter setDateFormat:@"e"];
    [weekDayFormatter setLocale:locale];
    
    // Set min/Max date
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth fromDate:today];
//    NSLog(@"Frist day: %d - %d", (int)components.day, (int)(components.day + [weekDayFormatter stringFromDate:today].integerValue));
    // Min date will be first Sunday in the first week of the current month
    minDate = [today dateByAddingTimeInterval:-(components.day + [weekDayFormatter stringFromDate:today].intValue) * DAYS];
    // 5 weeks after first day
    maxDate = [minDate dateByAddingTimeInterval:5 * 7 * DAYS];
    NSLog(@"DATES: %@ -- %@", minDate, maxDate);

    // Init calendar manager
    _calendarManager = [JTCalendarManager new];
    [_calendarManager.dateHelper.calendar setLocale:locale];
    [_calendarManager setDelegate:self];
    [_calendarManager setContentView:_calendarView];
    [_calendarManager setDate:today];
    _calendarView.scrollEnabled = NO;
    
    [self.workoutTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:WorkoutCellId];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:WorkoutDetailSegueId])
        ((WorkoutDetailViewController *)[segue destinationViewController]).workout = selectedWorkout;
}

#pragma mark - CalendarManager delegate

// Customize the appearance of dayView
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    dayView.dotView.backgroundColor = [UIColor orangeColor];
    dayView.circleView.hidden = YES;
    
    // Selected date
    if (dateSelected && [_calendarManager.dateHelper date:dateSelected isTheSameDayThan:dayView.date]) {
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor orangeColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    } else {
        if ([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]) {
            // Today
            dayView.circleView.hidden = NO;
            dayView.circleView.backgroundColor = ColorTeal;
            dayView.textLabel.textColor = [UIColor whiteColor];
        } else if (![_calendarManager.dateHelper date:_calendarView.date isTheSameMonthThan:dayView.date]) {
            // Other month
            dayView.textLabel.textColor = [UIColor lightGrayColor];
        } else {
            // Another day of the current month
            dayView.textLabel.textColor = [UIColor blackColor];
        }
    }
    
    if ([haveSchedule[[self weekdayForDate:dayView.date]] boolValue]) {
        dayView.dotView.hidden = NO;
    } else {
        dayView.dotView.hidden = YES;
    }
}

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
    dateSelected = dayView.date;
    
    // Animation for the circleView
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView
                      duration:.3
                       options:0
                    animations:^{
                        dayView.circleView.transform = CGAffineTransformIdentity;
                        [_calendarManager reload];
                    } completion:nil];
    [self.workoutTableView reloadData];
}

- (BOOL)calendar:(JTCalendarManager *)calendar canDisplayPageWithDate:(NSDate *)date {
    // Limit the date for the calendar
    return [_calendarManager.dateHelper date:date isEqualOrAfter:minDate andEqualOrBefore:maxDate];
}

#pragma mark - UITableView data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self workouts] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.workoutTableView dequeueReusableCellWithIdentifier:WorkoutCellId];
    [cell.textLabel setText:[[[self workouts] objectAtIndex:indexPath.row] valueForKey:@"name"]];
    [cell.textLabel setTextAlignment:NSTextAlignmentRight];
    
    return cell;
}

#pragma mark - UITableView delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedWorkout = [[self workouts] objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:WorkoutDetailSegueId sender:self];
}

#pragma mark - Private methods

- (int)weekdayForDate:(NSDate *)date {
    return [[weekDayFormatter stringFromDate:date] intValue] - 1;
}

/**
 * Return a list of workouts scheduled for the selected day
 */
- (NSMutableArray *)workouts {
    return [scheduledDays objectAtIndex:[self weekdayForDate:dateSelected]];
}

@end
