//
//  DownLoadViewController.m
//  DownloadFileDemo
//
//  Created by ZHENGBO on 15/1/5.
//  Copyright (c) 2015年 WeiPengwei. All rights reserved.
//

#import "DownLoadViewController.h"

@interface DownLoadViewController () {

    PWProgressView *progressView;
    
    NSMutableData *responsedata;//响应数据
    UIButton *downButton;   //下载按钮
    UILabel *statuslabel;     //状态标签
    long long totalLength;
    
}

@end

@implementation DownLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"大文件资源下载";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //进度条
    progressView= [[PWProgressView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, 2)];
    [self.view addSubview:progressView];
    progressView.progressColor = [UIColor brownColor];
    progressView.stackColor = [UIColor whiteColor];
    
    //状态显示
    statuslabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 150, ScreenWidth-20, 25)];
    statuslabel.textColor=[UIColor colorWithRed:0 green:146/255.0 blue:1.0 alpha:1.0];
    [self.view addSubview:statuslabel];
    
    //下载按钮
    downButton=[[UIButton alloc]initWithFrame:CGRectMake(50, ScreenHeight-80, ScreenWidth-100, 25)];
    [downButton setTitle:@"下载" forState:UIControlStateNormal];
    [downButton setTitleColor:[UIColor colorWithRed:0 green:146/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [downButton addTarget:self action:@selector(sendRequest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:downButton];
}
#pragma mark 更新进度
-(void)updateProgress{

    if (responsedata.length==totalLength) {
        statuslabel.text=@"下载完成";
    }else{
        statuslabel.text=@"正在下载...";
    }
    [progressView setProgress:(float)responsedata.length/totalLength animated:YES];
}

#pragma mark 发送数据请求
-(void)sendRequest{
    NSString *urlStr=[NSString stringWithFormat:@"http://more.tianjimedia.com/soft/down.jsp?id=31000033&f=official&path=http://dldir1.qq.com/qqfile/qq/QQ6.7/13451/QQ6.7.exe"];
    urlStr=[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //创建url链接
    NSURL *url=[NSURL URLWithString:urlStr];

    NSURLRequest *request=[[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0f];
    //创建连接
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    //启动连接
    [connection start];
    
}

#pragma mark - 连接代理方法
#pragma mark 开始响应
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    responsedata=[[NSMutableData alloc]init];
    [progressView setProgress:0.0 animated:YES];
    
    //通过响应头中的Content-Length取得整个响应的总长度
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary *httpResponseHeaderFields = [httpResponse allHeaderFields];
    totalLength = [[httpResponseHeaderFields objectForKey:@"Content-Length"] longLongValue];
    
}

#pragma mark 接收响应数据（根据响应内容的大小此方法会被重复调用）
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    //连续接收数据
    [responsedata appendData:data];
    //更新进度
    [self updateProgress];
}

#pragma mark 数据接收完成
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    //数据接收完保存文件(注意苹果官方要求：下载数据只能保存在缓存目录)
    NSString *savePath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    savePath=[savePath stringByAppendingPathComponent:@"QQ6.7.exe"];
    [responsedata writeToFile:savePath atomically:YES];
    
    NSLog(@"path:%@",savePath);
}

#pragma mark 请求失败
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    //如果连接超时或者连接地址错误可能就会报错
    NSLog(@"connection error,error detail is:%@",error.localizedDescription);
}

@end
