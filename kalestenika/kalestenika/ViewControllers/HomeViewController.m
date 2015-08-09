//
//  HomeViewController.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 31/07/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
