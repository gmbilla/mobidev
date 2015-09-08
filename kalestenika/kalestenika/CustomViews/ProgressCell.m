//
//  ProgressCell.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 08/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <Charts/Charts.h>
#import "ProgressCell.h"
#import "Constants.h"
#import "Session.h"
#import "Workout.h"


@interface ProgressCell () <ChartViewDelegate>

@end

@implementation ProgressCell {
    NSArray *sessions;
}

- (void)populateFromArray:(NSArray *)items forWorkout:(Workout *)workout {
    // Sort session by date
    sessions = [items sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((Session *)obj1).when compare:((Session *)obj2).when];
    }];
    NSLog(@"first: %@ - last: %@", ((Session *)[sessions firstObject]).when, ((Session *)[sessions lastObject]).when);
    
    // Init date formatter
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    int sum = 0, maxDuration = 0;
    // X axis values
    NSMutableArray *days = [NSMutableArray new];
    // Y axis values
    NSMutableArray *durations = [NSMutableArray new];
    // Set NSDateFormatter format for char values
    [formatter setDateFormat:@"d MMM"];
    int i = 0;
    for (Session *r in sessions) {
        NSLog(@"When: %@ - duration: %@", r.when, [Constants secondsToString:r.duration.intValue]);
        
        sum += r.duration.intValue;
        if (r.duration.intValue > maxDuration)
            maxDuration = r.duration.intValue;
        
        [days addObject:[formatter stringFromDate:r.when]];
        [durations addObject:[[ChartDataEntry alloc] initWithValue:r.duration.intValue xIndex:i++]];
    }
    
    // Compute average
    NSLog(@"%d durations -> Max: %d - Sum: %d", (int)[durations count], maxDuration, sum);
    float avgDuration = ([durations count] > 0) ? sum / (int)[durations count] : 0;
    
    [formatter setDateFormat:@"EEE, d MMM"];
    // Update views
    [self.workoutNameLabel setText:workout.name];
    [self.lastPlayLabel setText:[formatter stringFromDate:((Session *)[sessions lastObject]).when]];
    [self.avgDurationLabel setText:[Constants secondsToHhMmSs:avgDuration]];
    [self.maxDurationLabel setText:[Constants secondsToHhMmSs:maxDuration]];
    [self setupChartWithAvg:avgDuration];
    [self populateChartWithValuesForAxisX:days axisY:durations];
}



#pragma mark - Private methods

- (void)populateChartWithValuesForAxisX:(NSArray *)xValues axisY:(NSArray *)yValues {
    /*NSMutableArray *xVals = [NSMutableArray new];
    NSMutableArray *yVals = [NSMutableArray new];
    
    for (Session *s in sessions) {
        [xVals addObject:[@(i) stringValue]];
    }

    
    for (int i = 0; i < count; i++)
    {
        double mult = (range + 1);
        double val = (double) (arc4random_uniform(mult)) + 3;
        [yVals addObject:[[ChartDataEntry alloc] initWithValue:val xIndex:i]];
    }*/
    
    LineChartDataSet *set = [[LineChartDataSet alloc] initWithYVals:yValues label:@"DataSet 1"];
    
    /*
     LineDataSet dataset = new LineDataSet(entries, null);
     +        dataset.setColor(mContext.getResources().getColor(R.color.accent));
     +        dataset.setDrawCubic(true);
     +        dataset.setCircleColor(mContext.getResources().getColor(R.color.accent));
     +        dataset.setDrawCircleHole(false);
     +        dataset.disableDashedLine();
     +        dataset.setCubicIntensity(10);
     +        dataset.setDrawValues(false);
     +
     +        LineData data = new LineData(xVals, dataset);
     +
     +        holder.chart.getLegend().setEnabled(false);
     +        holder.chart.setDrawGridBackground(false);
     +        holder.chart.setDescription(null);
     +        holder.chart.setData(data);
     */
//    set.lineDashLengths = @[@5.f, @2.5f];
    [set setDrawCubicEnabled:YES];
    [set setColor:[UIColor orangeColor]];
    [set setCircleColor:[UIColor orangeColor]];
    [set setDrawCircleHoleEnabled:NO];
    // TODO format duration (Y axis) label to show it
    [set setDrawValuesEnabled:NO];
    
    set.lineWidth = 1.0;
    set.circleRadius = 3.0;
    
    set.valueFont = [UIFont systemFontOfSize:9.f];
    set.fillAlpha = 65/255.0;
    set.fillColor = UIColor.blackColor;
    
    LineChartData *data = [[LineChartData alloc] initWithXVals:xValues dataSets:@[set]];
    
    _chartView.data = data;
}

- (void)setupChartWithAvg:(int)avgValue {
    
    _chartView.delegate = self;
    _chartView.backgroundColor = [UIColor clearColor];
    
    _chartView.descriptionText = @"";
    _chartView.noDataTextDescription = @"No session data.";
    
    _chartView.dragEnabled = YES;
    [_chartView setScaleEnabled:YES];
    _chartView.pinchZoomEnabled = NO;
    [_chartView setDrawGridBackgroundEnabled:NO];
    
    // Scale Y axis according to average value
    [_chartView.leftAxis setCustomAxisMax:avgValue * 2];
//    [_chartView.leftAxis setCustomAxisMin:0.0];
//    [_chartView setAutoScaleMinMaxEnabled:NO];
//    leftAxis.startAtZeroEnabled = YES;
    
    // Disable axis an legend
    [_chartView.rightAxis setEnabled:NO];
    [_chartView.leftAxis setEnabled:NO];
    // leftAxis.labelCount = (int)yMax / 30 + 1;
    [_chartView.legend setEnabled:NO];
    
    // Animate data addition
    [_chartView animateWithXAxisDuration:1.5 easingOption:ChartEasingOptionEaseInOutQuart];
}

@end
