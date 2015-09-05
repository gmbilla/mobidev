//
//  WaitingData.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 05/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * When presenting a view controller from which the current view expects some data it can implement this protocol to be called back when the presented VC is dismissed.
 */
@protocol WaitingData <NSObject>

/**
 * Returns a list of objects to the caller VC.
 */
- (void)sendBackData:(NSArray *)items;

@end
