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
#import "NSUserDefaults+Addition.h"

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
  self.textView.text = @"Check it out!";
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

- (BOOL)automaticallyAdjustsScrollViewInsets {
  return NO;
}

- (void)didClickPostButton:(UIButton *)sender {
  NSLog(@"token %@", [TMAPIClient sharedInstance].OAuthToken);
  NSLog(@"key %@", [TMAPIClient sharedInstance].OAuthTokenSecret);
  NSLog(@"%@", [NSUserDefaults getTMLink]);
  
  NSString *content = self.textView.text;
  if (!content || [content isEqualToString:@""]) {
    content = @"Check it out!";
  }
  [[TMAPIClient sharedInstance] link:[NSUserDefaults getTMLink]
                          parameters:@{@"url":@"http:\\/\\/chaos.liveriot.net\\/videos\\/367\\/",
                                       @"title" : @"Video from LiveRiot",
                                       @"description" : content}
                            callback:^(id a, NSError *error) {
                              [self dismiss:error];
                            }];
}

- (void)dismiss:(NSError *)error
{
  if (!error) {
    NSLog(@"Succeed");
    
    [self dismissViewControllerAnimated:YES completion:^{
      [[[UIAlertView alloc] initWithTitle:@"Success"
                                  message:[NSString stringWithFormat:@"Post succeeded :)"]
                                 delegate:nil
                        cancelButtonTitle:@"OK"
                        otherButtonTitles:nil]
       show];
    }];
  } else {
    [[[UIAlertView alloc] initWithTitle:@"Failed"
                                message:[NSString stringWithFormat:@"Post failed :("]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
  }
}

@end
