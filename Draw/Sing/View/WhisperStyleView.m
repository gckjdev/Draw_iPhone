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

@interface WhisperStyleView ()

@property (assign, nonatomic) float sx;
@property (assign, nonatomic) float sy;

@end

@implementation WhisperStyleView

AUTO_CREATE_VIEW_BY_XIB(WhisperStyleView);

- (void)dealloc {
    [super dealloc];
}

+ (id)createWithFrame:(CGRect)frame
                 feed:(DrawFeed *)feed{
    
    WhisperStyleView *v = [[self alloc] initWithFrame:frame feed:feed];
    return v;
}

#define TAG_LABEL 201311131346
- (id)initWithFrame:(CGRect)frame
               feed:(DrawFeed *)feed{
    
    CGRect originFrame = CGRectMake(0, 0, feed.pbFeed.canvasSize.width, feed.pbFeed.canvasSize.height);

    if (self = [super initWithFrame:originFrame]) {
        
        UIImageView *iv = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        [iv setImageWithURL:[NSURL URLWithString:feed.drawImageUrl]];
        [self addSubview:iv];
        
        StrokeLabel *l = [[[StrokeLabel alloc] initWithFrame:CGRectZero] autorelease];
        l.text = feed.opusDesc;
        l.textAlignment = NSTextAlignmentCenter;
        l.tag = TAG_LABEL;
        l.backgroundColor = [UIColor clearColor];
        [self addSubview:l];
        
        // update lable info
        PBLabelInfo *labelInfo = feed.pbFeed.descLabelInfo;
        if (labelInfo != nil) {
            
            // set frame
            [l updateOriginX:labelInfo.frame.x];
            [l updateOriginY:labelInfo.frame.y];
            [l updateWidth:labelInfo.frame.width];
            [l updateHeight:labelInfo.frame.height];
            
            PPDebug(@"stroke label frame = %@", NSStringFromCGRect(l.frame));
            
            // set number of line
            l.numberOfLines = 0;

            // set text color
            l.textColor = [[DrawColor colorWithBetterCompressColor:labelInfo.textColor] color];
            
            // set font
            l.font = [UIFont systemFontOfSize:labelInfo.textFont];
            
            // set text stroke color
            l.textOutlineColor = [[DrawColor colorWithBetterCompressColor:labelInfo.textStrokeColor] color];
            
            // set text stroke widht
            l.textOutlineWidth = (ISIPAD ? 2 : 1);
                        
        }else{
            
            PPDebug(@"<updateDescriptionLabel>, but lableInfo is nil");
        }
        
                
        // transform from originFrame to frame
        self.sx = frame.size.width / self.frame.size.width;
        self.sy = frame.size.height / self.frame.size.height;
        
        CGAffineTransform transform = CGAffineTransformMakeScale(_sx, _sy);
        self.transform = transform;
        
        // update origin
        [self updateOriginX:frame.origin.x];
        [self updateOriginY:frame.origin.y];
    }
    
    return self;
}

- (void)setHotRankViewStyle{
    
    UILabel *label = (UILabel *)[self viewWithTag:TAG_LABEL];
    label.font = [UIFont systemFontOfSize:ISIPAD ? 30/_sx : 15/_sx];
    label.numberOfLines = 3;
//    [label updateHeight:(ISIPAD ? 140 : 70)];
    [label updateWidth:self.bounds.size.width];
    [label updateHeight:self.bounds.size.height];
    
    label.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

- (void)setHomeRankViewStyle{
    
    UILabel *label = (UILabel *)[self viewWithTag:TAG_LABEL];
    label.font = [UIFont systemFontOfSize:ISIPAD ? 20/_sx : 11/_sx];
    label.numberOfLines = 3;
    [label updateWidth:self.bounds.size.width];
    [label updateHeight:self.bounds.size.height];
    
    label.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

@end
