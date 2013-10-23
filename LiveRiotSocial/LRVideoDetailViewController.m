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

@interface LRVideoDetailViewController () <UIActionSheetDelegate, RDActivityViewControllerDelegate>

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
	// Do any additional setup after loading the view.
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
        [LRFacebookShareViewController showInViewController:self];
    } else if (buttonIndex == 2) {
        SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - RDActivityViewControllerDelegate

- (NSArray *)activityViewController:(NSArray *)activityViewController itemsForActivityType:(NSString *)activityType {
    NSString *defaultText = [NSString stringWithFormat:@"Check this out! http://youtu.be/jXhdX9r-fi4"];
    UIImage *defaultImage = [UIImage imageNamed:@"livemusic.jpg"];
    return @[defaultText, defaultImage];
}

@end
