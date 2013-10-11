//
//  LRFacebookProtocols.h
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-11.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

// Wraps an Open Graph object (of type "scrumps:meal") that has just two properties,
// an ID and a URL. The FBGraphObject allows us to create an FBGraphObject instance
// and treat it as an SCOGMeal with typed property accessors.
@protocol LRLiveShow<FBGraphObject>

// @property (retain, nonatomic) NSString        *id;
@property (retain, nonatomic) NSString *url;

@end

// Wraps an Open Graph object (of type "scrumps:eat") with a relationship to a meal,
// as well as properties inherited from FBOpenGraphAction such as "place" and "tags".
@protocol LRWatchVideoAction<FBOpenGraphAction>

@property (retain, nonatomic) id<LRLiveShow> live_show;

@end
