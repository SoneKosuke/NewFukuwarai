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

@interface AlbumTableViewController ()
<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    ALAssetsLibrary *_library;
    NSString *_AlbumName;
    NSMutableArray *_AlAssetsArr;
//    NSMutableArray *photimage;
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
    
    NSString *hogehoge = @"hogehoge";
    NSUserDefaults* defaultshogehoge = [NSUserDefaults standardUserDefaults];
    [defaultshogehoge setObject:hogehoge forKey:@"defaultshogehoge"];
    [defaultshogehoge synchronize];
    NSLog(@"%@", hogehoge);
    
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

NSLog(@"photoImages count%lu", (unsigned long)[_photoImages count]);
    return [_photoImages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
   
    //ユーザデフォルトに書き込む
    UIImage *image = [[UIImage alloc] initWithData:_photoImages[indexPath.row]];
    [cell setData:image];
    return cell;
    // reload tableview
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
