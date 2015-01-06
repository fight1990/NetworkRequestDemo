//
//  SessionTaskViewController.m
//  DownloadFileDemo
//
//  Created by ZHENGBO on 15/1/5.
//  Copyright (c) 2015年 WeiPengwei. All rights reserved.
//

#import "SessionTaskViewController.h"

@interface SessionTaskViewController ()

@end

@implementation SessionTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"NSURLSession使用";
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *btnNames = [[NSArray alloc] initWithObjects:@"获取数据",@"文件上传",@"文件下载", nil];
    for (int  i = 0; i < 3; i++) {
        UIButton *_button=[[UIButton alloc]initWithFrame:CGRectMake((ScreenWidth-300)/4+(((ScreenWidth-300)/4+100)*i), ScreenHeight-200, 100, 25)];
        _button.tag = i;
        [_button setTitle:[btnNames objectAtIndex:i] forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor colorWithRed:0.5 green:0.8 blue:rand()%10 alpha:1.0] forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_button];
    }
}
- (void)btnAction:(UIButton*)sender {

    if (sender.tag == 0 ) {
        [self loadJsonData];
    }
    else if (sender.tag == 1) {
        [self uploadFile];
    }
    else {
        [self downloadFile];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//-----------------------获取数据
-(void)loadJsonData{
    //1.创建url
    NSString *urlStr=[NSString stringWithFormat:@"http://www.pplogi.com:81/PanPacific/mob/clientNews_getNewsList.action?page=1"];
    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    //2.创建请求
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    
    //3.创建会话（这里使用了一个全局会话）并且启动任务
    NSURLSession *session=[NSURLSession sharedSession];
    //从会话创建任务
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSString *dataStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",dataStr);
        }else{
            NSLog(@"error is :%@",error.localizedDescription);
        }
    }];
    
    [dataTask resume];//恢复线程，启动任务
}


//-----------------------上传文件
#pragma mark 取得mime types
-(NSString *)getMIMETypes:(NSString *)fileName{
    return @"image/png";
}
#pragma mark 取得数据体
-(NSData *)getHttpBody:(NSString *)fileName{
    NSString *boundary=@"com.19lou";
    NSMutableData *dataM=[NSMutableData data];
    NSString *strTop=[NSString stringWithFormat:@"--%@\nContent-Disposition: form-data; name=\"file1\"; filename=\"%@\"\nContent-Type: %@\n\n",boundary,fileName,[self getMIMETypes:fileName]];
    NSString *strBottom=[NSString stringWithFormat:@"\n--%@--",boundary];
    NSString *filePath=[[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSData *fileData=[NSData dataWithContentsOfFile:filePath];
    [dataM appendData:[strTop dataUsingEncoding:NSUTF8StringEncoding]];
    [dataM appendData:fileData];
    [dataM appendData:[strBottom dataUsingEncoding:NSUTF8StringEncoding]];
    return dataM;
}
#pragma mark 上传文件
-(void)uploadFile{
    NSString *fileName=@"jingtian.png";
    //1.创建url
    NSString *urlStr=@"";
    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    //2.创建请求
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod=@"POST";
    
    //3.构建数据
    //NSString *path=[[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSData *data=[self getHttpBody:fileName];
    request.HTTPBody=data;
    
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",@"com.19lou"] forHTTPHeaderField:@"Content-Type"];
    
    
    
    //4.创建会话
    NSURLSession *session=[NSURLSession sharedSession];
    NSURLSessionUploadTask *uploadTask=[session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSString *dataStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",dataStr);
        }else{
            NSLog(@"error is :%@",error.localizedDescription);
        }
    }];
    
    [uploadTask resume];
}


//-----------------------下载文件
- (void)downloadFile{
    //1.创建url
    NSString *fileName=@"1.jpg";
    NSString *urlStr=[NSString stringWithFormat: @"http://img2.mtime.cn/up/1077/213077/D00DA261-2775-4B31-99D9-A5B40B5471E4_500.jpg"];
    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    //2.创建请求
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    
    //3.创建会话（这里使用了一个全局会话）并且启动任务
    NSURLSession *session=[NSURLSession sharedSession];
    
    NSURLSessionDownloadTask *downloadTask=[session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (!error) {
            //注意location是下载后的临时保存路径,需要将它移动到需要保存的位置
            
            NSError *saveError;
            NSString *cachePath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSString *savePath=[cachePath stringByAppendingPathComponent:fileName];
            NSLog(@"%@",savePath);
            NSURL *saveUrl=[NSURL fileURLWithPath:savePath];
            [[NSFileManager defaultManager] copyItemAtURL:location toURL:saveUrl error:&saveError];
            if (!saveError) {
                NSLog(@"save sucess.");
            }else{
                NSLog(@"error is :%@",saveError.localizedDescription);
            }
            
        }else{
            NSLog(@"error is :%@",error.localizedDescription);
        }
    }];
    
    [downloadTask resume];
}

@end
