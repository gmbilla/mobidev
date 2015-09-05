//
//  DecoupledView.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 13/08/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "DecoupledView.h"


@interface DecoupledViewOwner : NSObject
@property (nonatomic, weak) IBOutlet DecoupledView *decoupledView;
@end

@implementation DecoupledViewOwner
@end


@interface DecoupledView ()

@property (nonatomic, weak) UIViewController<DecoupledViewDelegate> *delegateViewController;

@end


@implementation DecoupledView

+(void)presentInViewController:(UIViewController<DecoupledViewDelegate>*) viewController {
    // Instantiating encapsulated here.
    DecoupledViewOwner *owner = [DecoupledViewOwner new];
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([viewController class])
                                  owner:owner
                                options:nil];
    
    // Pass in a reference of the viewController.
    owner.decoupledView.delegateViewController = viewController;
    
    // Add (thus retain).
    [viewController.view addSubview:owner.decoupledView];
}

#pragma mark - View actions

-(IBAction)viewTouchedUp {
    // Forward to delegate
    [self.delegateViewController decoupledViewTouchedUp:self];
}

-(IBAction)dismiss {
    // Forward to delegate
    [self.delegateViewController decoupledViewDidDismiss:self];
}

@end
