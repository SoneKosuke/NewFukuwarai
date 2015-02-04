//
//  BaseImageSelectViewController.m
//  Fuwarai_Test
//
//  Created by sonekousuke on 2015/02/02.
//  Copyright (c) 2015年 KosukeSone. All rights reserved.
//

#import "BaseImageSelectViewController.h"
#import "BaseImageSelectTableViewCell.h"
#import "AfterTakePhotViewController.h"

typedef NS_ENUM(NSUInteger, Class){
    kind = 0,
};


@interface BaseImageSelectViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic) NSArray *kind;
@property(nonatomic) int status;
@property(nonatomic) NSString *sendString;
@property(nonatomic) NSInteger row;
@end

@implementation BaseImageSelectViewController

- (void)viewDidLoad {
    // デリゲートメソッドをこのクラスで実装
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
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
    
    //プロジェクト内のファイルにアクセスできるオブジェクトを宣言
    NSBundle *bundle = [NSBundle mainBundle];
    //湯見込むプロパティリストのファイルパスをしてい。
    NSString *path = [bundle pathForResource:@"PropertyList" ofType:@"plist"];
    //プロパティリストのデータを取得
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *kind = [dic objectForKey:@"kind"];
    
    //取得できた配列データをメンバ変数に代入
    self.kind = kind;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)takePhotBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger rows = [self.kind count];
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseImageSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [cell setData:indexPath];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _row = indexPath.row;
    if (_row == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        //ユーザデフォルトに書き込む
        _status = 1;
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:_status forKey:@"status"];
        [defaults synchronize];
        [self performSegueWithIdentifier:@"ManualUnwindSegue" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Segueの特定
    if ( [[segue identifier] isEqualToString:@"ManualUnwindSegue"] ) {
        AfterTakePhotViewController *afterTakePhotViewController = [segue destinationViewController];
        //ここで遷移先ビューのクラスの変数receiveStringに値を渡している
        afterTakePhotViewController.selectedRow = _row;
    }
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
