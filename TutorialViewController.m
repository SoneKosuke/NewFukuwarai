//
//  TutorialViewController.m
//  Fuwarai_Test
//
//  Created by sonekousuke on 2015/02/07.
//  Copyright (c) 2015年 KosukeSone. All rights reserved.
//

#import "TutorialViewController.h"
#import "MyPage.h"

@interface TutorialViewController ()

@end

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    int status = 0;
    //ユーザデフォルトに書き込む
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:status forKey:@"status"];
    [defaults synchronize];
    
    // 撮影ボタンを配置したツールバーを生成
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50)];
    toolbar.translucent = YES;
    
    // 前の画面に戻る
    UIButton *customTakePhotBackButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0, 30,30)];
    // ボタンに画像配置
    [customTakePhotBackButton setBackgroundImage:[UIImage imageNamed:@"modoru.png"] forState:UIControlStateNormal];
    // ボタンにイベントを与える。
    [customTakePhotBackButton addTarget:self action:@selector(takePhotBack:) forControlEvents:UIControlEventTouchUpInside];
    // UIBarButtonItemにUIButtonをCustomViewとして配置する。
    UIBarButtonItem *takePhotBack = [[UIBarButtonItem alloc]initWithCustomView:customTakePhotBackButton];
    
    // スペーサを生成する
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                               target:nil action:nil];
    // toolbarにbuttonを配置
    NSArray *items = [NSArray arrayWithObjects:takePhotBack, spacer, nil];
    toolbar.items = items;
    
    [self.view addSubview:toolbar];

    // Do any additional setup after loading the view.
    //ページデータ（辞書オブジェクト）の配列を作る
    NSMutableArray *pages = [NSMutableArray array];
    [pages addObject:@{@"imageName":@"Tutorial_1.png", @"caption":@"名前もない木"}];
    [pages addObject:@{@"imageName":@"flashCamera.png", @"caption":@"赤い壁の家"}];
    [pages addObject:@{@"imageName":@"flashCamera.png", @"caption":@"桜の花"}];
    [pages addObject:@{@"imageName":@"flashCamera.png", @"caption":@"青いトラック"}];
    
    //ページコントロール（ドット）の設定
    _myPageControl.numberOfPages = pages.count;
    _myPageControl.currentPage = 0;
    //ドットの色
    _myPageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    _myPageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    
    //スクロールビューのデリゲートの設定
    _myScrollView.delegate = self;
    //スクロールビューの各種設定
    _myScrollView.scrollEnabled = YES; //スクロールできる
    _myScrollView.pagingEnabled = YES; //ページでスクロールする
    _myScrollView.showsHorizontalScrollIndicator = NO; //横スクローラを表示しない
    _myScrollView.showsVerticalScrollIndicator = NO; //縦スクローラを表示しない
    _myScrollView.backgroundColor = [UIColor colorWithRed:0.80  //背景色
                                                    green:0.80
                                                     blue:0.80
                                                    alpha:1.0];
    
    //1ページのフレームサイズ
    CGRect aFrame =  _myScrollView.frame;
    //スクロールするコンテンツの縦横サイズ
    _myScrollView.contentSize = CGSizeMake(self.view.frame.size.width * pages.count,
                                           aFrame.size.height);
    
    NSLog(@"_myScrollView.contentSize.height%f", _myScrollView.contentSize.height);
    NSLog(@"_myScrollView.contentSize.width%f", _myScrollView.contentSize.width);
    
    //コンテンツを作る
    for(int i=0; i<pages.count ;i++)
    {
        //1ページ分の情報を取り出す
        NSDictionary *pageDic = pages[i];
        NSString *imageName = pageDic[@"imageName"];
        NSString *caption = pageDic[@"caption"];
        //x座標の基準点をページ数だけずらす
        CGRect pageFrame;
        pageFrame.origin.x = self.view.frame.size.width * i;
        pageFrame.origin.y = 0;
        pageFrame.size = self.view.frame.size;
        //MyPageクラスで１ページ分のコンテンツ（サブビュー）を作る
        MyPage *aMyPage = [[MyPage alloc]initWithImageName:(NSString *)imageName
                                                     frame:(CGRect)pageFrame
                                                   caption:(NSString *)caption];
        NSLog(@"pageFrame.size.width%f", pageFrame.size.width);
        NSLog(@"pageFrame.size.height%f", pageFrame.size.height);
        //スクロールビューにページを追加する
        [_myScrollView addSubview:aMyPage];
    }
}

//スクロールのデリゲートメソッド
- (void)scrollViewDidScroll:(UIScrollView *) sender
{
    //現在のページ番号を調べる
    CGFloat pageWidth = _myScrollView.frame.size.width;
    int pageNo = floor((_myScrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
    _myPageControl.currentPage = pageNo;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)takePhotBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
