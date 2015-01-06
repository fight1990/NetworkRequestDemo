//
//  ViewController.m
//  DownloadFileDemo
//
//  Created by ZHENGBO on 15/1/5.
//  Copyright (c) 2015年 WeiPengwei. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){

    UITableView *myTableView;
    NSArray *cellsArray;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.title = @"首页";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    cellsArray = [[NSArray alloc] initWithObjects:@"文件下载",@"文本静态下载",@"文件上传",@"NSURLSession的使用",@"NSURLSession会话",@"NSURLSession后台下载",@"UIWebView",nil];
    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-64) style:UITableViewStylePlain];
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self.view addSubview:myTableView];
    myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
   
}

#pragma delegate/dataSource - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return cellsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *identifier = @"cellOne";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    cell.textLabel.text = [cellsArray objectAtIndex:indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        DownLoadViewController *down = [[DownLoadViewController alloc] init];
        [self.navigationController pushViewController:down animated:YES];
    }
    else if (indexPath.row == 1) {
        StaticDownloadViewController *down = [[StaticDownloadViewController alloc] init];
        [self.navigationController pushViewController:down animated:YES];
        
    }
    else if (indexPath.row == 2) {
        UploadFilesViewController *upload = [[UploadFilesViewController alloc] init];
        [self.navigationController pushViewController:upload animated:YES];
        
    }
    else if (indexPath.row == 3) {
        SessionTaskViewController *session = [[SessionTaskViewController alloc] init];
        [self.navigationController pushViewController:session animated:YES];
        
    }
    else if (indexPath.row == 4) {
        SessionReplyViewController *session = [[SessionReplyViewController alloc] init];
        [self.navigationController pushViewController:session animated:YES];
        
    }
    else if (indexPath.row == 5) {
        SessionBackgroundLoadViewController *session = [[SessionBackgroundLoadViewController alloc] init];
        [self.navigationController pushViewController:session animated:YES];
        
    }
    else if (indexPath.row == 6) {
        WebViewController *web = [[WebViewController alloc] init];
        [self.navigationController pushViewController:web animated:YES];
        
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
