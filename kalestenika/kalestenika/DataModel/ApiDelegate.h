//
//  ApiDelegate.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 03/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ApiDelegate <NSObject>

- (void)populateFromDictionary:(NSDictionary *)dictionary;

@end
