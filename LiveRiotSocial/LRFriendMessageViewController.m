//
//  LRFriendMessageViewController.m
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-17.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "LRFriendMessageViewController.h"

@interface LRFriendMessageViewController ()

@end

@implementation LRFriendMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"LRFacebookShareViewController" bundle:nibBundleOrNil];
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

- (void)configureNavigationBar {
    self.navigationItem.title = @"Message";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleBordered target:self action:@selector(didClickPostButton:)];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Choose Friends" style:UIBarButtonItemStyleBordered target:self action:@selector(didClickReturnButton:)];
}

- (void)didClickPostButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didClickReturnButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
