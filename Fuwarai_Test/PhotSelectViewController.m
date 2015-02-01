//
//  PhotSelectViewController.m
//  Fuwarai_Test
//
//  Created by sonekousuke on 2015/02/01.
//  Copyright (c) 2015年 KosukeSone. All rights reserved.
//

#import "PhotSelectViewController.h"

@interface PhotSelectViewController ()

@end

@implementation PhotSelectViewController

- (void)viewDidLoad {
    
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
    // toolbarにbuttonを配置
    NSArray *items = [NSArray arrayWithObjects:takePhotBack, spacer, nil];
    toolbar.items = items;
    
    [self.view addSubview:toolbar];
    
    NSMutableArray *photoImages;
    
    // アルバム写真データの読み出し
    NSUserDefaults *defaultsAlbumPhoto = [NSUserDefaults standardUserDefaults];
    photoImages = [defaultsAlbumPhoto objectForKey:@"defaultsAlbumPhoto"];
    UIImage *image = [[UIImage alloc] initWithData:photoImages[self.selectedRow]];
    self.photoimage.image = image;
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)takePhotBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
