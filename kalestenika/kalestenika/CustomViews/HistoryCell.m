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
#import "Place.h"


@implementation HistoryCell

- (void)populateFromSession:(Session *)session {
    [self.workoutNameLabel setText:session.workout.name];
    [self.durationLabel setText:[Constants secondsToHhMmSs:session.duration.intValue]];
    
    [self.completionLabel setText:[NSString stringWithFormat:@"%@%%", session.completion.stringValue]];
    // Change completion text color for 100%
    [self.completionLabel setTextColor:100 == session.completion.intValue ? [UIColor orangeColor] : [UIColor lightGrayColor]];

    // Set rating
    [self.ratingView setValue:session.rank.floatValue];
    [self.ratingView setTintColor:RankNone != session.rank.intValue ? [UIColor orangeColor] : [UIColor lightGrayColor]];
    
    // Change marker tint according to defined place
    [self.placeImage setImage:[self.placeImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self.placeImage setTintColor:session.place ? [UIColor orangeColor] : [UIColor lightGrayColor]];
}

@end
