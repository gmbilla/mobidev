//
//  Session.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 07/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "Session.h"
#import "Place.h"
#import "User.h"
#import "Workout.h"


@implementation Session

@dynamic when;
@dynamic duration;
@dynamic completion;
@dynamic rank;
@dynamic workout;
@dynamic user;
@dynamic place;

/*- (void)setRankFromInt:(NSInteger)rank {
    self.rank = @(rank == RankVeryBad ? VERY_BAD : rank == RankBad ? BAD : rank == RankNormal ? NORMAL : rank == RankGood ? GOOD : VERY_GOOD);
    
    NSLog(@"Setting rank to %@ (%d)", self.rank, (int)rank);
}*/

@end
