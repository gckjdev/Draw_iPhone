//
//  ClassTagButton.h
//  ifengNewsOrderDemo
//
//  Created by zer0 on 14-2-27.
//  Copyright (c) 2014年 zer0. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassTagButton : UIButton

@property (nonatomic,retain) UIViewController * vc;
@property (nonatomic,retain) NSArray * titleArr;
@property (nonatomic,retain) NSArray * urlStringArr;

+ (id)buttonWithViewController:(UIViewController *)vc titleArr:(NSArray *)titleArr urlStringArr:(NSArray *)urlStringArr;

@end
