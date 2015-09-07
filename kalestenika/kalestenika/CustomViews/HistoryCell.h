//
//  HistoryCell.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 07/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Session, HCSStarRatingView;

static NSString *const kHistoryCellId = @"HistoryCell";

@interface HistoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *workoutNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *completionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *placeImage;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;

- (void)populateFromSession:(Session *)session;

@end
