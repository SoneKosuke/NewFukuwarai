//
//  AfterTakePhotViewController.m
//  Fuwarai_Test
//
//  Created by sonekousuke on 2015/01/24.
//  Copyright (c) 2015年 KosukeSone. All rights reserved.
//

#import "AfterTakePhotViewController.h"
#import "BaseImageSelectViewController.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>


@interface AfterTakePhotViewController (){
    UIImage* _origImage;
    UIImage* _mouthImage;
    UIImage* _lefteyeImage;
    UIImage* _righteyeImage;
    UIImage* _noseImage;
    UIImage* _gryImage;
    UIImage* _eyesImage;
    ALAssetsLibrary *_library;
    NSURL *_groupURL;
    NSString *_AlbumName;
    
    //アルバムが写真アプリに既にあるかどうかの判定用
    BOOL _albumWasFound;
    CGAffineTransform currentTransForm;
}
@property (nonatomic) int status;
@property (nonatomic) NSInteger noseImageDoubleTapCount;
@property (nonatomic) NSInteger mouthImageDoubleTapCount;
@property (nonatomic) NSInteger righteyeImageDoubleTapCount;
@property (nonatomic) NSInteger lefteyeImageDoubleTapCount;
@property (nonatomic) NSInteger albumCount;
@property (nonatomic) CGFloat mouthrotation;

@end

@implementation AfterTakePhotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _noseImageDoubleTapCount = 0;
    _mouthImageDoubleTapCount = 0;
    _righteyeImageDoubleTapCount = 0;
    _lefteyeImageDoubleTapCount = 0;
    _status = 0;
    
    //ユーザデフォルトに書き込む
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:_status forKey:@"status"];
    [defaults synchronize];
    int eyesCount = 0;
    
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
    
    // shareボタン
    UIButton *customShareButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0, 30,30)];
    // ボタンに画像配置
    [customShareButton setBackgroundImage:[UIImage imageNamed:@"upload.png"] forState:UIControlStateNormal];
    // ボタンにイベントを与える。
    [customShareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    // UIBarButtonItemにUIButtonをCustomViewとして配置する。
    UIBarButtonItem *share = [[UIBarButtonItem alloc]initWithCustomView:customShareButton];

    // albumボタン
    UIButton *customBaseImageSelectButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0, 30,30)];
    // ボタンに画像配置
    [customBaseImageSelectButton setBackgroundImage:[UIImage imageNamed:@"selectbase.png"] forState:UIControlStateNormal];
    // ボタンにイベントを与える。
    [customBaseImageSelectButton addTarget:self action:@selector(baseImageSelect:) forControlEvents:UIControlEventTouchUpInside];
    // UIBarButtonItemにUIButtonをCustomViewとして配置する。
    UIBarButtonItem *baseImageSelect = [[UIBarButtonItem alloc]initWithCustomView:customBaseImageSelectButton];
    
    // ベース画像選択後のベース画像選択ボタン
    UIBarButtonItem *baseImageSelectAgain = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                                                     target:self
                                                                                     action:@selector(baseImageSelectAgain:)];
    if (self.selectedRow) {
        // toolbarにbuttonを配置
        NSArray *itemsBaseImageSelect = [NSArray arrayWithObjects:takePhotBack, spacer, share, spacer, baseImageSelectAgain, nil];
        toolbar.items = itemsBaseImageSelect;
    } else {
        NSArray *items = [NSArray arrayWithObjects:takePhotBack, spacer, share, spacer, baseImageSelect, nil];
        toolbar.items = items;
    }

    [self.view addSubview:toolbar];
    
    // 保存した画像の読み出し
    NSUserDefaults *defaultphot = [NSUserDefaults standardUserDefaults];
    NSString *path = [defaultphot stringForKey:@"path"];
    
    UIImage *image= [[UIImage alloc] initWithContentsOfFile:path];
    self.imageView.image = image;
    
    _origImage = self.imageView.image;
    _mouthImage = self.mouth.image;
    _noseImage = self.nose.image;
    _lefteyeImage = self.lefteye.image;
    _righteyeImage = self.righteye.image;
    
    // 画像のリサイズ
    _origImage = [self resizeImage:_origImage newSize:CGSizeMake(312, 390)];
    
    // おまじない(結構重要。これが無いと、なかなか認識されない）
    UIGraphicsBeginImageContext(_origImage.size);
    [_origImage drawInRect:CGRectMake(0, 0, _origImage.size.width, _origImage.size.height)];
    _origImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // imageをmat形式に変換
    cv::Mat baseMat = [self cvMatFromUIImage:_origImage];
    // 顔カスケードファイルの読み込み
    NSString* resDir = [[NSBundle mainBundle] resourcePath];
    const char *cascadeNameFace = "haarcascade_frontalface_alt.xml";
    char cascade_path[PATH_MAX];
    sprintf(cascade_path, "%s/%s", [resDir cStringUsingEncoding:NSASCIIStringEncoding], cascadeNameFace );
    cv::CascadeClassifier cascade;
    if(!cascade.load(cascade_path)) {
        NSLog(@"loading failed");
        
        return;
    } else {
        NSLog(@"loading success");
    }
    std::vector<cv::Rect> faces;
    
    // マルチスケール（顔）探索
    // 画像，出力矩形，縮小スケール，最低矩形数，（フラグ），最小矩形
    cascade.detectMultiScale(baseMat, faces, 1.1, 2, cv::CASCADE_SCALE_IMAGE, cv::Size(30, 30));
    
    // 目カスケードファイルの読み込み
    NSString* resDirEye = [[NSBundle mainBundle] resourcePath];
    const char *cascadeNameEye = "haarcascade_eye.xml";
    
    char cascadePathEye[PATH_MAX];
    sprintf(cascadePathEye, "%s/%s", [resDirEye cStringUsingEncoding:NSASCIIStringEncoding], cascadeNameEye );
    cv::CascadeClassifier cascadeName_Eye;
    
    if(!cascadeName_Eye.load(cascadePathEye)) {
        NSLog(@"loading failed");
        return;
    } else {
        NSLog(@"loading success");
    }
    
    // 鼻　カスケードファイルの読み込み
    NSString* resDirNose = [[NSBundle mainBundle] resourcePath];
    const char *cascadeNameNose = "haarcascade_mcs_nose.xml";
    
    char cascadePathNose[PATH_MAX];
    sprintf(cascadePathNose, "%s/%s", [resDirNose cStringUsingEncoding:NSASCIIStringEncoding], cascadeNameNose );
    cv::CascadeClassifier cascadeName_Nose;
    
    if(!cascadeName_Nose.load(cascadePathNose)) {
        NSLog(@"loading failed");
        return;
    } else {
        NSLog(@"loading success");
    }
    
    // 口　カスケードファイルの読み込み
    NSString* resDirMouth = [[NSBundle mainBundle] resourcePath];
    const char *cascadeNameMouth = "haarcascade_mcs_mouth.xml";
    
    char cascadePathMouth[PATH_MAX];
    sprintf(cascadePathMouth, "%s/%s", [resDirMouth cStringUsingEncoding:NSASCIIStringEncoding], cascadeNameMouth );
    cv::CascadeClassifier cascadeName_Mouth;
    
    if(!cascadeName_Mouth.load(cascadePathMouth)) {
        NSLog(@"loading failed");
        return;
    } else {
        NSLog(@"loading success");
    }
    
    // 顔位置に丸を描く
    std::vector<cv::Rect>::const_iterator r = faces.begin();
    for(; r != faces.end(); ++r) {
        cv::Point face_center;
        face_center.x = cv::saturate_cast<int>((r->x + r->width*0.5));
        face_center.y = cv::saturate_cast<int>((r->y + r->height*0.5));
        NSLog(@"face_center x:%d y:%d", face_center.x, face_center.y);
        
        // 画像，出力矩形，縮小スケール，最低矩形数，（フラグ），最小矩形
        cv:: Mat smallImgROIEye = baseMat(*r);
        std::vector<cv::Rect> nestedObjectsEye;
        cascadeName_Eye.detectMultiScale(smallImgROIEye, nestedObjectsEye, 1.3, 3, cv::CASCADE_SCALE_IMAGE, cv::Size(30,30));
        
        // 画像，出力矩形，縮小スケール，最低矩形数，（フラグ），最小矩形
        cv:: Mat smallImgROINose = baseMat(*r);
        std::vector<cv::Rect> nestedObjectsNose;
        cascadeName_Nose.detectMultiScale(smallImgROINose, nestedObjectsNose, 1.3, 3, cv::CASCADE_SCALE_IMAGE, cv::Size(30,30));
        // 画像，出力矩形，縮小スケール，最低矩形数，（フラグ），最小矩形
        cv:: Mat smallImgROIMouth = baseMat(*r);
        std::vector<cv::Rect> nestedObjectsMouth;
        cascadeName_Mouth.detectMultiScale(smallImgROIMouth, nestedObjectsMouth, 2.5, 3, cv::CASCADE_SCALE_IMAGE, cv::Size(30,30));
        
        // 検出結果（目）の描画
        std::vector<cv::Rect>::const_iterator er = nestedObjectsEye.begin();
        for(; er != nestedObjectsEye.end(); ++er) {
            cv::Point eyes_center;
            eyes_center.x = cv::saturate_cast<int>((r->x + er->x + er->width*0.5));
            eyes_center.y = cv::saturate_cast<int>((r->y + er->y + er->height*0.5));
            NSLog(@"eyes_center x:%d y:%d", eyes_center.x, eyes_center.y);
            
            // 切り取り画像の表示
            if (eyesCount == 0) {
                
                // 切り取り
                CGRect trimArea = CGRectMake( eyes_center.x-30, eyes_center.y-25, 60, 50);
                
                // CoreGraphicsの機能を用いて,切り抜いた画像を作成する。
                CGImageRef srcImageRef = [_origImage CGImage];
                CGImageRef trimmedImageRef = CGImageCreateWithImageInRect(srcImageRef, trimArea);
                _eyesImage = [UIImage imageWithCGImage:trimmedImageRef];
                
                self.righteye.image = _eyesImage;
                // 切り出し画像の面取り
                _righteye.layer.cornerRadius = _righteye.frame.size.width * 0.1f;
                _righteye.clipsToBounds = YES;
                
                eyesCount ++;
            } else if (eyesCount == 1) {
                
                // 切り取り
                CGRect trimArea = CGRectMake( eyes_center.x-30, eyes_center.y-25, 60, 50);
                
                // CoreGraphicsの機能を用いて,切り抜いた画像を作成する。
                CGImageRef srcImageRef = [_origImage CGImage];
                CGImageRef trimmedImageRef = CGImageCreateWithImageInRect(srcImageRef, trimArea);
                _eyesImage = [UIImage imageWithCGImage:trimmedImageRef];
                
                self.lefteye.image =_eyesImage;
                // 切り出し画像の面取り
                _lefteye.layer.cornerRadius = _lefteye.frame.size.width * 0.1f;
                _lefteye.clipsToBounds = YES;
            }
        }
        
        // 検出結果（鼻）の描画
        std::vector<cv::Rect>::const_iterator nr = nestedObjectsNose.begin();
        for(; nr != nestedObjectsNose.end(); ++nr) {
            cv::Point nose_center;
            nose_center.x = cv::saturate_cast<int>((r->x + nr->x + nr->width*0.5));
            nose_center.y = cv::saturate_cast<int>((r->y + nr->y + nr->height*0.5));
            NSLog(@"nose_center x:%d y:%d", nose_center.x, nose_center.y);
            
            // CoreGraphicsの機能を用いて,切り抜いた画像を作成する。
            CGRect trimArea = CGRectMake( nose_center.x-25, nose_center.y-25, 50, 50);
            CGImageRef srcImageRef = [_origImage CGImage];
            CGImageRef trimmedImageRef = CGImageCreateWithImageInRect(srcImageRef, trimArea);
            _noseImage = [UIImage imageWithCGImage:trimmedImageRef];
            
            self.nose.image = _noseImage;
            // 切り出し画像の面取り
            _nose.layer.cornerRadius = _nose.frame.size.width * 0.1f;
            _nose.clipsToBounds = YES;
            
        }
        
        // 検出結果（口）の描画
        std::vector<cv::Rect>::const_iterator mr = nestedObjectsMouth.begin();
        for(; mr != nestedObjectsMouth.end(); ++mr) {
            cv::Point mouth_center;
            mouth_center.x = cv::saturate_cast<int>((r->x + mr->x + mr->width*0.5));
            mouth_center.y = cv::saturate_cast<int>((r->y + mr->y + mr->height*0.5));
            NSLog(@"mouth_center x:%d y:%d", mouth_center.x, mouth_center.y);
            
            // 切り取り
            CGRect trimArea = CGRectMake( mouth_center.x-40, mouth_center.y-20, 80, 40);
            
            // CoreGraphicsの機能を用いて、切り抜いた画像を作成する。
            CGImageRef srcImageRef = [_origImage CGImage];
            CGImageRef trimmedImageRef = CGImageCreateWithImageInRect(srcImageRef, trimArea);
            _mouthImage = [UIImage imageWithCGImage:trimmedImageRef];
            
            // 切り取り画像の表示
            self.mouth.image = _mouthImage;
            // 切り出し画像の面取り
            _mouth.layer.cornerRadius = _mouth.frame.size.width * 0.1f;
            _mouth.clipsToBounds = YES;
            
        }
        
        // ベースイメージを表示
        UIImage *baseImage = MatToUIImage(baseMat);
        self.imageView.image = baseImage;
        
        // ダブルタップイベントを作成
        UITapGestureRecognizer *noseImageDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(noseImageDoubleTap:)];
        noseImageDoubleTap.numberOfTapsRequired = 2;
        [self.nose addGestureRecognizer:noseImageDoubleTap];
        
        UITapGestureRecognizer *mouthImageDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(mouthImageDoubleTap:)];
        mouthImageDoubleTap.numberOfTapsRequired = 2;
        [self.mouth addGestureRecognizer:mouthImageDoubleTap];
        
        UITapGestureRecognizer *righteyeImageDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(righteyeImageDoubleTap:)];
        righteyeImageDoubleTap.numberOfTapsRequired = 2;
        [self.righteye addGestureRecognizer:righteyeImageDoubleTap];
        
        UITapGestureRecognizer *lefteyeImageDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(lefteyeImageDoubleTap:)];
        lefteyeImageDoubleTap.numberOfTapsRequired = 2;
        [self.lefteye addGestureRecognizer:lefteyeImageDoubleTap];
    }
    
    // 検出したパーツの数を確認
    NSInteger facePartCount = 0;
    if (self.mouth.image) {
        facePartCount ++;
    }
    if (self.nose.image) {
        facePartCount ++;
    }
    if (self.lefteye.image) {
        facePartCount ++;
    }
    if (self.righteye.image) {
        facePartCount ++;
    }

    if (facePartCount < 4) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Your face couldn't be recognize"
                                  message:@"Please try again"
                                  delegate:self
                                  cancelButtonTitle:@"Close"
                                  otherButtonTitles:nil];
        
        [alertView show];
    } else {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
}

- (void)alertView:(UIAlertView*)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            _status = 0;
            //ユーザデフォルトに書き込む
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:_status forKey:@"status"];
            [defaults synchronize];
            [[UIApplication sharedApplication].delegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
            break;
    }
}

// イメージをリサイズする
- (UIImage *)resizeImage:(UIImage *)image newSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

// UIImageからMatに変換
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

// MatからUIImageへ変換
-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 戻るボタンが押された時
- (void)takePhotBack:(id)sender {
    _status = 0;
    //ユーザデフォルトに書き込む
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:_status forKey:@"status"];
    [defaults synchronize];
    [[UIApplication sharedApplication].delegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    
}

// 保存・シェアボタンが押された時
- (void)share:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Save・Share"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Save", @"Share on FaceBook", @"Share on Twitter", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            // キャプチャ画像を描画する対象を生成します。
            CGSize size = CGSizeMake(self.imageView.bounds.size.width , self.imageView.bounds.size.height);
            UIGraphicsBeginImageContextWithOptions(size, NO, 0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            // コンテキストの位置を切り取り開始位置に合わせる
            CGPoint point = self.imageView.frame.origin;
            CGAffineTransform affineMoveLeftTop
            = CGAffineTransformMakeTranslation(
                                               -(int)point.x ,
                                               -(int)point.y );
            CGContextConcatCTM(context , affineMoveLeftTop );
            
            // viewから切り取る
            [(CALayer*)self.view.layer renderInContext:context];
            
            // 描画した内容をUIImageとして受け取ります。
            UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
            
            // 描画を終了します。
            UIGraphicsEndImageContext();
            
            // ALAssetLibraryのインスタン作成
            _library = [[ALAssetsLibrary alloc] init];
            _AlbumName = @"Fukuwarai";
            
            if (_albumCount == 1) {
                _albumWasFound = TRUE;
            } else {
                _albumWasFound = FALSE;
            }
            
            // アルバムを検索してなかったら新規作成、あったらアルバムのURLを保持
            [_library enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if (group) {
                    if ([_AlbumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {

                        // URLをクラスインスタンスに保持
                        _groupURL = [group valueForProperty:ALAssetsGroupPropertyURL];
                        _albumWasFound = TRUE;
                        
                    // アルバムがない場合は新規作成
                    }else if (_albumWasFound == FALSE) {
                        ALAssetsLibraryGroupResultBlock resultBlock = ^(ALAssetsGroup *group) {
                        _groupURL = [group valueForProperty:ALAssetsGroupPropertyURL];
                    };
                                                
                    // 新しいアルバムを作成
                    [_library addAssetsGroupAlbumWithName:_AlbumName resultBlock:resultBlock failureBlock: nil];
                        _albumWasFound = TRUE;
                    }
                }
            } failureBlock:nil];
            
            // カメラロールにUIImageを保存する。保存完了後、completionBlockで「NSURL* assetURL」が取得できる
            [_library writeImageToSavedPhotosAlbum:capturedImage.CGImage orientation:(ALAssetOrientation)capturedImage.imageOrientation completionBlock:^(NSURL* assetURL, NSError* error) {

                // アルバムにALAssetを追加するメソッド
                [self addAssetURL:assetURL AlbumURL:_groupURL];
                _albumCount = 1;
                }
             ];
        }
            break;
        case 1:
            // 組み込みのFacebookが利用可能な端末かを検証する
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                
                // キャプチャ画像を描画する対象を生成します。
                CGSize size = CGSizeMake(self.imageView.bounds.size.width , self.imageView.bounds.size.height);
                UIGraphicsBeginImageContextWithOptions(size, NO, 0);
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                // コンテキストの位置を切り取り開始位置に合わせる
                CGPoint point = self.imageView.frame.origin;
                CGAffineTransform affineMoveLeftTop
                = CGAffineTransformMakeTranslation(
                                                   -(int)point.x ,
                                                   -(int)point.y );
                CGContextConcatCTM(context , affineMoveLeftTop );
                
                // viewから切り取る
                [(CALayer*)self.view.layer renderInContext:context];
                
                // 描画した内容をUIImageとして受け取ります。
                UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
                
                // 描画を終了します。
                UIGraphicsEndImageContext();
                
                // Facebook投稿機能のインスタンスを作成する
                SLComposeViewController *slComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                
                // 投稿するコンテンツを設定する
                // 表示する文字列
                [slComposeViewController setInitialText:@"Fukuwarai"];
                // URL
//                [slComposeViewController addURL:[NSURL URLWithString:@"http://www.yoheim.net/"]];
                // 画像
                [slComposeViewController addImage:capturedImage];
                
                // 処理終了後に呼び出されるコールバックを指定する
                [slComposeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
                    
                    switch (result) {
                        case SLComposeViewControllerResultDone:
                            NSLog(@"Done!!");
                            break;
                        case SLComposeViewControllerResultCancelled:
                            NSLog(@"Cancel!!");
                    }
                }];  
                
                // 表示する
                [self presentViewController:slComposeViewController animated:YES completion:nil];    
            } else {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"Couldn't be Share"
                                          message:@"Please Sing in FaceBook"
                                          delegate:self
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles:nil];
                
                [alertView show];

            }
            break;
        case 2:
            // 組み込みのTwitterが利用可能な端末かを検証する
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
                
                // キャプチャ画像を描画する対象を生成します。
                CGSize size = CGSizeMake(self.imageView.bounds.size.width , self.imageView.bounds.size.height);
                UIGraphicsBeginImageContextWithOptions(size, NO, 0);
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                // コンテキストの位置を切り取り開始位置に合わせる
                CGPoint point = self.imageView.frame.origin;
                CGAffineTransform affineMoveLeftTop
                = CGAffineTransformMakeTranslation(
                                                   -(int)point.x ,
                                                   -(int)point.y );
                CGContextConcatCTM(context , affineMoveLeftTop );
                
                // viewから切り取る
                [(CALayer*)self.view.layer renderInContext:context];

                
                // 描画した内容をUIImageとして受け取ります。
                UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
                
                // 描画を終了します。
                UIGraphicsEndImageContext();
                
                // Twitter投稿機能のインスタンスを作成する
                SLComposeViewController *slComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                
                // 投稿するコンテンツを設定する
                // 表示する文字列
                [slComposeViewController setInitialText:@"Fukuwarai"];
                // URL
                //                [slComposeViewController addURL:[NSURL URLWithString:@"http://www.yoheim.net/"]];
                // 画像
                [slComposeViewController addImage:capturedImage];
                
                // 処理終了後に呼び出されるコールバックを指定する
                [slComposeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
                    
                    switch (result) {
                        case SLComposeViewControllerResultDone:
                            NSLog(@"Done!!");
                            break;
                        case SLComposeViewControllerResultCancelled:
                            NSLog(@"Cancel!!");
                    }
                }];
                
                // 表示する
                [self presentViewController:slComposeViewController animated:YES completion:nil];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"Couldn't be Share"
                                          message:@"Please Sing in Twitter"
                                          delegate:self
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles:nil];
                
                [alertView show];
                
            }
            break;
        default:
            NSLog(@"Cansel");
            break;
    }
}

// アルバムにALAssetを追加するメソッド
- (void)addAssetURL:(NSURL*)assetURL AlbumURL:(NSURL *)albumURL{
    
    // URLからGroupを取得
    [_library groupForURL:albumURL resultBlock:^(ALAssetsGroup *group){
        
        // URLからALAssetを取得
        [_library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            if (group.editable) {
                
                // GroupにAssetを追加
                [group addAsset:asset];

            } else {

            }
        } failureBlock: nil];
    } failureBlock:nil];
}

// ベースイメージセレクトボタンが押された時
- (void)baseImageSelect:(id)sender {
    BaseImageSelectViewController *baseImageSelectViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BaseImageSelectViewController"];
    [self presentViewController:baseImageSelectViewController animated:YES completion:nil];
}

// baseImageSelectAgainが押された時
- (void) baseImageSelectAgain:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)rightEyemove:(UIPanGestureRecognizer *)sender {
    CGPoint rightEyemove = [sender translationInView:self.imageView];
    CGPoint homerighteye = _righteye.center;
    homerighteye.x += rightEyemove.x;
    homerighteye.y += rightEyemove.y;
    _righteye.center = homerighteye;
    
    [sender setTranslation:CGPointZero inView:self.righteye];
}

- (IBAction)leftEyeMove:(UIPanGestureRecognizer *)sender {
    CGPoint leftEyeMove = [sender translationInView:self.imageView];
    CGPoint homelefteye = _lefteye.center;
    homelefteye.x += leftEyeMove.x;
    homelefteye.y += leftEyeMove.y;
    _lefteye.center = homelefteye;
    
    [sender setTranslation:CGPointZero inView:self.lefteye];
}

- (IBAction)noseMove:(UIPanGestureRecognizer *)sender {
    CGPoint noseMove = [sender translationInView:self.imageView];
    CGPoint homeLoc = _nose.center;
    homeLoc.x += noseMove.x;
    homeLoc.y += noseMove.y;
    _nose.center = homeLoc;
    
    [sender setTranslation:CGPointZero inView:self.nose];
}

- (IBAction)mouthMove:(UIPanGestureRecognizer *)sender {
    CGPoint mouthMove = [sender translationInView:self.imageView];
    CGPoint homeLoc = _mouth.center;
    homeLoc.x += mouthMove.x;
    homeLoc.y += mouthMove.y;
    _mouth.center = homeLoc;
    
    [sender setTranslation:CGPointZero inView:self.mouth];
}

- (IBAction)nosePinch:(UIPinchGestureRecognizer *)sender {
    // ピンチジェスチャー発生時に、Imageの現在のアフィン変形の状態を保存する
    if (sender.state == UIGestureRecognizerStateBegan) {
        currentTransForm = self.nose.transform;
    }
    
    // ピンチジェスチャー発生時から、どれだけ拡大率が変化したかを取得する
    // 2本の指の距離が離れた場合には、1以上の値、近づいた場合には、1以下の値が取得できる
    CGFloat scale = [sender scale];
    // ピンチジェスチャー開始時からの拡大率の変化を、imgViewのアフィン変形の状態に設定する事で、拡大する。
    self.nose.transform = CGAffineTransformConcat(currentTransForm, CGAffineTransformMakeScale(scale, scale));
}

- (IBAction)mouthPinch:(UIPinchGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        currentTransForm = self.mouth.transform;
    }
    CGFloat scale = [sender scale];
    self.mouth.transform = CGAffineTransformConcat(currentTransForm, CGAffineTransformMakeScale(scale, scale));
}

- (IBAction)leftEyePinch:(UIPinchGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        currentTransForm = self.lefteye.transform;
    }
    CGFloat scale = [sender scale];
    self.lefteye.transform = CGAffineTransformConcat(currentTransForm, CGAffineTransformMakeScale(scale, scale));
}

- (IBAction)rightEyePinch:(UIPinchGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        currentTransForm = self.righteye.transform;
    }
    CGFloat scale = [sender scale];
    self.righteye.transform = CGAffineTransformConcat(currentTransForm, CGAffineTransformMakeScale(scale, scale));
}

- (IBAction)rightRotation:(UIRotationGestureRecognizer *)sender {
    CGFloat rotation = [sender rotation];
    self.righteye.transform = CGAffineTransformMakeRotation(rotation);
}

- (IBAction)leftRotation:(UIRotationGestureRecognizer *)sender {
    CGFloat rotation = [sender rotation];
    self.lefteye.transform = CGAffineTransformMakeRotation(rotation);
}

- (IBAction)noseRotation:(UIRotationGestureRecognizer *)sender {
    CGFloat rotation = [sender rotation];
    self.nose.transform = CGAffineTransformMakeRotation(rotation);
}

- (IBAction)mouthRotation:(UIRotationGestureRecognizer *)sender {
    _mouthrotation = [sender rotation];
    self.mouth.transform = CGAffineTransformMakeRotation(_mouthrotation);
}

- (void)noseImageDoubleTap:(UITapGestureRecognizer *)recognizer {
    currentTransForm = self.nose.transform;
    int noseImageDoubleTapCountRemainder = _noseImageDoubleTapCount % 2;
    if (noseImageDoubleTapCountRemainder == 0) {
        self.nose.transform = CGAffineTransformConcat(currentTransForm, CGAffineTransformMakeScale(2, 2));
    } else {
        self.nose.transform = CGAffineTransformConcat(currentTransForm, CGAffineTransformMakeScale(0.5f, 0.5f));
    }
    _noseImageDoubleTapCount ++;
}

- (void)mouthImageDoubleTap:(UITapGestureRecognizer *)recognizer {
    currentTransForm = self.mouth.transform;
    int mouthImageDoubleTapCountRemainder = _mouthImageDoubleTapCount % 2;
    if (mouthImageDoubleTapCountRemainder == 0) {
        self.mouth.transform = CGAffineTransformConcat(currentTransForm, CGAffineTransformMakeScale(2, 2));
    } else {
        self.mouth.transform = CGAffineTransformConcat(currentTransForm, CGAffineTransformMakeScale(0.5f, 0.5f));
    }
    _mouthImageDoubleTapCount ++;
}

- (void)righteyeImageDoubleTap:(UITapGestureRecognizer *)recognizer {
    currentTransForm = self.righteye.transform;
    int righteyeImageDoubleTapCountRemainder = _righteyeImageDoubleTapCount % 2;
    if (righteyeImageDoubleTapCountRemainder == 0) {
        self.righteye.transform = CGAffineTransformConcat(currentTransForm, CGAffineTransformMakeScale(2, 2));
    } else {
        self.righteye.transform = CGAffineTransformConcat(currentTransForm, CGAffineTransformMakeScale(0.5f, 0.5f));
    }
    _righteyeImageDoubleTapCount ++;
}

- (void)lefteyeImageDoubleTap:(UITapGestureRecognizer *)recognizer {
    currentTransForm = self.lefteye.transform;
    int lefteyeImageDoubleTapCountRemainder = _lefteyeImageDoubleTapCount % 2;
    if (lefteyeImageDoubleTapCountRemainder == 0) {
        self.lefteye.transform = CGAffineTransformConcat(currentTransForm, CGAffineTransformMakeScale(2, 2));
    } else {
        self.lefteye.transform = CGAffineTransformConcat(currentTransForm, CGAffineTransformMakeScale(0.5f, 0.5f));
    }
    _lefteyeImageDoubleTapCount ++;
}


- (IBAction)firstViewReturnActionForSegue:(UIStoryboardSegue *)segue
{
    //プロジェクト内のファイルにアクセスできるオブジェクトを宣言
    NSBundle *bundle = [NSBundle mainBundle];
    //湯見込むプロパティリストのファイルパスをしてい。
    NSString *pathBaseImage = [bundle pathForResource:@"PropertyList" ofType:@"plist"];
    //プロパティリストのデータを取得
    NSDictionary *dicBaseImage = [NSDictionary dictionaryWithContentsOfFile:pathBaseImage];
    NSArray *document = [dicBaseImage objectForKey:@"document"];
    
    if (self.selectedRow == 0) {
        self.imageView.image = _origImage;
    } else {
        self.imageView.image = [UIImage imageNamed:document[self.selectedRow]];
    }
}


@end
