//
//  LRVideoDetailViewController.h
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-3.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface LRVideoDetailViewController : UIViewController

//@property (weak, nonatomic) IBOutlet UIWebView *videoWebView;
@property (nonatomic, strong) MPMoviePlayerController *videoPlayer;
@property (nonatomic, weak) IBOutlet UIView *videoView;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *avatarImageName;
@property (nonatomic, copy) NSString *previewImageName;
@property (nonatomic, copy) NSString *videoLink;
@property (nonatomic, copy) NSString *timeString;

@end
