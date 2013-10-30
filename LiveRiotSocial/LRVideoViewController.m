//
//  LRVideoViewController.m
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-3.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "LRVideoViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "LRFacebookLoginViewController.h"
#import "LRVideoDetailViewController.h"

@interface LRVideoCell ()

@property (nonatomic, weak) IBOutlet UIImageView *videoPreviewImageView;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *timestampLabel;

@end

@implementation LRVideoCell


@end

@interface LRVideoViewController ()

@end

@implementation LRVideoViewController

static NSArray *staticTitleArray = nil;
static NSArray *staticVideoImageNameArray = nil;
static NSArray *staticAvatarImageNameArray = nil;
static NSArray *staticTimeStringArray = nil;
static NSArray *staticLinkArray = nil;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            staticVideoImageNameArray = @[@"The Dead Ships.jpg", @"Hands.jpg", @"Vanaprasta.jpg"];
            staticAvatarImageNameArray = @[@"zichuanwang", @"haoyuhuang", @"haishanye"];
            staticTitleArray = @[@"Check out this Dead Ships show!", @"Amazing live show", @"I love this song :)"];
            staticTimeStringArray = @[@"09:00 p.m. Today", @"08:31 p.m. 10/24/2013", @"11:20 p.m. 10/23/2013"];
            staticLinkArray = @[@"http://chaos.liveriot.net/videos/542", @"http://chaos.liveriot.net/videos/548", @"http://chaos.liveriot.net/videos/387"];
        });
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)refreshControlDidChange:(UIRefreshControl *)control {
    [control endRefreshing];
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
    static NSString *CellIdentifier = @"LRVideoCell";
    LRVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.videoPreviewImageView.image = [UIImage imageNamed:staticVideoImageNameArray[indexPath.row]];
    cell.avatarImageView.image = [UIImage imageNamed:staticAvatarImageNameArray[indexPath.row]];
    cell.titleLabel.text = staticTitleArray[indexPath.row];
    cell.timestampLabel.text = staticTimeStringArray[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *titleString = staticTitleArray[indexPath.row];
    CGFloat height = [titleString boundingRectWithSize:CGSizeMake(220.0f, CGFLOAT_MAX)
                                               options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                            attributes: @{NSFontAttributeName : [UIFont systemFontOfSize:17.0f]}
                                               context:nil].size.height;
    return 260.0f + (height > 20.0f ? height : 20.0f);
}

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


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *controller = [segue destinationViewController];
    if ([controller isKindOfClass:[LRVideoDetailViewController class]]) {
        LRVideoCell *cell = (LRVideoCell *)sender;
        NSInteger rowOfCell = [self.tableView indexPathForCell:cell].row;
        LRVideoDetailViewController *detailController = (LRVideoDetailViewController *)controller;
        detailController.title = staticTitleArray[rowOfCell];
        detailController.timeString = staticTimeStringArray[rowOfCell];
        detailController.avatarImageName = staticAvatarImageNameArray[rowOfCell];
        detailController.videoLink = staticLinkArray[rowOfCell];
        detailController.previewImageName = staticVideoImageNameArray[rowOfCell];
    }
}


@end
