//
//  LRTumblrShareViewController.m
//  LiveRiotSocial
//
//  Created by Gabriel Yeah on 13-10-30.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "LRTumblrShareViewController.h"
#import "CRNavigationController.h"
#import "TMAPIClient.h"

@interface LRTumblrShareViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation LRTumblrShareViewController

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
  [self configureNavigationBar];
  [self.textView becomeFirstResponder];
  
  self.textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
  // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

+ (void)showInViewController:(UIViewController *)viewController {
  LRTumblrShareViewController *loginViewController = [[LRTumblrShareViewController alloc] init];
  CRNavigationController *nav = [[CRNavigationController alloc] initWithRootViewController:loginViewController];
  [viewController presentViewController:nav animated:YES completion:nil];
}

- (void)configureNavigationBar {
  self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:234 / 255. green:82 / 255. blue:81 / 255. alpha:1.];
  
  self.navigationItem.title = @"Share to Tumblr";
  
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(didClickCancelButton:)];
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleBordered target:self action:@selector(didClickPostButton:)];
}

- (void)didClickCancelButton:(UIButton *)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didClickPostButton:(UIButton *)sender {
  NSLog(@"token %@", [TMAPIClient sharedInstance].OAuthToken);
  NSLog(@"key %@", [TMAPIClient sharedInstance].OAuthTokenSecret);
  [[TMAPIClient sharedInstance] link:@"Video"
                          parameters:@{@"url": @"http:\\/\\/greenbay.usc.edu\\/csci577\\/fall2013\\/projects\\/team04\\/website\\/video001",
                                       @"title" : @"Video",
                                       @"description" : @"This is a video page!"}
                            callback:^(id a, NSError *error) {
                              if (!error) {
                                NSLog(@"Succeed");
                              } else {
                                NSLog(@"Failure");
                              }
                            }];
}

@end
