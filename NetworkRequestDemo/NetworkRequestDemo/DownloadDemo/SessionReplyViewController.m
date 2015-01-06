//
//  SessionReplyViewController.m
//  DownloadFileDemo
//
//  Created by ZHENGBO on 15/1/5.
//  Copyright (c) 2015年 WeiPengwei. All rights reserved.
//

/*
 NSURLSession支持进程三种会话：
 
 1、defaultSessionConfiguration：进程内会话（默认会话），用硬盘来缓存数据。
 2、ephemeralSessionConfiguration：临时的进程内会话（内存），不会将cookie、缓存储存到本地，只会放到内存中，当应用程序退出后数据也会消失。
 3、backgroundSessionConfiguration：后台会话，相比默认会话，该会话会在后台开启一个线程进行网络数据处理。
 */

#import "SessionReplyViewController.h"

@interface SessionReplyViewController ()<NSURLSessionDownloadDelegate>{
    UIProgressView *_progressView;
    UILabel *_label;
    UIButton *_btnDownload;
    UIButton *_btnCancel;
    UIButton *_btnSuspend;
    UIButton *_btnResume;
    NSURLSessionDownloadTask *_downloadTask;
}

@end

@implementation SessionReplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"NSURLSession会话";
    self.view.backgroundColor = [UIColor whiteColor];
    
    //进度条
    _progressView=[[UIProgressView alloc]initWithFrame:CGRectMake(10, 100, 300, 25)];
    [self.view addSubview:_progressView];
    //状态显示
    _label=[[UILabel alloc]initWithFrame:CGRectMake(10, 130, 300, 25)];
    _label.textColor=[UIColor colorWithRed:0 green:146/255.0 blue:1.0 alpha:1.0];
    [self.view addSubview:_label];
    //下载按钮
    _btnDownload=[[UIButton alloc]initWithFrame:CGRectMake(20, 500, 50, 25)];
    [_btnDownload setTitle:@"下载" forState:UIControlStateNormal];
    [_btnDownload setTitleColor:[UIColor colorWithRed:0 green:146/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [_btnDownload addTarget:self action:@selector(downloadFile) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnDownload];
    //取消按钮
    _btnCancel=[[UIButton alloc]initWithFrame:CGRectMake(100, 500, 50, 25)];
    [_btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [_btnCancel setTitleColor:[UIColor colorWithRed:0 green:146/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [_btnCancel addTarget:self action:@selector(cancelDownload) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnCancel];
    //挂起按钮
    _btnSuspend=[[UIButton alloc]initWithFrame:CGRectMake(180, 500, 50, 25)];
    [_btnSuspend setTitle:@"暂停" forState:UIControlStateNormal];
    [_btnSuspend setTitleColor:[UIColor colorWithRed:0 green:146/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [_btnSuspend addTarget:self action:@selector(suspendDownload) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnSuspend];
    //恢复按钮
    _btnResume=[[UIButton alloc]initWithFrame:CGRectMake(260, 500, 50, 25)];
    [_btnResume setTitle:@"恢复" forState:UIControlStateNormal];
    [_btnResume setTitleColor:[UIColor colorWithRed:0 green:146/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [_btnResume addTarget:self action:@selector(resumeDownload) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnResume];
}
#pragma mark 设置界面状态
-(void)setUIStatus:(int64_t)totalBytesWritten expectedToWrite:(int64_t)totalBytesExpectedToWrite{
    dispatch_async(dispatch_get_main_queue(), ^{
        _progressView.progress=(float)totalBytesWritten/totalBytesExpectedToWrite;
        if (totalBytesWritten==totalBytesExpectedToWrite) {
            _label.text=@"下载完成";
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            _btnDownload.enabled=YES;
        }else{
            _label.text=@"正在下载...";
            [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
        }
    });
}


#pragma mark 文件下载
-(void)downloadFile{
    //1.创建url

    NSString *urlStr=[NSString stringWithFormat: @"http://more.tianjimedia.com/soft/down.jsp?id=31000033&f=official&path=http://dldir1.qq.com/qqfile/qq/QQ6.7/13451/QQ6.7.exe"];
    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    //2.创建请求
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    
    //3.创建会话
    //默认会话
    NSURLSessionConfiguration *sessionConfig=[NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForRequest=5.0f;//请求超时时间
    sessionConfig.allowsCellularAccess=true;//是否允许蜂窝网络下载（2G/3G/4G）
    //创建会话
    NSURLSession *session=[NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];//指定配置和代理
    _downloadTask=[session downloadTaskWithRequest:request];
    
    [_downloadTask resume];
}
#pragma mark 取消下载
-(void)cancelDownload{
    [_downloadTask cancel];
    
}
#pragma mark 挂起下载
-(void)suspendDownload{
    [_downloadTask suspend];
}
#pragma mark 恢复下载下载
-(void)resumeDownload{
    [_downloadTask resume];
}

#pragma mark - 下载任务代理
#pragma mark 下载中(会多次调用，可以记录下载进度)
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    [self setUIStatus:totalBytesWritten expectedToWrite:totalBytesExpectedToWrite];
}

#pragma mark 下载完成
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSError *error;
    NSString *cachePath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *savePath=[cachePath stringByAppendingPathComponent:@"QQ.exe"];
    NSLog(@"%@",savePath);
    NSURL *saveUrl=[NSURL fileURLWithPath:savePath];
    [[NSFileManager defaultManager] copyItemAtURL:location toURL:saveUrl error:&error];
    if (error) {
        NSLog(@"Error is:%@",error.localizedDescription);
    }
}

#pragma mark 任务完成，不管是否下载成功
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    [self setUIStatus:0 expectedToWrite:0];
    if (error) {
        NSLog(@"Error is:%@",error.localizedDescription);
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
