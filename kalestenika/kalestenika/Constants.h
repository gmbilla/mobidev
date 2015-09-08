//
//  Constants.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 31/07/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ColorTeal [UIColor colorWithRed:0.0/255 green:153.0/255 blue:153.0/255 alpha:1.0]
#define ColorGooglePlus [UIColor colorWithRed:211.0/255 green:72.0/255 blue:54.0/255 alpha:1.0]

@interface Constants : NSObject

+ (NSString *)addLeadingZero:(int)base60int;
+ (NSString *)secondsToHhMmSs:(int)seconds;
+ (NSString *)secondsToString:(int)seconds;
+ (NSDateFormatter *)weekDayFormatter;

@end