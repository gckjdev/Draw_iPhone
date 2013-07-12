//
//  OpusActionManager.m
//  Draw
//
//  Created by 王 小涛 on 13-7-4.
//
//

#import "OpusActionManager.h"
#import "CommonImageManager.h"

@implementation OpusActionManager

+ (NSString *)nameWithAction:(int)action{
        
    switch (action) {
        case ActionShareViaSinaWeiBo:
            return NSLS(@"kSinaWeibo");
            break;
            
        case ActionShareViaTencentWeiBo:
            return NSLS(@"kTencentWeibo");
            break;
            
        case ActionShareViaFacebook:
            return NSLS(@"kFacebook");
            break;
            
        case ActionShareViaWeChatTimeline:
            return NSLS(@"kWeChatTimeline");
            break;
            
        case ActionShareViaWeChatFriends:
            return NSLS(@"kWeChatFriends");
            
            break;
            
        case ActionShareViaEmail:
            return NSLS(@"kEmail");
            break;
            
        case ActionSaveToAlbum:
            return NSLS(@"kAlbum");
            break;
            
        case ActionSaveAsFavorite:
            return NSLS(@"kFavorite");
            break;
            
        default:
            break;
    }
    
    return nil;
}

+ (UIImage *)imageWithAction:(int)action{
    
    CommonImageManager* imageManager = [CommonImageManager defaultManager];
    
    switch (action) {
        case ActionShareViaSinaWeiBo:
            return imageManager.sinaImage;
            break;
            
        case ActionShareViaTencentWeiBo:
            return imageManager.qqWeiboImage;
            break;
            
        case ActionShareViaFacebook:
            return imageManager.facebookImage;
            break;
            
        case ActionShareViaWeChatTimeline:
            return imageManager.wechatImage;
            break;
            
        case ActionShareViaWeChatFriends:
            return imageManager.wechatFriendsImage;
            
            break;
            
        case ActionShareViaEmail:
            return imageManager.emailImage;
            break;
            
        case ActionSaveToAlbum:
            return imageManager.albumImage;
            break;
            
        case ActionSaveAsFavorite:
            return imageManager.favoriteImage;
            break;
            
        default:
            break;
    }
    
    return nil;
}

+ (NSArray *)actions{
    
    NSArray *arr = [NSArray arrayWithObjects:
                    @(ActionShareViaSinaWeiBo),
                    @(ActionShareViaTencentWeiBo),
                    @(ActionShareViaFacebook),
                    @(ActionShareViaWeChatTimeline),
                    @(ActionShareViaWeChatFriends),
                    @(ActionShareViaEmail),
                    @(ActionSaveToAlbum),
                    @(ActionSaveAsFavorite),
                    nil];
    return arr;
}

@end
