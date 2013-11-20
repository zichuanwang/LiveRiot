//
//  LRSettingViewController.m
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-16.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "LRSettingViewController.h"
#import "LRSettingCell.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FHSTwitterEngine.h"
#import "LRUIAlertViewDelegate.h"
#import "LRAppDelegate.h"
#import "TMAPIClient.h"
#import "NSUserDefaults+Addition.h"

@interface LRSettingViewController () <FHSTwitterEngineAccessTokenDelegate, UIActionSheetDelegate>

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
    
    [self setupTwitterEngine];
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
    
    switch (indexPath.row) {
        case 0: {
            BOOL signedIn = FBSession.activeSession.isOpen;
            settingCell.detailLabel.text = signedIn ? [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentFacebookUserName] : @"";
            settingCell.iconImageView.image = [UIImage imageNamed:signedIn ? @"facebook_logo_hl" : @"facebook_logo"];
            break;
        }
        case 1: {
            BOOL signedIn = [[FHSTwitterEngine sharedEngine] isAuthorized];
            settingCell.detailLabel.text = signedIn ? [[FHSTwitterEngine sharedEngine] loggedInUsername] : @"";
            settingCell.iconImageView.image = [UIImage imageNamed:signedIn ? @"twitter_logo_hl" : @"twitter_logo"];
            
            break;
        }
        case 2: {
            BOOL signedIn = [NSUserDefaults isTMLoggedIn];
            settingCell.detailLabel.text = signedIn ? [NSUserDefaults getTMUserName] : @"";
            settingCell.iconImageView.image = [UIImage imageNamed:signedIn ? @"tumblr_logo_hl" : @"tumblr_logo"];
          
          break;
        }

        default:
            break;
    }
    
    if (indexPath.row == 2) {
        settingCell.separatorImageView.hidden = YES;
    } else {
        settingCell.separatorImageView.hidden = NO;
    }
    return cell;
}

static NSString *kCurrentFacebookUserName = @"kCurrentFacebookUserName";

- (void)populateUserDetails {
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 [[NSUserDefaults standardUserDefaults] setObject:user.name forKey:kCurrentFacebookUserName];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 // self.userProfileImage.profileID = [user objectForKey:@"id"];
                 [self.tableView reloadData];
             }
         }];
    }
}

#pragma mark - UIActionSheetDelegate>

#define FACEBOOK_LOGOUT_ACTION_TAG  1
#define TWITTER_LOGOUT_ACTION_TAG   2
#define TUMBLR_LOGOUT_ACTION_TAG    3

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == FACEBOOK_LOGOUT_ACTION_TAG) {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            [self closeFacebookSession];
        }
    } else if (actionSheet.tag == TWITTER_LOGOUT_ACTION_TAG) {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            // clear access token
            [[FHSTwitterEngine sharedEngine] clearAccessToken];
        }
    } else if (actionSheet.tag == TUMBLR_LOGOUT_ACTION_TAG) {
      if (buttonIndex != actionSheet.cancelButtonIndex) {
        [NSUserDefaults logoutTM];
      }
    }
    [self.tableView reloadData];
}

- (void)closeFacebookSession {
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession setActiveSession:nil];
}

- (void)openFacebookSession {
    // if the session isn't open, let's open it now and present the login UX to the user
    [FBSession.activeSession openWithCompletionHandler:^(FBSession *session,
                                         FBSessionState status,
                                         NSError *error) {
        // and here we make sure to update our UX according to the new session state
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Failure" message:error.localizedDescription delegate:nil cancelButtonTitle:@"I see" otherButtonTitles:nil] show];
        }
        [self populateUserDetails];
        [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]].selected = NO;
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            if (![FBSession activeSession].isOpen) {
                [self openFacebookSession];
            } else {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Do you want to disconnect from Facebook?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Disconnect Facebook" otherButtonTitles:nil];
                actionSheet.tag = FACEBOOK_LOGOUT_ACTION_TAG;
                [actionSheet showInView:self.view];
            }
            
            break;
        case 1:
            
            if ([[FHSTwitterEngine sharedEngine] isAuthorized] == YES) {
                // the access token is authorzied
                // ask user to unlink twitter or not.
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Do you want to disconnect from Twitter?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Disconnect Twitter" otherButtonTitles:nil];
                actionSheet.tag = TWITTER_LOGOUT_ACTION_TAG;
                [actionSheet showInView:self.view];
            } else {
                // the access token is not existed or invalid, authenticate user with OAuth
                [[FHSTwitterEngine sharedEngine] showOAuthLoginControllerFromViewController:self withCompletion:^(BOOL success) {
                    NSString* userName = [[FHSTwitterEngine sharedEngine]loggedInUsername];
                    NSLog(success ? @"Twitter OAuth Login success with UserName %@" : @"Twitter OAuth Loggin Failed %@", userName);
                    if (success) {
                        [tableView reloadData];
                    }
                    
                }];
            }
            break;
        case 2:
          if (![NSUserDefaults isTMLoggedIn]) {
            [self loginTumblr];
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

#pragma mark - Twitter

- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}

- (void) setupTwitterEngine {
    // twitter engine set up...
    [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:@"Sh5JfGh1T74hpE8lh35Rhg" andSecret:@"YAEI63uVUqwCw1cDlVFdocPfbBGedYAYD3odDYO8fOo"];
    [[FHSTwitterEngine sharedEngine] setDelegate:self];
    [[FHSTwitterEngine sharedEngine] loadAccessToken];
}

#pragma mark - Tumblr
- (void)loginTumblr
{
  [[TMAPIClient sharedInstance] authenticate:@"LiveRiotSocial" callback:^(NSError *error) {
    if (!error) {
      [NSUserDefaults loginTMWithToken:[TMAPIClient sharedInstance].OAuthToken
                                secret:[TMAPIClient sharedInstance].OAuthTokenSecret];
      [[TMAPIClient sharedInstance] userInfo:^(id dict, NSError *error) {
        if (!error) {
          if ([dict isKindOfClass:[NSDictionary class]]) {
            NSDictionary *userInfoDict = dict[@"user"];
            NSString *userName = userInfoDict[@"name"];
            [NSUserDefaults setTMUserName:userName];
          }
        }
      }];
    }
  }];
}

#pragma mark alertView delegate


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
