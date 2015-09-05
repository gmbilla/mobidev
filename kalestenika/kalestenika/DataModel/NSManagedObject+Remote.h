//
//  NSManagedObject+Remote.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 03/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Remote)

+ (void)fetchAsync:(void (^)(NSArray *))callback;

@end
