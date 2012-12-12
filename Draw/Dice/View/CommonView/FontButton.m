//
//  FontButton.m
//  Draw
//
//  Created by 小涛 王 on 12-8-1.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "FontButton.h"
#import "DiceFontManager.h"

@implementation FontButton

@synthesize fontLable = _fontLable;

- (void)dealloc {
    [_fontLable release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame 
           fontName:(NSString *)fontName 
          pointSize:(CGFloat)pointSize
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.fontLable = [[[FontLabel alloc] initWithFrame:self.bounds
                                                  fontName:fontName
                                                 pointSize:pointSize] autorelease];;
        _fontLable.backgroundColor = [UIColor clearColor];
        _fontLable.textAlignment = UITextAlignmentCenter;
        [self addSubview:_fontLable];
    }
    
    return self;
}

//- (id)initWithCoder:(NSCoder *)coder
//{
//    self = [super initWithCoder:coder];
//    if (self) {
//        self.fontLable = [[[FontLabel alloc] initWithFrame:self.bounds
//                                                  fontName:[[DiceFontManager defaultManager] fontName]
//                                                 pointSize:self.titleLabel.font.pointSize] autorelease];
//        _fontLable.backgroundColor = [UIColor clearColor];
//        _fontLable.textAlignment = UITextAlignmentCenter;
//        _fontLable.text = self.titleLabel.text;
//        _fontLable.textColor = self.titleLabel.textColor;
//        [self setTitle:nil forState:UIControlStateNormal];
//        [self addSubview:_fontLable];
//    }
//    return self;
//}

@end
