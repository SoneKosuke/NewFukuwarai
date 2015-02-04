//
//  BaseImageSelectTableViewCell.h
//  Fuwarai_Test
//
//  Created by sonekousuke on 2015/02/02.
//  Copyright (c) 2015年 KosukeSone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseImageSelectTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *image;

- (void)setData:(NSIndexPath *)indexPath;

@end
