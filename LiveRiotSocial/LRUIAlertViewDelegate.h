//
//  LRUIAlertView.h
//  LiveRiotSocial
//
//  Created by Haoyu Huang on 11/5/13.
//  Copyright (c) 2013 LiveRiot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LRUIAlertViewDelegate : NSObject<UIAlertViewDelegate>

typedef void (^AlertViewCompletionBlock) (NSInteger buttonIndex);

@property(strong, nonatomic) AlertViewCompletionBlock callback;

+ (void) showAlertView:(UIAlertView*)alertView withCallback:(AlertViewCompletionBlock)callback;

@end
