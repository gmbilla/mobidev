//
//  HomeViewController.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 31/07/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "MainViewController.h"
#import "User.h"


@interface MainViewController ()

@end

@implementation MainViewController {
    User *user;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    // Set UITabBar tint color to orange
    self.tabBar.tintColor = [UIColor orangeColor];
}

- (void)viewDidAppear:(BOOL)animated {
    // Fetch current logged in user if any
    user = [User fetchCurrentUser];
    NSLog(@"Current user: %@", user);
    
    if (user == nil) {
        // User must login, show login modal
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];
    }
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

@end
