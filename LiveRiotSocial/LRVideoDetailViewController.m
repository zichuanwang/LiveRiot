//
//  LRVideoDetailViewController.m
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-3.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "LRVideoDetailViewController.h"
#import "RDActivityViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "LRFacebookLoginViewController.h"

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
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose a share method" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use Social.framework", @"Use Facebook SDK", nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        RDActivityViewController *vc = [[RDActivityViewController alloc] initWithDelegate:self];
        vc.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll, UIActivityTypeCopyToPasteboard, UIActivityTypeMessage, UIActivityTypeMail, UIActivityTypeAirDrop];
        [self presentViewController:vc animated:YES completion:nil];
    } else if (buttonIndex == 1) {
        [LRFacebookLoginViewController showInViewController:self];
        // id image = @"https://fbcdn-photos-a.akamaihd.net/photos-ak-snc7/v85005/200/233936543368280/app_1_233936543368280_595563194.gif";
        // Create an Open Graph eat action with the meal, our location, and the people we were with.
//        id<SCOGEatMealAction> action = [self actionFromMealInfo];
//        
//        if (self.selectedPhoto) {
//            self.selectedPhoto = [self normalizedImage:self.selectedPhoto];
//            action.image = self.selectedPhoto;
//            image = @[@{@"url":self.selectedPhoto, @"user_generated":@"true"}];
//        }
//        
//        id object = [FBGraphObject openGraphObjectForPostWithType:@"fb_sample_scrumps:meal"
//                                                            title:self.selectedMeal
//                                                            image:image
//                                                              url:nil
//                                                      description:[@"Delicious " stringByAppendingString:self.selectedMeal]];
//        action.meal = object;
//        
//        BOOL presentable = nil != [FBDialogs presentShareDialogWithOpenGraphAction:action
//                                                                        actionType:@"fb_sample_scrumps:eat"
//                                                               previewPropertyName:@"meal"
//                                                                           handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//                                                                               if (!error) {
//                                                                                   [self resetMealInfo];
//                                                                               } else {
//                                                                                   NSLog(@"%@", error);
//                                                                               }
//                                                                           }];
    }
}

#pragma mark - RDActivityViewControllerDelegate

- (NSArray *)activityViewController:(NSArray *)activityViewController itemsForActivityType:(NSString *)activityType {
    NSString *defaultText = [NSString stringWithFormat:@"Check this out! http://youtu.be/jXhdX9r-fi4"];
    UIImage *defaultImage = [UIImage imageNamed:@"livemusic.jpg"];
    return @[defaultText, defaultImage];
}

@end
