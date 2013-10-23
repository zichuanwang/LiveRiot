//
//  LRFriendShareViewController.m
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-16.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "LRFriendShareViewController.h"
#import "CRNavigationController.h"
#import "LRFriendCell.h"
#import "LRFriendMessageViewController.h"

@interface LRFriendShareViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *indexSelectionArray;

@end

@implementation LRFriendShareViewController

+ (void)showInViewController:(UIViewController *)viewController {
    LRFriendShareViewController *loginViewController = [[LRFriendShareViewController alloc] init];
    CRNavigationController *nav = [[CRNavigationController alloc] initWithRootViewController:loginViewController];
    [viewController presentViewController:nav animated:YES completion:nil];
    
}

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
    // Do any additional setup after loading the view from its nib.
    [self configureNavigationBar];
    self.indexSelectionArray = [NSMutableArray arrayWithObjects:@(YES), @(NO), @(NO), @(YES), @(YES), @(NO), nil];
}

- (void)configureNavigationBar {
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:234 / 255. green:82 / 255. blue:81 / 255. alpha:1.];
    
    self.navigationItem.title = @"Choose Friends";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(didClickCancelButton:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(didClickPostButton:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didClickCancelButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didClickPostButton:(UIButton *)sender {
    [self.navigationController pushViewController:[[LRFriendMessageViewController alloc] init] animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LRFriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (!cell) {
        cell = [LRFriendCell createCell];
    }
    
    LRFriendCell *friendCell = (LRFriendCell *)cell;
    
    friendCell.nameLabel.text = @[@"Zichuan Wang", @"Haoyu Huang", @"Haishan Ye", @"Yang Li", @"Kaiqi Zhang", @"Ye Tian"][indexPath.row];
    friendCell.imageView.image = [UIImage imageNamed:@[@"zichuanwang", @"haoyuhuang", @"haishanye", @"yangli", @"kaiqizhang", @"yetian"][indexPath.row]];
    cell.accessoryType = [self.indexSelectionArray[indexPath.row] boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.indexSelectionArray[indexPath.row] = @(![self.indexSelectionArray[indexPath.row] boolValue]);
    // cell.accessoryType = [self.indexSelectionArray[indexPath.row] boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    [self.tableView reloadData];
}

@end
