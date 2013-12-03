//
//  LRVideoDetailViewController.m
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-3.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "LRVideoDetailViewController.h"
#import "LRShareViewController.h"

@interface LRVideoDetailViewController () <UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;

@end

@implementation LRVideoDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSURL *ytvideo = [NSURL URLWithString:@"https://s3.amazonaws.com/lr-chaos/videos/files/000/000/548/original/sd_Hands-Elegant-Road-04-22-13.mp4"];
        _videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:ytvideo];
        [_videoPlayer prepareToPlay];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.title;
    self.timeLabel.text = self.timeString;
    self.titleLabel.text = self.title;
    self.avatarImageView.image = [UIImage imageNamed:self.avatarImageName];
    
    //NSString *embedHTML = @"<html><body><iframe width=\"320\" height=\"240\" src=\"embed/5KsabeJ1UEk\" frameborder=\"0\" allowfullscreen></iframe></body></html>";
    
    /*for (UIView *view in self.videoWebView.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)view).scrollEnabled = NO;
        }
    }*/
    NSURL *ytvideo = [NSURL URLWithString:@"https://s3.amazonaws.com/lr-chaos/videos/files/000/000/548/original/sd_Hands-Elegant-Road-04-22-13.mp4"];
    _videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:ytvideo];
    [_videoPlayer prepareToPlay];
    
    [_videoPlayer.view setFrame:_videoView.bounds];
    [_videoView addSubview:_videoPlayer.view];
    
    //NSURL *ytVideo = [NSURL URLWithString:@"http://greenbay.usc.edu/csci577/fall2013/projects/team04/EmbedVideo.html"];
    //NSURLRequest *requestObj = [NSURLRequest requestWithURL:ytVideo];
    //self.videoWebView.allowsInlineMediaPlayback = true;
    //[self.videoWebView loadRequest:requestObj];
    //[_videoView loadHTMLString:embedHTML baseURL:[NSURL URLWithString:@"http://www.youtube.com/"]];
    //[self.view addSubview:_videoView];
    
    [_videoPlayer play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)didClickActionButton:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose a share method"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Share to Facebook", @"Share to Twitter", @"Share to Tumblr", nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [LRShareViewController showInViewController:self shareLink:self.videoLink shareImageName:self.previewImageName socialNetworkType:(SocialNetworkType)buttonIndex];
}

@end
