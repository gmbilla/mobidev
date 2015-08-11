//
//  HomeViewController.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 31/07/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "HomeViewController.h"
#import "User.h"


@interface HomeViewController ()

@end

@implementation HomeViewController {
    User *user;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Fetch current logged in user if any
    user = [User fetchCurrentUser];
    NSLog(@"Current user: %@", user);
}

- (void)viewWillAppear:(BOOL)animated {
    // Style tab bar
    NSLog(@"tabBarItem: %@", self.tabBarItem.title);
    
    NSLog(@"tabBar tint color: %@", self.tabBar.tintColor);
    self.tabBar.tintColor = [UIColor orangeColor];
    
    UIImage *selectedImage = self.tabBar.selectedItem.image;
    self.tabBar.selectedItem.image = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    for (UITabBarItem *item in self.tabBar.items) {
        NSLog(@"%@: %@", item.title, item.image);
    }
}

- (void)viewDidAppear:(BOOL)animated {
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
