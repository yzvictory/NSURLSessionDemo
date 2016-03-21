//
//  ViewController.m
//  NSUrlSessionDemo
//
//  Created by yz on 16/3/18.
//  Copyright © 2016年 DeviceOne. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self upload];
    // Do any additional setup after loading the view, typically from a nib.
}
//普通网络请求
- (void) request
{
    NSString *urlstr = @"http://developertest.deviceone.cn";
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:urlstr] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *reData = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        NSLog(@"%@",reData);
    }] resume];
}
//下载
- (void)download
{
    NSString *urlStr = @"http://ds2.deviceone.net/Files/install/20151103/342c733d-c491-4e34-a25c-c7fd8c47c126.apk";
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"downloadTaskWithRequest = %@",location);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //下载好保存在本地一个临时的文件，需要保存
        NSString *fileName = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:response.suggestedFilename];
        NSLog(@"local file name : %@",fileName);
        [fileManager moveItemAtURL:location toURL:[NSURL URLWithString:fileName] error:nil];
        
    }] resume];
}

- (void)upload
{
    NSString *urlStr = @"http://developertest.deviceone.cn/test/upload";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    request.HTTPMethod = @"POST";
    NSString *typeStr = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", @"boundary"];
    [request setValue:typeStr forHTTPHeaderField:@"Content-Type"];
    NSURLSession *session =  [NSURLSession sharedSession];
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"0.jpg" ofType:nil];
    NSData *data = [self getHttpBodyWithFilePath:filePath formName:@"file" reName:@"test.jpg"];
    request.HTTPBody = data;
    [[session uploadTaskWithRequest:request fromData:nil completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSLog(@"upload success：%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        } else {
            NSLog(@"upload error:%@",error);
        }
    }] resume];
}
- (NSData *)getHttpBodyWithFilePath:(NSString *)filePath formName:(NSString *)formName reName:(NSString *)reName
{
    NSMutableData *data = [NSMutableData data];
    // 文件类型：MIMEType  文件的大小：expectedContentLength  文件名字：suggestedFilename
    NSString *fileType = [self mimeTypeWithFilePath:filePath];
    
    // 如果没有传入上传后文件名称,采用本地文件名!
//    if (reName == nil) {
//        reName = response.suggestedFilename;
//    }
    
    // 表单拼接
    NSMutableString *headerStrM =[NSMutableString string];
    [headerStrM appendFormat:@"--%@\r\n",@"boundary"];
    // name：表单控件名称  filename：上传文件名
    [headerStrM appendFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n",formName,reName];
    [headerStrM appendFormat:@"Content-Type: %@\r\n\r\n",fileType];
    [data appendData:[headerStrM dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 文件内容
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    [data appendData:fileData];
    
    NSMutableString *footerStrM = [NSMutableString stringWithFormat:@"\r\n--%@--\r\n",@"boundary"];
    [data appendData:[footerStrM  dataUsingEncoding:NSUTF8StringEncoding]];
    //    NSLog(@"dataStr=%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    return data;
}
/** 指定全路径文件的mimeType */
- (NSString *)mimeTypeWithFilePath:(NSString *)filePath
{
    // 1. 判断文件是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    
    // 2. 使用HTTP HEAD方法获取上传文件信息
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 3. 调用同步方法获取文件的MimeType
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    
    return response.MIMEType;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
