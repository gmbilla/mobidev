//
//  WorkoutViewController.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 31/07/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "TestWorkoutViewController.h"
#import "WorkoutCell.h"

@implementation TestWorkoutViewController

static NSString *const cellViewIdentifier = @"WorkoutCell";

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[WorkoutCell class]
           forCellReuseIdentifier:cellViewIdentifier];
}

# pragma UITableView delegate

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 5;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 240;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WorkoutCell *cell = [tableView dequeueReusableCellWithIdentifier:cellViewIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        // Is this piece of code ever called?!
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"WorkoutCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    [cell.titleLabel setText:[NSString stringWithFormat:@"Porco dio x%li", (long)[indexPath row]]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
