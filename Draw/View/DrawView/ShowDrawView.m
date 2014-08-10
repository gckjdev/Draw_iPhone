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


#include <ImageIO/ImageIO.h>
#include <MobileCoreServices/MobileCoreServices.h>

//#define DEFAULT_PLAY_SPEED  (0.01)
//#define MIN_PLAY_SPEED      (0.001f)
typedef enum {
    PlaySpeedTypeLow = 1, // 1/30.0
    PlaySpeedTypeNormal = 2, // x2
    PlaySpeedTypeHigh = 4, //x4
    PlaySpeedTypeSuper = 6,//x6
    PlaySpeedTypeMax = 12,//x10
}PlaySpeedType;



@interface ShowDrawView ()
{
    NSInteger _playingActionIndex;
    NSInteger _playingPointIndex;
    
    BOOL _showPenHidden;
    BOOL _supportLongPress;
    PenView *pen;

}
@property(nonatomic, assign) NSInteger speed; //default is Normal;
@property (nonatomic, retain) PaintAction *tempAction;

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
    
    if ([_currentAction isKindOfClass:[PaintAction class]]) {
        pen.hidden = NO;
        PaintAction *paintAction = (PaintAction *)_currentAction;
        
        if (_playingPointIndex == 0 && pen.penType != paintAction.paint.penType) {
            //reset pen type
            ItemType penType = paintAction.paint.penType;
            [pen setPenType:penType];
        }
        CGPoint point = [paintAction.paint pointAtIndex:_playingPointIndex];

        point= [pen.superview convertPoint:point fromView:self];
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
    
    NSArray *array = [_drawActionList subarrayWithRange:NSMakeRange(0, index)];
    [dlManager arrangeActions:array];
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
        self.maxPlaySpeed = [PPConfigManager getMaxPlayDrawSpeed];
        self.playSpeed = [PPConfigManager getDefaultPlayDrawSpeed];
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
        _playingPointIndex = MIN([_currentAction pointCount]-1, _playingPointIndex + 1); //self.speed);
    }
    
}


- (void)updateTempAction
{
    
    if ([_currentAction isKindOfClass:[PaintAction class]]) {
        Paint *currentPaint = [(PaintAction *)_currentAction paint];
        if (self.tempAction == nil) {
            Paint *paint = [Paint paintWithWidth:currentPaint.width color:currentPaint.color penType:currentPaint.penType pointList:nil];
            self.tempAction = [PaintAction paintActionWithPaint:paint];
            self.tempAction.shadow = [_currentAction shadow];
            self.tempAction.clipAction = _currentAction.clipAction;
            self.tempAction.layerTag = _currentAction.layerTag;
            self.tempAction.layerAlpha = _currentAction.layerAlpha;
        }
        NSInteger i = [self.tempAction pointCount];
        for (; i <= _playingPointIndex; ++ i) {
            CGPoint p = [currentPaint pointAtIndex:i];
            [self.tempAction addPoint:p inRect:self.bounds];
        }
        
        if (i >= [currentPaint pointCount]){
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
            if (![_currentAction isPaintAction]) {
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
//        BOOL slow = ![_currentAction isKindOfClass:[PaintAction class]];
        
        [self updateNextPlayIndex];
        
#ifdef DEBUG
       
#endif
        
        
        [self playCurrentFrame];
        
//        if (slow) {
//            [self performSelector:@selector(playCurrentFrame) withObject:nil afterDelay:0.4];
//        }else{
//            [self playCurrentFrame];
//        }
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}


- (void)setPlaySpeed:(double)playSpeed
{
    _playSpeed = playSpeed;
    double delta = playSpeed/self.maxPlaySpeed;
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

//gif的制作
+ (void) createGIF:(NSInteger)frameNumber
         delayTime:(double) delayTime
    drawActionList:(NSMutableArray*)drawActionList
           bgImage:(UIImage*)bgImage
            layers:(NSArray*)layers
        canvasSize:(CGSize)canvasSize
        outputPath:(NSString*)outputPath
        scaleSize:(double)scaleSize
{
    //利用参数获取源数据image
    NSMutableArray *srcImgList = [self createImagesForGIF:frameNumber
                                           drawActionList:drawActionList
                                                  bgImage:bgImage
                                                   layers:layers
                                               canvasSize:canvasSize
                                                scaleSize:scaleSize];
    //图像目标
    CGImageDestinationRef destImg;
    
    //创建输出路径
    NSString *path = outputPath;
    PPDebug(@"output gif to: %@",path);
    //创建CFURL对象
    /*
     CFURLCreateWithFileSystemPath(CFAllocatorRef allocator, CFStringRef filePath, CFURLPathStyle pathStyle, Boolean isDirectory)
     
     allocator : 分配器,通常使用kCFAllocatorDefault
     filePath : 路径
     pathStyle : 路径风格,我们就填写kCFURLPOSIXPathStyle 更多请打问号自己进去帮助看
     isDirectory : 一个布尔值,用于指定是否filePath被当作一个目录路径解决时相对路径组件
     */
    CFURLRef url = CFURLCreateWithFileSystemPath (
                                                  kCFAllocatorDefault,
                                                  (CFStringRef)path,
                                                  kCFURLPOSIXPathStyle,
                                                  false);
    
    //通过一个url返回图像目标
    destImg = CGImageDestinationCreateWithURL(url, kUTTypeGIF, srcImgList.count, NULL);
    
    //设置gif的信息,播放间隔时间,基本数据,和delay时间
    NSDictionary *frameProperties = [NSDictionary
                                     dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:delayTime], (NSString *)kCGImagePropertyGIFDelayTime, nil]
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
    return;
}

+ (NSMutableArray*)createImagesForGIF:(NSInteger)frameNumber
                       drawActionList:(NSMutableArray*)drawActionList
                              bgImage:(UIImage*)bgImage
                               layers:(NSArray*)layers
                           canvasSize:(CGSize)canvasSize
                            scaleSize:(double) scaleSize
{
    //update showview
    ShowDrawView* showView = [ShowDrawView showViewWithFrame:CGRectFromCGSize(canvasSize)
                                              drawActionList:nil
                                                    delegate:nil];
    
    [showView updateLayers:layers];
    [showView setDrawActionList:drawActionList];
    if (bgImage) {
        [showView setBGImage:bgImage];
    }
    
    
    NSMutableArray *cuttingList = [NSMutableArray arrayWithCapacity:frameNumber];//mark the cutting list
    NSMutableArray *gifFrames = [NSMutableArray arrayWithCapacity:frameNumber];//input the images
    
    // add last frame
    for(NSInteger i=0;i < 4;i++){
        UIImage *lastImage = [showView createImageAtIndex:[drawActionList count]];
        //resize the image scale according to requirement
        lastImage = [lastImage scaleImage:lastImage toScale:scaleSize];
        [gifFrames addObject:lastImage];
    }
    // add several frames
    for(NSInteger i = 1;i < frameNumber;i++)
    {
        [cuttingList addObject:@(i * [drawActionList count] / frameNumber)];
        NSNumber* playIndex = [cuttingList objectAtIndex:(i-1)];
        UIImage* image = [showView createImageAtIndex:[playIndex intValue]];
        image = [image scaleImage:image toScale:scaleSize];
        [gifFrames addObject:image];
        PPDebug(@"<createImagesForGIF> create %d frame, index=%d", i, [playIndex intValue]);
    }
    
    return gifFrames;
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



@end
