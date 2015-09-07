//
//  Session.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 07/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


#define VERY_BAD "VERY_BAD"
#define BAD "BAD"
#define NORMAL "NORMAL"
#define GOOD "GOOD"
#define VERY_GOOD "VERY_GOOD"

@class Place, User, Workout;

typedef NS_ENUM(NSInteger, Rank) {
    RankVeryBad, RankBad, RankNormal, RankGood, RankVeryGood
};

static NSString *const kSessionWhen = @"when";

@interface Session : NSManagedObject

@property (nonatomic, retain) NSDate *when;
@property (nonatomic, retain) NSNumber *duration;
@property (nonatomic, retain) NSNumber *completion;
@property (nonatomic, retain) NSNumber *rank;
@property (nonatomic, retain) Workout *workout;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Place *place;

@end
