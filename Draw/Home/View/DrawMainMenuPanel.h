//
//  DrawMainMenuPanel.h
//  Draw
//
//  Created by Gamy on 13-9-15.
//
//

#import "HomeMainMenuPanel.h"

typedef void (^MainAnimationHandler)(BOOL open);

#define MAIN_ANIMATION_INTEVAL 1.2

@interface DrawMainMenuPanel : HomeMainMenuPanel

//@property (copy, nonatomic) MainAnimationHandler startHandler;
//@property (copy, nonatomic) MainAnimationHandler finishHandler;

- (void)openAnimated:(BOOL)animated
          completion:(void (^)(BOOL finished))completion;

- (void)closeAnimated:(BOOL)animated
           completion:(void (^)(BOOL finished))completion;

- (void)centerMenu:(HomeMenuType)type
          Animated:(BOOL)animated
        completion:(void (^)(BOOL finished))completion;

- (void)moveMenuTypeToBottom:(HomeMenuType)type
                    Animated:(BOOL)animated
                  completion:(void (^)(BOOL finished))completion;

@end
