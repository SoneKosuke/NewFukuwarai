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

//- (void)setData:(UIImage *)image
- (void)setData:(NSIndexPath *)indexPath
{

    NSMutableArray *photoImages;
    NSMutableArray *photoImagesDate;
    
    // アルバム写真データの読み出し
    NSUserDefaults *defaultsAlbumPhoto = [NSUserDefaults standardUserDefaults];
    photoImages = [defaultsAlbumPhoto objectForKey:@"defaultsAlbumPhoto"];
    
    // アルバム写真データの読み出し
    NSUserDefaults *defaultsAlbumPhotoDate = [NSUserDefaults standardUserDefaults];
    photoImagesDate = [defaultsAlbumPhotoDate objectForKey:@"defaultsAlbumPhotoDate"];
    
    UIImage *image = [[UIImage alloc] initWithData:photoImages[indexPath.row]];
    NSString *label = [[[photoImagesDate[indexPath.row] description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    
    self.photImage.image = image;

    self.dateLabel.text = label;
    
}


@end
