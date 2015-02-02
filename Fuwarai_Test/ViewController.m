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
#import "AlbumViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

@interface ViewController () {
    ALAssetsLibrary *_library;
    NSString *_AlbumName;
    NSMutableArray *_AlAssetsArr;
    NSInteger cameraPosition;
}
@property (strong, nonatomic) AVCaptureDeviceInput *videoInput;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) UIView *previewView;
@property NSInteger status;


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
    
        // 撮影ボタンを配置したツールバーを生成（下）
        UIToolbar *toolbarunder = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, 50)];
        toolbarunder.translucent = YES;
        
        // アルバムボタンを生成する
        UIBarButtonItem *album = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                                                target:self
                                                                                action:@selector(album:)];
        // カメラマークボタンを生成する
        UIBarButtonItem *camera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                            target:self
                                                                            action:@selector(takePhoto:)];
        // スペーサを生成する
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                               target:nil action:nil];
        // ライブラリボタンを生成する
        UIBarButtonItem *library = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
                                                                             target:self
                                                                             action:@selector(openLibrary:)];
        
        // toolbarunderにbuttonを配置
        NSArray *itemsunder = [NSArray arrayWithObjects:album, spacer, camera, spacer, library, nil];
        
        
        toolbarunder.items = itemsunder;
        [self.view addSubview:toolbarunder];
        
        // 撮影ボタンを配置したツールバーを生成（上）
        UIToolbar *toolbartop = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
        toolbartop.translucent = YES;
        
        // カメラの切り替えボタンを生成する
        UIBarButtonItem *turnover = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                               target:self
                                                                               action:@selector(turnover:)];
        
        // toolbarunderにbuttonを配置
        NSArray *itemstop = [NSArray arrayWithObjects:turnover, spacer, nil];
        
        toolbartop.items = itemstop;
        [self.view addSubview:toolbartop];
        
    
        // プレビュー用のビューを生成
        self.previewView = [[UIView alloc] initWithFrame:CGRectMake(0, toolbartop.frame.size.height,
                                                                self.view.bounds.size.width,
                                                                self.view.bounds.size.height - 2*(toolbarunder.frame.size.height))];
        
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
    
    // デバイスの設定
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    
    switch (cameraPosition) {
        case 0:
        {   // バックカメラを使用
            captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        }
            break;
        default:
        {
            // フロントカメラを使用
            for (AVCaptureDevice *device in videoDevices)
            {
                if (device.position == AVCaptureDevicePositionFront)
                {
                    captureDevice = device;
                    break;
                }
            }
        }
            break;
    }
    
    // カメラからの入力を作成し、セッションに追加
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
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

// カメラの切り替え
- (void)turnover:(id)sender {
    if (cameraPosition == 0) {
        cameraPosition = 1;
        [self.session stopRunning];
        [self setupAVCapture];

    } else {
        cameraPosition = 0;
        [self.session stopRunning];
        [self setupAVCapture];
    }
}

// アルバムへ
- (void)album:(id)sender {
    NSLog(@"album選択");
    
    int status = 1;
    //ユーザデフォルトに書き込む
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:status forKey:@"status"];
    [defaults synchronize];
    
    // モーダルビューを閉じる
    [self.session stopRunning];
    
    // AlbumTableViewControllerのインスタンス化
    AlbumViewController *AlbumViewController =  [self.storyboard instantiateViewControllerWithIdentifier:@"AlbumViewController"];
    
    // AlbumTableViewControllerの起動
    [self presentViewController:AlbumViewController animated:YES completion:nil];
    
}

// シャッター
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
         NSLog(@"%@", imageDataSampleBuffer);
         
         // 入力された画像データからJPEGフォーマットとしてデータを取得
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
         
         // 取得画像をカメラロールに保存
//         UIImage *cameraRoll = [[UIImage alloc]initWithData:imageData];
//         UIImageWriteToSavedPhotosAlbum(cameraRoll, nil, nil, nil);
         
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

// カメラロールから写真を選択
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
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // 選択された画像データをNSDataに変換
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    
    // 保存するディレクトリを指定します
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
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
