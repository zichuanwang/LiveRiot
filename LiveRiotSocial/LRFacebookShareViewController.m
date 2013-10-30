//
//  LRFacebookShareViewController.m
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-11.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "LRFacebookShareViewController.h"
#import "LRFacebookLoginViewController.h"
#import "CRNavigationController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "LRFacebookProtocols.h"

@interface LRFacebookShareViewController ()

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UIImageView *shareImageView;

@property (nonatomic, copy) NSString *shareLink;
@property (nonatomic, copy) NSString *shareImageName;

@end

@implementation LRFacebookShareViewController

+ (void)showInViewController:(UIViewController *)viewController
                   shareLink:(NSString *)shareLink
              shareImageName:(NSString *)imageName {
    
    LRFacebookShareViewController *loginViewController = [[LRFacebookShareViewController alloc] init];
    loginViewController.shareLink = shareLink;
    loginViewController.shareImageName = imageName;
    
    CRNavigationController *nav = [[CRNavigationController alloc] initWithRootViewController:loginViewController];
    [viewController presentViewController:nav animated:YES completion:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configureNavigationBar];
    [self.textView becomeFirstResponder];
    self.textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    self.shareImageView.image = [UIImage imageNamed:self.shareImageName];
}

- (BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
}

#pragma mark - Handle notification

- (void)handleKeyboardWillShowNotification:(NSNotification*)notification {
    UIEdgeInsets insets = self.textView.contentInset;
    insets.bottom += [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self.textView.contentInset = insets;
    
    insets = self.textView.scrollIndicatorInsets;
    insets.bottom += [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self.textView.scrollIndicatorInsets = insets;
}

- (void)handleKeyboardWillHideNotification:(NSNotification*)notification {
    UIEdgeInsets insets = self.textView.contentInset;
    insets.bottom -= [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    self.textView.contentInset = insets;
    
    insets = self.textView.scrollIndicatorInsets;
    insets.bottom -= [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    self.textView.scrollIndicatorInsets = insets;
}

#pragma mark - UITextFiledDelegate 

//- (void)textViewDidBeginEditing:(UITextView *)textView {
//    _oldRect = [self.textView caretRectForPosition:self.textView.selectedTextRange.end];
//    
//    _caretVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(_scrollCaretToVisible) userInfo:nil repeats:YES];
//}m
//
//- (void)textViewDidEndEditing:(UITextView *)textView {
//    [_caretVisibilityTimer invalidate];
//    _caretVisibilityTimer = nil;
//}
//
//- (void)_scrollCaretToVisible {
//    //This is where the cursor is at.
//    CGRect caretRect = [self.textView caretRectForPosition:self.textView.selectedTextRange.end];
//    
//    if(CGRectEqualToRect(caretRect, _oldRect))
//        return;
//    
//    _oldRect = caretRect;
//    
//    //This is the visible rect of the textview.
//    CGRect visibleRect = self.textView.bounds;
//    visibleRect.size.height -= (self.textView.contentInset.top + self.textView.contentInset.bottom);
//    visibleRect.origin.y = self.textView.contentOffset.y;
//    
//    //We will scroll only if the caret falls outside of the visible rect.
//    if(!CGRectContainsRect(visibleRect, caretRect))
//    {
//        CGPoint newOffset = self.textView.contentOffset;
//        
//        newOffset.y = MAX((caretRect.origin.y + caretRect.size.height) - visibleRect.size.height + 5, 0);
//        
//        [self.textView setContentOffset:newOffset animated:YES];
//    }
//}

#pragma mark - Logic

#pragma mark - UI

- (void)configureNavigationBar {
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:234 / 255. green:82 / 255. blue:81 / 255. alpha:1.];
    
    self.navigationItem.title = @"Share to Facebook";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(didClickCancelButton:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleBordered target:self action:@selector(didClickPostButton:)];
}

#pragma mark - Action

- (void)didClickCancelButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didClickPostButton:(UIButton *)sender {
    if (FBSession.activeSession.isOpen) {
        // Facebook SDK * pro-tip *
        // Ask for publish permissions only at the time they are needed.
        if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
            [self requestPermissionAndPost];
        } else {
            [self postOpenGraphAction];
        }
    } else {
        // Facebook SDK * pro-tip *
        // Support sharing even if the user isn't logged in with Facebook, by using the share dialog
        [self presentShareDialogForVideoInfo];
    }
}

- (void)requestPermissionAndPost {
    [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                          defaultAudience:FBSessionDefaultAudienceFriends
                                        completionHandler:^(FBSession *session, NSError *error) {
                                            if (!error && [FBSession.activeSession.permissions indexOfObject:@"publish_actions"] != NSNotFound) {
                                                // Now have the permission
                                                [self postOpenGraphAction];
                                            } else if (error){
                                                // Facebook SDK * error handling *
                                                // if the operation is not user cancelled
                                                if (error.fberrorCategory != FBErrorCategoryUserCancelled) {
                                                    [self presentAlertForError:error];
                                                }
                                            }
                                        }];
}

- (void)presentAlertForError:(NSError *)error {
    // Facebook SDK * error handling *
    // Error handling is an important part of providing a good user experience.
    // When fberrorShouldNotifyUser is YES, a fberrorUserMessage can be
    // presented as a user-ready message
    if (error.fberrorShouldNotifyUser) {
        // The SDK has a message for the user, surface it.
        [[[UIAlertView alloc] initWithTitle:@"Something Went Wrong"
                                    message:error.fberrorUserMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    } else {
        NSLog(@"unexpected error:%@", error);
    }
}

// Creates the Open Graph Action.
- (void)postOpenGraphAction {
    
    FBRequestConnection *requestConnection = [[FBRequestConnection alloc] init];
    requestConnection.errorBehavior = FBRequestConnectionErrorBehaviorRetry
    | FBRequestConnectionErrorBehaviorReconnectSession;
//    if (self.selectedPhoto) {
//        self.selectedPhoto = [self normalizedImage:self.selectedPhoto];
//        FBRequest *stagingRequest = [FBRequest requestForUploadStagingResourceWithImage:self.selectedPhoto];
//        [requestConnection addRequest:stagingRequest
//                    completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                        if (error) {
//                            [self enableUserInteraction:YES];
//                            [self handlePostOpenGraphActionError:error];
//                        }
//                    }
//                       batchEntryName:@"stagedphoto"];
//    }
    
    // Create an Open Graph eat action with the meal, our location, and the people we were with.
    id<LRLiveShow> video = (id<LRLiveShow>)[FBGraphObject graphObject];
    video.url = self.shareLink;
    
    id<LRWatchVideoAction> action = (id<LRWatchVideoAction>)[FBGraphObject graphObject];
    action.live_show = video;
    if (self.textView.text.length > 0)
        action.message = self.textView.text;
    [(NSMutableDictionary *)action setValue:@"true" forKey:@"fb:explicitly_shared"];

    // Create the request and post the action to the "me/fb_sample_scrumps:eat" path.
    FBRequest *actionRequest = [FBRequest requestForPostWithGraphPath:@"me/liveriot:share"
                                                          graphObject:action];
    
    [requestConnection addRequest:actionRequest
                completionHandler:^(FBRequestConnection *connection,
                                    id result,
                                    NSError *error) {
                    
                    if (!error) {
                        [self dismissViewControllerAnimated:YES completion:^{
                            [[[UIAlertView alloc] initWithTitle:@"Result"
                                                        message:[NSString stringWithFormat:@"Posted Open Graph action, id: %@",
                                                                 [result objectForKey:@"id"]]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil]
                             show];
                        }];
                    } else {
                        [self handlePostOpenGraphActionError:error];
                    }
                }];
    [requestConnection start];
}

- (void)handlePostOpenGraphActionError:(NSError *) error {
    // Facebook SDK * error handling *
    [self presentAlertForError:error];
}


- (void)presentShareDialogForVideoInfo {
    id liveShow = [FBGraphObject openGraphObjectForPostWithType:@"liveriot:live_show"
                                                        title:@"Amazing live music"
                                                        image:nil
                                                          url:self.shareLink
                                                  description:[@"Description " stringByAppendingString:@"test."]];
    
    id<LRWatchVideoAction> action = (id<LRWatchVideoAction>)[FBGraphObject graphObject];
    action.live_show = liveShow;
    
    BOOL presentable = nil != [FBDialogs presentShareDialogWithOpenGraphAction:action
                                                                    actionType:@"liveriot:share"
                                                           previewPropertyName:@"live_show"
                                                                       handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                                           if (!error) {
                                                                               [self dismissViewControllerAnimated:YES completion:^{
                                                                                   [[[UIAlertView alloc] initWithTitle:@"Result"
                                                                                                               message:[NSString stringWithFormat:@"Posted Open Graph action, id: %@", [results objectForKey:@"id"]]
                                                                                                              delegate:nil
                                                                                                     cancelButtonTitle:@"OK"
                                                                                                     otherButtonTitles:nil]
                                                                                    show];
                                                                               }];
                                                                           } else {
                                                                               NSLog(@"%@", error);
                                                                               [[[UIAlertView alloc] initWithTitle:@"Failure"
                                                                                                           message:[NSString stringWithFormat:@"%@", error]
                                                                                                          delegate:nil
                                                                                                 cancelButtonTitle:@"I See"
                                                                                                 otherButtonTitles:nil]
                                                                                show];
                                                                           }
                                                                       }];
    
    if (!presentable) {
        NSLog(@"Can not present Facebook share dialog.");
        [LRFacebookLoginViewController showInViewController:self];
    }
}

@end
