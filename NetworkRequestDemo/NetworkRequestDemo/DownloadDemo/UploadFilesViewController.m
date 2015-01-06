//
//  UploadFilesViewController.m
//  DownloadFileDemo
//
//  Created by ZHENGBO on 15/1/5.
//  Copyright (c) 2015年 WeiPengwei. All rights reserved.
//

#import "UploadFilesViewController.h"
#define kBOUNDARY_STRING @"com.19lou"

@interface UploadFilesViewController ()<NSURLConnectionDataDelegate>{
    UITextField *_textField;
    UIButton *_button;
}

@end

@implementation UploadFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"资源文件上传";
    self.view.backgroundColor = [UIColor whiteColor];
    
    //地址栏
    _textField=[[UITextField alloc]initWithFrame:CGRectMake(10, 80, ScreenWidth-20, 25)];
    _textField.borderStyle=UITextBorderStyleRoundedRect;
    _textField.textColor=[UIColor colorWithRed:0 green:146/255.0 blue:1.0 alpha:1.0];
    _textField.text=@"jingtian.png";
    [self.view addSubview:_textField];
    
    //上传按钮
    _button=[[UIButton alloc]initWithFrame:CGRectMake(10, 500, ScreenWidth-20, 25)];
    [_button setTitle:@"上传" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor colorWithRed:0 green:146/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(uploadFile) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
}
#pragma mark 取得请求链接
-(NSURL *)getUploadUrl:(NSString *)fileName{
    NSString *urlStr=[NSString stringWithFormat:@"http://192.168.1.208/FileUpload.aspx?file=%@",fileName];
    urlStr=[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    return url;
}
#pragma mark 取得mime types
-(NSString *)getMIMETypes:(NSString *)fileName{
    return @"image/png";
}
#pragma mark 取得数据体
-(NSData *)getHttpBody:(NSString *)fileName{
    NSMutableData *dataM=[NSMutableData data];
    NSString *strTop=[NSString stringWithFormat:@"--%@\nContent-Disposition: form-data; name=\"file1\"; filename=\"%@\"\nContent-Type: %@\n\n",kBOUNDARY_STRING,fileName,[self getMIMETypes:fileName]];
    NSString *strBottom=[NSString stringWithFormat:@"\n--%@--",kBOUNDARY_STRING];
    NSString *filePath=[[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSData *fileData=[NSData dataWithContentsOfFile:filePath];
    [dataM appendData:[strTop dataUsingEncoding:NSUTF8StringEncoding]];
    [dataM appendData:fileData];
    [dataM appendData:[strBottom dataUsingEncoding:NSUTF8StringEncoding]];
    return dataM;
}


#pragma mark 上传文件
-(void)uploadFile{
    NSString *fileName=_textField.text;
    
    NSMutableURLRequest *request= [NSMutableURLRequest requestWithURL:[self getUploadUrl:fileName] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0f];
    request.HTTPMethod=@"POST";
    NSData *data=[self getHttpBody:fileName];
    
    //通过请求头设置
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",kBOUNDARY_STRING] forHTTPHeaderField:@"Content-Type"];
    //设置数据体
    request.HTTPBody=data;
    
    //发送请求
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError){
            NSLog(@"error:%@",connectionError.localizedDescription);
        }
    }];
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
