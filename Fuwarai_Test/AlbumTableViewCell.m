//
//  AlbumTableViewCell.m
//  Fuwarai_Test
//
//  Created by sonekousuke on 2015/01/29.
//  Copyright (c) 2015年 KosukeSone. All rights reserved.
//

#import "AlbumTableViewCell.h"
#import "AlbumViewController.h"

@implementation AlbumTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void)setData:(UIImage *)image
- (void)setData:(NSIndexPath *)indexPath
{

    NSMutableArray *photoImages;
    NSMutableArray *photoImagesDate;
    
    // アルバム写真データの読み出し
    NSUserDefaults *defaultsAlbumPhoto = [NSUserDefaults standardUserDefaults];
    photoImages = [defaultsAlbumPhoto objectForKey:@"defaultsAlbumPhoto"];
    UIImage *image = [[UIImage alloc] initWithData:photoImages[indexPath.row]];
    self.photImage.image = image;

    // 写真の保存時間を読み出し
    NSUserDefaults *defaultsAlbumPhotoDate = [NSUserDefaults standardUserDefaults];
    photoImagesDate = [defaultsAlbumPhotoDate objectForKey:@"defaultsAlbumPhotoDate"];
    
    // 余分なデータを削除
    NSString *mstr = [[[photoImagesDate[indexPath.row] description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSMutableString *label = [NSMutableString stringWithString:mstr];
    [label deleteCharactersInRange:NSMakeRange(10, 13)];

    self.dateLabel.text = label;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
}


@end
