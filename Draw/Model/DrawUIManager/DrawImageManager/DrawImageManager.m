//
//  DrawImageManager.m
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import "DrawImageManager.h"
//#import "PPResourceService.h"
//#import "GameResource.h"
#import "ShareImageManager.h"

//DrawImageManager *_staticDrawImageManager;
static DrawImageManager * _staticDrawImageManager;

@interface DrawImageManager ()
{
 
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
{
    NSString *imageName = [self fixImageName:name];
    UIImage *image = [UIImage imageNamed:imageName];
    return [image stretchableImageWithLeftCapWidth:image.size.width * leftCapWidthScale
                                      topCapHeight:image.size.height * topCapHeightScale];
}


- (UIImage *)drawHomeBbs
{
    NSString *imageName = [self fixImageName:@"draw_home_bbs"];
    return [UIImage imageNamed:imageName];

}
- (UIImage *)drawHomeContest{
    NSString *imageName = [self fixImageName:@"draw_home_contest"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)drawHomeDraw{
    NSString *imageName = [self fixImageName:@"draw_home_draw"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)drawHomeGuess{
    NSString *imageName = [self fixImageName:@"draw_home_guess"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)drawHomeHome{
    NSString *imageName = [self fixImageName:@"draw_home_home"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)drawHomeMessage{
    NSString *imageName = [self fixImageName:@"draw_home_message"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)drawHomeOnlineGuess{
    NSString *imageName = [self fixImageName:@"draw_home_online_guess"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)drawHomeOpus{
    NSString *imageName = [self fixImageName:@"draw_home_opus"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)drawHomeSetting{
    NSString *imageName = [self fixImageName:@"draw_home_setting"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)drawHomeShop{
    NSString *imageName = [self fixImageName:@"draw_home_shop"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)drawHomeTimeline{
    NSString *imageName = [self fixImageName:@"draw_home_timeline"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)drawHomeTop{
    NSString *imageName = [self fixImageName:@"draw_home_top"];
    return [UIImage imageNamed:imageName];
}

//stretcable
- (UIImage *)drawHomeSplitline{
    
    return [self stretchableImageWithImageName:@"draw_home_splitline"
                             leftCapWidthScale:0.5 topCapHeightScale:0.5];
}
@end
