//
//  MyPage.m
//  Fuwarai_Test
//
//  Created by sonekousuke on 2015/02/07.
//  Copyright (c) 2015年 KosukeSone. All rights reserved.
//

#import "MyPage.h"

@implementation MyPage

//イニシャライザ
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"hogehoge");
    }
    return self;
}

//カスタムイニシャライザ
-(id)initWithImageName:(NSString *)imageName frame:(CGRect)frame caption:(NSString *)caption
{
    //イニシャライザで初期化済みのインスタンスを取得する
    self = [self initWithFrame:frame];
    
    int labelH = 25;//ラベルの高さ
    //絵を表示したイメージビューを作成する
    CGRect imageFrame = CGRectMake(0, 0, frame.size.width, frame.size.height-labelH);
    NSLog(@"frame.size.width%f", frame.size.width);
    NSLog(@"frame.size.height%f", frame.size.height);
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:imageFrame];
    imageView.image = [UIImage imageNamed:imageName];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //キャプションの入ったラベルを作成する
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.text =caption;
    myLabel.frame = CGRectMake(0, frame.size.height-labelH, frame.size.width, labelH);
    myLabel.textAlignment = NSTextAlignmentCenter;
    myLabel.font = [UIFont systemFontOfSize:14];
    
    //イメージビューとラベルをサブビューとして追加する
    [self addSubview:imageView];
    [self addSubview:myLabel];
    
    //できあがったページを返す
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
