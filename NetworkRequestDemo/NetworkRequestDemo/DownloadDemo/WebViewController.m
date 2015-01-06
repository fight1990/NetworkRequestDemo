//
//  WebViewController.m
//  DownloadFileDemo
//
//  Created by ZHENGBO on 15/1/5.
//  Copyright (c) 2015年 WeiPengwei. All rights reserved.
//

#import "WebViewController.h"
#define kFILEPROTOCOL @"file://"

@interface WebViewController ()<UISearchBarDelegate,UIWebViewDelegate>{
    UIWebView *_webView;
    UIToolbar *_toolbar;
    UISearchBar *_searchBar;
    UIBarButtonItem *_barButtonBack;
    UIBarButtonItem *_barButtonForward;
}

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"NSURLSession后台下载";
    self.view.backgroundColor = [UIColor whiteColor];
    
    /*添加地址栏*/
    _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, 44)];
    _searchBar.delegate=self;
    [self.view addSubview:_searchBar];
    
    /*添加浏览器控件*/
    _webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 110, ScreenWidth, ScreenHeight-110-44)];
    _webView.dataDetectorTypes=UIDataDetectorTypeAll;//数据检测，例如内容中有邮件地址，点击之后可以打开邮件软件编写邮件
    _webView.delegate=self;
    [self.view addSubview:_webView];
    
    /*添加下方工具栏*/
    _toolbar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, ScreenHeight-44, ScreenWidth, 44)];
    UIButton *btnBack=[UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.bounds=CGRectMake(0, 0, 50, 32);
    [btnBack setTitle:@"back" forState:UIControlStateNormal];
    [btnBack setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(webViewBack) forControlEvents:UIControlEventTouchUpInside];
    _barButtonBack=[[UIBarButtonItem alloc]initWithCustomView:btnBack];
    _barButtonBack.enabled=NO;
    
    UIBarButtonItem *btnSpacing=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIButton *btnForward=[UIButton buttonWithType:UIButtonTypeCustom];
    btnForward.bounds=CGRectMake(0, 0, 32, 32);
    [btnForward setTitle:@"go" forState:UIControlStateNormal];
    [btnForward setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    [btnForward addTarget:self action:@selector(webViewForward) forControlEvents:UIControlEventTouchUpInside];
    _barButtonForward=[[UIBarButtonItem alloc]initWithCustomView:btnForward];
    _barButtonForward.enabled=NO;
    
    _toolbar.items=@[_barButtonBack,btnSpacing,_barButtonForward];
    [self.view addSubview:_toolbar];
}
#pragma mark 设置前进后退按钮状态
-(void)setBarButtonStatus{
    if (_webView.canGoBack) {
        _barButtonBack.enabled=YES;
    }else{
        _barButtonBack.enabled=NO;
    }
    if(_webView.canGoForward){
        _barButtonForward.enabled=YES;
    }else{
        _barButtonForward.enabled=NO;
    }
}
#pragma mark 后退
-(void)webViewBack{
    [_webView goBack];
}
#pragma mark 前进
-(void)webViewForward{
    [_webView goForward];
}
#pragma mark 浏览器请求
-(void)request:(NSString *)urlStr{
    //创建url
    NSURL *url;
    
    //如果file://开头的字符串则加载bundle中的文件
    if([urlStr hasPrefix:kFILEPROTOCOL]){
        //取得文件名
        NSRange range= [urlStr rangeOfString:kFILEPROTOCOL];
        NSString *fileName=[urlStr substringFromIndex:range.length];
        url=[[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
    }else if(urlStr.length>0){
        //如果是http请求则直接打开网站
        if ([urlStr hasPrefix:@"http"]) {
            url=[NSURL URLWithString:urlStr];
        }else{//如果不符合任何协议则进行搜索
            urlStr=[NSString stringWithFormat:@"http://m.bing.com/search?q=%@",urlStr];
        }
        urlStr=[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//url编码
        url=[NSURL URLWithString:urlStr];
        
    }
    
    //创建请求
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    
    //加载请求页面
    [_webView loadRequest:request];
}

#pragma mark - WebView 代理方法
#pragma mark 开始加载
-(void)webViewDidStartLoad:(UIWebView *)webView{
    //显示网络请求加载
    [UIApplication sharedApplication].networkActivityIndicatorVisible=true;
}

#pragma mark 加载完毕
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    //隐藏网络请求加载图标
    [UIApplication sharedApplication].networkActivityIndicatorVisible=false;
    //设置按钮状态
    [self setBarButtonStatus];
}
#pragma mark 加载失败
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"error detail:%@",error.localizedDescription);
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"网络连接发生错误!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}


#pragma mark - SearchBar 代理方法
#pragma mark 点击搜索按钮或回车
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self request:_searchBar.text];
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
