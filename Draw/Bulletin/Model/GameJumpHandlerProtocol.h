//
//  GameJumpHandlerProtocol.h
//  Draw
//
//  Created by Kira on 12-12-20.
//
//

#import <Foundation/Foundation.h>

@protocol GameJumpHandlerProtocol <NSObject>

- (UIViewController *)controllerForGameId:(NSString *)gameId
                                     func:(NSString *)func
                                     para:(NSString *)para
                           fromController:(UIViewController*)controller;

@end
