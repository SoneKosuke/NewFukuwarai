//
//  AlbumTableViewCell.h
//  Fuwarai_Test
//
//  Created by sonekousuke on 2015/01/29.
//  Copyright (c) 2015年 KosukeSone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photImage;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

//- (void)setData:(UIImage *)image;
- (void)setData:(NSIndexPath *)indexPath;




@end
