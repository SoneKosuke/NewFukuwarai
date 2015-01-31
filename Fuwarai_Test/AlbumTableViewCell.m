//
//  AlbumTableViewCell.m
//  Fuwarai_Test
//
//  Created by sonekousuke on 2015/01/29.
//  Copyright (c) 2015年 KosukeSone. All rights reserved.
//

#import "AlbumTableViewCell.h"
#import "AlbumTableViewController.h"

@implementation AlbumTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(UIImage *)image
{
    // 保存した画像の読み出し
//    NSUserDefaults *defaultsAlbumPhot = [NSUserDefaults standardUserDefaults];
//    NSData *photImage = [defaultsAlbumPhot dataForKey:@"defaultsAlbumPhot"];
    
//NSLog(@"%@", photImage);
//    // initWithData:メソッドでNSDataを元にUIImageを初期化できる
//    UIImage* image = [[UIImage alloc] initWithData:photImage];
//NSLog(@"%@", image);
    
//    NSLog(@"=========photImage=========%@", photImage);
//    NSArray *photImageArray = [NSKeyedUnarchiver unarchiveObjectWithData:photImage];
    
//    UIImage *image = [photImageArray objectAtIndex:0];
//    self.photImage.image = image;
//    NSLog(@"=========image=========%@", image);
    
    NSLog(@"%@", image);
    
    self.photImage.image = image;
    
    
    //ユーザーデフォルトから文字を読み出す。
    NSUserDefaults *defaultshogehoge = [NSUserDefaults standardUserDefaults];
    NSString *hogehoge = [defaultshogehoge stringForKey:@"defaultshogehoge"];
    
    //    //ユーザーデフォルトから文字を読み出す。
    //    NSUserDefaults *defaultsphotNumber = [NSUserDefaults standardUserDefaults];
    //    int photNumber = [defaultsphotNumber integerForKey:@"photNumber"];
    ////    NSLog(@"%d", photNumber);

    NSString *label;
    label = @"hogehoge";
    self.dateLabel.text = hogehoge;
    
}

@end
