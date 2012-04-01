//
//  ShareImageManager.m
//  Draw
//
//  Created by  on 12-3-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareImageManager.h"
#import "UIImageUtil.h"

@implementation ShareImageManager

static ShareImageManager* _defaultManager;
static UIImage* _woodButtonImage;
static UIImage* _orangeButtonImage;
static UIImage* _greenButtonImage;
static UIImage *_buyButtonImage;
static UIImage* _showcaseBackgroundImage;

+ (ShareImageManager*)defaultManager
{
    if (_defaultManager == nil){
        _defaultManager = [[ShareImageManager alloc] init];
    }
    
    return _defaultManager;
}

- (UIImage*)woodImage
{
    if (_woodButtonImage == nil){        
        _woodButtonImage = [[UIImage strectchableImageName:@"wood_button.png"] retain];
    }
    
    return _woodButtonImage;
}

- (UIImage*)greenImage
{
    if (_greenButtonImage == nil){        
        _greenButtonImage = [[UIImage strectchableImageName:@"green_button.png"] retain];
    }
    
    return _greenButtonImage;    
}

- (UIImage*)orangeImage
{
    if (_orangeButtonImage == nil){        
        _orangeButtonImage = [[UIImage strectchableImageName:@"orange_button.png"] retain];
    }
    
    return _orangeButtonImage;    
}

- (UIImage *)buyButtonImage
{
    if(_buyButtonImage == nil)
    {
        _buyButtonImage = [[UIImage strectchableImageName:@"buybutton.png"] retain];
    }
    return _buyButtonImage;
}

- (UIImage*)showcaseBackgroundImage
{
    if (_showcaseBackgroundImage == nil) {
        _showcaseBackgroundImage = [[UIImage strectchableImageName:SHOWCASE_BACKGROUND]retain];
    }
    return _showcaseBackgroundImage;
}


- (UIImage *)pickEasyWordCellImage
{
    return [UIImage imageNamed:WORD_EASY_CELL_BACKGROUND];
}
- (UIImage *)pickNormakWordCellImage
{
    return [UIImage imageNamed:WORD_NORMAL_CELL_BACKGROUND];    
}
- (UIImage *)pickHardWordCellImage
{
    return [UIImage imageNamed:WORD_HARD_CELL_BACKGROUND];
}

- (UIImage *)coinImage
{
    return [UIImage imageNamed:@"coin.png"];
}
- (UIImage *)toolImage
{
    return [UIImage imageNamed:@"tool.png"];
}


#pragma makr - Color Image

- (UIImage *)redColorImage
{
    return [UIImage imageNamed:@"red_color.png"];
//    return [UIImage strectchableImageName:@"red_color.png"];
}
- (UIImage *)blueColorImage
{
    return [UIImage imageNamed:@"blue_color.png"];    
}
- (UIImage *)yellowColorImage
{
    return [UIImage imageNamed:@"yellow_color.png"];    
}

@end
