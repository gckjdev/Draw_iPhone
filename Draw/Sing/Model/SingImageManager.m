//
//  SingImageManager.m
//  Draw
//
//  Created by 王 小涛 on 13-5-28.
//
//

#import "SingImageManager.h"
#import "SynthesizeSingleton.h"

@implementation SingImageManager

SYNTHESIZE_SINGLETON_FOR_CLASS(SingImageManager);

- (UIImage*)inputDialogBgImage{
    return [UIImage imageNamed:@"sing_bg@2x.jpg"];
}

- (UIImage*)inputDialogInputBgImage{
    return nil;
}

- (UIImage*)inputDialogLeftBtnImage{
    return nil;
}

- (UIImage*)inputDialogRightBtnImage{
    return nil;
    
}

- (UIImage*)commonDialogBgImage{
    return nil;
}

- (UIImage*)commonDialogLeftBtnImage{
    return nil;
}

- (UIImage*)commonDialogRightBtnImage{
    return nil;
}

@end