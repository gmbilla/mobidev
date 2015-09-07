//
//  HomeViewController.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 12/08/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "DashboardViewController.h"
#import "ProgressViewController.h"
#import "HistoryViewController.h"


@interface DashboardViewController ()

@end

@implementation DashboardViewController {
    UIViewController *currentViewController;
    NSArray *segmentsViewControllers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
//    segmentsViewControllers = @[[sb instantiateViewControllerWithIdentifier:@"TestVC"], [ProgressViewController new], [HistoryViewController new]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    segmentsViewControllers = @[[ProgressViewController new], [storyboard instantiateViewControllerWithIdentifier:kHistoryViewControllerId]];
    NSLog(@"VC list created");
    
    [self swapVCWithIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IB Actions

- (IBAction)segmentedControlAction:(UISegmentedControl *)sender {
    long selected = self.homeSegmentedControl.selectedSegmentIndex;
    
    NSLog(@"Swapping with segment %lu", selected);
    [self swapVCWithIndex:selected];
}

# pragma mark - Private methods

- (void)swapVCWithIndex:(long)index {
    UIViewController *viewController = segmentsViewControllers[index];
    
    //0. Remove the current Detail View Controller showed
    if(currentViewController){
        //1. Call the willMoveToParentViewController with nil
        //   This is the last method where your detailViewController can perform some operations before neing removed
        [currentViewController willMoveToParentViewController:nil];
        
        //2. Remove the DetailViewController's view from the Container
        [currentViewController.view removeFromSuperview];
        
        //3. Update the hierarchy"
        //   Automatically the method didMoveToParentViewController: will be called on the detailViewController)
        [currentViewController removeFromParentViewController];
    }
    
    //1. Add the detail controller as child of the container
    [self addChildViewController:viewController];
    
    //2. Define the detail controller's view size
    viewController.view.frame = self.containerView.bounds;
    
    //3. Add the Detail controller's view to the Container's detail view and save a reference to the detail View Controller
    [self.containerView addSubview:viewController.view];
    currentViewController = viewController;
    
    //4. Complete the add flow calling the function didMoveToParentViewController
    [viewController didMoveToParentViewController:self];
}

/*
- (void)swapWithViewControllerAtIndex:(long)index{
    
    //1. The current controller is going to be removed
    [self.currentDetailViewController willMoveToParentViewController:nil];
    
    //2. The new controller is a new child of the container
    [self addChildViewController:viewController];
    
    //3. Setup the new controller's frame depending on the animation you want to obtain
    viewController.view.frame = CGRectMake(0, 2000, viewController.view.frame.size.width, viewController.view.frame.size.height);
    
    //The transition automatically removes the old view from the superview and attaches the new controller's view as child of the
    //container controller's view
    
    //Save the button position... we'll need it later
    CGPoint buttonCenter = self.button.center;
    
    [self transitionFromViewController:self.currentDetailViewController toViewController:viewController
                              duration:1.3 options:0
                            animations:^{
                                
                                //The new controller's view is going to take the position of the current controller's view
                                viewController.view.frame = self.currentDetailViewController.view.frame;
                                
                                //The current controller's view will be moved outside the window
                                self.currentDetailViewController.view.frame = CGRectMake(0,
                                                                                         -2000,
                                                                                         self.currentDetailViewController.view.frame.size.width,
                                                                                         self.currentDetailViewController.view.frame.size.width);
                                
                                self.button.center = CGPointMake(buttonCenter.x,1000);
                                
                                
                            } completion:^(BOOL finished) {
                                //Remove the old view controller
                                [self.currentDetailViewController removeFromParentViewController];
                                
                                //Set the new view controller as current
                                self.currentDetailViewController = viewController;
                                [self.currentDetailViewController didMoveToParentViewController:self];
                                
                                //reset the button position
                                [UIView animateWithDuration:0.5 animations:^{
                                    self.button.center = buttonCenter;
                                }];
                                
                            }];
}
*/
@end
