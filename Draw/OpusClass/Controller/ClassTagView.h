//
//  TouchView.h
//  TouchDemo
//
//  Created by Zer0 on 13-10-11.
//  Copyright (c) 2013年 Zer0. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpusClassInfo;

@interface ClassTagView : UIImageView
{
    CGPoint _point;
    CGPoint _point2;
    NSInteger _sign;

@public
    
}


@property (nonatomic,retain) NSMutableArray *array;
@property (nonatomic,retain) NSMutableArray *viewArr11;
@property (nonatomic,retain) NSMutableArray *viewArr22;

@property (nonatomic,retain) UILabel * label;
@property (nonatomic,retain) UILabel * moreChannelsLabel;
@property (nonatomic,retain) UILabel * selectedChannelsLabel;
@property (nonatomic,retain) OpusClassInfo * touchViewModel;

@end
