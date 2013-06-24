//
//  StrawTouchHandler.m
//  Draw
//
//  Created by gamy on 13-3-9.
//
//

#import "StrawTouchHandler.h"
#import "StrawView.h"

@interface StrawTouchHandler()
{
    StrawView *_strawView;
    CGContextRef _tempBitmapContext;
}
@end

@implementation StrawTouchHandler

- (void)reset
{
    [_strawView removeFromSuperview];
    _strawView = nil;
    CGContextRelease(_tempBitmapContext);
    _tempBitmapContext = NULL;

}

- (DrawColor *)colorAtPoint:(CGPoint)point inContext:(CGContextRef)context
{
    unsigned char* data = CGBitmapContextGetData (context);
    DrawColor *color = nil;
    CGFloat w = (NSUInteger)CGRectGetWidth(self.drawView.bounds);
    CGFloat h = (NSUInteger)CGRectGetHeight(self.drawView.bounds);
    point.y = h - point.y; //Needed in new version
    
    if (data != NULL) {
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        int offset = 4*((w*round(point.y))+round(point.x));
        
        int red = data[offset++];
        int green = data[offset++];
        int blue = data[offset++];
        int alpha =  data[offset++];
        
        color = [DrawColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
    }
    // Free image data memory for the context
    
    //    if (data) { free(data); }
    return color;
}

- (void)handlePoint:(CGPoint)point forTouchState:(TouchState)state
{
    [super handlePoint:point forTouchState:state];
    
//    point.y = CGRectGetHeight(self.drawView.bounds) - point.y;
    switch (state) {
        case TouchStateBegin:
        {
            handleFailed = NO;
            [self reset];
            //new and show color view and show it in the super view
            _tempBitmapContext = [self.drawView createBitmapContext];
            
//            CGContextScaleCTM(_tempBitmapContext, 1, -1);
//            CGContextTranslateCTM(_tempBitmapContext, 1, - self.drawView.bounds.size.height);
            
            DrawColor *color = [self colorAtPoint:point inContext:_tempBitmapContext];
            _strawView = [StrawView strawViewWithColor:color.color];
            [self.drawView addSubview:_strawView];
            _strawView.center = point;
        }
            break;
        case TouchStateMove:
        case TouchStateEnd:
        default:
        {
            if (handleFailed) {
                return;
            }
            DrawColor *color = [self colorAtPoint:point inContext:_tempBitmapContext];
            [_strawView setColor:color.color];
            _strawView.center = point;
            break;
        }
    }
    if (state == TouchStateCancel || state == TouchStateEnd) {
        {
            DrawColor *color = [self colorAtPoint:point inContext:_tempBitmapContext];
            if (_strawDelegate && [_strawDelegate respondsToSelector:@selector(didStrawGetColor:)]) {
                [_strawDelegate didStrawGetColor:color];
            }
            [self reset];
        }
    }
}
- (void)handleFailTouch
{
    [super handleFailTouch];
}


- (void)dealloc
{
    [self reset];
    [super dealloc];

}
@end
