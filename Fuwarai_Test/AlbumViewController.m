//
//  AlbumViewController.m
//  Fuwarai_Test
//
//  Created by sonekousuke on 2015/02/02.
//  Copyright (c) 2015年 KosukeSone. All rights reserved.
//

#import "AlbumViewController.h"
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AlbumTableViewCell.h"
#import "PhotSelectViewController.h"

@interface AlbumViewController ()<UITableViewDelegate, UITableViewDataSource> {
    ALAssetsLibrary *_library;
    NSString *_AlbumName;
    NSMutableArray *_AlAssetsArr;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) NSMutableArray *photoImages;
@property  int countPhot;
@property (nonatomic, weak) NSArray *imageList;

////
@property (nonatomic, strong) NSArray *dataSourceiPhone;
@property (nonatomic, strong) NSArray *dataSourceAndroid;
///

@end

@implementation AlbumViewController

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
    

    
    // アルバムの写真をカメラロールから取得
    _library = [[ALAssetsLibrary alloc] init];
    _AlbumName = @"123";
    _AlAssetsArr = [NSMutableArray array];
    NSMutableArray *imageList = [NSMutableArray new];
    NSMutableArray *imageDateList = [NSMutableArray new];
    
    
    // AlAssetsLibraryからALAssetGroupを検索
    [_library enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        // ALAssetsLibraryのすべてのアルバムが列挙される
        if (group) {
            // アルバム名が「_AlbumName」と同一だった時の処理
            if ([_AlbumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
                // assetsEnumerationBlock
                ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    
                    if (result) {
                        // asset をNSMutableArraryに格納
                        [_AlAssetsArr addObject:result];
                        
                    }else{
                        // NSMutableArraryに格納後の処理
                        for (int i=0; i<[_AlAssetsArr count]; i++) {
                            
                            // ALAssetからサムネール画像を取得してUIImageに変換
                            UIImage *image = [UIImage imageWithCGImage:[[_AlAssetsArr objectAtIndex:i] thumbnail]];
                            NSData* imageData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(image, 1)];
                            [imageList addObject:imageData];
                            
                            // exifデータの取得
                            NSData *imageSaveDate = [[NSData alloc] init];
                            imageSaveDate = [[_AlAssetsArr objectAtIndex:i ] valueForProperty:ALAssetPropertyDate];
                            
                            [imageDateList addObject:imageSaveDate];
                            
                        }
                    }
                };
                
                // アルバム(group)からALAssetの取得
                [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
                
            }
        } else {
            // 取得されたアルバムデータを取得
            NSUserDefaults* defaultsAlbumPhoto = [NSUserDefaults standardUserDefaults];
            [defaultsAlbumPhoto setObject:imageList forKey:@"defaultsAlbumPhoto"];
            [defaultsAlbumPhoto synchronize];
            
            NSUserDefaults* defaultsAlbumPhotoDate = [NSUserDefaults standardUserDefaults];
            [defaultsAlbumPhotoDate setObject:imageDateList forKey:@"defaultsAlbumPhotoDate"];
            [defaultsAlbumPhotoDate synchronize];
            
        }
    } failureBlock:nil];
    
    // アルバム写真データの読み出し
    NSUserDefaults *defaultsAlbumPhoto = [NSUserDefaults standardUserDefaults];
    _photoImages = [defaultsAlbumPhoto objectForKey:@"defaultsAlbumPhoto"];
    
    
    // デリゲートメソッドをこのクラスで実装する
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
////
    // テーブルに表示したいデータソースをセット
    self.dataSourceiPhone = @[@"iPhone 4", @"iPhone 4S", @"iPhone 5", @"iPhone 5c", @"iPhone 5s"];
    self.dataSourceAndroid = @[@"Nexus", @"Galaxy", @"Xperia"];
////
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)takePhotBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"%d", [_photoImages count]);
    return [_photoImages count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [cell setData:indexPath];
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    // 画面遷移をプログラムで実装
    PhotSelectViewController *photSelectView = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotSelectViewController"];
    photSelectView.selectedRow = row;
    // PhotSelectViewControllerの起動
    [self presentViewController:photSelectView animated:YES completion:nil];
    
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
