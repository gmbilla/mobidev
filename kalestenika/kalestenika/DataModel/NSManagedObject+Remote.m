//
//  NSManagedObject+Remote.m
//  kalestenika
//
//  Created by Gian Marco Sibilla on 03/09/15.
//  Copyright (c) 2015 Gian Marco Sibilla. All rights reserved.
//

#import "NSManagedObject+Remote.h"
#import "NSManagedObject+Local.h"
#import "ApiDelegate.h"


static NSString *const BaseApiURL = @"https://kalestenika.appspot.com/_ah/api/kalestenika/v1";

@implementation NSManagedObject (Remote)

+ (void)fetchAsync:(void (^)(NSArray *))callback {
    // TODO add error to callback
    
    // Check if requesting entity conforms to required protocol
    if (![self conformsToProtocol:@protocol(ApiDelegate)]) {
        NSLog(@"Entity %@ doesn't conforms to ApiDelegate protocol!", [self entityName]);
        
        if (callback)
            callback(nil);
        
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/list", BaseApiURL, [[self entityName] lowercaseString]];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    NSLog(@"Requesting %@", urlString);
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"There was and error while fetching: %@", connectionError);
        } else {
            NSLog(@"Parsing response");
            NSError *error;
            NSDictionary *parsed = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSArray *items = nil;
            
            if (error) {
                NSLog(@"Error parsing JSON response: %@", error);
            } else {
                items = [parsed valueForKey:@"items"];
            }
            
            NSLog(@"Parsed %lu entities: Done.", (unsigned long)[items count]);
            if (callback)
                callback(items);
        }
    }];
}

@end
