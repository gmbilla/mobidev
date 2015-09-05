//
//  Constants.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 31/07/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "Constants.h"

@implementation Constants

+ (NSString *)secondsToString:(int)seconds {
    int min = (int)(seconds / 60);
    int sec = seconds % 60;
    return [NSString stringWithFormat:@"%@%@", min > 0 ? [NSString stringWithFormat:@" %dm", min] : @"", sec > 0 ? [NSString stringWithFormat:@" %ds", sec] : @""];
}

@end
