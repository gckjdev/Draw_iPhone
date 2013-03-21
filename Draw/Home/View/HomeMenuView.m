//
//  HomeMenuView.m
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import "HomeMenuView.h"
#import "DrawImageManager.h"
#import "ConfigManager.h"
#import "ShareImageManager.h"

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
        case HomeMenuTypeDrawFreeCoins:
        case HomeMenuTypeDiceFreeCoins:
        {
            return NSLS(@"kFreeGetCoins");
        }
        case HomeMenuTypeDrawPlayWithFriend:{
            return NSLS(@"kPlayWithFriend");
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
        case HomeMenuTypeZJHCharge:{
            return NSLS(@"kHomeMenuTypeZJHCharge");
        }
            
        case HomeMenuTypeZJHShop:{
            return NSLS(@"kHomeMenuTypeZJHShop");
        }
            
            
        case HomeMenuTypeDiceStart:
            return NSLS(@"kDiceMenuStart");
        case HomeMenuTypeDiceHelp:
            return NSLS(@"kDiceMenuHelp");
            
        case HomeMenuTypeDiceHappyRoom:
            return NSLS(@"kDiceMenuHappyRoom");
        case HomeMenuTypeDiceHighRoom:
            return NSLS(@"kDiceMenuHighRoom");
        case HomeMenuTypeDiceSuperHighRoom:
            return NSLS(@"kDiceMenuSuperHighRoom");
        case HomeMenuTypeDiceShop:
            return NSLS(@"kDiceMenuShop");

        default:
        return nil;
    }
}
+ (UIImage *)imageForType:(HomeMenuType)type
{
    DrawImageManager *imageManager = [DrawImageManager defaultManager];
//    ShareImageManager *shareImageManager = [ShareImageManager defaultManager];
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
        case HomeMenuTypeDrawPlayWithFriend:{
            return [imageManager drawPlayWithFriend];
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
        case HomeMenuTypeZJHCharge:{
            return [imageManager drawHomeShop];
        }
        case HomeMenuTypeZJHShop:{
            return [imageManager drawHomeShop];
        }
            
            
            
        //dice
        case HomeMenuTypeDiceStart:
//            return [shareImageManager diceStartMenuImage];
            return [imageManager zjhHomeStart];
        case HomeMenuTypeDiceShop:
//            return [shareImageManager diceShopImage];
            return [imageManager drawHomeShop];
        case HomeMenuTypeDiceHelp:
//            return [shareImageManager diceHelpMenuImage];
            return [imageManager zjhHomeHelp];
        case HomeMenuTypeDiceHappyRoom:
//            return [shareImageManager normalRoomMenuImage];
            return [imageManager zjhHomeNormalSite];
        case HomeMenuTypeDiceHighRoom:
//            return [shareImageManager highRoomMenuImage];
            return [imageManager zjhHomeRichSite];
        case HomeMenuTypeDiceSuperHighRoom:
//            return [shareImageManager superHighRoomMenuImage];
            return [imageManager zjhHomeRichSite];
        case HomeMenuTypeDiceFreeCoins:
            //            return [shareImageManager diceShopImage];
            return [imageManager drawFreeCoins];
        default:
            return nil;
    }
}


#define CENTER_DISTANCE_Y 26

- (void)updateView
{
    if ([DeviceDetection isIPhone5] && [self isHomeMainMenu]) {
        CGFloat y = self.center.y - CENTER_DISTANCE_Y;
        self.badge.center = CGPointMake(self.badge.center.x, y);
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

- (BOOL)isHomeMainMenu
{
    NSInteger type = self.type;
    if (type < HomeMenuTypeDrawBottomBegin || (type >= HomeMenuTypeZJHMainBegin && type < HomeMenuTypeZJHBottomBegin) || (type >= HomeMenuTypeDiceStart && type < HomeMenuTypeDiceBottomBegin)) {
        return YES;
    }
    return NO;
}

+ (NSString *)identifierForType:(HomeMenuType)type
{
    if (type < HomeMenuTypeDrawBottomBegin || (type >= HomeMenuTypeZJHMainBegin && type < HomeMenuTypeZJHBottomBegin) || (type >= HomeMenuTypeDiceStart && type < HomeMenuTypeDiceBottomBegin)) {
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
        [menu setType:type];
        [menu updateView];
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



int *getDrawMainMenuTypeListWithFreeCoins()
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
        HomeMenuTypeDrawPlayWithFriend,
        HomeMenuTypeEnd
    };
    return list;
}

int *getDrawMainMenuTypeListWithoutFreeCoins()
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
        HomeMenuTypeDrawPlayWithFriend,
        HomeMenuTypeEnd
    };
    return list;
}

int *getDrawMainMenuTypeList()
{
    return ([ConfigManager freeCoinsEnabled] ? getDrawMainMenuTypeListWithFreeCoins() : getDrawMainMenuTypeListWithoutFreeCoins());
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
int *getZJHMainMenuTypeListWithFreeCoins()
{
    int static list[] = {
        HomeMenuTypeZJHStart,
        HomeMenuTypeZJHNormalSite,
        HomeMenuTypeZJHRichSite,
        HomeMenuTypeZJHVSSite,
        HomeMenuTypeDrawFreeCoins,
        HomeMenuTypeZJHCharge,
        HomeMenuTypeDrawBBS,
        HomeMenuTypeZJHShop,
        HomeMenuTypeZJHHelp,
        HomeMenuTypeEnd
    };
    return list;
}

int *getZJHMainMenuTypeListWithoutFreeCoins()
{
    int static list[] = {
        HomeMenuTypeZJHStart,
        HomeMenuTypeZJHNormalSite,
        HomeMenuTypeZJHRichSite,
        HomeMenuTypeZJHVSSite,
        HomeMenuTypeZJHCharge,
        HomeMenuTypeDrawBBS,
//        HomeMenuTypeZJHShop,
        HomeMenuTypeZJHHelp,
        HomeMenuTypeEnd
    };
    return list;
}

int *getZJHMainMenuTypeList()
{
    return ([ConfigManager freeCoinsEnabled] ? getZJHMainMenuTypeListWithFreeCoins() : getZJHMainMenuTypeListWithoutFreeCoins());
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



int *getDiceMainMenuTypeListWithFreeCoins()
{
    int static list[] = {
        HomeMenuTypeDiceStart,
        HomeMenuTypeDiceHappyRoom,
        HomeMenuTypeDiceSuperHighRoom,
        HomeMenuTypeDiceFreeCoins,
        HomeMenuTypeDiceShop,
        HomeMenuTypeDrawBBS,
        HomeMenuTypeDiceHelp,
        HomeMenuTypeEnd,
    };
    return list;
}

int *getDiceMainMenuTypeListWithoutFreeCoins()
{
    int static list[] = {
        HomeMenuTypeDiceStart,
        HomeMenuTypeDiceHappyRoom,
        HomeMenuTypeDiceSuperHighRoom,
        HomeMenuTypeDiceShop,
        HomeMenuTypeDrawBBS,
        HomeMenuTypeDiceHelp,
        HomeMenuTypeEnd,
    };
    return list;
}

int *getDiceMainMenuTypeList()
{
    return ([ConfigManager freeCoinsEnabled] ? getDiceMainMenuTypeListWithFreeCoins() : getDiceMainMenuTypeListWithoutFreeCoins());
}

int *getDiceBottomMenuTypeList()
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
