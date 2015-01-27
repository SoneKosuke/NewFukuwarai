//
//  ThumViewController.m
//  Fuwarai_Test
//
//  Created by sonekousuke on 2015/01/27.
//  Copyright (c) 2015年 KosukeSone. All rights reserved.
//

#import "ThumViewController.h"
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ThumViewController ()
<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    ALAssetsLibrary *_library;
    NSString *_AlbumName;
    NSMutableArray *_AlAssetsArr;
}

@end

@implementation ThumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 撮影ボタンを配置したツールバーを生成（下）
    UIToolbar *toolbarunder = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, 50)];
    toolbarunder.translucent = YES;
    
    // 前の画面に戻る
    UIBarButtonItem *takePhotBack = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                                                                  target:self
                                                                                  action:@selector(takePhotBack:)];

    // スペーサを生成する
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                               target:nil action:nil];

    
    // toolbarunderにbuttonを配置
    NSArray *itemsunder = [NSArray arrayWithObjects:takePhotBack, spacer, nil];
    
    
    toolbarunder.items = itemsunder;
    [self.view addSubview:toolbarunder];
    
    
    int status = 0;
    //ユーザデフォルトに書き込む
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:status forKey:@"status"];
    [defaults synchronize];
    
    
    _library = [[ALAssetsLibrary alloc] init];
    _AlbumName = @"123";
    _AlAssetsArr = [NSMutableArray array];
    
    //AlAssetsLibraryからALAssetGroupを検索
    [_library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                            usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                
                                //ALAssetsLibraryのすべてのアルバムが列挙される
                                if (group) {
                                    
                                    //アルバム名が「_AlbumName」と同一だった時の処理
                                    if ([_AlbumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
                                        
                                        //assetsEnumerationBlock
                                        ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                            
                                            if (result) {
                                                //asset をNSMutableArraryに格納
                                                [_AlAssetsArr addObject:result];
                                                
                                            }else{
                                                //NSMutableArraryに格納後の処理
                                                for (int i=0; i<[_AlAssetsArr count]; i++) {
                                                    int x,y;
                                                    
                                                    //タイル上に並べるためのx、yの計算
                                                    x = ((i % 3) * 100) + 10;
                                                    y = ((i / 3) * 100) + 10;
                                                    
                                                    //ALAssetからサムネール画像を取得してUIImageに変換
                                                    UIImage *image = [UIImage imageWithCGImage:[[_AlAssetsArr objectAtIndex:i] thumbnail]];
                                                    
                                                    //表示させるためにUIImageViewを作成
                                                    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                                                    
                                                    //UIImageViewのサイズと位置を設定
                                                    imageView.frame = CGRectMake(x+10,y+10,90,90);
                                                    
                                                    //ViewにaddSubView
                                                    [self.view addSubview:imageView];
                                                    
                                                }
                                            }
                                            
                                        };
                                        
                                        //アルバム(group)からALAssetの取得        
                                        [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
                                    }            
                                }
                                
                            } failureBlock:nil];
    
    
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
