//
//  AfterTakePhotViewController.m
//  Fuwarai_Test
//
//  Created by sonekousuke on 2015/01/24.
//  Copyright (c) 2015年 KosukeSone. All rights reserved.
//

#import "AfterTakePhotViewController.h"

@interface AfterTakePhotViewController (){
    UIImage* _origImage;
}

@end

@implementation AfterTakePhotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // self.originImage.image = image;
    
    int status = 0;
    //ユーザデフォルトに書き込む
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:status forKey:@"status"];
    [defaults synchronize];
    
    // 撮影ボタンを配置したツールバーを生成
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, 50)];
    toolbar.translucent = YES;
    
    // 前の画面に戻る
    UIBarButtonItem *takePhotBack = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                                                            target:self
                                                                            action:@selector(takePhotBack:)];
    // スペーサを生成する
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                               target:nil action:nil];
    // 顔をバラバラにする。
    UIBarButtonItem *library = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
                                                                             target:self
                                                                             action:@selector(openLibrary:)];
    // toolbarにbuttonを配置
    NSArray *items = [NSArray arrayWithObjects:spacer, takePhotBack, spacer, library, nil];
    toolbar.items = items;
    
    [self.view addSubview:toolbar];
    
    NSUserDefaults *defaultphot = [NSUserDefaults standardUserDefaults];
    NSString *path = [defaultphot stringForKey:@"path"];
    NSLog(@"%@", path);
    
    
    UIImage *image= [[UIImage alloc] initWithContentsOfFile:path];
    
//    UIImage *image = [UIImage imageNamed:@"/var/mobile/Containers/Data/Application/F35B7DAA-CBB0-442B-BD4E-617F576F561E/Documents/sample.jpg"];
    self.originImage.image = image;
    
    
    
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

- (void)takePhotBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
