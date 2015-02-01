//
//  AlbumTableViewController.m
//  Fuwarai_Test
//
//  Created by sonekousuke on 2015/01/29.
//  Copyright (c) 2015年 KosukeSone. All rights reserved.
//

#import "AlbumTableViewController.h"
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AlbumTableViewCell.h"
#import "PhotSelectViewController.h"

@interface AlbumTableViewController ()
<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    ALAssetsLibrary *_library;
    NSString *_AlbumName;
    NSMutableArray *_AlAssetsArr;

}
@property (nonatomic, weak) NSMutableArray *photoImages;
@property  int countPhot;
@property (nonatomic, weak) NSArray *imageList;

@end

@implementation AlbumTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_photoImages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    
    [cell setData:indexPath];
    

    
    return cell;
    // reload tableview
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


- (void)takePhotBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
