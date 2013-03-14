//
//  main.m
//  Draw
//
//  Created by gamy on 12-3-4.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}

/*
 
 Release Notes
 
 － 检查所有URL是否正确设置为正式服务器的URL
 － 检查广告是否被屏蔽
 
 Info Plist
 － 修改Bundle ID
 － 修改URL Scheme
 － 修改Icon
 － 修改CFChannelID
 - 修改Launch image

 Resource
 － 删除Resource文件
 
 InfoPlist.strings
 － 修改应用名称
 
 Test
 － iPhone
 － iPad
 － iPhone 4.3
 
 注册
 设置
 快速开始
 房间进入
 帮助
 商店购买
*/


// TODO 分享加载bug; 统计分析；