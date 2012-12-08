//
//  DrawImageManager.m
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import "DrawImageManager.h"
#import "PPResourceService.h"
#import "GameResource.h"
#import "ShareImageManager.h"

//DrawImageManager *_staticDrawImageManager;
static DrawImageManager * _staticDrawImageManager;

@interface DrawImageManager ()
{
    PPResourceService *_resService;
}
@end

@implementation DrawImageManager

+ (id)defaultManager
{
    if (_staticDrawImageManager == nil) {
        _staticDrawImageManager = [[DrawImageManager alloc] init];
    }
    return _staticDrawImageManager;
}

- (id)init
{
    if (self = [super init]) {
        _resService = [PPResourceService defaultService];
    }
    return self;
}



- (NSString *)fixImageName:(NSString *)imageName
{
    if([DeviceDetection isIPAD]){
        return [NSString stringWithFormat:@"%@@2x",imageName];
    }
    return imageName;
}



- (UIImage *)stretchableImageWithImageName:(NSString *)name
                         leftCapWidthScale:(CGFloat)leftCapWidthScale //0.0-1.0
                         topCapHeightScale:(CGFloat)topCapHeightScale //0.0-1.0
                         inResourcePackage:(NSString *)package
{
    NSString *imageName = [self fixImageName:name];
    UIImage *image = [_resService imageByName:imageName
                            inResourcePackage:package];
    return [image stretchableImageWithLeftCapWidth:image.size.width * leftCapWidthScale
                                      topCapHeight:image.size.height * topCapHeightScale];
}

- (UIImage *)stretchableImageWithImageName:(NSString *)name
                         inResourcePackage:(NSString *)package
{
    return [self stretchableImageWithImageName:name
                             leftCapWidthScale:0.5
                             topCapHeightScale:0.5
                             inResourcePackage:package];
}




- (UIImage *)drawHomeContest{
    NSString *imageName = [self fixImageName:@"draw_home_contest"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)drawHomeDraw{
    NSString *imageName = [self fixImageName:@"draw_home_draw"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)drawHomeFrontPage{
    NSString *imageName = [self fixImageName:@"draw_home_front_page"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)drawHomeGuess{
    NSString *imageName = [self fixImageName:@"draw_home_guess"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)drawHomeHome{
    NSString *imageName = [self fixImageName:@"draw_home_home"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)drawHomeMessage{
    NSString *imageName = [self fixImageName:@"draw_home_message"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)drawHomeMoney{
    NSString *imageName = [self fixImageName:@"draw_home_money"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)drawHomeNextpage{
    NSString *imageName = [self fixImageName:@"draw_home_nextpage"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)drawHomeOnlineGuess{
    NSString *imageName = [self fixImageName:@"draw_home_online_guess"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)drawHomeOpus{
    NSString *imageName = [self fixImageName:@"draw_home_opus"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)drawHomeSetting{
    NSString *imageName = [self fixImageName:@"draw_home_setting"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)drawHomeShop{
    NSString *imageName = [self fixImageName:@"draw_home_shop"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)drawHomeTask{
    NSString *imageName = [self fixImageName:@"draw_home_task"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)drawHomeTimeline{
    NSString *imageName = [self fixImageName:@"draw_home_timeline"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)drawHomeTop{
    NSString *imageName = [self fixImageName:@"draw_home_top"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)drawHomeCoin{
    NSString *imageName = [self fixImageName:@"draw_home_coin"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_DRAW];
}

//stretcable
- (UIImage *)drawHomeWoodBg{
    return [self stretchableImageWithImageName:@"draw_home_bottom_bg" inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)drawHomeSplitline{
return [self stretchableImageWithImageName:@"draw_home_displaybg" inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)drawHomeDisplaybg{
    return [self stretchableImageWithImageName:@"draw_home_header_bg" inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)drawHomeHeaderBg{
    return [self stretchableImageWithImageName:@"draw_home_wood_bg" inResourcePackage:RESOURCE_PACKAGE_DRAW];
}

@end
