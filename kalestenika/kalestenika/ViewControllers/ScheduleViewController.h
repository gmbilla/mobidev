//
//  ScheduleViewController.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 01/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTCalendar.h"

@interface ScheduleViewController : UIViewController <JTCalendarDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet JTHorizontalCalendarView *calendarView;
@property (weak, nonatomic) IBOutlet UITableView *workoutTableView;

@property (nonatomic, strong) JTCalendarManager *calendarManager;

@end
