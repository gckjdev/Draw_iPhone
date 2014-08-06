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
#import "ClipAction.h"
#import "Tutorial.pb.h"
#import "DrawLayer.h"

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



- (id)initWithPBDrawActionC:(Game__PBDrawAction *)action
{
    self = [super initWithPBDrawActionC:action];
    if (self) {
        self.type = DrawActionTypeChangeBGImage;
        if (action->drawbg != NULL){
            PBDrawBg_Builder* builder = [PBDrawBg builder];
            [builder setBgId:[NSString stringWithUTF8String:action->drawbg->bgid]];
            if (action->drawbg->localurl != NULL){
                [builder setLocalUrl:[NSString stringWithUTF8String:action->drawbg->localurl]];
            }
            
            if (action->drawbg->remoteurl != NULL){
                [builder setRemoteUrl:[NSString stringWithUTF8String:action->drawbg->remoteurl]];
            }
            
            if (action->drawbg->has_showstyle){
                [builder setShowStyle:action->drawbg->showstyle];
            }
            
            if (action->drawbg->has_type){
                [builder setType:action->drawbg->type];
            }
            
            if (action->drawbg->has_purpose){
                [builder setPurpose:action->drawbg->purpose];
            }

            if (action->drawbg->has_layerposition){
                [builder setLayerPosition:action->drawbg->layerposition];
            }
            
            if (action->drawbg->tutorialbgimagename != NULL){
                [builder setTutorialBgImageName:[NSString stringWithUTF8String:action->drawbg->tutorialbgimagename]];
            }

            if (action->drawbg->tutorialid != NULL){
                [builder setTutorialId:[NSString stringWithUTF8String:action->drawbg->tutorialid]];
            }

            if (action->drawbg->stageid != NULL){
                [builder setStageId:[NSString stringWithUTF8String:action->drawbg->stageid]];
            }
            
            self.drawBg = [builder build];
        }
        
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

- (id)initWithPBNoCompressDrawActionC:(Game__PBNoCompressDrawAction *)action
{
    return nil;
}



- (PBDrawAction *)toPBDrawAction
{
    PBDrawAction_Builder *builder = [[[PBDrawAction_Builder alloc] init] autorelease];
    [builder setType:DrawActionTypeChangeBGImage];
    [builder setClipTag:self.clipTag];
    if (self.drawBg) {
        [builder setDrawBg:self.drawBg];
    }
    return [builder build];
  
}

- (void)toPBDrawActionC:(Game__PBDrawAction*)pbDrawActionC
{
    
    [super toPBDrawActionC:pbDrawActionC];
    pbDrawActionC->type = DrawActionTypeChangeBGImage;
    if (self.clipAction) {
        pbDrawActionC->has_cliptag = 1;
        pbDrawActionC->cliptag = self.clipAction.clipTag;
    }
    if (self.drawBg) {
//        [builder setDrawBg:self.drawBg];
        
        pbDrawActionC->drawbg = malloc(sizeof(Game__PBDrawBg));
        game__pbdraw_bg__init(pbDrawActionC->drawbg);
        
        pbDrawActionC->drawbg->bgid = (char*)[self.drawBg.bgId UTF8String];
        pbDrawActionC->drawbg->localurl = (char*)[self.drawBg.localUrl UTF8String];
        pbDrawActionC->drawbg->remoteurl = (char*)[self.drawBg.remoteUrl UTF8String];
        
        pbDrawActionC->drawbg->showstyle = self.drawBg.showStyle;
        pbDrawActionC->drawbg->has_showstyle = 1;
        
        pbDrawActionC->drawbg->type = self.drawBg.type;
        pbDrawActionC->drawbg->has_type = 1;
        
        pbDrawActionC->drawbg->layerposition = self.drawBg.layerPosition;
        pbDrawActionC->drawbg->has_layerposition = 1;

        pbDrawActionC->drawbg->purpose = self.drawBg.purpose;
        pbDrawActionC->drawbg->has_purpose = 1;

        pbDrawActionC->drawbg->tutorialid = (char*)[self.drawBg.tutorialId UTF8String];
        pbDrawActionC->drawbg->stageid = (char*)[self.drawBg.stageId UTF8String];
        pbDrawActionC->drawbg->tutorialbgimagename = (char*)[self.drawBg.tutorialBgImageName UTF8String];
    }
    return;

}


- (void)addPoint:(CGPoint)point inRect:(CGRect)rect
{
    
}

- (void)updateImage
{
    if (self.image == nil) {
        self.image = [[self drawBg] localImage];
        if (self.image == nil) {
            __block typeof(self) cp = self;
            
            [[SDWebImageManager sharedManager] downloadWithURL:self.drawBg.remoteURL options:SDWebImageRetryFailed progress:NULL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
               
                if (finished && error == nil) {
                    cp.image = image;
                }
            }];
        }
    }
}

- (CGRect)imageRectWithSize:(CGSize)size canvasRect:(CGRect)rect
{
    CGSize cSize = rect.size;
    //if the size scale is the same, and canvas size is not large than the bg size
    if (abs(size.width * cSize.height - cSize.width * size.height) < 2) {
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



- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect
{
//    CGContextClearRect(context, rect);
    CGContextSaveGState(context);
 
    [self.clipAction clipContext:context];

    [self updateImage];
    if (self.image) {

        UIGraphicsPushContext(context);
        if (self.drawBg.showStyle == ShowStyleCenter) {
            [self.image drawInRect:rect];
        }else if(self.drawBg.showStyle == ShowStylePattern){
            [self.image drawAsPatternInRect:rect];
        }else{
            //
        }
        UIGraphicsPopContext();
    }

    CGContextRestoreGState(context);

    return rect;
}

+ (ChangeBGImageAction *)actionWithDrawBG:(PBDrawBg *)drawBg
{
    ChangeBGImageAction *changBG = [[[ChangeBGImageAction alloc] initWithDrawBg:drawBg] autorelease];
    return changBG;
}

+ (NSString*)bgImageNameForLearnDrawBgImage:(NSString*)tutorialId
                                    stageId:(NSString*)stageId
{
    NSString* key = [NSString stringWithFormat:@"%@__%@__bg.png", tutorialId, stageId];
    PPDebug(@"<keyForLearnDrawBgImage> key=%@", key);
    return key;
}

/*
message PBDrawBg
{
    required string bgId = 1;
    optional string localUrl  = 2;
    optional string remoteUrl  = 3;
    optional int32 showStyle = 4 [default=0]; // 0 for show in center, 1 for show in pattern
    
    optional int32 type = 5[default=0];       // refer to PBDrawBgType
    optional int32 purpose = 6;               // refer to PBDrawBgPurpose
    optional int32 layerPosition = 7;         // refer to PBDrawBgLayerType
    
    optional string tutorialId = 20;           // learn draw background's tutorial ID
    optional string stageId = 21;
    optional string tutorialBgImageName = 22;
}
 */

+ (ChangeBGImageAction *)actionForNormalDrawBg:(PBDrawBgLayerType)layerPosition
                                      bgImage:(UIImage*)bgImage
                                  bgImageName:(NSString*)bgImageName
                                     needSave:(BOOL)needSave
{
    if (bgImage == nil || [bgImageName length] == 0){
        PPDebug(@"<actionForNormalDrawBg> no bg image or bgImageName(%@) nil", bgImageName);
        return nil;
    }
    
    //    NSString* key = [self bgImageNameForLearnDrawBgImage:tutorial.tutorialId stageId:stage.stageId];
    if (needSave){
        NSString* key = bgImageName;
        BOOL result = [[DrawBgManager defaultManager] saveImage:bgImage forKey:key];
        if (!result){
            PPDebug(@"<actionForNormalDrawBg> save bg image for key %@ failure", key);
            return nil;
        }
    }
    
    PBDrawBg_Builder* builder = [PBDrawBg builder];
    [builder setBgId:bgImageName];
    [builder setLocalUrl:bgImageName];
    [builder setShowStyle:ShowStyleCenter];
    [builder setType:PBDrawBgTypeDrawBgNormalDraw];
    [builder setPurpose:PBDrawBgPurposeDrawBgPurposeNormalDraw];
    [builder setLayerPosition:layerPosition];
    
    PBDrawBg* drawBg = [builder build];
    
    ChangeBGImageAction* action = [self actionWithDrawBG:drawBg];
    if (layerPosition == PBDrawBgLayerTypeDrawBgLayerForeground){
        [action setLayerTag:BG_LAYER_TAG];
    }
    else{
        [action setLayerTag:MAIN_LAYER_TAG];
    }
    
    return action;
}

+ (ChangeBGImageAction *)actionForLearnDrawBg:(PBDrawBgLayerType)layerPosition
                                     tutorial:(PBTutorial*)tutorial
                                        stage:(PBStage*)stage
                                      bgImage:(UIImage*)bgImage
                                  bgImageName:(NSString*)bgImageName
                                     needSave:(BOOL)needSave
{
    if (stage == nil){
        PPDebug(@"<actionForLearnDrawBg> but stage nil");
        return nil;
    }
    
    if (bgImage == nil || [bgImageName length] == 0){
        PPDebug(@"<actionForLearnDrawBg> no bg image or bgImageName(%@) nil", bgImageName);
        return nil;
    }
    
//    NSString* key = [self bgImageNameForLearnDrawBgImage:tutorial.tutorialId stageId:stage.stageId];
    if (needSave){
        NSString* key = bgImageName;
        BOOL result = [[DrawBgManager defaultManager] saveImage:bgImage forKey:key];
        if (!result){
            PPDebug(@"<actionForLearnDrawBg> save bg image for key %@ failure", key);
            return nil;
        }
    }

    PBDrawBg_Builder* builder = [PBDrawBg builder];
    [builder setBgId:bgImageName];
    [builder setLocalUrl:bgImageName];
    [builder setShowStyle:ShowStyleCenter];
    [builder setType:PBDrawBgTypeDrawBgNormalDraw];
    [builder setPurpose:PBDrawBgPurposeDrawBgPurposeLearnDraw];
    [builder setLayerPosition:layerPosition];
    [builder setTutorialId:tutorial.tutorialId];
    [builder setStageId:stage.stageId];
    [builder setTutorialBgImageName:stage.bgImageName];
    
    PBDrawBg* drawBg = [builder build];

    ChangeBGImageAction* action = [self actionWithDrawBG:drawBg];
    if (layerPosition == PBDrawBgLayerTypeDrawBgLayerForeground){
        [action setLayerTag:BG_LAYER_TAG];
    }
    else{
        [action setLayerTag:MAIN_LAYER_TAG];
    }
    
    return action;
}

@end
