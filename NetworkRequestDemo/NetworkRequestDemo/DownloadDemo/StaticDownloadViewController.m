//
//  StaticDownloadViewController.m
//  DownloadFileDemo
//
//  Created by ZHENGBO on 15/1/5.
//  Copyright (c) 2015年 WeiPengwei. All rights reserved.
//

#import "StaticDownloadViewController.h"
#define kFILE_BLOCK_SIZE (1024) //每次1KB

@interface StaticDownloadViewController ()<NSURLConnectionDataDelegate>{
    UIButton *_button;
    UIProgressView *_progressView;
    UILabel *_label;
    long long _totalLength;
    long long _loadedLength;
}

@end

@implementation StaticDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"文本资源静态下载";
    self.view.backgroundColor = [UIColor whiteColor];
    
    //进度条
    _progressView=[[UIProgressView alloc]initWithFrame:CGRectMake(10, 100, ScreenWidth-20, 25)];
    [self.view addSubview:_progressView];
    //状态显示
    _label=[[UILabel alloc]initWithFrame:CGRectMake(10, 130, ScreenWidth-20, 25)];
    _label.textColor=[UIColor colorWithRed:0 green:146/255.0 blue:1.0 alpha:1.0];
    [self.view addSubview:_label];
    //下载按钮
    _button=[[UIButton alloc]initWithFrame:CGRectMake(0, ScreenHeight-200, 100, 25)];
    _button.center = CGPointMake(ScreenWidth/2, _button.center.y);
    [_button setTitle:@"下载" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor colorWithRed:0 green:146/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(downloadFileAsync) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    
}

#pragma mark 更新进度
-(void)updateProgress{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (_loadedLength==_totalLength) {
            _label.text=@"下载完成";
        }else{
            _label.text=@"正在下载...";
        }
        [_progressView setProgress:(double)_loadedLength/_totalLength];
    }];
}
#pragma mark 取得请求链接
-(NSURL *)getDownloadUrl:(NSString *)fileName{
    NSString *urlStr=[NSString stringWithFormat:@"http://img2.mtime.cn/up/1077/213077/D00DA261-2775-4B31-99D9-A5B40B5471E4_500.jpg"];
    urlStr=[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    return url;
}
#pragma mark 取得保存地址(保存在沙盒缓存目录)
-(NSString *)getSavePath:(NSString *)fileName{
    fileName = @"jingtian.png";
    NSString *path=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
     NSLog(@"%@",[path stringByAppendingPathComponent:fileName]);
    return [path stringByAppendingPathComponent:fileName];
}
#pragma mark 文件追加
-(void)fileAppend:(NSString *)filePath data:(NSData *)data{
    //以可写方式打开文件
    NSFileHandle *fileHandle=[NSFileHandle fileHandleForWritingAtPath:filePath];
    //如果存在文件则追加，否则创建
    if (fileHandle) {
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
        [fileHandle closeFile];//关闭文件
    }else{
        [data writeToFile:filePath atomically:YES];//创建文件
    }
}

#pragma mark  取得文件大小
-(long long)getFileTotlaLength:(NSString *)fileName{

    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[self getDownloadUrl:fileName] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0f];
    //设置为头信息请求
    [request setHTTPMethod:@"HEAD"];
    
    NSURLResponse *response;
    NSError *error;
    //注意这里使用了同步请求，直接将文件大小返回
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        NSLog(@"detail error:%@",error.localizedDescription);
    }
    //取得内容长度
    return response.expectedContentLength;
}

#pragma mark 下载指定块大小的数据
-(void)downloadFile:(NSString *)fileName startByte:(long long)start endByte:(long long)end{
    NSString *range=[NSString stringWithFormat:@"Bytes=%lld-%lld",start,end];
    NSLog(@"%@",range);
    
    NSMutableURLRequest *request= [NSMutableURLRequest requestWithURL:[self getDownloadUrl:fileName] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0f];
    //通过请求头设置数据请求范围
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    NSURLResponse *response;
    NSError *error;
    //注意这里使用同步请求，避免文件块追加顺序错误
    NSData *data= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(!error) {
        NSLog(@"dataLength=%lld",(long long)data.length);
        [self fileAppend:[self getSavePath:fileName] data:data];
    }
    else {
        NSLog(@"detail error:%@",error.localizedDescription);
    }
}

#pragma mark 文件下载
-(void)downloadFile{
    _totalLength=[self getFileTotlaLength:@""];
    _loadedLength=0;
    long long startSize=0;
    long long endSize=0;
    //分段下载
    while(startSize< _totalLength){
        endSize=startSize+kFILE_BLOCK_SIZE-1;
        if (endSize>_totalLength) {
            endSize=_totalLength-1;
        }
        [self downloadFile:@"" startByte:startSize endByte:endSize];
        
        //更新进度
        _loadedLength+=(endSize-startSize)+1;
        [self updateProgress];
        
        
        startSize+=kFILE_BLOCK_SIZE;
        
    }
}

#pragma mark 异步下载文件
-(void)downloadFileAsync{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self downloadFile];
    });
}
@end
