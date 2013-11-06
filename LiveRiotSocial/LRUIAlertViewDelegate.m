//
//  LRUIAlertView.m
//  LiveRiotSocial
//
//  Created by Haoyu Huang on 11/5/13.
//  Copyright (c) 2013 LiveRiot. All rights reserved.
//

#import "LRUIAlertViewDelegate.h"

@implementation LRUIAlertViewDelegate
@synthesize callback;

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    callback(buttonIndex);
}

+ (void) showAlertView:(UIAlertView*)alertView withCallback:(AlertViewCompletionBlock)callback {
    __block LRUIAlertViewDelegate *delegate = [[LRUIAlertViewDelegate alloc] init];
    alertView.delegate = delegate;
    delegate.callback = ^(NSInteger buttonIndex) {
        callback(buttonIndex);
        alertView.delegate = nil;
        #pragma clang diagnostic ignored "-Warc-retain-cycles"
        delegate = nil;
    };
    [alertView show];
}
@end
