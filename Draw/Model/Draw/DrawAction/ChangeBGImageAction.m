//
//  ChangeBGImageAction.m
//  Draw
//
//  Created by gamy on 13-4-1.
//
//

#import "ChangeBGImageAction.h"
#import "DrawBgManager.h"
#import "SDWebImageManager.h"

@interface ChangeBGImageAction()

@property(nonatomic, retain) UIImage *image;

@end

@implementation ChangeBGImageAction

- (void)dealloc
{
    PPRelease(_drawBg);
    PPRelease(_image);
    [super dealloc];
}

- (id)initWithDrawBg:(PBDrawBg *)drawBg
{
    self = [super init];
    if (self) {
        self.type = DrawActionTypeChangeBGImage;
        self.drawBg = drawBg;
    }
    return self;
}

- (id)initWithPBDrawAction:(PBDrawAction *)action
{
    self = [super initWithPBDrawAction:action];
    if (self) {
        self.type = DrawActionTypeChangeBGImage;
        self.drawBg = action.drawBg;
    }
    return self;
}
- (id)initWithPBNoCompressDrawAction:(PBNoCompressDrawAction *)action
{
    //old data model has no chang draw bg image action
    
    return nil;
}


- (PBDrawAction *)toPBDrawAction
{
    PBDrawAction_Builder *builder = [[[PBDrawAction_Builder alloc] init] autorelease];
    [builder setType:DrawActionTypeChangeBGImage];
    if (self.drawBg) {
        [builder setDrawBg:self.drawBg];
    }
    return [builder build];
  
}
- (void)addPoint:(CGPoint)point inRect:(CGRect)rect
{
    
}

- (void)updateImage
{
    if (self.image == nil) {
        self.image = [[self drawBg] localImage];
        if (self.image == nil) {
            __block typeof (self) cp = self;
            [[SDWebImageManager sharedManager] downloadWithURL:self.drawBg.remoteURL delegate:self options:0 success:^(UIImage *image, BOOL cached) {
                cp.image = image;
            } failure:^(NSError *error) {
                
            }];
        }
    }
}

- (CGRect)imageRectWithSize:(CGSize)size canvasRect:(CGRect)rect
{
    CGSize cSize = rect.size;
    //if the size scale is the same, and canvas size is not large than the bg size
    if (abs(size.width * cSize.height - cSize.width * size.height) < 2  && cSize.width <= (size.width + 1)) {
        return rect;
    }else{
        //return the mid rect, the size
        CGRect retRect;
        retRect.size = size;
        retRect.origin.x = (CGRectGetWidth(rect) - size.width) / 2;
        retRect.origin.y = (CGRectGetHeight(rect) - size.height) / 2;
        return retRect;
    }
}

#define CTMContext(context,rect) \
CGContextScaleCTM(context, 1.0, -1.0);\
CGContextTranslateCTM(context, 0, -CGRectGetHeight(rect));


- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect
{
    CGContextClearRect(context, rect);
    CGContextSaveGState(context);


    [self updateImage];
    if (self.image) {
        CTMContext(context, rect);        
        if (self.drawBg.showStyle == ShowStyleCenter) {
            CGRect imageRect = [self imageRectWithSize:self.image.size canvasRect:rect];
            CGContextDrawImage(context, imageRect, self.image.CGImage);
        }else if(self.drawBg.showStyle == ShowStylePattern){
            [self.image drawAsPatternInRect:rect];
            CGContextDrawTiledImage(context, rect, self.image.CGImage);
        }else{
            //
        }
    }
    
    CGContextRestoreGState(context);

    return rect;
}

@end