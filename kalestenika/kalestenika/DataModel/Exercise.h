//
//  Exercise.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 03/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ApiDelegate.h"


static NSString *const KeyName = @"name";
static NSString *const IdRest = @"Rest";

@interface Exercise : NSManagedObject <ApiDelegate>

@property (nonatomic, retain) NSString * exerciseDescription;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * requirement;
@property (nonatomic, retain) NSNumber * estimatedDuration;

+ (NSArray *)fetchAll;

@end
