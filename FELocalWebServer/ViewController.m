//
//  ViewController.m
//  FELocalWebServer
//
//  Created by FlyElephant on 16/6/6.
//  Copyright © 2016年 FlyElephant. All rights reserved.
//

#import "ViewController.h"
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"
#import "GCDWebServerURLEncodedFormRequest.h"
#import "GCDWebUploader.h"
#import "FEWebUploader.h"

static NSString * const CellIdentifier=@"CellIdentifier";

static const NSInteger Port=7258;

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong,nonatomic) NSMutableArray *data;

@property (strong,nonatomic) GCDWebServer *webServer;

@property (strong,nonatomic) GCDWebUploader *webUploader;

@property (strong,nonatomic) FEWebUploader  *customWebUploader;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.data count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text=self.data[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row==0) {
        [self loadSimpleServer];
    }else if (indexPath.row==1){
        [self loadHtmlFile];
    }else if (indexPath.row==2){
        [self loadWebUploader];
    }else if (indexPath.row==3){
        [self loadCustomUploader];
    }
}

#pragma mark - Setup

-(void)setup{
    self.automaticallyAdjustsScrollViewInsets=NO;
     self.webServer = [[GCDWebServer alloc] init];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    self.data=[[NSMutableArray alloc]init];
    [self.data addObject:@"默认上传页面"];
    [self.data addObject:@"加载本地文件"];
    [self.data addObject:@"上传文件"];
    [self.data addObject:@"自定义上传"];
}

-(void)showServerURL:(NSString *)message{
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"GCDWebServer" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:^{}];
}

-(void)loadSimpleServer{
    // Add a handler to respond to GET requests on any URL
    [self.webServer addDefaultHandlerForMethod:@"GET"
                             requestClass:[GCDWebServerRequest class]
                             processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                                 
                                 return [GCDWebServerDataResponse responseWithHTML:@"<html><body><p>Hello World</p></body></html>"];
                                 
                             }];
    [self.webServer startWithPort:Port bonjourName:nil];
    NSLog(@"Visit %@ in your web browser--Path:%@", self.webServer.serverURL,[self.webServer.serverURL absoluteString]);
    [self showServerURL:[self.webServer.serverURL absoluteString]];
}

-(void)loadHtmlFile{
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *filePath =[resourcePath stringByAppendingPathComponent:@"index.html"];
    NSMutableString *htmlstring=[[NSMutableString alloc] initWithContentsOfFile:filePath  encoding:NSUTF8StringEncoding error:nil];
    
    [self.webServer addHandlerForMethod:@"GET"
                         path:@"/"
                 requestClass:[GCDWebServerRequest class]
                 processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                     return [GCDWebServerDataResponse responseWithHTML:htmlstring];
                 }];
    
    [self.webServer addHandlerForMethod:@"POST"
                                   path:@"/test"
                           requestClass:[GCDWebServerURLEncodedFormRequest class]
                           processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                               
                               NSString* value = [[(GCDWebServerURLEncodedFormRequest*)request arguments] objectForKey:@"bookName"];
                               NSLog(@"图书的名字:%@",value);
                               return [GCDWebServerDataResponse responseWithJSONObject:@{@"success":@"Post返回时成功"}];
                               
                           }];
    [self.webServer startWithPort:Port bonjourName:nil];
    NSLog(@"Visit %@ in your web browser--Path:%@", self.webServer.serverURL,[self.webServer.serverURL absoluteString]);
    [self showServerURL:[self.webServer.serverURL absoluteString]];
}

-(void)loadWebUploader{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSLog(@"上传文件的地址:%@",documentsPath);
    self.webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
    [self.webUploader start];
    NSLog(@"Visit %@ in your web browser", self.webUploader.serverURL);
    [self showServerURL:[self.webUploader.serverURL absoluteString]];
}

-(void)loadCustomUploader{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSLog(@"上传文件的地址:%@",documentsPath);
    self.customWebUploader = [[FEWebUploader alloc] initWithUploadDirectory:documentsPath];
    [self.customWebUploader start];
    NSLog(@"Visit %@ in your web browser", self.customWebUploader.serverURL);
    [self showServerURL:[self.customWebUploader.serverURL absoluteString]];
}

@end
