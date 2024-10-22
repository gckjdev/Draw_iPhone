//
//  DrawView.m
//  Draw
//
//  Created by  on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShowDrawView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageExt.h"
#import "UIImageUtil.h"
#import "PenView.h"
#import "Paint.h"
#import "PPConfigManager.h"
#import "CanvasRect.h"
#import "DrawHolderView.h"
#import "ClipAction.h"
#import "SDWebImageDecoder.h"
#import "HJImagesToVideo.h"
#import "BrushAction.h"
#include <ImageIO/ImageIO.h>
#include <MobileCoreServices/MobileCoreServices.h>
#import "ShareService.h"

//#define DEFAULT_PLAY_SPEED  (0.01)
//#define MIN_PLAY_SPEED      (0.001f)
typedef enum {
    PlaySpeedTypeLow = 1, // 1/30.0
    PlaySpeedTypeNormal = 2, // x2
    PlaySpeedTypeHigh = 4, //x4
    PlaySpeedTypeSuper = 6,//x6
    PlaySpeedTypeMax = 10,//x10
}PlaySpeedType;



@interface ShowDrawView ()
{
    NSInteger _playingActionIndex;
    NSInteger _playingPointIndex;
    
    BOOL _showPenHidden;
    BOOL _supportLongPress;
    PenView *pen;

}

@property(nonatomic, assign) NSUInteger totalPointCount; //default is Normal;

//@property (nonatomic, retain) PaintAction *tempAction;
@property (nonatomic, retain) DrawAction *tempAction;

@end


@implementation ShowDrawView
@synthesize speed = _speed;
@synthesize delegate = _delegate;
@synthesize status = _status;

#pragma mark Action Funtion


- (void)cleanAllActions
{
    [self setStatus:Stop];

    _playingActionIndex = 0;
    _playingPointIndex = 0;
    self.tempAction = nil;
    _currentAction = nil;

    [super cleanAllActions];
}


- (void)resetView
{
    [self setStatus:Stop];
    _playingActionIndex = 0;
    _playingPointIndex = 0;

    self.tempAction = nil;
    _currentAction = nil;
    [dlManager resetAllLayers];
    pen.hidden = YES;

}

#define VALUE(x) (ISIPAD ? 2*x : x)
#define SHOWPEN_WIDTH VALUE(31)
#define SHOWPEN_HEIGHT VALUE(36.5)

- (void)movePen
{
    
    if (pen.superview == nil) {
        [self.superview addSubview:pen];
    }
    
    if ([_currentAction isKindOfClass:[PaintAction class]] ||
        [_currentAction isKindOfClass:[BrushAction class]]) {

        pen.hidden = NO;
        
        ItemType currentPenType;
        CGPoint point;
        if ([_currentAction isKindOfClass:[PaintAction class]]){
            PaintAction *paintAction = (PaintAction *)_currentAction;
            currentPenType = paintAction.paint.penType;
            point = [paintAction.paint pointAtIndex:_playingPointIndex];
        }
        else{
            BrushAction *action = (BrushAction *)_currentAction;
            currentPenType = action.brushStroke.brushType;
            point = [action.brushStroke pointAtIndex:_playingPointIndex];
        }
        
        if (_playingPointIndex == 0 && pen.penType != currentPenType) {
            //reset pen type
//            ItemType penType = paintAction.paint.penType;
            [pen setPenType:currentPenType];
        }

        point = [pen.superview convertPoint:point fromView:self];
        if (pen.penType != Eraser && pen.penType != DeprecatedEraser) {
            pen.frame = CGRectMake(point.x, point.y-SHOWPEN_HEIGHT, SHOWPEN_WIDTH, SHOWPEN_HEIGHT);
        }else{
            pen.frame = CGRectMake(point.x, point.y, SHOWPEN_WIDTH, SHOWPEN_HEIGHT);
        }
    
    }else{
        pen.hidden = YES;
    }
}


- (BOOL)playFromDrawActionIndex:(NSInteger)index
{
    _playingActionIndex = index;
    _playingPointIndex = 0;
    if (index < [self.drawActionList count]) {
        _currentAction = [self.drawActionList objectAtIndex:index];
        self.status = Playing;
        [self playCurrentFrame];
        return YES;
    }else{
        self.status = Stop;
        PPDebug(@"<playFromDrawActionIndex> index out of action array bounds. Stop");
        return NO;
    }
}

- (void)play
{
    PPDebug(@"<ShowDrawView> play");
    [self resetView];
    [self playFromDrawActionIndex:0];

}

- (void)stop
{
    PPDebug(@"<ShowDrawView> stop");
    self.status = Stop;
    pen.hidden = YES;
}

- (void)show
{
    PPDebug(@"<ShowDrawView> show");
    [self showToIndex:[_drawActionList count]];
}

- (void)showToIndex:(NSInteger)index
{
    index = MAX(0, index);
    index = MIN(index , [self.drawActionList count]);
    
    [self resetView];
    
    BOOL useLayerOpacity = (index >= [self.drawActionList count]);
    
    NSArray *array = [_drawActionList subarrayWithRange:NSMakeRange(0, index)];
    [dlManager arrangeActions:array useLayerOpacity:useLayerOpacity];
    _playingActionIndex = index;

    
    if (index >= [self.drawActionList count]) {
        self.status = Stop;
        NSArray* layers = [self layers];
        for (DrawLayer *layer in layers) {
            if (layer.clipAction) {
                [layer exitFromClipMode];
            }
        }
    }else{
        self.status = Playing;
    }
          
}


- (void)pause
{
    if(self.status == Playing){
        PPDebug(@"<ShowDrawView> pause");
        self.status = Pause;        
    }else{
        PPDebug(@"<ShowDrawView> not playing, pause failed");
    }
}


- (void)resume
{
    if (self.status == Pause) {
        PPDebug(@"<ShowDrawView> resume");
        self.status = Playing;
        if (_currentAction == nil) {
            _playingActionIndex --;
            [self updateNextPlayIndex];
        }

        [self playCurrentFrame];
    }else{
        PPDebug(@"<ShowDrawView> not pause, resume failed");
    }
}


- (void)addDrawAction:(DrawAction *)action play:(BOOL)play
{
    [self.drawActionList addObject:action];

    if (play) {
        if (self.status == Playing) {
            return;
        }else if(self.status == Stop){
            _currentAction = action;
            [self playFromDrawActionIndex:[self.drawActionList count] -1];
        }
    }else{
        self.status = Stop;
    }
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.status = Stop;
        self.speed = PlaySpeedTypeNormal;
        _drawActionList = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor whiteColor];      
        
        //set pen
        pen = [[PenView alloc] initWithPenType:Pencil];
        [self setShowPenHidden:NO];
        pen.hidden = YES;
        pen.userInteractionEnabled = NO;
        
        pen.penType = 0;
        
        [self setMaxPlaySpeed:[PPConfigManager getMaxPlayDrawSpeed]];
        [self setPlaySpeedWithSliderSpeed:[PPConfigManager getDefaultPlayDrawSpeed]];
        
        [self.superview addSubview:pen];
        
    }
    return self;
}

- (void)resetFrameSize:(CGSize)size
{
    CGRect rect = CGRectZero;
    rect.size = size;
    self.frame = rect;
    if ([self.superview isKindOfClass:[DrawHolderView class]]) {
        [(DrawHolderView *)self.superview updateContentScale];
    }
}

- (void)updateLayers:(NSArray *)layers
{
    [super updateLayers:layers];
    for (DrawLayer *layer in layers) {
        if ([layer supportCache]) {
            layer.cachedCount = 10;
        }
    }

}

+ (ShowDrawView *)showView
{
    return [[[ShowDrawView alloc] initWithFrame:[CanvasRect defaultRect]] autorelease];
}

+ (ShowDrawView *)showViewWithFrame:(CGRect)frame
                     drawActionList:(NSArray *)actionList
                           delegate:(id<ShowDrawViewDelegate>)delegate
{
    ShowDrawView *showView = [[[ShowDrawView alloc] initWithFrame:frame] autorelease];
    
    if ([actionList isKindOfClass:[NSMutableArray class]]) {
        showView.drawActionList = (NSMutableArray *)actionList;
    }else{
        showView.drawActionList = [NSMutableArray arrayWithArray:actionList];
    }
    showView.delegate = delegate;
    showView.frame = frame;
    return showView;
}

+ (BOOL)canPlayDrawVersion:(NSInteger)version
{
    return [PPConfigManager currentDrawDataVersion] >= version;
}


- (void)dealloc
{
    [self stop];
    PPRelease(_drawActionList);
    PPRelease(pen);
//    PPRelease(_tempPaint);
    PPRelease(_tempAction);
    [super dealloc];
}

- (NSInteger)lastCleanActionIndex
{
    int i = 0, ans = -1;
    for (DrawAction *action in self.drawActionList) {
        if (action.type == DrawActionTypeClean) {
            ans = i;
        }
        ++ i;
    }
    return  ans;
}


- (void)setShowPenHidden:(BOOL)showPenHidden
{
    _showPenHidden = showPenHidden;
    pen.hidden = showPenHidden;
}

//#define STEP 3
- (void)updateNextPlayIndex
{

    if (_playingPointIndex+self.speed >= [_currentAction pointCount] && _playingPointIndex < [_currentAction pointCount]-1) {
        _playingPointIndex = [_currentAction pointCount] - 1;
    }else{
        _playingPointIndex += self.speed;
    }
    
    if (_playingPointIndex >= [_currentAction pointCount]) {
        _playingPointIndex = 0;

        //next action
        if (++ _playingActionIndex < [self.drawActionList count]) {
            _currentAction = [self.drawActionList objectAtIndex:_playingActionIndex];
        }else{
            _currentAction = nil;
            _status = Stop;
        }
    }else{
        _playingPointIndex = MIN([_currentAction pointCount]-1, _playingPointIndex + 1);
    }
    
}


- (void)updateTempAction
{
    
    if ([_currentAction isKindOfClass:[PaintAction class]] ||
        [_currentAction isKindOfClass:[BrushAction class]]) {

        NSUInteger pointCount = 0;
        Paint* currentPaint = nil;
        BrushStroke *cbs = nil;
        if ([_currentAction isKindOfClass:[PaintAction class]]){
            currentPaint = [(PaintAction *)_currentAction paint];
            if (self.tempAction == nil) {
                Paint *paint = [Paint paintWithWidth:currentPaint.width
                                               color:currentPaint.color
                                             penType:currentPaint.penType
                                           pointList:nil];
                self.tempAction = [PaintAction paintActionWithPaint:paint];
            }
            
            pointCount = [currentPaint pointCount];
        }
        else{
            cbs = [(BrushAction *)_currentAction brushStroke];
            if (self.tempAction == nil) {
                BrushStroke *bs = [BrushStroke brushStrokeWithWidth:cbs.width
                                                              color:cbs.color
                                                          brushType:cbs.brushType
                                                          pointList:nil
                                                        isOptimized:cbs.isOptimized];
                
                self.tempAction = [BrushAction brushActionWithBrushStroke:bs];
            }
            
            pointCount = [cbs pointCount];
        }
        
        self.tempAction.shadow = [_currentAction shadow];
        self.tempAction.clipAction = _currentAction.clipAction;
        self.tempAction.layerTag = _currentAction.layerTag;
        self.tempAction.layerAlpha = _currentAction.layerAlpha;
        
        NSInteger i = [self.tempAction pointCount];
        CGPoint p;
        float width;
        for (; i <= _playingPointIndex; ++ i) {
            if (currentPaint){
                p = [currentPaint pointAtIndex:i];
                [self.tempAction addPoint:p inRect:self.bounds];
            }
            else{
                p = [cbs pointAtIndex:i];
                width = [cbs widthAtIndex:i];
                [(BrushAction *)self.tempAction addPoint:p
                                                   width:width
                                                  inRect:self.bounds
                                                 forShow:YES];
            }

        }
        
        if (i >= pointCount){ // [currentPaint pointCount]){
            [self.tempAction finishAddPoint];
        }
    }else{
        self.tempAction = nil;//_currentAction;
    }
    
}


- (void)callDidDrawPaintDelegate
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPlayDrawView:AtActionIndex:pointIndex:)]) {
        [self.delegate didPlayDrawView:self AtActionIndex:_playingActionIndex pointIndex:_playingPointIndex];
    }    
    if(_playingActionIndex >= [self.drawActionList count]-1){
        if(self.delegate && [self.delegate respondsToSelector:@selector(didPlayDrawView:)]){
            [self.delegate didPlayDrawView:self];
            
            self.status = Stop;
            _playingActionIndex = _playingPointIndex = 0;
            _currentAction =  nil;
            
            for (DrawLayer *layer in [self layers]) {
                if (layer.clipAction) {
                    [layer exitFromClipMode];
                }
                [layer setOpacity:layer.finalOpacity];
            }

        }
    }
    self.tempAction = nil;

}

- (void)delayShowAction:(DrawAction *)drawAction
{
    [self delayShowAction:drawAction stop:NO];
}

- (void)delayShowActionStop:(DrawAction *)drawAction
{
    [self delayShowAction:drawAction stop:YES];
}

- (void)delayShowAction:(DrawAction *)drawAction stop:(BOOL)stop
{
    
    
//    [self drawDrawAction:drawAction show:YES];
    
//    PPDebug(@"<delayShowAction>actionIndex = %d, pointIndex = %d, currentAction = %@, tempAction = %@", _playingActionIndex, _playingPointIndex,_currentAction,_tempAction);

    
    [self callDidDrawPaintDelegate];

    if (!stop) {
        [self performSelector:@selector(playNextFrame) withObject:nil afterDelay:self.playSpeed];
    }else{
        [self setStatus:Stop];
    }
}

//add procession of points in replay
- (void)playCurrentFrame
{
    _playFrameTime = CACurrentMediaTime();
    
//    [self updateTempPaint];
    [self updateTempAction];
    if (self.status == Playing) {
        if (self.tempAction) {
            if([self.tempAction pointCount] == 1){
                [dlManager addDrawAction:self.tempAction show:YES];
                if ([self currentClip] && _currentAction.clipAction == nil) {
                    [dlManager exitFromClipMode];
                }
            }else{
                [dlManager updateLastAction:self.tempAction refresh:YES];
            }

            if ([self.tempAction hasFinishAddPoint]) {
                [dlManager updateLastAction:_currentAction refresh:NO];
                [dlManager finishLastAction:_currentAction refresh:YES];
                [self callDidDrawPaintDelegate];
            }
            
            double delay = (CACurrentMediaTime() - _playFrameTime - self.playSpeed);
            delay = MIN(self.playSpeed, delay);
            delay = MAX(0, delay);
            [self performSelector:@selector(playNextFrame) withObject:nil afterDelay:delay];

        }else{
            if (![_currentAction isPaintAction] &&
                ![_currentAction isBrushAction]) {
                [self addDrawAction:_currentAction show:NO];
                [self finishLastAction:_currentAction refresh:YES];
                [self delayShowAction:_currentAction];
                
            } else {
                [self delayShowActionStop:_currentAction];
            }
            if ([self currentClip] && _currentAction.clipAction == nil) {
                [dlManager exitFromClipMode];
            }
        }
    }
    if(!_showPenHidden){
        [self movePen];
    }
}

- (void)playNextFrame
{
    if (Playing == self.status) {
        
        [self updateNextPlayIndex];
        
        [self playCurrentFrame];
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}


- (void)setPlaySpeedWithSliderSpeed:(double)sliderSpeed;
{
    self.playSpeed = sliderSpeed;
    
    double delta = sliderSpeed/self.maxPlaySpeed;
    NSInteger speed = (1-delta) * PlaySpeedTypeMax;
    speed = MAX(speed, 0);
    
    self.speed = speed + PlaySpeedTypeLow;
}

//#define LEVEL_TIMES 500

- (void)setDrawActionList:(NSMutableArray *)drawActionList
{
    [super setDrawActionList:drawActionList];
/*
    self.speed = PlaySpeedTypeNormal;
    
    if ([PPConfigManager useSpeedLevel]) {
        NSInteger count = [self.drawActionList count];
        if (count < PlaySpeedTypeNormal * LEVEL_TIMES) {
            self.speed = PlaySpeedTypeLow;
        }else if(count < PlaySpeedTypeHigh * LEVEL_TIMES){
            self.speed = PlaySpeedTypeNormal;
        }else if(count < PlaySpeedTypeSuper* LEVEL_TIMES){
            self.speed = PlaySpeedTypeHigh;
        }else{
            self.speed = PlaySpeedTypeSuper;
        }
        PPDebug(@"<setDrawActionList>auto set speed: %d,actionCount = %d",self.speed, count);
    }    
 */
}

- (void)changeRect:(CGRect)rect
{
    [super changeRect:rect];
}

+(UIImage*)addImage:(UIImage*)image1 toImage:(UIImage*)image2
{
    UIGraphicsBeginImageContext(image2.size);
    
    // Draw image1
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    
    // Draw image2
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

#pragma mark - GIF methods

- (UIImage*)createImageAtIndex:(NSUInteger)index
{
//    //追寻到index位置的图，并利用createImage返回一个UIImage对象
//    PPDebug(@"create an image at index: %d", index);
//    [self showToIndex:index];
//    return [self createImage];

    return [self createImageAtIndex:index bgColor:[UIColor whiteColor]];
}

- (UIImage*)createImageAtIndex:(NSUInteger)index bgColor:(UIColor*)bgColor
{
    //追寻到index位置的图，并利用createImage返回一个UIImage对象
    PPDebug(@"create an image at index: %d", index);
    [self showToIndex:index];
    return [self createImageWithBgColor:bgColor];
   
}

- (UIImage*)createImageFromLayer:(DrawLayer*)layer bgImage:(UIImage*)bgImage
{
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
 
//    CGContextSaveGState(ctx);
//    CGContextSetAlpha(ctx, 1.0 - layer.opacity);
    // draw bg image
    if (bgImage){
        [bgImage drawAtPoint:CGPointZero];
    }
//    CGContextRestoreGState(ctx);

    // draw layer
    [layer renderInContext:ctx];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (NSMutableArray*)createGIF:(NSUInteger)frameNumber scaleSize:(float)scaleSize finalImage:(UIImage*)finalImage
{
    
//    if (frameNumber <= 0 || frameNumber > [PPConfigManager maxGIFFrame]){
//        PPDebug(@"<createGIF> but frameNumber (%d) out of bound", frameNumber);
//        return nil;
//    }
//    
//    if (scaleSize <=0 || scaleSize > 100){
//        PPDebug(@"<createGIF> but scaleSize (%.2f) out of bound", scaleSize);
//        return nil;
//    }
//    
    int startTime = time(0);
    
    CGSize finalImageSize = finalImage ? finalImage.size : CGSizeZero;
    BOOL sizeFit = (abs(finalImageSize.width - self.bounds.size.width) < 1.0f &&
                    abs(finalImageSize.height - self.bounds.size.height) < 1.0f);
    
    if (sizeFit == NO){
        if (finalImageSize.width > self.bounds.size.width &&
            finalImageSize.height > self.bounds.size.height){
            
            // scaling finalImage to the same size
            finalImage = [finalImage imageByScalingAndCroppingForSize:self.bounds.size];
            sizeFit = YES;
        }
    }
    
    if (finalImage && sizeFit){
        // has final image and its size is the same as draw view size
        frameNumber --;
    }
    else{
        // size not the same, don't use it!
        finalImage = nil;
    }
    
    NSArray* drawActionList = self.drawActionList;
    
    NSMutableArray *gifFrames = [NSMutableArray arrayWithCapacity:frameNumber];//input the images
    
    CGFloat progress = 0;

    [self resetView];

    NSArray* layerList = [dlManager layers];
    

    NSMutableDictionary *layerAlphaDict = [NSMutableDictionary dictionaryWithCapacity:[layerList count]];
    NSMutableDictionary *prevLayerImageDict = nil;
    
//    CGSize outputSize = CGSizeMake(self.bounds.size.width*scaleSize, self.bounds.size.height*scaleSize);
    
    // add several frames
    int startIndex = 0;
    int endIndex = 0;
    int totalCount = [drawActionList count];
    frameNumber = MIN(totalCount, frameNumber);     // avoid frame number is bigger than total action count
    for(NSInteger i = 1;i <= frameNumber;i++)
    {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        endIndex = (i * totalCount / frameNumber - 1);
        PPDebug(@"<createImagesForGIF> create %d frame, start=%d, end=%d", i, startIndex, endIndex);
        
        int showLength = MAX(0, endIndex - startIndex + 1);
        showLength = MIN(showLength, totalCount);
        if (i == frameNumber){
            // last frame
            showLength = totalCount - startIndex;
        }
        
        BOOL useLayerOpacity = (i >= frameNumber);
        
        if (startIndex < 0 || startIndex >= totalCount){
            PPDebug(@"<createGIF> startIndex(%d) out of bound", startIndex);
            break;
        }
        
        NSArray *actions = [_drawActionList subarrayWithRange:NSMakeRange(startIndex, showLength)];

        // init layer actions
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[layerList count]];
        for (DrawLayer *layer in layerList) {
            [dict setObject:[NSMutableArray array] forKey:@(layer.layerTag)];
        }
        
        // put actions into its layer
        for (DrawAction *action in actions) {
            NSMutableArray *array = [dict objectForKey:@(action.layerTag)];
            [array addObject:action];
            
            // set last alpha
            if (!useLayerOpacity){
                [layerAlphaDict setObject:@(action.layerAlpha) forKey:@(action.layerTag)];
            }
        }
        
        UIImage *image;
        PPDebug(@"<createImage> size=%@", NSStringFromCGSize(self.bounds.size));
        
        UIGraphicsBeginImageContext(self.bounds.size);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();

        // draw background as white
        UIColor* bgColor = [UIColor whiteColor];
        if (bgColor){
            [bgColor setFill];
            CGContextFillRect(ctx, self.bounds);
        }

        // draw layers
        NSMutableDictionary *layerImageDict = [NSMutableDictionary dictionaryWithCapacity:[layerList count]];
//        for (DrawLayer *layer in layerList) {
//            PPDebug(@"<arrangeActions> layer name = %@", layer.layerName);
//            [layer reset];
//            
//            // set layer alpha
//            if (!useLayerOpacity){
//                NSNumber* alpha = [layerAlphaDict objectForKey:@(layer.layerTag)];
//                if (alpha){
//                    layer.opacity = [alpha floatValue];
//                }
//            }
//            else{
//                layer.opacity = layer.finalOpacity;
//            }
//            
//            PPDebug(@"layer opacity is %.2f", layer.opacity);
//            
//            // set layer actions
//            NSMutableArray *array = [dict objectForKey:@(layer.layerTag)];
//            [layer updateWithDrawActions:array];
//            
//            // draw layer
//            [layer setNeedsDisplay];
//            
//            UIImage* prevImage = [prevLayerImageDict objectForKey:@(layer.layerTag)];
//            
//            ClipAction *clip = [layer clipAction];
//            NSInteger gridLineNumber = [[layer drawInfo] gridLineNumber];
//            UIImage* layerImage = nil;
//            if (clip != nil || gridLineNumber != 0) {
//                // clear clip info
//                layer.clipAction = nil;
//                layer.drawInfo.gridLineNumber = 0;
//                [layer setNeedsDisplay];
//                
//                // create layer image
//                layerImage = [self createImageFromLayer:layer bgImage:prevImage];
//                
//                // restore clip info
//                [layer setClipAction:clip];
//                [layer.drawInfo setGridLineNumber:gridLineNumber];
//                [layer setNeedsDisplay];
//            }else{
//                layerImage = [self createImageFromLayer:layer bgImage:prevImage];
//            }
//            
//            if (layerImage){
//                [layerImageDict setObject:layerImage forKey:@(layer.layerTag)];
//            }
//        }
        
        // draw each layer in image context
        [layerList reversEnumWithHandler:^(id object) {
            DrawLayer *layer = object;
            
            PPDebug(@"<draw> layer name = %@", layer.layerName);
            [layer reset];
            
            // set layer alpha
            if (!useLayerOpacity){
                NSNumber* alpha = [layerAlphaDict objectForKey:@(layer.layerTag)];
                if (alpha){
                    layer.opacity = [alpha floatValue];
                }
            }
            else{
                layer.opacity = layer.finalOpacity;
            }
            
            PPDebug(@"layer opacity is %.2f", layer.opacity);
            
            // set layer actions
            NSMutableArray *array = [dict objectForKey:@(layer.layerTag)];
            [layer updateWithDrawActions:array];
            
            // draw layer
            [layer setNeedsDisplay];
            
            UIImage* prevImage = [prevLayerImageDict objectForKey:@(layer.layerTag)];
            
            ClipAction *clip = [layer clipAction];
//            NSInteger gridLineNumber = [[layer drawInfo] gridLineNumber];
            UIImage* layerImage = nil;
            if (clip != nil){ // || gridLineNumber != 0) {
                // clear clip info
                layer.clipAction = nil;
//                layer.drawInfo.gridLineNumber = 0;
                [layer setNeedsDisplay];
                
                // create layer image
                layerImage = [self createImageFromLayer:layer bgImage:prevImage];
                
                // restore clip info
                [layer setClipAction:clip];
//                [layer.drawInfo setGridLineNumber:gridLineNumber];
                [layer setNeedsDisplay];
            }else{
                layerImage = [self createImageFromLayer:layer bgImage:prevImage];
            }
            
            if (layerImage){
                [layerImageDict setObject:layerImage forKey:@(layer.layerTag)];
            }
            
            if (layer.opacity > 0.0){
                // draw bg image
//                if (prevImage){
//                    [prevImage drawAtPoint:CGPointZero];
//                }
                //    CGContextRestoreGState(ctx);
                
                // draw layer
//                [layer renderInContext:ctx];
//                UIImage* layerImage = [layerImageDict objectForKey:@(layer.layerTag)];
                [layerImage drawAtPoint:CGPointZero];
            }
        }];
        
        // get image
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // save for next bg image
        [prevLayerImageDict release];                   // release old
        prevLayerImageDict = nil;
        prevLayerImageDict = [layerImageDict retain];   // retain current

        // scale image and add image into list
        image = [image scaleImage:image toScale:scaleSize];
        if (image){
            [gifFrames addObject:image];
        }
        else{
            PPDebug(@"<createImagesForGIF> fail to create frame image");
        }
        
        // report progress to UI
        progress = (i*1.0f)/(frameNumber*1.0f);
        [ShowDrawView postCreateGIFNotification:progress];

        // change start index
        startIndex = endIndex;
        
        [pool drain];
    }
    
    [prevLayerImageDict release];                   // release old
    prevLayerImageDict = nil;
    
    // add last image to first for good display
    if (finalImage){
        finalImage = [finalImage scaleImage:finalImage toScale:scaleSize];
//        finalImage = [UIImage decodedImageWithImage:finalImage];
        if (finalImage){
            [gifFrames insertObject:finalImage atIndex:0];
            [gifFrames addObject:finalImage];
        }
    }
    else{
        UIImage* lastImage = [gifFrames lastObject];
//        lastImage = [UIImage decodedImageWithImage:lastImage];
        if (lastImage){
            [gifFrames insertObject:lastImage atIndex:0];
        }
    }
    
    [gifFrames removeLastObject];

    // report final progress
    [ShowDrawView postCreateGIFNotification:0.999f];
    
    PPDebug(@"create gif 2 spend time is %d seconds", time(0) - startTime);
    return gifFrames;
}

//gif的制作
+ (void) createGIF:(NSInteger)frameNumber
         delayTime:(double) delayTime
    drawActionList:(NSMutableArray*)drawActionList
           bgImage:(UIImage*)bgImage
            layers:(NSArray*)layers
        canvasSize:(CGSize)canvasSize
        finalImage:(UIImage*)finalImage
        outputPath:(NSString*)outputPath
        scaleSize:(double)scaleSize

{
    
    PPDebug(@"<createGIF> delay(%f) path(%@) scale(%f)", delayTime, outputPath, scaleSize);
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    //利用参数获取源数据image
    NSMutableArray *srcImgList = [self createImagesForGIF:frameNumber
                                           drawActionList:drawActionList
                                                  bgImage:bgImage
                                                   layers:layers
                                               canvasSize:canvasSize
                                                scaleSize:scaleSize
                                               finalImage:finalImage];
    
    
    
    
    
    
    [srcImgList retain];
    [pool drain];
    
    if ([srcImgList count] == 0){
        [srcImgList release];
        return;
    }

#ifdef DEBUG
    
    
    NSString* name = [NSString stringWithFormat:@"作者：%@",[ShareService defaultService].draft.drawUserNickName];
    PPDebug(@"nickname is %@",name);
//    UIImage* srcImage = [self makeEndingImage:[UIImage imageNamed:@"shipinEnding.jpg"] AndText:name];
//    UIImage *beginningSrcImage = [self makeBeginningImage:[srcImgList objectAtIndex:0]];
    
    [srcImgList addObject:[srcImgList objectAtIndex:0]];
    [srcImgList addObject:[srcImgList objectAtIndex:0]];
//    [srcImgList insertObject:beginningSrcImage atIndex:0];
//    [srcImgList addObject:srcImage];
//    [srcImgList addObject:srcImage];
//    [srcImgList addObject:srcImage];
    
    NSString *path2 = [NSHomeDirectory() stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"Documents/movie.mp4"]];
    
    [[NSFileManager defaultManager] removeItemAtPath:path2 error:NULL];
    
    CGSize videoSize = (CGSize){960, 640};
    [HJImagesToVideo saveVideoToPhotosWithImages:srcImgList withSize:videoSize  withFPS:5 animateTransitions:YES  withCallbackBlock:^(BOOL success){
        if (success) {
            PPDebug(@"Success, size %@", NSStringFromCGSize(canvasSize));
        } else {
            NSLog(@"Failed, size %@", NSStringFromCGSize(canvasSize));
        }
    }];
    [srcImgList removeLastObject];
    
    
    
    
    
#endif
    
    /*
    //图像目标
    CGImageDestinationRef destImg;
    
    //创建输出路径
    NSString *path = outputPath;
    CFURLRef url = CFURLCreateWithFileSystemPath (
                                                  kCFAllocatorDefault,
                                                  (CFStringRef)path,
                                                  kCFURLPOSIXPathStyle,
                                                  false);
    
    //通过一个url返回图像目标
    destImg = CGImageDestinationCreateWithURL(url, kUTTypeGIF, srcImgList.count, NULL);
    
    //设置gif的信息,播放间隔时间,基本数据,和delay时间
    NSDictionary *frameProperties = [NSDictionary
                                     dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@(delayTime), (NSString *)kCGImagePropertyGIFDelayTime, @(1), (NSString *)kCGImagePropertyGIFLoopCount, nil]
                                     forKey:(NSString *)kCGImagePropertyGIFDictionary];
    
    //设置gif信息
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(YES) forKey:(NSString*)kCGImagePropertyGIFHasGlobalColorMap];
    [dict setObject:(NSString *)kCGImagePropertyColorModelRGB forKey:(NSString *)kCGImagePropertyColorModel];
    [dict setObject:@(frameNumber) forKey:(NSString*)kCGImagePropertyDepth];
    [dict setObject:@(0) forKey:(NSString *)kCGImagePropertyGIFLoopCount];
    NSDictionary *gifProperties = [NSDictionary dictionaryWithObject:dict
                                                              forKey:(NSString *)kCGImagePropertyGIFDictionary];
    //合成gif
    for (UIImage* image in srcImgList)
    {
        CGImageDestinationAddImage(destImg, image.CGImage, (__bridge CFDictionaryRef)frameProperties);
    }
    CGImageDestinationSetProperties(destImg, (__bridge CFDictionaryRef)gifProperties);
    CGImageDestinationFinalize(destImg);
    CFRelease(destImg);
    CFRelease(url);
    
    [srcImgList release];
     */
    
#ifdef DEBUG
//    [HJImagesToVideo addAudioToFileAtPath:@"/Users/pipi/Desktop/temp.mp4" toPath:@"/Users/pipi/Desktop/2.mp4"];
#endif
    
    return;
}

+ (void)postCreateGIFNotification:(CGFloat)progress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary* userInfo = @{ KEY_DATA_PARSING_PROGRESS : @(progress) };
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GIF_CREATION object:nil userInfo:userInfo];
    });
}

+ (NSMutableArray*)createImagesForGIF:(NSInteger)frameNumber
                       drawActionList:(NSMutableArray*)drawActionList
                              bgImage:(UIImage*)bgImage
                               layers:(NSArray*)layers
                           canvasSize:(CGSize)canvasSize
                            scaleSize:(double) scaleSize
                           finalImage:(UIImage*)finalImage

{
    if ([drawActionList count] == 0 || [layers count] == 0){
        PPDebug(@"<createImagesForGIF> but action list count is 0 or layers count is 0");
        return nil;
    }
    
    //update showview
    ShowDrawView* showView = [ShowDrawView showViewWithFrame:CGRectFromCGSize(canvasSize)
                                              drawActionList:nil
                                                    delegate:nil];
    
    [showView updateLayers:layers];
    [showView setDrawActionList:drawActionList];
    if (bgImage) {
        [showView setBGImage:bgImage];
    }

    return [showView createGIF:frameNumber scaleSize:scaleSize finalImage:finalImage];

    // the following is old implementation, just for backup
    /*
    int startTime = time(0);
    
    NSMutableArray *gifFrames = [NSMutableArray arrayWithCapacity:frameNumber];//input the images
    
    CGFloat progress = 0;
    
    // add several frames
    UIImage* prevImage = nil;
    int startIndex = 0;
    int endIndex = 0;
    for(NSInteger i = 1;i < frameNumber;i++)
    {
        endIndex = (i * [drawActionList count] / frameNumber - 1);
        PPDebug(@"<createImagesForGIF> create %d frame, start=%d, end=%d", i, startIndex, endIndex);
        UIImage* image = [showView createImageAtIndex:endIndex bgColor:[UIColor whiteColor]];
        image = [image scaleImage:image toScale:scaleSize];
        if (image){
            [gifFrames addObject:image];
            prevImage = image;
        }
        else{
            PPDebug(@"<createImagesForGIF> fail to create frame image");
        }
        progress = (i*1.0f)/(frameNumber*1.0f);
        [self postCreateGIFNotification:progress];
    }
    
    // last image
    UIImage *lastImage = [showView createImageAtIndex:[drawActionList count] bgColor:[UIColor whiteColor]];
    lastImage = [lastImage scaleImage:lastImage toScale:scaleSize];
    if (lastImage){
        [gifFrames addObject:lastImage];
        [gifFrames insertObject:lastImage atIndex:0];   // insert first to make GIF readable
    }
    
    [self postCreateGIFNotification:0.999f];
    
    PPDebug(@"create gif spend time is %d seconds", time(0) - startTime);
    
    return gifFrames;
     */
}

+ (UIImage*)createImage:(NSMutableArray*)drawActionList
                       bgImage:(UIImage*)bgImage
                        layers:(NSArray*)layers
                    canvasSize:(CGSize)canvasSize

{
    if ([drawActionList count] == 0 || [layers count] == 0){
        PPDebug(@"<createImagesForGIF> but action list count is 0 or layers count is 0");
        return nil;
    }
    
    //update showview
    ShowDrawView* showView = [ShowDrawView showViewWithFrame:CGRectFromCGSize(canvasSize)
                                              drawActionList:nil
                                                    delegate:nil];
    
    [showView updateLayers:layers];
    [showView setDrawActionList:drawActionList];
    if (bgImage) {
        [showView setBGImage:bgImage];
    }
    
    return [showView createImageAtIndex:[drawActionList count] bgColor:[UIColor whiteColor]];
    
}


- (void) createImageOfLayer:(NSInteger)num
                       Path:(NSString*)path
{
    UIImage* img = [self createImageAtIndex:([self.drawActionList count]-1)];
    [img saveImageToFile:path];
}

@end



@implementation ShowDrawView (PressAction)

- (void)gestureRecognizerManager:(GestureRecognizerManager *)manager
                   didGestureEnd:(UIGestureRecognizer *)gestureRecognizer
{
    if (_supportLongPress && [gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        if(_delegate && [self.delegate respondsToSelector:@selector(didLongClickShowDrawView:)])
        {
            [_delegate didLongClickShowDrawView:self];
        }
    }else if (_supportLongPress && [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if(_delegate && [self.delegate respondsToSelector:@selector(didClickShowDrawView:)])
        {
            [_delegate didClickShowDrawView:self];
        }
    }
}

- (void)setPressEnable:(BOOL)enable
{
    if (!_supportLongPress && enable) {
        [_gestureRecognizerManager addLongPressGestureReconizerToView:self];
        [_gestureRecognizerManager addTapGestureReconizerToView:self];
    }
    _supportLongPress = enable;
}

+(UIImage *)makeEndingImage:(UIImage *)srcImage AndText:(NSString *)text{
    
    if (text == nil) {
        return srcImage;
    }
    float labelHeight = srcImage.size.height*0.05;
    int labelFontSize = (int)labelHeight;
    
    if (labelFontSize > 25){
        labelFontSize = 25;
    }
    
    UIColor* imageShadowColor = [UIColor colorWithRed:112/255.0 green:109/255.0 blue:109/255.0 alpha:1.0];
    //    UIColor* labelShadowColor = [UIColor colorWithRed:108/255.0 green:107/255.0 blue:107/255.0 alpha:1.0];
    
    UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, srcImage.size.width + shadow*2, labelHeight)] autorelease];
    [label setText:text];
    [label setAdjustsFontSizeToFitWidth:YES];
    [label setMinimumScaleFactor:3];
    [label setTextColor:COLOR_WHITE];
    
    [label setFont:[UIFont boldSystemFontOfSize:labelFontSize]];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    UIGraphicsBeginImageContext(CGSizeMake(490, srcImage.size.height + 5*3 + labelHeight+5));
    
    CGContextRef ref = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ref);
    
//    //line of left
//    CGContextSetShadowWithColor(ref, CGSizeMake(-5, 0), 10, imageShadowColor.CGColor);
//    //right line
//    CGContextSetShadowWithColor(ref, CGSizeMake(5, 0), 10, imageShadowColor.CGColor);
//    CGContextSetShadowWithColor(ref, CGSizeMake(0, 5), 10, imageShadowColor.CGColor);
    
    // draw image with shadow
    CGRect rect = CGRectMake(5, 0, 490, 320);
    [srcImage drawInRect:rect];
    
    CGContextRestoreGState(ref);
    
    // draw text
    [label drawTextInRect:CGRectMake(0, srcImage.size.height-labelHeight, srcImage.size.width, labelHeight)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    return resultingImage;

    
    
}
+(UIImage *)makeBeginningImage:(UIImage *)drawImage{
    
    NSString* name = [NSString stringWithFormat:@"作者：%@",[ShareService defaultService].draft.drawUserNickName];
    UIImage *srcImage = [UIImage imageNamed:@"shipinEnding.jpg"];
    UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200,20)] autorelease];
    [label setText:name];
    [label setAdjustsFontSizeToFitWidth:YES];
    [label setMinimumScaleFactor:3];
    [label setTextColor:COLOR_WHITE];
    
    [label setFont:[UIFont boldSystemFontOfSize:20]];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    UILabel* imageTitle = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200,20)] autorelease];
    NSString* drawName = [NSString stringWithFormat:@"小吉画画作品欣赏"];
    [imageTitle setText:drawName];
    [imageTitle setAdjustsFontSizeToFitWidth:YES];
    [imageTitle setMinimumScaleFactor:3];
    [imageTitle setTextColor:COLOR_WHITE];
    
    [imageTitle setFont:[UIFont boldSystemFontOfSize:20]];
    [imageTitle setTextAlignment:NSTextAlignmentCenter];
    
    

    UIGraphicsBeginImageContext(CGSizeMake(490, srcImage.size.height + 5*3));
    CGContextRef ref = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ref);
    CGRect rect = CGRectMake(5, 0, 490, 320);
    [srcImage drawInRect:rect];
    CGRect drawRect = CGRectMake(srcImage.size.width/2 - 100, srcImage.size.height/2 - 100, 200, 200);
    if(drawImage != nil){
        [drawImage drawInRect:drawRect];
    }

    CGContextRestoreGState(ref);
    
    [label drawTextInRect:CGRectMake(0, srcImage.size.height-40, srcImage.size.width, 20)];
    [imageTitle drawTextInRect:CGRectMake(0,20, srcImage.size.width, 20)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    return resultingImage;
}





@end
