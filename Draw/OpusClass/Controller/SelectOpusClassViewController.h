//
//  OrderViewController.h
//  ifengNewsOrderDemo
//
//  Created by zer0 on 14-2-27.
//  Copyright (c) 2014年 zer0. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"

typedef void (^ SelectOpusClassResultHandler) (int resultCode, NSArray *selectedArray, NSArray *arrayForSelection);


@interface SelectOpusClassViewController : PPViewController
{

@public
    
    NSMutableArray * _viewArr1; // array tags
    NSMutableArray * _viewArr2; // array for selection
}

@property (nonatomic, retain) NSArray * modelArr1;
@property (nonatomic, retain) NSArray * modelArrayForSelect;


@property (nonatomic,retain) UILabel * titleLabel;
@property (nonatomic,retain) UILabel * titleLabel2;
@property (nonatomic,retain) NSArray * titleArr;
@property (nonatomic,retain) NSArray * urlStringArr;
@property (nonatomic,retain) UIButton * backButton;
@property (nonatomic,copy) SelectOpusClassResultHandler callback;

- (id)initWithSelectedTags:(NSArray*)selectedTags
         arrayForSelection:(NSArray*)arrayForSelection
                  callback:(SelectOpusClassResultHandler)callback;

+ (void)showInViewController:(PPViewController*)viewController
                selectedTags:(NSArray*)selectedTags
           arrayForSelection:(NSArray*)arrayForSelection
                    callback:(SelectOpusClassResultHandler)callback;


@end
