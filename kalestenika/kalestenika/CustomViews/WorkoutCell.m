//
//  WorkoutCell.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 31/07/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "WorkoutCell.h"

@implementation WorkoutCell

- (instancetype)initWithFrame:(CGRect)frame {
    NSLog(@"initWithFrame");
    
    self = [super initWithFrame:frame];
    [self.nameLabel setText:@"nameLabel"];
    [self.exerciseNrLabel setText:@"exerciseNrLabel"];
    
    [self setBackgroundColor:[UIColor purpleColor]];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSLog(@"initWithCoder");
    return [super initWithCoder:aDecoder];
}

@end
