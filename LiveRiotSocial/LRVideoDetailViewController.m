//
//  LRVideoDetailViewController.m
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-3.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "LRVideoDetailViewController.h"
#import "RDActivityViewController.h"
#import "LRFacebookShareViewController.h"
#import <Social/Social.h>
#import "LRFriendShareViewController.h"
#import "FHSTwitterEngine.h"
#import "LRTwitterShareViewController.h"

@interface LRVideoDetailViewController () <UIActionSheetDelegate, RDActivityViewControllerDelegate, UIAlertViewDelegate>

// @property (nonatomic, weak)

@end

@implementation LRVideoDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSString *embedHTML = @"<html><body><iframe width=\"320\" height=\"240\" src=\"embed/5KsabeJ1UEk\" frameborder=\"0\" allowfullscreen></iframe></body></html>";
    
    NSURL *ytVideo = [NSURL URLWithString:@"http://greenbay.usc.edu/csci577/fall2013/projects/team04/EmbedVideo.html"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:ytVideo];
    _videoView.allowsInlineMediaPlayback = true;
    [_videoView loadRequest:requestObj];
    //[_videoView loadHTMLString:embedHTML baseURL:[NSURL URLWithString:@"http://www.youtube.com/"]];
    //[self.view addSubview:_videoView];
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
                                              otherButtonTitles:@"Share to Friends", @"Share to Facebook", @"Share to Twitter", nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
//        RDActivityViewController *vc = [[RDActivityViewController alloc] initWithDelegate:self];
//        vc.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll, UIActivityTypeCopyToPasteboard, UIActivityTypeMessage, UIActivityTypeMail, UIActivityTypeAirDrop];
//        [self presentViewController:vc animated:YES completion:nil];
        [LRFriendShareViewController showInViewController:self];
    } else if (buttonIndex == 1) {
        // Facebook share view
        [LRFacebookShareViewController showInViewController:self];
    } else if (buttonIndex == 2) {
        // Twitter share view
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter] == YES) {
            // the built-in twitter service is accessible and has at least one account set up
            [self postTweetByTwitterSheet];
        } else {
            [LRTwitterShareViewController showInViewController:self];
        }
    }
}

#pragma mark - FHSTwitterEngineAccessTokenDelegate

// post tweet by twitter sheet
- (void) postTweetByTwitterSheet {
    //  Create an instance of the Tweet Sheet
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    // Sets the completion handler.  Note that we don't know which thread the
    // block will be called on, so we need to ensure that any required UI
    // updates occur on the main queue
    tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone:
                break;
        }
    };
    // add the twitter photo card url to the tweet
    [tweetSheet addURL:[NSURL URLWithString:@"http://greenbay.usc.edu/csci577/fall2013/projects/team04/twittercard.html"]];
    //  Set the initial body of the Tweet
    [tweetSheet setInitialText:@""];
    
    //  Presents the Tweet Sheet to the user
    [self presentViewController:tweetSheet animated:NO completion:^{
        NSLog(@"Tweet sheet has been presented.");
    }];
}


#pragma mark - RDActivityViewControllerDelegate

- (NSArray *)activityViewController:(NSArray *)activityViewController itemsForActivityType:(NSString *)activityType {
    NSString *defaultText = [NSString stringWithFormat:@"Check this out! http://youtu.be/jXhdX9r-fi4"];
    UIImage *defaultImage = [UIImage imageNamed:@"livemusic.jpg"];
    return @[defaultText, defaultImage];
}

@end
