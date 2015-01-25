//
//  AfterTakePhotViewController.m
//  Fuwarai_Test
//
//  Created by sonekousuke on 2015/01/24.
//  Copyright (c) 2015年 KosukeSone. All rights reserved.
//

#import "AfterTakePhotViewController.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>

@interface AfterTakePhotViewController (){
    UIImage* _origImage;
    UIImage* _mouthImage;
    UIImage* _lefteyeImage;
    UIImage* _righteyeImage;
    UIImage* _noseImage;
    UIImage* _gryImage;
    UIImage* _eyesImage;

}

@end

@implementation AfterTakePhotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // self.originImage.image = image;
    
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
    // 顔をバラバラにする。
    UIBarButtonItem *library = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
                                                                             target:self
                                                                             action:@selector(openLibrary:)];
    // toolbarにbuttonを配置
    NSArray *items = [NSArray arrayWithObjects:spacer, takePhotBack, spacer, library, nil];
    toolbar.items = items;
    
    [self.view addSubview:toolbar];
    
    NSUserDefaults *defaultphot = [NSUserDefaults standardUserDefaults];
    NSString *path = [defaultphot stringForKey:@"path"];
    NSLog(@"%@", path);
    
    UIImage *image= [[UIImage alloc] initWithContentsOfFile:path];
    self.imageView.image = image;
    
    // ImageView の Outlet として imageView を用意した。
    // imageView には予め画像を設定してあるので、ここで元の画像をとっておく。
    _origImage = self.imageView.image;
    _mouthImage = self.mouth.image;
    _noseImage = self.nose.image;
    _lefteyeImage = self.lefteye.image;
    _righteyeImage = self.righteye.image;

    
    int count = 0;
    
    // おまじない(結構重要。これが無いと、なかなか認識されない）
    UIGraphicsBeginImageContext(_origImage.size);
    [_origImage drawInRect:CGRectMake(0, 0, _origImage.size.width, _origImage.size.height)];
    _origImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // 画像のリサイズ
    //    _origImage = [self resizeImage:_origImage newSize:CGSizeMake(240, 300)];
    //    self.imageView.image = _origImage;
    //    _mouthImage = [self resizeImage:_mouthImage newSize:CGSizeMake(87, 32)];
    
    // imageをmat形式に変換
    cv::Mat baseMat = [self cvMatFromUIImage:_origImage];
    
    // 顔カスケードファイルの読み込み
    NSString* resDir = [[NSBundle mainBundle] resourcePath];
    const char *cascadeNameFace = "haarcascade_frontalface_alt.xml";
    NSLog(@"%s", cascadeNameFace);
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
    NSLog(@"%s", cascadeNameEye);
    
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
    NSLog(@"%s", cascadeNameNose);
    
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
    NSLog(@"%s", cascadeNameMouth);
    
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
            
            //            // 目の塗りつぶし
            //            cv::rectangle(baseMat,
            //                          cv::Point(eyes_center.x-30, eyes_center.y-25),
            //                          cv::Point(eyes_center.x+30, eyes_center.y+25),
            //                          cv::Scalar(244,202,172), -1);
            //
            //            // ガウシアンを用いた平滑化
            //            cv::Rect roi_rect(eyes_center.x-20,eyes_center.y-10,60,40); // x,y,w,h
            //            cv::Mat src_roi = baseMat(roi_rect);
            //            cv::Mat dst_roi = baseMat(roi_rect);
            
            
            
            // 切り取り画像の表示
            if ( count == 0 ) {
                
                // 切り取り
                CGRect trimArea = CGRectMake( eyes_center.x-30, eyes_center.y-25, 60, 50);
                
                // CoreGraphicsの機能を用いて,切り抜いた画像を作成する。
                CGImageRef srcImageRef = [_origImage CGImage];
                CGImageRef trimmedImageRef = CGImageCreateWithImageInRect(srcImageRef, trimArea);
                _eyesImage = [UIImage imageWithCGImage:trimmedImageRef];
                
                self.righteye.image = _eyesImage;
                count ++;
            } else if (count == 1) {
                
                // 切り取り
                CGRect trimArea = CGRectMake( eyes_center.x-30, eyes_center.y-25, 60, 50);
                
                // CoreGraphicsの機能を用いて,切り抜いた画像を作成する。
                CGImageRef srcImageRef = [_origImage CGImage];
                CGImageRef trimmedImageRef = CGImageCreateWithImageInRect(srcImageRef, trimArea);
                _eyesImage = [UIImage imageWithCGImage:trimmedImageRef];
                
                self.lefteye.image =_eyesImage;
            }
            
            
        }
        
        // 検出結果（鼻）の描画
        std::vector<cv::Rect>::const_iterator nr = nestedObjectsNose.begin();
        for(; nr != nestedObjectsNose.end(); ++nr) {
            cv::Point nose_center;
            nose_center.x = cv::saturate_cast<int>((r->x + nr->x + nr->width*0.5));
            nose_center.y = cv::saturate_cast<int>((r->y + nr->y + nr->height*0.5));
            NSLog(@"nose_center x:%d y:%d", nose_center.x, nose_center.y);
            
            //            // 鼻の塗りつぶし
            //            cv::rectangle(baseMat,
            //                          cv::Point(nose_center.x-25, nose_center.y-25),
            //                          cv::Point(nose_center.x+25, nose_center.y+25),
            //                          cv::Scalar(244,202,172), -1);
            //
            //            // ガウシアンを用いた平滑化
            //            cv::Rect roi_rect(nose_center.x-25, nose_center.y-25, 50, 50); // x,y,w,h
            //            cv::Mat src_roi = baseMat(roi_rect);
            //            cv::Mat dst_roi = baseMat(roi_rect);
            
            // CoreGraphicsの機能を用いて,切り抜いた画像を作成する。
            CGRect trimArea = CGRectMake( nose_center.x-25, nose_center.y-25, 50, 50);
            CGImageRef srcImageRef = [_origImage CGImage];
            CGImageRef trimmedImageRef = CGImageCreateWithImageInRect(srcImageRef, trimArea);
            _noseImage = [UIImage imageWithCGImage:trimmedImageRef];
            
            // 切り取り画像の表示
            self.nose.image = _noseImage;
            
        }
        
        // 検出結果（口）の描画
        std::vector<cv::Rect>::const_iterator mr = nestedObjectsMouth.begin();
        for(; mr != nestedObjectsMouth.end(); ++mr) {
            cv::Point mouth_center;
            mouth_center.x = cv::saturate_cast<int>((r->x + mr->x + mr->width*0.5));
            mouth_center.y = cv::saturate_cast<int>((r->y + mr->y + mr->height*0.5));
            NSLog(@"mouth_center x:%d y:%d", mouth_center.x, mouth_center.y);
            
            //            // 口の塗りつぶし
            //            cv::rectangle(baseMat,
            //                          cv::Point(mouth_center.x-40, mouth_center.y-20),
            //                          cv::Point(mouth_center.x+40, mouth_center.y+20),
            //                          cv::Scalar(244,202,172), -1);
            
            //            // ガウシアンを用いた平滑化
            //            cv::Rect roi_rect(mouth_center.x-30,mouth_center.y-20,60,40); // x,y,w,h
            //            cv::Mat src_roi = baseMat(roi_rect);
            //            cv::Mat dst_roi = baseMat(roi_rect);
            
            // 入力画像，出力画像，カーネルサイズ，標準偏差x, y
            //            cv::GaussianBlur(src_roi, dst_roi, cv::Size( 5, 5), 10, 10);
            
            // 切り取り
            CGRect trimArea = CGRectMake( mouth_center.x-40, mouth_center.y-20, 80, 40);
            
            // CoreGraphicsの機能を用いて、切り抜いた画像を作成する。
            CGImageRef srcImageRef = [_origImage CGImage];
            CGImageRef trimmedImageRef = CGImageCreateWithImageInRect(srcImageRef, trimArea);
            _mouthImage = [UIImage imageWithCGImage:trimmedImageRef];
            
            float heightO = _origImage.size.height;
            float widthO = _origImage.size.width;
            
            NSLog(@"%f",heightO);
            NSLog(@"%f",widthO);
            
            // 切り取り画像の表示
            self.mouth.image = _mouthImage;
            
        }
    }
    
    // 変換結果を画面に表示
    self.imageView.image = MatToUIImage(baseMat);
    
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

// イメージをリサイズする
- (UIImage *)resizeImage:(UIImage *)image newSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


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

- (IBAction)rightEyemove:(UIPanGestureRecognizer *)sender {
    CGPoint rightEyemove = [sender translationInView:self.righteye];
    CGPoint homerighteye = _righteye.center;
    homerighteye.x += rightEyemove.x;
    homerighteye.y += rightEyemove.y;
    _righteye.center = homerighteye;
    
    [sender setTranslation:CGPointZero inView:self.righteye];
}

- (IBAction)leftEyeMove:(UIPanGestureRecognizer *)sender {
    CGPoint leftEyeMove = [sender translationInView:self.lefteye];
    CGPoint homelefteye = _lefteye.center;
    homelefteye.x += leftEyeMove.x;
    homelefteye.y += leftEyeMove.y;
    _lefteye.center = homelefteye;
    
    [sender setTranslation:CGPointZero inView:self.lefteye];
}

- (IBAction)noseMove:(UIPanGestureRecognizer *)sender {
    CGPoint noseMove = [sender translationInView:self.nose];
    CGPoint homeLoc = _nose.center;
    homeLoc.x += noseMove.x;
    homeLoc.y += noseMove.y;
    _nose.center = homeLoc;
    
    [sender setTranslation:CGPointZero inView:self.nose];
}

- (IBAction)mouthMove:(UIPanGestureRecognizer *)sender {
    CGPoint mouthMove = [sender translationInView:self.mouth];
    CGPoint homeLoc = _mouth.center;
    homeLoc.x += mouthMove.x;
    homeLoc.y += mouthMove.y;
    _mouth.center = homeLoc;
    
    [sender setTranslation:CGPointZero inView:self.mouth];
}


@end
