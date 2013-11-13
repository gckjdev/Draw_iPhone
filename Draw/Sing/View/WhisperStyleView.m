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
#import "StrokeLabel.h"
#import "UIViewUtils.h"

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

- (id)initWithFrame:(CGRect)frame
               feed:(DrawFeed *)feed{
    
    CGRect originFrame = CGRectMake(0, 0, feed.pbFeed.canvasSize.width, feed.pbFeed.canvasSize.height);

    if (self = [super initWithFrame:originFrame]) {
        
        UIImageView *iv = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        [iv setImageWithURL:[NSURL URLWithString:feed.drawImageUrl]];
        [self addSubview:iv];
        
        StrokeLabel *l = [[[StrokeLabel alloc] initWithFrame:CGRectZero] autorelease];
        l.text = feed.desc;
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
            
            // set text color
            l.textColor = [[DrawUtils decompressColor8:labelInfo.textColor] color];
            
            // set font
            l.font = [UIFont systemFontOfSize:labelInfo.textFont];
            
            // set text stroke color
            l.textOutlineColor = [[DrawUtils decompressColor8:labelInfo.textStrokeColor] color];
            
            // set text stroke widht
            l.textOutlineWidth = labelInfo.textStrokeWidth;
            
        }else{
            
            PPDebug(@"<updateDescriptionLabel>, but lableInfo is nil");
        }
        
                
        // transform from originFrame to frame
        float sx = frame.size.width / self.frame.size.width;
        float sy = frame.size.height / self.frame.size.height;
        
        CGAffineTransform transform = CGAffineTransformMakeScale(sx, sy);
        self.transform = transform;
        
        // update origin
        [self updateOriginX:frame.origin.x];
        [self updateOriginY:frame.origin.y];
    }
    
    return self;
}


@end
