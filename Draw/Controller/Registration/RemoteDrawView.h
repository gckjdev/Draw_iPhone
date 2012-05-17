//
//  RemoteDrawView.h
//  Draw
//
//  Created by haodong qiu on 12年5月16日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJManagedImageV.h"

@class RemoteDrawData;

@interface RemoteDrawView : UIView
@property (retain, nonatomic) IBOutlet HJManagedImageV *avatarImage;
@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UIButton *paintButton;

+ (RemoteDrawView*)creatRemoteDrawView;

- (void)setViewByRemoteDrawData:(RemoteDrawData *)remoteDrawData;


@end
