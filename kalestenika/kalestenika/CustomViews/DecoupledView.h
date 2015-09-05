//
//  DecoupledView.h
//  kalestenika
//
//  Created by Gian Marco Sibilla on 13/08/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DecoupledView;

/**
 * Protocol that introduces the view's features to the controller, and assure 
 * the view that controller will respond to it’s messages,
 */
@protocol DecoupledViewDelegate

-(void)decoupledViewTouchedUp:(DecoupledView*) decoupledView;
-(void)decoupledViewDidDismiss:(DecoupledView*) decoupledView;

@end


/**
 * Helper class to allow automatic loading of UIViews defined in a XIB file
 */
@interface DecoupledView : UIView

// Indicate that this view should be presented only controllers those implements the delegate methods.
+(void)presentInViewController:(UIViewController<DecoupledViewDelegate>*) viewController;
-(IBAction)viewTouchedUp;
-(IBAction)dismiss;

@end
