//
//  Storable.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 08/08/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

@protocol Storable <NSObject>

/**
 * Name of the entity model
 */
- (NSString *)entityName;
/**
 * List of entity attributes name
 */
- (NSArray *)entityAttributes;

@end