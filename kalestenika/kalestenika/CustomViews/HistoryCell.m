//
//  HistoryCell.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 07/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "HistoryCell.h"
#import "HCSStarRatingView.h"
#import "Constants.h"
#import "Session.h"
#import "Workout.h"


@implementation HistoryCell

- (void)populateFromSession:(Session *)session {
    [self.workoutNameLabel setText:session.workout.name];
    [self.durationLabel setText:[Constants secondsToHhMmSs:session.duration.intValue]];
    [self.completionLabel setText:[NSString stringWithFormat:@"%@%%", session.completion.stringValue]];
    // Change completion text color for 100%
    if (session.completion.intValue == 100)
        [self.completionLabel setTextColor:[UIColor orangeColor]];
    else
        [self.completionLabel setTextColor:[UIColor lightGrayColor]];
    self.ratingView.value = session.rank.floatValue;
    
    // Change marker tint according to defined place
    if (session.place)
        [self.placeImage setTintColor:[UIColor orangeColor]];
    else
        [self.placeImage setTintColor:[UIColor lightGrayColor]];
}

@end
