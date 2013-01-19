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
                           fromController:(UIViewController*)controller;
//- (BOOL)isFunctionAvailable:(NSString*)func;
@end
