//
//  BaseImageSelectTableViewCell.m
//  Fuwarai_Test
//
//  Created by sonekousuke on 2015/02/02.
//  Copyright (c) 2015年 KosukeSone. All rights reserved.
//

#import "BaseImageSelectTableViewCell.h"
#import "BaseImageSelectViewController.h"

@implementation BaseImageSelectTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(NSIndexPath *)indexPath
{
    //プロジェクト内のファイルにアクセスできるオブジェクトを宣言
    NSBundle *bundle = [NSBundle mainBundle];
    //湯見込むプロパティリストのファイルパスをしてい。
    NSString *path = [bundle pathForResource:@"PropertyList" ofType:@"plist"];
    //プロパティリストのデータを取得
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *kind = [dic objectForKey:@"kind"];
    NSArray *document = [dic objectForKey:@"document"];

    self.label.text = kind[indexPath.row];
    if (indexPath.row == 0) {
        // 撮影画像の読み出し
        NSUserDefaults *defaultphot = [NSUserDefaults standardUserDefaults];
        NSString *path = [defaultphot stringForKey:@"path"];
        UIImage *image= [[UIImage alloc] initWithContentsOfFile:path];
        self.image.image = image;
    } else {
        self.image.image = [UIImage imageNamed:document[indexPath.row]];
    }
}

@end
