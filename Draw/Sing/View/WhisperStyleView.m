//
//  WhisperStyleView.m
//  Draw
//
//  Created by 王 小涛 on 13-11-12.
//
//

#import "WhisperStyleView.h"
#import "AutoCreateViewByXib.h"
#import "UIImageView+WebCache.h"
#import "UILabel+Extend.h"
#import "DrawFeed.h"
#import "DrawUtils.h"
#import "DrawColor.h"
#import "StrokeLabel.h"
#import "UIViewUtils.h"
#import "SDImageCache.h"

@interface WhisperStyleView ()

@property (assign, nonatomic) float sx;
@property (assign, nonatomic) float sy;

@property (retain, nonatomic) UIImageView *imageView;
@property (retain, nonatomic) StrokeLabel *label;

@end

@implementation WhisperStyleView

AUTO_CREATE_VIEW_BY_XIB(WhisperStyleView);

- (void)dealloc {
    [_imageView release];
    [_label release];
    [super dealloc];
}

+ (id)createWithFrame:(CGRect)frame
                 feed:(DrawFeed *)feed
          useBigImage:(BOOL)useBigImage{
    
    WhisperStyleView *v = [[[self alloc] initWithFrame:frame feed:feed useBigImage:useBigImage] autorelease];
    return v;
}

+ (id)createWithFrame:(CGRect)frame{
    
    WhisperStyleView *v = [[[self alloc] initWithFrame:frame feed:nil useBigImage:NO] autorelease];
    return v;
}



- (id)initWithFrame:(CGRect)frame
               feed:(DrawFeed *)feed
        useBigImage:(BOOL)useBigImage{


    if (self = [super initWithFrame:frame]) {
    
        self.imageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.imageView setClipsToBounds:YES];
        [self addSubview:self.imageView];
                
        self.label = [[[StrokeLabel alloc] initWithFrame:CGRectZero] autorelease];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.backgroundColor = [UIColor clearColor];
        
        // set number of line
        self.label.numberOfLines = 0;
        
        // set text stroke widht
        self.label.textOutlineWidth = (ISIPAD ? 2 : 1); // change by Benson
        
        [self addSubview:self.label];

        [self setClipsToBounds:YES];
        
        if (feed != nil) {
            [self setViewInfo:feed useBigImage:useBigImage];
        }
    }
    
    return self;
}

- (void)setViewInfo:(DrawFeed *)feed
        useBigImage:(BOOL)useBigImage{
        
    CGRect originFrame = CGRectMake(0, 0, feed.pbFeed.canvasSize.width, feed.pbFeed.canvasSize.height);

    // transform from originFrame to frame
    self.sx = originFrame.size.width / self.frame.size.width;
    self.sy = originFrame.size.height / self.frame.size.height;
    
    self.label.text = [feed opusDesc];
    // update lable info
    PBLabelInfo *labelInfo = feed.pbFeed.descLabelInfo;
    if (labelInfo != nil) {
        
        // set frame
        [self.label updateOriginX:labelInfo.frame.x / _sx];
        [self.label updateOriginY:labelInfo.frame.y / _sy];
        [self.label updateWidth:labelInfo.frame.width / _sx];
        [self.label updateHeight:labelInfo.frame.height / _sy];
        
        // set text color
        self.label.textColor = [[DrawColor colorWithBetterCompressColor:labelInfo.textColor] color];
        
        // set font
        self.label.font = [UIFont systemFontOfSize:ISIPAD ? 25 : 15];
        
        // set text stroke color
        self.label.textOutlineColor = [[DrawColor colorWithBetterCompressColor:labelInfo.textStrokeColor] color];
    }else{
        
        PPDebug(@"<updateDescriptionLabel>, but lableInfo is nil");
    }
    
    
    
    UIImage *placeHolder = [UIImage imageNamed:@"unloadbg@2x.png"];
    
    if (useBigImage) {
        
        UIActivityIndicatorView *indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
        [indicator updateCenterX:self.imageView.frame.size.width/2];
        [indicator updateCenterY:self.imageView.frame.size.height/2];
        [indicator startAnimating];
        [self.imageView addSubview:indicator];
        
        [self.imageView setImageWithURL:[feed thumbURL]
                       placeholderImage:placeHolder
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                  [self.imageView setImageWithURL:[feed largeImageURL] placeholderImage:image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                      [indicator stopAnimating];
                                      [indicator removeFromSuperview];
                                  }];
                              }];
    }else{
        
        [self.imageView setImageWithURL:feed.thumbURL placeholderImage:placeHolder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            
        }];
    }
}

- (void)setHotRankViewStyle{
    
    self.label.font = [UIFont systemFontOfSize:ISIPAD ? 25 : 15];
    self.label.numberOfLines = 3;
    
//    [self.label wrapTextWithConstrainedSize:CGSizeMake(self.bounds.size.width * 0.8, self.bounds.size.height)];
    
    [self.label updateWidth:self.bounds.size.width];
    [self.label updateHeight:self.bounds.size.height];
    
    self.label.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

- (void)setHomeRankViewStyle{
    
    self.label.font = [UIFont systemFontOfSize:ISIPAD ? 20 : 11];
    self.label.numberOfLines = 3;
    
//    [self.label wrapTextWithConstrainedSize:CGSizeMake(self.bounds.size.width * 0.8, self.bounds.size.height)];

    [self.label updateWidth:self.bounds.size.width];
    [self.label updateHeight:self.bounds.size.height];
    self.label.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

- (void)setFeedDetailStyle{
    
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    self.label.font = [UIFont systemFontOfSize:ISIPAD ? 25 : 15];
    [self.label updateHeight:self.bounds.size.height];

    // 有时候上传的照片，用户明明有编辑描述，但是上传后frame就是0，所以这里做一下保护。
    // 如果上述的bug解决了，这里的代码就可以不要了。
    
    if (self.label.text.length != 0
        && (CGRectGetWidth(self.label.frame) == 0 || CGRectGetHeight(self.label.frame) == 0)) {
        self.label.numberOfLines = 99;
        
        [self.label updateWidth:self.bounds.size.width];

        self.label.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    }
}

@end
