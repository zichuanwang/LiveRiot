//
//  LRSettingViewController.m
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-16.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "LRSettingViewController.h"
#import "LRFacebookLoginViewController.h"
#import "LRSettingCell.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FHSTwitterEngine.h"
#import "LRUIAlertViewDelegate.h"

@interface LRSettingViewController () <FHSTwitterEngineAccessTokenDelegate>

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
    return 2;
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
    settingCell.platformLabel.text = @[@"Facebook", @"Twitter"][indexPath.row];
    settingCell.detailLabel.text = @"";
    
    switch (indexPath.row) {
        case 0: {
            BOOL signedIn = FBSession.activeSession.isOpen;
            settingCell.iconImageView.image = [UIImage imageNamed:signedIn ? @"facebook_logo_hl" : @"facebook_logo"];
            break;
        }
        case 1: {
            BOOL signedIn = [[FHSTwitterEngine sharedEngine] isAuthorized];
            if (signedIn) {
                settingCell.detailLabel.text = [[FHSTwitterEngine sharedEngine] loggedInUsername];
            }
            settingCell.iconImageView.image = [UIImage imageNamed:signedIn ? @"twitter_logo_hl" : @"twitter_logo"];
            
            break;
        }
        default:
            break;
    }
    
    if (indexPath.row == 1) {
        settingCell.separatorImageView.hidden = YES;
    } else {
        settingCell.separatorImageView.hidden = NO;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [LRFacebookLoginViewController showInViewController:self];
            break;
        case 1:
            // twitter engine set up...
            [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:@"Sh5JfGh1T74hpE8lh35Rhg" andSecret:@"YAEI63uVUqwCw1cDlVFdocPfbBGedYAYD3odDYO8fOo"];
            [[FHSTwitterEngine sharedEngine]setDelegate:self];
            
            if ([[FHSTwitterEngine sharedEngine] isAuthorized] == YES) {
                // the access token is authorzied
                // ask user to unlink twitter or not.
                UIAlertView *alert = [[UIAlertView alloc] init];
                [alert setMessage:@"Are you sure to unlink Twitter?"];
                [alert addButtonWithTitle:@"Yes"];
                [alert addButtonWithTitle:@"No"];
                [LRUIAlertViewDelegate showAlertView:alert withCallback:^(NSInteger buttonIndex) {
                    // code to take action depending on the value of buttonIndex
                    if (buttonIndex == 0) {
                        // clear access toekn and update table cell
                        [[FHSTwitterEngine sharedEngine] clearAccessToken];
                        [self updateTableCell:tableView didSelectRowAtIndexPath:indexPath isAuthorized:NO userName:nil];
                    } else if (buttonIndex == 1) {
                        // update table cell
                        [self updateTableCell:tableView didSelectRowAtIndexPath:indexPath isAuthorized:NO userName:nil];
                    }
                }];
            } else {
                // the access token is not existed or invalid, authenticate user with OAuth
                [[FHSTwitterEngine sharedEngine] showOAuthLoginControllerFromViewController:self withCompletion:^(BOOL success) {
                    NSString* userName = [[FHSTwitterEngine sharedEngine]loggedInUsername];
                    NSLog(success ? @"Twitter OAuth Login success with UserName %@" : @"Twitter OAuth Loggin Failed %@", userName);
                    if (success) {
                        [self updateTableCell:tableView didSelectRowAtIndexPath:indexPath isAuthorized:YES userName:userName];
                    }
                    
                }];
            }
            break;
        default:
            break;
    }
}

// update the table cell
-(void)updateTableCell:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath isAuthorized:(BOOL) isAuthorized userName:(NSString*)userName {
//    static NSString *CellIdentifier = @"LRSettingCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    LRSettingCell *settingCell = (LRSettingCell *)cell;
//    
//    switch (indexPath.row) {
//        case 0:
//            // update facebook cell
//            
//            break;
//        case 1:
//            // update twitter cell
//            settingCell.iconImageView.image = [UIImage imageNamed:isAuthorized ? @"twitter_logo_hl" : @"twitter_logo"];
//            if (isAuthorized) {
//                settingCell.detailLabel.text = userName;
//                NSLog(@"in");
//            } else {
//                settingCell.detailLabel.text = @"";
//            }
//            //
//            break;
//        default:
//            break;
//    }
    // update the table view
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
}

#pragma mark - Twitter

- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
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
