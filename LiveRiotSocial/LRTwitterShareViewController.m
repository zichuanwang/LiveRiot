//
//  LRTwitterShareViewController.m
//  LiveRiotSocial
//
//  Created by Haoyu Huang on 10/28/13.
//  Copyright (c) 2013 LiveRiot. All rights reserved.
//

#import "LRTwitterShareViewController.h"
#import "CRNavigationController.h"
#import "FHSTwitterEngine.h"
#import "Social/SLComposeViewController.h"
#import "Social/SLServiceTypes.h"


@interface LRTwitterShareViewController () <FHSTwitterEngineAccessTokenDelegate, UIAlertViewDelegate>

@end

@implementation LRTwitterShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (void)showInViewController:(UIViewController *)viewController {
    LRTwitterShareViewController *loginViewController = [[LRTwitterShareViewController alloc] init];
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
    
    // twitter engine setup
    [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:@"Sh5JfGh1T74hpE8lh35Rhg" andSecret:@"YAEI63uVUqwCw1cDlVFdocPfbBGedYAYD3odDYO8fOo"];
    [[FHSTwitterEngine sharedEngine]setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [[FHSTwitterEngine sharedEngine]loadAccessToken];
    NSString* userName = [[FHSTwitterEngine sharedEngine]loggedInUsername];
    if (userName.length > 0) {
        // display the loggedIn UserName in the textView
//        [_textView setText:userName];
//        [_textView setTextColor:[UIColor lightGrayColor]];
    } else {
        // user needs to log in twitter by OAuth,
        // due to the fact that user may use built-in twitter account, display no text here for now.
//        [_textView setText:@""];
//        [_textView setTextColor:[UIColor lightGrayColor]];
    }
}

// clear text when begin editing
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    textView.text=@"";
    _textView.textColor = [UIColor blackColor];
    return YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark - Logic

#pragma mark - UI

- (void) configureNavigationBar {
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:234 / 255. green:82/255. blue:81/255. alpha:1.];
    self.navigationItem.title = @"Share to Twitter";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(didClickCancelButton:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleBordered target:self action:@selector(didClickPostButton:)];
}

#pragma mark - Action

- (void)didClickCancelButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didClickPostButton:(UIButton *)sender {
    
    if ([[FHSTwitterEngine sharedEngine]isAuthorized] == YES) {
        // the access token is authorzied
        [self postTweets];
    } else {
        // the access token is not existed or invalid, authenticate user with OAuth
        [[FHSTwitterEngine sharedEngine]showOAuthLoginControllerFromViewController:self withCompletion:^(BOOL success) {
            NSLog(success?@"Twitter OAuth Login success":@"Twitter OAuth Loggin Failed");
            if (success == YES) {
                [self postTweets];
                
            }
        }];
    }
}

#pragma mark - Twitter

- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}

// Post tweets to Twitter after OAuth success
- (void) postTweets {
    [_textView resignFirstResponder];
    
    dispatch_async(GCDBackgroundThread, ^{
        @autoreleasepool {
            NSString* tweet = self.textView.text;
            // append the twitter photo card link to the tweet
            tweet = [tweet stringByAppendingString:@" http://greenbay.usc.edu/csci577/fall2013/projects/team04/twittercard.html"];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            NSError *returnCode = [[FHSTwitterEngine sharedEngine]postTweet:tweet];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            NSString *title = nil;
            NSString *message = nil;
            
            if (returnCode) {
                title = [NSString stringWithFormat:@"Error %d",returnCode.code];
                message = returnCode.localizedDescription;
            } else {
                title = @"Tweet Posted";
                message = _textView.text;
            }
            
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    UIAlertView *av = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [av show];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            });
        }
    });
}


@end
