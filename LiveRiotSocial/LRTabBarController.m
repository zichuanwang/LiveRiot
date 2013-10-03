//
//  LRTabBarController.m
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-3.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "LRTabBarController.h"

@interface LRTabBarController ()

@end

@implementation LRTabBarController

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
    [self.tabBar.items[0] setSelectedImage:[UIImage imageNamed:@"tabbar_featured_hl"]];
    [self.tabBar.items[1] setSelectedImage:[UIImage imageNamed:@"tabbar_video_hl"]];
    [self.tabBar.items[2] setSelectedImage:[UIImage imageNamed:@"tabbar_shot_hl"]];
    [self.tabBar.items[3] setSelectedImage:[UIImage imageNamed:@"tabbar_search_hl"]];
    [self.tabBar.items[4] setSelectedImage:[UIImage imageNamed:@"tabbar_setting_hl"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
