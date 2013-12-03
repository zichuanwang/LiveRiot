//
//  LRSettingViewController.m
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-16.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "LRSettingViewController.h"
#import "LRSettingCell.h"
#import "LRSocialNetworkManager.h"

@interface LRSettingViewController () <UIActionSheetDelegate>

@end

@implementation LRSettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIImageView *topSepImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 29, 320, 1)];
    topSepImageView.image = [UIImage imageNamed:@"line_seperator"];
    UIImageView *bottomSepImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    bottomSepImageView.image = [UIImage imageNamed:@"line_seperator_rev"];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 30.0f)];
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 30.0f)];
    
    [topView addSubview:topSepImageView];
    [bottomView addSubview:bottomSepImageView];
    
    self.tableView.tableHeaderView = topView;
    self.tableView.tableFooterView = bottomView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LRSettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (!cell) {
        cell = [LRSettingCell createCell];
    }
    LRSettingCell *settingCell = (LRSettingCell *)cell;
    settingCell.platformLabel.text = @[@"Facebook", @"Twitter", @"Tumblr"][indexPath.row];
    settingCell.detailLabel.text = @"";
    
    BOOL signedIn = [[LRSocialNetworkManager sharedManager] checkPlatformLoginStatus:(SocialNetworkType)indexPath.row];
    
    switch (indexPath.row) {
        case 0: {
            
            settingCell.iconImageView.image = [UIImage imageNamed:signedIn ? @"facebook_logo_hl" : @"facebook_logo"];
            break;
        }
        case 1: {
            settingCell.iconImageView.image = [UIImage imageNamed:signedIn ? @"twitter_logo_hl" : @"twitter_logo"];
            
            break;
        }
        case 2: {
            settingCell.iconImageView.image = [UIImage imageNamed:signedIn ? @"tumblr_logo_hl" : @"tumblr_logo"];
            
            break;
        }
            
        default:
            break;
    }
    
    settingCell.detailLabel.text = signedIn ? [[LRSocialNetworkManager sharedManager] userNameForPlatform:(SocialNetworkType)indexPath.row] : @"";
    
    if (indexPath.row == 2) {
        settingCell.separatorImageView.hidden = YES;
    } else {
        settingCell.separatorImageView.hidden = NO;
    }
    return cell;
}

#pragma mark - UIActionSheetDelegate

#define FACEBOOK_LOGOUT_ACTION_TAG  1
#define TWITTER_LOGOUT_ACTION_TAG   2
#define TUMBLR_LOGOUT_ACTION_TAG    3

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == FACEBOOK_LOGOUT_ACTION_TAG) {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            [[LRSocialNetworkManager sharedManager] closeFacebookConnection];
        }
    } else if (actionSheet.tag == TWITTER_LOGOUT_ACTION_TAG) {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            [[LRSocialNetworkManager sharedManager] closeTwitterConnection];
        }
    } else if (actionSheet.tag == TUMBLR_LOGOUT_ACTION_TAG) {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            [[LRSocialNetworkManager sharedManager] closeTumblrConnection];
        }
    }
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL signedIn = [[LRSocialNetworkManager sharedManager] checkPlatformLoginStatus:(SocialNetworkType)indexPath.row];
    switch (indexPath.row) {
        case 0:
            if (!signedIn) {
                [[LRSocialNetworkManager sharedManager] openFacebookConnectionWithCallback:^(NSError *error) {
                    [self.tableView reloadData];
                }];
            } else {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Do you want to disconnect from Facebook?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Disconnect Facebook" otherButtonTitles:nil];
                actionSheet.tag = FACEBOOK_LOGOUT_ACTION_TAG;
                [actionSheet showInView:self.view];
            }
            
            break;
        case 1:
            if (signedIn) {
                // the access token is authorzied
                // ask user to unlink twitter or not.
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Do you want to disconnect from Twitter?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Disconnect Twitter" otherButtonTitles:nil];
                actionSheet.tag = TWITTER_LOGOUT_ACTION_TAG;
                [actionSheet showInView:self.view];
            } else {
                // the access token is not existed or invalid, authenticate user with OAuth
                [[LRSocialNetworkManager sharedManager] openTwitterConnectionWithController:self callback:^(NSError *error) {
                    [self.tableView reloadData];
                }];
            }
            break;
        case 2:
            if (!signedIn) {
                [[LRSocialNetworkManager sharedManager] openTumblrConnectionWithCallback:^(NSError *error) {
                    [self.tableView reloadData];
                }];
            } else {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Do you want to disconnect from Tumblr?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Disconnect Tumblr" otherButtonTitles:nil];
                actionSheet.tag = TUMBLR_LOGOUT_ACTION_TAG;
                [actionSheet showInView:self.view];
            }
            
            break;
        default:
            break;
    }
}

@end
