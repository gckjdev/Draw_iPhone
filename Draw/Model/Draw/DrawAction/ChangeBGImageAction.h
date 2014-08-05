//
//  ChangeBGImageAction.h
//  Draw
//
//  Created by gamy on 13-4-1.
//
//

#import "DrawAction.h"

@class PBTutorial;
@class PBStage;

@interface ChangeBGImageAction : DrawAction

@property(nonatomic, retain)PBDrawBg *drawBg;

- (id)initWithDrawBg:(PBDrawBg *)drawBg;
+ (ChangeBGImageAction *)actionWithDrawBG:(PBDrawBg *)drawBg;
+ (ChangeBGImageAction *)actionForLearnDrawBg:(PBDrawBgLayerType)layerPosition
                                     tutorial:(PBTutorial*)tutorial
                                        stage:(PBStage*)stage
                                      bgImage:(UIImage*)bgImage             // 背景图
                                  bgImageName:(NSString*)bgImageName        // 背景图名字，唯一
                                     needSave:(BOOL)needSave;               // 是否需要保存背景图

+ (NSString*)bgImageNameForLearnDrawBgImage:(NSString*)tutorialId
                                    stageId:(NSString*)stageId;

@end
