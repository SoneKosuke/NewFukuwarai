//
//  AfterTakePhotViewController.h
//  Fuwarai_Test
//
//  Created by sonekousuke on 2015/01/24.
//  Copyright (c) 2015年 KosukeSone. All rights reserved.
//

#import "ViewController.h"

@interface AfterTakePhotViewController : ViewController<UIActionSheetDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *righteye;
@property (weak, nonatomic) IBOutlet UIImageView *lefteye;
@property (weak, nonatomic) IBOutlet UIImageView *nose;
@property (weak, nonatomic) IBOutlet UIImageView *mouth;
- (IBAction)rightEyemove:(UIPanGestureRecognizer *)sender;
- (IBAction)leftEyeMove:(UIPanGestureRecognizer *)sender;
- (IBAction)noseMove:(UIPanGestureRecognizer *)sender;
- (IBAction)mouthMove:(UIPanGestureRecognizer *)sender;
- (IBAction)nosePinch:(UIPinchGestureRecognizer *)sender;
- (IBAction)mouthPinch:(UIPinchGestureRecognizer *)sender;
- (IBAction)leftEyePinch:(UIPinchGestureRecognizer *)sender;
- (IBAction)rightEyePinch:(UIPinchGestureRecognizer *)sender;

@end
