//
//  HomeMenuView.m
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import "HomeMenuView.h"
#import "DrawImageManager.h"

@implementation HomeMenuView
@synthesize button = _button;

- (void)updateIcon:(UIImage *)icon
             title:(NSString *)title
              type:(HomeMenuType)type
{
    [self.button setImage:icon forState:UIControlStateNormal];
    if (self.title) {
        [self.title setText:title];
    }else{
        [self.button setTitle:title forState:UIControlStateNormal];
    }
    
    [self setType:type];
}

- (void)updateBadge:(NSInteger)count
{
    if (count <= 0 ) {
        self.badge.hidden = YES;
    }else if(count > 99){
        self.badge.hidden = NO;
        [self.badge setTitle:@"N" forState:UIControlStateNormal];
    }else{
        self.badge.hidden = NO;
        [self.badge setTitle:[NSString stringWithFormat:@"%d",count]
                    forState:UIControlStateNormal];
    }
}

+ (NSString *)titleForType:(HomeMenuType)type
{

    switch (type) {
        //draw main menu
        case HomeMenuTypeDrawDraw :{
            return NSLS(@"kHomeMenuTypeDrawDraw");
        }
        case HomeMenuTypeDrawGuess:{
            return NSLS(@"kHomeMenuTypeDrawGuess");
        }
        case HomeMenuTypeDrawGame:{
            return NSLS(@"kHomeMenuTypeDrawGame");
        }
        case HomeMenuTypeDrawTimeline:{
            return NSLS(@"kHomeMenuTypeDrawTimeline");
        }
        case HomeMenuTypeDrawRank:{
            return NSLS(@"kHomeMenuTypeDrawRank");
        }
        case HomeMenuTypeDrawContest:{
            return NSLS(@"kHomeMenuTypeDrawContest");
        }
        case HomeMenuTypeDrawBBS:{
            return NSLS(@"kHomeMenuTypeDrawBBS");
        }
        case HomeMenuTypeDrawShop:{
            return NSLS(@"kHomeMenuTypeDrawShop");
        }
        case HomeMenuTypeDrawApps:{
            return NSLS(@"kMore_apps");
        }
        case HomeMenuTypeDrawFreeCoins:{
            return NSLS(@"kFreeGetCoins");
        }

        //ZJH
        case HomeMenuTypeZJHHelp:{
            return NSLS(@"kHomeMenuTypeZJHHelp");
        }
        case HomeMenuTypeZJHStart:{
            return NSLS(@"kHomeMenuTypeZJHStart");
        }
        case HomeMenuTypeZJHRichSite:{
            return NSLS(@"kHomeMenuTypeZJHRichSite");
        }
        case HomeMenuTypeZJHNormalSite:{
            return NSLS(@"kHomeMenuTypeZJHNormalSite");
        }
        case HomeMenuTypeZJHVSSite:{
            return NSLS(@"kHomeMenuTypeZJHVSSite");
        }
        case HomeMenuTypeZJHShop:{
            return NSLS(@"kHomeMenuTypeZJHShop");
        }

        default:
        return nil;
    }
}
+ (UIImage *)imageForType:(HomeMenuType)type
{
    DrawImageManager *imageManager = [DrawImageManager defaultManager];
    switch (type) {
            //draw main menu
        case HomeMenuTypeDrawDraw :{
            return [imageManager drawHomeDraw];
        }
        case HomeMenuTypeDrawGuess:{
            return [imageManager drawHomeGuess];;
        }
        case HomeMenuTypeDrawGame:{
            return [imageManager drawHomeOnlineGuess];
        }
        case HomeMenuTypeDrawTimeline:{
            return [imageManager drawHomeTimeline];
        }
        case HomeMenuTypeDrawRank:{
            return [imageManager drawHomeTop];
        }
        case HomeMenuTypeDrawContest:{
            return [imageManager drawHomeContest];
        }
        case HomeMenuTypeDrawBBS:{
            return [imageManager drawHomeBbs];
        }
        case HomeMenuTypeDrawShop:{
            return [imageManager drawHomeShop];
        }
        case HomeMenuTypeDrawApps:{
            return [imageManager drawAppsRecommand];
        }
        case HomeMenuTypeDrawFreeCoins:{
            return [imageManager drawFreeCoins];
        }
            //draw bottom menu
        case HomeMenuTypeDrawHome :{
            return [imageManager drawHomeHome];
        }
        case HomeMenuTypeDrawOpus:{
            return [imageManager drawHomeOpus];
        }
        case HomeMenuTypeDrawMessage:{
            return [imageManager drawHomeMessage];
        }
        case HomeMenuTypeDrawSetting:{
            return [imageManager drawHomeSetting];
        }
        case HomeMenuTypeDrawMore:{
            return [imageManager drawHomeMore];
        }
        case HomeMenuTypeDrawMe:{
            return [imageManager drawHomeMe];
        }
        case HomeMenuTypeDrawFriend:{
            return [imageManager drawHomeFriend];
        }
            
        //ZJH
        case HomeMenuTypeZJHHelp:{
            return [imageManager zjhHomeHelp];
        }
        case HomeMenuTypeZJHStart:{
            return [imageManager zjhHomeStart];
        }
        case HomeMenuTypeZJHRichSite:{
            return [imageManager zjhHomeRichSite];
        }
        case HomeMenuTypeZJHNormalSite:{
            return [imageManager zjhHomeNormalSite];
        }
        case HomeMenuTypeZJHVSSite:{
            return [imageManager zjhHomeVSSite];
        }
        case HomeMenuTypeZJHShop:{
            return [imageManager drawHomeShop];
        }
        default:
            return nil;
    }
}

+ (id)createView:(id<HomeCommonViewDelegate>)delegate identifier:(NSString *)identifier
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find view object from Nib", identifier);
        return nil;
    }
    HomeCommonView<HomeCommonViewProtocol> *view = [topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
//    [view updateView];
    return view;
}


+ (NSString *)identifierForType:(HomeMenuType)type
{
    if (type < HomeMenuTypeDrawBottomBegin || (type >= HomeMenuTypeZJHMainBegin && type < HomeMenuTypeZJHBottomBegin)) {
        return @"HomeMainMenu";
    }else{
        return @"HomeBottomMenu";
    }
    return nil;
}
+ (HomeMenuView *)menuViewWithType:(HomeMenuType)type
                             badge:(NSInteger)badge
                          delegate:(id<HomeCommonViewDelegate>)delegate
{
    NSString *identifier = [HomeMenuView identifierForType:type];
    if (identifier) {
        HomeMenuView *menu = [HomeMenuView createView:delegate identifier:identifier];
        NSString *title = [HomeMenuView titleForType:type];
        UIImage *image = [HomeMenuView imageForType:type];
        [menu updateIcon:image title:title type:type];
        [menu updateBadge:badge];
        return menu;
    }
    return nil;
}

- (void)dealloc {
    PPRelease(_button);
    [_badge release];
    [_title release];
    [super dealloc];
}

- (IBAction)clickButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickMenu:type:)]) {
        [self.delegate didClickMenu:self type:self.type];
    }
}
@end

int *getDrawMainMenuTypeList()
{
    int static list[] = {
        HomeMenuTypeDrawDraw,
        HomeMenuTypeDrawGuess,
        HomeMenuTypeDrawGame,
        HomeMenuTypeDrawTimeline,
        HomeMenuTypeDrawRank,
        HomeMenuTypeDrawShop,
        HomeMenuTypeDrawContest,
        HomeMenuTypeDrawBBS,
        HomeMenuTypeDrawApps,
        HomeMenuTypeDrawFreeCoins,
        HomeMenuTypeEnd
    };
    return list;
}
int *getDrawBottomMenuTypeList()
{
    int static list[] = {
        HomeMenuTypeDrawMe,
        HomeMenuTypeDrawOpus,
        HomeMenuTypeDrawFriend,
        HomeMenuTypeDrawMessage,
        HomeMenuTypeDrawMore,
        HomeMenuTypeEnd
    };
    return list;    
}
int *getZJHMainMenuTypeList()
{
    int static list[] = {
        HomeMenuTypeZJHStart,
        HomeMenuTypeZJHNormalSite,
        HomeMenuTypeZJHRichSite,
        HomeMenuTypeZJHVSSite,
        HomeMenuTypeDrawFreeCoins,
        HomeMenuTypeZJHShop,
        HomeMenuTypeDrawBBS,
        HomeMenuTypeZJHHelp,
        HomeMenuTypeEnd
    };
    return list;
}
int *getZJHBottomMenuTypeList()
{
    int static list[] = {
        HomeMenuTypeDrawMe,
        HomeMenuTypeDrawFriend,
        HomeMenuTypeDrawMessage,
        HomeMenuTypeDrawMore,
        HomeMenuTypeEnd
    };
    return list;
}
