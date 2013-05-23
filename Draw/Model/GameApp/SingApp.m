//
//  SingApp.m
//  Draw
//
//  Created by 王 小涛 on 13-5-21.
//
//

#import "SingApp.h"
#import "SingController.h"

@implementation SingApp

- (PPViewController *)homeController{
    return [[[SingController alloc] init] autorelease];
}

@end
