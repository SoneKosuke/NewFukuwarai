//
//  PhotSelectViewController.h
//  Fuwarai_Test
//
//  Created by sonekousuke on 2015/02/01.
//  Copyright (c) 2015年 KosukeSone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotSelectViewController : UIViewController
@property NSInteger selectedRow;
@property (weak, nonatomic) IBOutlet UIImageView *photoimage;

@end
