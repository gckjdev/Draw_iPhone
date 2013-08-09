//
//  DrawAction.m
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawAction.h"
#import "DrawColor.h"
#import "ConfigManager.h"
#import "ShapeAction.h"
#import "ChangeBackAction.h"
#import "PaintAction.h"
#import "CleanAction.h"
#import "ChangeBGImageAction.h"
#import "StringUtil.h"
#import "Word.h"
#import "DrawUtils.h"
#import "Draw.pb-c.h"
#import "Draw.pb.h"
#import "BBS.pb-c.h"
#import "Draw.h"
#import "GradientAction.h"
#import "ClipAction.h"

@implementation DrawAction


- (BOOL)isPaintAction
{
    return [self isKindOfClass:[PaintAction class]];
}
- (BOOL)isShapeAction
{
    return [self isKindOfClass:[ShapeAction class]];
}
- (BOOL)isClipAction
{
     return [self isKindOfClass:[ClipAction class]];
}
- (BOOL)isGradientAction
{
     return [self isKindOfClass:[GradientAction class]];
}
- (BOOL)isChangeBGAction
{
     return [self isKindOfClass:[ChangeBackAction class]];
}
- (BOOL)isChangeImageBGAction
{
     return [self isKindOfClass:[ChangeBGImageAction class]];
}



- (void)setCanvasSize:(CGSize)canvasSize
{
    
}

- (void)dealloc
{
    PPRelease(_shadow);
    [super dealloc];
}

+ (id)drawActionWithPBDrawActionC:(Game__PBDrawAction *)action
{
    switch (action->type) {
        case DrawActionTypeClean:
            return [[[CleanAction alloc] initWithPBDrawActionC:action] autorelease];
        case DrawActionTypeShape:
            return [[[ShapeAction alloc] initWithPBDrawActionC:action] autorelease];
        case DrawActionTypePaint:
            if (action->width >= BACK_GROUND_WIDTH / 10) {
                return [[[ChangeBackAction alloc] initWithPBDrawActionC:action] autorelease];
            }
            return [[[PaintAction alloc] initWithPBDrawActionC:action] autorelease];
        case DrawActionTypeChangeBack:
            return [[[ChangeBackAction alloc] initWithPBDrawActionC:action] autorelease];
        case DrawActionTypeChangeBGImage:
            return [[[ChangeBGImageAction alloc] initWithPBDrawActionC:action] autorelease];
        case DrawActionTypeGradient:
            return [[[GradientAction alloc] initWithPBDrawActionC:action] autorelease];
        case DrawActionTypeClip:
            return [[[ClipAction alloc] initWithPBDrawActionC:action] autorelease];
            
        default:
            return nil;
    }
    
}

+ (id)drawActionWithPBDrawAction:(PBDrawAction *)action
{
    switch (action.type) {
        case DrawActionTypeClean:
            return [[[CleanAction alloc] initWithPBDrawAction:action] autorelease];
        case DrawActionTypeShape:
            return [[[ShapeAction alloc] initWithPBDrawAction:action] autorelease];
        case DrawActionTypePaint:
            if (action.width >= BACK_GROUND_WIDTH / 10) {
                return [[[ChangeBackAction alloc] initWithPBDrawAction:action] autorelease];
            }
            return [[[PaintAction alloc] initWithPBDrawAction:action] autorelease];
        case DrawActionTypeChangeBack:
            return [[[ChangeBackAction alloc] initWithPBDrawAction:action] autorelease];
        case DrawActionTypeChangeBGImage:
            return [[[ChangeBGImageAction alloc] initWithPBDrawAction:action] autorelease];
        
        default:
            return nil;
    }
}

+ (id)drawActionWithPBNoCompressDrawActionC:(Game__PBNoCompressDrawAction *)action
{
    switch (action->type) {
        case DrawActionTypeClean:
            return [[[CleanAction alloc] initWithPBNoCompressDrawActionC:action] autorelease];
        case DrawActionTypeShape:
            return [[[ShapeAction alloc] initWithPBNoCompressDrawActionC:action] autorelease];
        case DrawActionTypePaint:
            if (action->width >= BACK_GROUND_WIDTH / 10) {
                return [[[ChangeBackAction alloc] initWithPBNoCompressDrawActionC:action] autorelease];
            }
            return [[[PaintAction alloc] initWithPBNoCompressDrawActionC:action] autorelease];
        case DrawActionTypeChangeBack:
            return [[[ChangeBackAction alloc] initWithPBNoCompressDrawActionC:action] autorelease];
        case DrawActionTypeChangeBGImage:
            return [[[ChangeBGImageAction alloc] initWithPBNoCompressDrawActionC:action] autorelease];
        default:
            return nil;
    }
}


- (id)initWithPBNoCompressDrawAction:(PBNoCompressDrawAction *)action
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithPBNoCompressDrawActionC:(Game__PBNoCompressDrawAction *)action
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect
{
    return CGRectZero;
}

- (CGRect)redrawRectInRect:(CGRect)rect
{
    return rect;
}

- (id)initWithPBDrawAction:(PBDrawAction *)action
{
    self = [super init];
    if (self) {
        self.type = action.type;
        self.clipTag = (action.hasClipTag ? action.clipTag : 0);
        self.layerTag = (action.hasLayerTag ? action.layerTag : 0);
        if ([action hasShadowOffsetX] && [action hasShadowColor]) {
            self.shadow = [Shadow shadowWithIntColor:action.shadowColor
                                              offset:CGSizeMake(action.shadowOffsetX,
                                                                action.shadowOffsetY)
                                                blur:action.shadowBlur];
        }
    }
    return self;
}

#define DEFAULT_LAYER_TAG 2

- (id)initWithPBDrawActionC:(Game__PBDrawAction *)action
{
    self = [super init];
    if (self) {
        self.type = action->type;
        self.clipTag = action->has_cliptag ? action->cliptag : 0;
        self.layerTag = (action->has_layertag && action->layertag != 0 ) ? action->layertag : DEFAULT_LAYER_TAG;
/*
#if DEBGU
        if (action->layertag == 2) {
            action->layertag = 10;
        }
#endif
  */      
        if (action->has_shadowoffsetx && action->has_shadowoffsety && action->has_shadowcolor) {            
            self.shadow = [Shadow shadowWithIntColor:action->shadowcolor offset:CGSizeMake(action->shadowoffsetx, action->shadowoffsety) blur:action->shadowblur];
        }
    }
    return self;
}

- (PBDrawAction *)toPBDrawAction
{
    return nil;
}

- (NSData *)toData
{
    int count = 1;
    int i = 0;
    Game__PBDrawAction** pbDrawActionC = malloc(sizeof(Game__PBDrawAction*)*count);
    
    pbDrawActionC[i] = malloc (sizeof(Game__PBDrawAction));
    game__pbdraw_action__init(pbDrawActionC[i]);
    [self toPBDrawActionC:pbDrawActionC[i]];
    
    
    void *buf = NULL;
    unsigned len = 0;
    NSData* data = nil;
    
    len = game__pbdraw_action__get_packed_size (pbDrawActionC[i]);    // This is the calculated packing length
    buf = malloc (len);                                                 // Allocate memory
    if (buf != NULL){
        game__pbdraw_action__pack (pbDrawActionC[i], buf);                // Pack msg, including submessages
        // create data object
        data = [NSData dataWithBytesNoCopy:buf length:len];
//        free(buf)   if call dataWithBytesNoCopy, should not free buf...
    }
    
    [DrawAction freePBDrawActionC:pbDrawActionC count:count];
    return data;
}

- (void)toPBDrawActionC:(Game__PBDrawAction*)pbDrawActionC
{
    if (self.clipTag != 0) {
        pbDrawActionC->cliptag = self.clipTag;
        pbDrawActionC->has_cliptag = YES;
    }
    pbDrawActionC->layertag = self.layerTag;
    pbDrawActionC->has_layertag = YES;
}

- (void)addPoint:(CGPoint)point inRect:(CGRect)rect
{
    
}

- (NSUInteger)pointCount
{
    return 0;
}

- (void)finishAddPoint
{
    _hasFinishAddPoint = YES;
}

#pragma mark-- Common Methods

+ (NSMutableArray *)pbNoCompressDrawDataCToDrawActionList:(Game__PBNoCompressDrawData *)data canvasSize:(CGSize)canvasSize
{
    NSMutableArray *drawActionList = [NSMutableArray array];

    if (data->n_drawactionlist2 > 0) {
        NSMutableDictionary *clipDict = [NSMutableDictionary dictionary];        
        for (int i=0; i<data->n_drawactionlist2; i++){
            DrawAction *at = [DrawAction drawActionWithPBDrawActionC:data->drawactionlist2[i]];
            if (at) {
                if ([at isKindOfClass:[ClipAction class]]) {
                    [clipDict setObject:at forKey:@(at.layerTag)];
                    [at finishAddPoint];
                }else{
                    ClipAction *clipAction = [clipDict objectForKey:@(at.layerTag)];
                    if (at.clipTag == clipAction.clipTag) {
                        at.clipAction = clipAction;
                    }
                }
                [at setCanvasSize:canvasSize];
                [drawActionList addObject:at];
                at = nil;                
            }
        }
    }else if(data->n_drawactionlist > 0){
        for (int i=0; i<data->n_drawactionlist; i++){
            DrawAction *dAction = [DrawAction drawActionWithPBNoCompressDrawActionC:data->drawactionlist[i]];
            if (dAction) {
                [dAction setCanvasSize:canvasSize];
                [drawActionList addObject:dAction];
                dAction = nil;                
            }
        }
    }
    
    return drawActionList;
}


+ (void)updatePBLayerC:(Game__PBLayer **)pblayers layers:(NSArray *)layers
{
    int i=0;
    for (DrawLayer *layer in layers) {
        pblayers[i] = malloc(sizeof(Game__PBLayer));
        game__pblayer__init(pblayers[i]);
        [layer updatePBLayerC:pblayers[i]];
        i++;
    }    
}

+ (void)freePBLayers:(Game__PBLayer **)pblayers count:(int)count
{
    for (int i = 0; i < count; i ++) {
        if (pblayers[i]->rectcomponent) {
            free(pblayers[i]->rectcomponent);
        }
    }
}

+ (void)createPBDrawActionC:(Game__PBDrawAction**)pbDrawActionC drawActionList:(NSArray*)drawActionList
{
    int i=0;
    for (DrawAction *drawAction in drawActionList) {
        pbDrawActionC[i] = malloc (sizeof(Game__PBDrawAction));
        game__pbdraw_action__init(pbDrawActionC[i]);
        [drawAction toPBDrawActionC:pbDrawActionC[i]];
        i++;
    }
}

+ (void)freePBDrawActionC:(Game__PBDrawAction**)pbDrawActionC count:(int)count
{
    // free malloc memory in structs
    for (int i=0; i<count; i++){
        
        // be careful to free sub message inside draw action
        if (pbDrawActionC[i]->rectcomponent != NULL){
            free(pbDrawActionC[i]->rectcomponent);
        }
        
        // free point x
        if (pbDrawActionC[i]->pointsx != NULL){
            free(pbDrawActionC[i]->pointsx);
        }
        
        // free point y
        if (pbDrawActionC[i]->pointsy != NULL){
            free(pbDrawActionC[i]->pointsy);
        }
        
        if (pbDrawActionC[i]->drawbg != NULL){
            free(pbDrawActionC[i]->drawbg);
        }
                
        if (pbDrawActionC[i]->gradient != NULL) {
            if (pbDrawActionC[i]->gradient->color != NULL) {
                free(pbDrawActionC[i]->gradient->color);
            }
            if (pbDrawActionC[i]->gradient->point) {
                free(pbDrawActionC[i]->gradient->point);
            }
            free(pbDrawActionC[i]->gradient);            
        }
        // free draw action
        free(pbDrawActionC[i]);
    }
    
}

+ (NSData *)buildBBSDrawData:(NSArray *)drawActionList
                  canvasSize:(CGSize)size
                        info:(NSDictionary *)info
{
    
    Game__PBBBSDraw pbBBSDrawC = GAME__PBBBSDRAW__INIT;
    
    Game__PBSize canvasSize = GAME__PBSIZE__INIT;
    pbBBSDrawC.canvassize = &canvasSize;
    pbBBSDrawC.canvassize->has_height = 1;
    pbBBSDrawC.canvassize->has_width = 1;
    pbBBSDrawC.canvassize->height = size.height;
    pbBBSDrawC.canvassize->width = size.width;
    
    pbBBSDrawC.version = [ConfigManager currentDrawDataVersion];
    pbBBSDrawC.has_version = 1;
    
    int count = [drawActionList count];
    if (count > 0){
        pbBBSDrawC.drawactionlist = malloc(sizeof(Game__PBDrawAction*)*count);
        pbBBSDrawC.n_drawactionlist = count;
    }
    
    // set data
    [DrawAction createPBDrawActionC:pbBBSDrawC.drawactionlist drawActionList:drawActionList];
    
    void *buf = NULL;
    unsigned len = 0;
    NSData* data = nil;
    
    len = game__pbbbsdraw__get_packed_size (&pbBBSDrawC);    // This is the calculated packing length
    buf = malloc (len);                                                 // Allocate memory
    if (buf != NULL){
        game__pbbbsdraw__pack (&pbBBSDrawC, buf);                // Pack msg, including submessages
        
        // create data object
        data = [NSData dataWithBytesNoCopy:buf length:len];
    }
    
    // free memory
    [DrawAction freePBDrawActionC:pbBBSDrawC.drawactionlist count:pbBBSDrawC.n_drawactionlist];
    free(pbBBSDrawC.drawactionlist);
    
    return data;
}




+ (NSData*)buildPBDrawData:(NSString*)userId
                      nick:(NSString *)nick
                    avatar:(NSString *)avatar
            drawActionList:(NSArray*)drawActionList
                  drawWord:(Word*)drawWord
                  language:(int)language
                      size:(CGSize)size
              isCompressed:(BOOL)isCompressed
                    layers:(NSArray *)layers
                      info:(NSDictionary *)info
{
    Game__PBDraw pbDrawC = GAME__PBDRAW__INIT;
    
    pbDrawC.userid = (char*)[userId UTF8String];
    pbDrawC.nickname = (char*)[nick UTF8String];
    pbDrawC.avatar = (char*)[avatar UTF8String];
    pbDrawC.word = (char*)[[drawWord text] UTF8String];
    
    pbDrawC.language = language;
    pbDrawC.level = [drawWord level];
    pbDrawC.score = [drawWord score];
    pbDrawC.has_score = 1;
    
    Game__PBSize canvasSize = GAME__PBSIZE__INIT;
    pbDrawC.canvassize = &canvasSize;
    pbDrawC.canvassize->has_height = 1;
    pbDrawC.canvassize->has_width = 1;
    pbDrawC.canvassize->height = size.height;
    pbDrawC.canvassize->width = size.width;
    
    pbDrawC.version = [ConfigManager currentDrawDataVersion];
    pbDrawC.has_version = 1;
    
    pbDrawC.iscompressed = isCompressed;
    pbDrawC.has_iscompressed = 1;
    
    //update layers
    int layerNum = [layers count];
    if (layerNum > 0) {
        pbDrawC.layer = malloc(sizeof(Game__PBLayer*)*layerNum);
        pbDrawC.n_layer = layerNum;
        [DrawAction updatePBLayerC:pbDrawC.layer layers:layers];
    }

    
    int count = [drawActionList count];
    if (count > 0){
        pbDrawC.drawdata = malloc(sizeof(Game__PBDrawAction*)*count);
        pbDrawC.n_drawdata = count;
    }
    
    // set data
    [DrawAction createPBDrawActionC:pbDrawC.drawdata drawActionList:drawActionList];
    
    void *buf = NULL;
    unsigned len = 0;
    NSData* data = nil;
    
    len = game__pbdraw__get_packed_size (&pbDrawC);    // This is the calculated packing length
    buf = malloc (len);                                                 // Allocate memory
    if (buf != NULL){
        game__pbdraw__pack (&pbDrawC, buf);                // Pack msg, including submessages
        // create data object
        data = [NSData dataWithBytesNoCopy:buf length:len];
    }
    
    // free memory
    [DrawAction freePBDrawActionC:pbDrawC.drawdata count:pbDrawC.n_drawdata];
    //Free layers
    [DrawAction freePBLayers:pbDrawC.layer count:pbDrawC.n_layer];
    
    free(pbDrawC.drawdata);
    
    
    
    return data;
}



+ (NSData *)pbNoCompressDrawDataCFromDrawActionList:(NSArray *)drawActionList
                                               size:(CGSize)size
                                           opusDesc:(NSString *)opusDesc
                                         drawToUser:(PBUserBasicInfo *)drawToUser
                                    bgImageFileName:(NSString *)bgImageFileName
                                             layers:(NSArray *)layers
{
    if ([drawActionList count] != 0 || [GameApp forceSaveDraft]) {
        
        Game__PBNoCompressDrawData pbNoCompressDrawDataC = GAME__PBNO_COMPRESS_DRAW_DATA__INIT;
        
        int count = [drawActionList count];
        if (count > 0){
            pbNoCompressDrawDataC.drawactionlist2 = malloc(sizeof(Game__PBDrawAction*)*count);
            pbNoCompressDrawDataC.n_drawactionlist2 = count;

            [DrawAction createPBDrawActionC:pbNoCompressDrawDataC.drawactionlist2 drawActionList:drawActionList];
        }

        
        //update layers
        int layerNum = [layers count];
        if (layerNum > 0) {
            pbNoCompressDrawDataC.layer = malloc(sizeof(Game__PBLayer*)*layerNum);
            pbNoCompressDrawDataC.n_layer = layerNum;
            [DrawAction updatePBLayerC:pbNoCompressDrawDataC.layer layers:layers];
        }
        
        if (drawToUser && drawToUser.userId && drawToUser.nickName) {
            Game__PBUserBasicInfo pbDrawToUserC = GAME__PBUSER_BASIC_INFO__INIT;
            pbNoCompressDrawDataC.drawtouser = &pbDrawToUserC;
            pbNoCompressDrawDataC.drawtouser->avatar = (char*)[drawToUser.avatar UTF8String];
            pbNoCompressDrawDataC.drawtouser->nickname = (char*)[drawToUser.nickName UTF8String];
            pbNoCompressDrawDataC.drawtouser->userid = (char*)[drawToUser.userId UTF8String];
            pbNoCompressDrawDataC.drawtouser->gender = (char*)[drawToUser.gender UTF8String];
        }
        
        // set opus desc
        if (opusDesc) {
            pbNoCompressDrawDataC.opusdesc = (char*)[opusDesc UTF8String];
        }        
        
        // set canvas size
        Game__PBSize pbCanvasSize = GAME__PBSIZE__INIT;
        pbNoCompressDrawDataC.canvassize = &pbCanvasSize;
        CGSizeToPBSizeC(size, pbNoCompressDrawDataC.canvassize);

        // set version
        pbNoCompressDrawDataC.version = [ConfigManager currentDrawDataVersion];
        pbNoCompressDrawDataC.has_version = 1;

        // set bg image name
        pbNoCompressDrawDataC.bgimagename = (char*)[bgImageFileName UTF8String];

        void *buf = NULL;
        unsigned len = 0;
        NSData* data = nil;
        
        len = game__pbno_compress_draw_data__get_packed_size (&pbNoCompressDrawDataC);    // This is the calculated packing length
        buf = malloc (len);                                             // Allocate memory
        if (buf != NULL){
            game__pbno_compress_draw_data__pack (&pbNoCompressDrawDataC, buf);                // Pack msg, including submessages
            
            // create data object
            data = [NSData dataWithBytesNoCopy:buf length:len];
        }
        
        [DrawAction freePBDrawActionC:pbNoCompressDrawDataC.drawactionlist2 count:pbNoCompressDrawDataC.n_drawactionlist2];
        free(pbNoCompressDrawDataC.drawactionlist2);
        [DrawAction freePBLayers:pbNoCompressDrawDataC.layer count:pbNoCompressDrawDataC.n_layer];
        return data;
    }
    
    return nil;
}



+ (NSMutableArray *)drawActionListFromPBBBSDraw:(PBBBSDraw *)bbsDraw
{
    
    NSMutableArray* drawActionList = nil;
    
    if (bbsDraw) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
        Game__PBBBSDraw* pbBBSDrawC = NULL;
        
        NSData* data = [bbsDraw data];
        int dataLen = [data length];
        if (dataLen > 0){
            uint8_t* buf = malloc(dataLen);
            if (buf != NULL){
                
                [data getBytes:buf length:dataLen];
                pbBBSDrawC = game__pbbbsdraw__unpack(NULL, dataLen, buf);
                free(buf);

                
                drawActionList = (id)[Draw drawActionListFromPBActions:pbBBSDrawC->drawactionlist
                                                      actionCount:pbBBSDrawC->n_drawactionlist
                                                       canvasSize:CGSizeFromPBSizeC(pbBBSDrawC->canvassize)];
                [drawActionList retain];
                game__pbbbsdraw__free_unpacked(pbBBSDrawC, NULL);
            }
        }
        
        [pool drain];
    }

    return [drawActionList autorelease];
    
}
+ (NSMutableArray *)drawActionListFromPBMessage:(PBMessage *)message
{
    NSMutableArray* drawActionList = nil;
    
    if (message) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
        Game__PBMessage *pbMessageC = NULL;
        
        NSData* data = [message data];
        int dataLen = [data length];
        if (dataLen > 0){
            uint8_t* buf = malloc(dataLen);
            if (buf != NULL){
                
                [data getBytes:buf length:dataLen];
                pbMessageC = game__pbmessage__unpack(NULL, dataLen, buf);
                free(buf);
                
                drawActionList = (id)[Draw drawActionListFromPBActions:pbMessageC->drawdata
                                                                     actionCount:pbMessageC->n_drawdata
                                                                      canvasSize:CGSizeFromPBSizeC(pbMessageC->canvassize)];
                
                [drawActionList retain];
                game__pbmessage__free_unpacked(pbMessageC, NULL);
            }
        }
        
        [pool drain];
    }
    
    return [drawActionList autorelease];
    

}

@end



@implementation PBNoCompressDrawAction (Ext)

- (DrawColor *)drawColor
{
    if ([self hasRgbColor]){
        return [DrawColor colorWithBetterCompressColor:self.rgbColor];
    }
    if ([self hasColor]) {
        return [[[DrawColor alloc] initWithPBColor:self.color] autorelease];
    }
    return [DrawColor colorWithRed:self.red green:self.green blue:self.blue alpha:self.alpha];
}



@end


