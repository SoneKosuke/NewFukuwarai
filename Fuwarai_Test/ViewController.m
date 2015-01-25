//
//  ViewController.m
//  Fuwarai_Test
//
//  Created by sonekousuke on 2015/01/09.
//  Copyright (c) 2015年 KosukeSone. All rights reserved.
//

#import "ViewController.h"
#import "AfterTakePhotViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface ViewController ()
@property (strong, nonatomic) AVCaptureDeviceInput *videoInput;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) UIView *previewView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //ユーザーデフォルトから文字を読み出す。
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int status = [defaults integerForKey:@"status"];
    NSLog(@"%d", status);
    
    if (status == 0) {
    
        // 撮影ボタンを配置したツールバーを生成
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, 50)];
        toolbar.translucent = YES;
        
        // アルバムを生成する
        UIBarButtonItem *album = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                                                target:self
                                                                                action:@selector(album:)];
        // カメラマークを生成する
        UIBarButtonItem *camera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                            target:self
                                                                            action:@selector(takePhoto:)];
        // スペーサを生成する
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                               target:nil action:nil];
        // ライブラリを生成する
        UIBarButtonItem *library = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
                                                                             target:self
                                                                             action:@selector(openLibrary:)];
        // toolbarにbuttonを配置
        NSArray *items = [NSArray arrayWithObjects:album, spacer, camera, spacer, library, nil];
        toolbar.items = items;
        [self.view addSubview:toolbar];
    
        // プレビュー用のビューを生成
        self.previewView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                toolbar.frame.size.height,
                                                                self.view.bounds.size.width,
                                                                self.view.bounds.size.height - 2*toolbar.frame.size.height)];
        [self.view addSubview:self.previewView];
    }
}


- (void)tearDownAVCapture
{
    // メモリの解放処理
    [self.session stopRunning];
    for (AVCaptureOutput *output in self.session.outputs) {
        [self.session removeOutput:output];
    }
    for (AVCaptureInput *input in self.session.inputs) {
        [self.session removeInput:input];
    }
    self.stillImageOutput = nil;
    self.videoInput = nil;
    self.session = nil;
}


- (void)viewWillAppear:(BOOL)animated
{
    //撮影開始
    [self setupAVCapture];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // メモリ解放開始
    [self tearDownAVCapture];
}

- (void)setupAVCapture
{
    NSError *error = nil;
    
    // 入力と出力からキャプチャーセッションを作成
    self.session = [[AVCaptureSession alloc] init];
    
    // 正面に配置されているカメラを取得
    AVCaptureDevice *camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // カメラからの入力を作成し、セッションに追加
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];
    [self.session addInput:self.videoInput];
    
    // 画像への出力を作成し、セッションに追加
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    [self.session addOutput:self.stillImageOutput];
    
    // キャプチャーセッションから入力のプレビュー表示を作成
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    captureVideoPreviewLayer.frame = self.view.bounds;
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    // レイヤーをViewに設定
    CALayer *previewLayer = self.previewView.layer;
    previewLayer.masksToBounds = YES;
    [previewLayer addSublayer:captureVideoPreviewLayer];
    
    // セッション開始
    [self.session startRunning];
    
}

- (void)album:(id)sender {
    NSLog(@"album選択");
}

- (void)takePhoto:(id)sender
{
    // ビデオ入力のAVCaptureConnectionを取得
    AVCaptureConnection *videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if (videoConnection == nil) {
        return;
    }
    
    // ビデオ入力から画像を非同期で取得。ブロックで定義されている処理が呼び出され、画像データを引数から取得する
    [self.stillImageOutput
     captureStillImageAsynchronouslyFromConnection:videoConnection
     completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
         if (imageDataSampleBuffer == NULL) {
             return;
         }
         
         // 入力された画像データからJPEGフォーマットとしてデータを取得
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
         
         // JPEGデータからUIImageを作成
//         UIImage *image = [[UIImage alloc] initWithData:imageData];
         
         // 保存するディレクトリを指定します
         // ここではデータを保存する為に一般的に使われるDocumentsディレクトリ
         NSString *path = [NSString stringWithFormat:@"%@/sample.jpg",
                           [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
         
         // NSDataのwriteToFileメソッドを使ってファイルに書き込みます
         // atomically=YESの場合、同名のファイルがあったら、まずは別名で作成して、その後、ファイルの上書きを行います
         if ([imageData writeToFile:path atomically:YES]) {
             NSLog(@"save OK");
             NSLog(@"%@", path);
             
             NSUserDefaults* defaultphot = [NSUserDefaults standardUserDefaults];
             [defaultphot setObject:path forKey:@"path"];
             [defaultphot synchronize];
             
         } else {
             NSLog(@"save NG");
         }
         
//         // アルバムに画像を保存
//         UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
         
         int status = 1;
         //ユーザデフォルトに書き込む
         NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
         [defaults setInteger:status forKey:@"status"];
         [defaults synchronize];
         
         // モーダルビューを閉じる
         [self.session stopRunning];
         
         // AfterTakePhotViewControllerのインスタンス化
         AfterTakePhotViewController *AfterTakePhotVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"AfterTakePhotViewController"];
         
         // AfterTakePhotViewControllerの起動
         [self presentViewController:AfterTakePhotVC animated:YES completion:nil];
         
     }];
}

- (void)openLibrary:(id)sender {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = sourceType;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:NULL];
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:^{
    self.originImage.image = image;
    }];
    
    int status = 1;
    //ユーザデフォルトに書き込む
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:status forKey:@"status"];
    [defaults synchronize];
    
//    // モーダルビューを閉じる
//    [self.session stopRunning];
    
    // AfterTakePhotViewControllerのインスタンス化
    AfterTakePhotViewController *AfterTakePhotVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"AfterTakePhotViewController"];
    
    // AfterTakePhotViewControllerの起動
    [self presentViewController:AfterTakePhotVC animated:YES completion:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
