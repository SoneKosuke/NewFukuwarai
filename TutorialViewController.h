//
//  TutorialViewController.h
//  Fuwarai_Test
//
//  Created by sonekousuke on 2015/02/07.
//  Copyright (c) 2015年 KosukeSone. All rights reserved.
//

#import "ViewController.h"
@interface TutorialViewController : ViewController<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *myPageControl;
@end
