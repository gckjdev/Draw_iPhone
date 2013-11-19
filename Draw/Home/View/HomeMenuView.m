//
//  HomeMenuView.m
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import "HomeMenuView.h"
#import "DrawImageManager.h"
#import "PPConfigManager.h"
#import "ShareImageManager.h"
#import "StatisticManager.h"
#import "UIButton+Sound.h"
#import "StableView.h"

@implementation HomeMenuView
@synthesize button = _button;

- (void)updateIcon:(UIImage *)icon
             title:(NSString *)title
              type:(HomeMenuType)type
{
    [self.button setImage:icon forState:UIControlStateNormal];
    [self setType:type];
    
    if (!isMainMenuButton(type)) {
        title = nil;
    }
    if (self.title) {
        [self.title setText:title];
    }else{
        [self.button setTitle:title forState:UIControlStateNormal];
    }
    [self.title setTextColor:COLOR_GREEN];

}

- (void)updateBadge:(NSInteger)count
{
    [self.badge setNumber:count];
}

- (void)toBeTitleUpStyle
{
    [self.title updateOriginY:0];
}

- (void)toBeTitleDownStyle
{
    [self.title updateOriginY:CGRectGetHeight(self.bounds)-CGRectGetHeight(self.title.bounds)];
}


+ (NSString *)titleForType:(HomeMenuType)type
{
    Class vc = [GameApp homeControllerClass];
    if ([vc respondsToSelector:@selector(menuTitleDictionary)] &&
        [vc respondsToSelector:@selector(defaultMenuTitleDictionary)]){

        NSDictionary* menuDict = [vc performSelector:@selector(menuTitleDictionary)];
        NSDictionary* defaultMenuTitleDict = [vc performSelector:@selector(defaultMenuTitleDictionary)];
        
        NSString* title = [menuDict objectForKey:@(type)];
        if (title == nil){
            title = [defaultMenuTitleDict objectForKey:@(type)];
        }
        
        return title;
    }
    else{
        return nil;
    }
    
    

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
        case HomeMenuTypeTask:{
            return NSLS(@"kHomeMenuTypeTask");
        }
        case HomeMenuTypeDrawBigShop:
        case HomeMenuTypeDrawShop:{
            return NSLS(@"kHomeMenuTypeDrawShop");
        }
        case HomeMenuTypeDrawApps:{
            return NSLS(@"kMore_apps");
        }
        case HomeMenuTypeDrawFreeCoins:
        {
            return NSLS(@"kFreeIngots");
        }
        case HomeMenuTypeZJHFreeCoins:
        case HomeMenuTypeDiceFreeCoins:
        {
            return NSLS(@"kFreeCoins");
        }
        case HomeMenuTypeDrawPlayWithFriend:{
            return NSLS(@"kPlayWithFriend");
        }
            
        case HomeMenuTypeDrawMore:
            return NSLS(@"kHomeMenuTypeDrawMore");
        case HomeMenuTypeDrawCharge: {
            return NSLS(@"kChargeTitle");
        }
        case HomeMenuTypeDrawPhoto: {
            return NSLS(@"kGallery");
        }
        case HomeMenuTypeDrawPainter: {
            return NSLS(@"kPainter");
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
        case HomeMenuTypeZJHMore:
        {
            return NSLS(@"kHomeMenuTypeDrawMore");
        }
        
            
        // Dice
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
        case HomeMenuTypeDiceMore:
            return NSLS(@"kHomeMenuTypeDrawMore");
            
        case HomeMenuTypeSing:
            return NSLS(@"kSing");
        case HomeMenuTypeGuessSing:
            return NSLS(@"kGuessSing");
//        case HomeMenuTypeSingContest:
//            return NSLS(@"kSingContest");
//        case HomeMenuTypeSingTop:
//            return NSLS(@"kSingTop");
//        case HomeMenuTypeSingBBS:
//            return NSLS(@"kBBS");
//        case HomeMenuTypeSingFreeCoins:
//            return NSLS(@"kFreeCoins");
        default:
        return nil;
    }
}
+ (UIImage *)imageForType:(HomeMenuType)type
{    
    Class vc = [GameApp homeControllerClass];
    if ([vc respondsToSelector:@selector(menuImageDictionary)] &&
        [vc respondsToSelector:@selector(defaultMenuImageDictionary)]){
        
        NSDictionary* menuDict = [vc performSelector:@selector(menuImageDictionary)];
        NSDictionary* defaultMenuImageDict = [vc performSelector:@selector(defaultMenuImageDictionary)];
        
        UIImage* image = [menuDict objectForKey:@(type)];
        if (image == nil){
            image = [defaultMenuImageDict objectForKey:@(type)];
        }
        
        return image;
    }
    else{
        return nil;
    }

    
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
        case HomeMenuTypeTask:{
            return [imageManager task];
        }
        case HomeMenuTypeDrawShop:{
            return [imageManager drawHomeShop];
        }
        case HomeMenuTypeDrawBigShop: {
            return [imageManager drawHomeBigShop];
        }
        case HomeMenuTypeDrawApps:{
            return [imageManager drawAppsRecommand];
        }
        case HomeMenuTypeDrawFreeCoins:
        {
            return [imageManager drawFreeCoins];
        }
        case HomeMenuTypeDrawPlayWithFriend:{
            return [imageManager drawPlayWithFriend];
        }
        case HomeMenuTypeDrawPhoto: {
            return [imageManager userPhoto];
        }
            
        case HomeMenuTypeDrawPainter:{
            return [imageManager drawHomePainter];
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
        case HomeMenuTypeDrawCharge: {
            return [imageManager zjhHomeCharge];
        }

        //little gee
        case HomeMenuTypeLittleGeeOptions:
            return [imageManager littleGeeMoreOptionsImage];
        case HomeMenuTypeLittleGeeFriend:
            return [imageManager drawHomeFriend];
        case HomeMenuTypeLittleGeePlaceholder:
            return nil;
        case HomeMenuTypeLittleGeeChat:
            return [imageManager drawHomeMessage];
        case HomeMenuTypeLittleGeeFeed:
            return [imageManager drawHomeTimeline];
            
            
        //sing
        case HomeMenuTypeSing:
            return [imageManager singHomeSing];
        case HomeMenuTypeGuessSing:
            return [imageManager singHomeGuess];
//        case HomeMenuTypeSingTop:
//            return [imageManager singHomeTop];
//        case HomeMenuTypeSingBBS:
//            return [imageManager singHomeBBS];
//        case HomeMenuTypeSingFreeCoins:
//            return [imageManager singHomeFreeCoins];
            
            
            
//        case HomeMenuTypeSingTimeline:
//            return [imageManager drawHomeTimeline];
        case HomeMenuTypeSingDraft:
            return [imageManager drawHomeOpus];
//        case HomeMenuTypeSingShop:
//            return [imageManager drawHomeShop];
//        case HomeMenuTypeSingChat:
//            return [imageManager drawHomeMessage];
//        case HomeMenuTypeSingSetting:
//            return [imageManager drawHomeSetting];
//        case HomeMenuTypeSingFriend:
//            return [imageManager drawHomeFriend];
        default:
            return nil;
    }
}


#define CENTER_DISTANCE_Y 26

- (void)updateView
{
    return;
    if ([DeviceDetection isIPhone5] && [self isHomeMainMenu]) {
        CGFloat y = self.center.y - CENTER_DISTANCE_Y;
        self.badge.center = CGPointMake(self.badge.center.x, y);
    }
}

+ (id)createView:(id<HomeCommonViewDelegate>)delegate identifier:(NSString *)identifier
{
    HomeCommonView<HomeCommonViewProtocol> *view = [self createViewWithXibIdentifier:identifier];
    view.delegate = delegate;
    
    return view;
}

- (BOOL)isHomeMainMenu
{
    return isMainMenuButton(self.type);
}

+ (NSString *)identifierForType:(HomeMenuType)type
{
    if (isMainMenuButton(type)) {
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
        [menu.button registerSound:SOUND_EFFECT_BUTTON_DOWN];
        [menu updateIcon:image title:title type:type];
        [menu updateBadge:badge];
        [menu setType:type];
        [menu updateView];
        [menu.title setTextColor:[GameApp homeMenuColor]];
        return menu;
    }
    return nil;
}

- (void)dealloc {
    [_button unregisterSound];
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



int *getZJHMainMenuTypeListWithFreeCoins()
{
    int static list[] = {
        HomeMenuTypeZJHStart,
        HomeMenuTypeZJHNormalSite,
        HomeMenuTypeZJHRichSite,
        HomeMenuTypeZJHVSSite,
        HomeMenuTypeZJHFreeCoins,
        HomeMenuTypeZJHCharge,
        HomeMenuTypeDrawBBS,
//        HomeMenuTypeZJHShop,
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
    return ([PPConfigManager freeCoinsEnabled] ? getZJHMainMenuTypeListWithFreeCoins() : getZJHMainMenuTypeListWithoutFreeCoins());
}

int *getZJHBottomMenuTypeList()
{
    int static list[] = {
        HomeMenuTypeDrawMe,
        HomeMenuTypeDrawFriend,
        HomeMenuTypeDrawMessage,
        HomeMenuTypeZJHMore,
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
    return ([PPConfigManager freeCoinsEnabled] ? getDiceMainMenuTypeListWithFreeCoins() : getDiceMainMenuTypeListWithoutFreeCoins());
}

//int *getSingMainMenuTypeList(){
//    return ([PPConfigManager freeCoinsEnabled] ? getSingMainMenuTypeListWithFreeCoins() : getSingMainMenuTypeListWithoutFreeCoins());
//}


int *getDiceBottomMenuTypeList()
{
    int static list[] = {
        HomeMenuTypeDrawMe,
        HomeMenuTypeDrawFriend,
        HomeMenuTypeDrawMessage,
        HomeMenuTypeDiceMore,
        HomeMenuTypeEnd
    };
    return list;
}

int *getLearnDrawBottomMenuTypeList()
{
    int static list[] = {
        HomeMenuTypeLearnDrawDraw,
        HomeMenuTypeLearnDrawDraft,
        HomeMenuTypeLearnDrawShop,
        HomeMenuTypeLearnDrawMore,
        HomeMenuTypeEnd
    };
    return list;
}

int *getLittleGeeBottomMenuTypeList()
{
    int static list[] = {
        HomeMenuTypeLittleGeeOptions,
        HomeMenuTypeLittleGeeFriend,
        HomeMenuTypeLittleGeePlaceholder,
        HomeMenuTypeLittleGeePlaceholder,
        HomeMenuTypeLittleGeePlaceholder,
        HomeMenuTypeLittleGeeChat,
        HomeMenuTypeLittleGeeFeed,
        HomeMenuTypeEnd
    };
    return list;
}



int *getDreamAvatarBottomMenuTypeListtWithFreeIngots()
{
    int static list[] = {
        HomeMenuTypeDreamAvatarDraw,
        HomeMenuTypeDreamAvatarDraft,
        HomeMenuTypeDreamAvatarShop,
        HomeMenuTypeDreamAvatarFreeIngot,
        HomeMenuTypeDreamAvatarMore,
        HomeMenuTypeEnd,
    };
    return list;
}

int *getDreamAvatarBottomMenuTypeListtWithoutFreeIngots()
{
    int static list[] = {
        HomeMenuTypeDreamAvatarDraw,
        HomeMenuTypeDreamAvatarDraft,
        HomeMenuTypeDreamAvatarShop,
        HomeMenuTypeDreamAvatarMore,
        HomeMenuTypeEnd,
    };
    return list;
}

int *getDreamAvatarBottomMenuTypeList()
{
    return ([PPConfigManager freeCoinsEnabled] ? getDreamAvatarBottomMenuTypeListtWithFreeIngots() : getDreamAvatarBottomMenuTypeListtWithoutFreeIngots());
}

int *getDreamLockscreenBottomMenuTypeListtWithFreeIngots()
{
    int static list[] = {
        HomeMenuTypeDreamLockscreenDraft,
        HomeMenuTypeDreamLockscreenShop,
        HomeMenuTypeDreamLockscreenFreeIngot,
        HomeMenuTypeDreamLockscreenMore,
        HomeMenuTypeEnd,
    };
    return list;
}

int *getDreamLockscreenBottomMenuTypeListtWithoutFreeIngots()
{
    int static list[] = {
        HomeMenuTypeDreamLockscreenDraft,
        HomeMenuTypeDreamLockscreenShop,
        HomeMenuTypeDreamLockscreenMore,
        HomeMenuTypeEnd,
    };
    return list;
}

int *getDreamLockscreenBottomMenuTypeList()
{
    return ([PPConfigManager freeCoinsEnabled] ? getDreamLockscreenBottomMenuTypeListtWithFreeIngots() : getDreamLockscreenBottomMenuTypeListtWithoutFreeIngots());
}

BOOL typeInList(HomeMenuType type, int *list)
{
    int *l = list;
    while (l != NULL && *l != HomeMenuTypeEnd) {
        if (*l == type) {
            return YES;
        }
        ++ l;
    }
    return NO;
}

BOOL isMainMenuButton(HomeMenuType type)
{
    if (typeInList(type, getMainMenuTypeList())) {
        return YES;
    }
//    if (typeInList(type, getDiceMainMenuTypeList())) {
//        return YES;
//    }
//    if (typeInList(type, getZJHMainMenuTypeList())) {
//        return YES;
//    }
//    if (typeInList(type, getSingMainMenuTypeList())) {
//        return YES;
//    }

    return NO;
}

int *getBottomMenuTypeList()
{
//    if (isDrawApp()) {
//        return getDrawBottomMenuTypeList();
//    }/*else if(isZhajinhuaApp()){
//        return getZJHBottomMenuTypeList();
//    }else if(isDiceApp()){
//        return getDiceBottomMenuTypeList();
//    }else if(isLearnDrawApp()){
//        return getLearnDrawBottomMenuTypeList();
//    }else if(isDreamAvatarApp() || isDreamAvatarFreeApp()){
//        return getDreamAvatarBottomMenuTypeList();
//    }else if(isDreamLockscreenApp() || isDreamLockscreenFreeApp()){
//        return getDreamLockscreenBottomMenuTypeList();
//    }else if (isLittleGeeAPP()) {
//        return getLittleGeeBottomMenuTypeList();
//    }*/else if (isSingApp()){
//        return getSingBottomMenuTypeList();
//    }
//    return NULL;

    Class class = [GameApp homeControllerClass];
    if ([class respondsToSelector:@selector(getBottomMenuList)]){
        id retList = [class performSelector:@selector(getBottomMenuList) withObject:nil];
        return (int*)retList;
    }
    else{
        PPDebug(@"<getMainMenuTypeList> but getBottomMenuList not implemented in home controller class!");
        return NULL;
    }
    
}

int *getMainMenuTypeList()
{
//    if (gameAppType() == GameAppTypeDraw) {
//        return getDrawMainMenuTypeList();
//    }else if(gameAppType() == GameAppTypeZJH){
//        return getZJHMainMenuTypeList();
//    }else if(gameAppType() == GameAppTypeDice){
//        return getDiceMainMenuTypeList();
//    }else if(gameAppType() == GameAppTypeSing){
//        return getSingMainMenuTypeList();
//    }
    
    Class class = [GameApp homeControllerClass];    
    if ([class respondsToSelector:@selector(getMainMenuList)]){
        id retList = [class performSelector:@selector(getMainMenuList) withObject:nil];
        return (int*)retList;
    }
    else{
        PPDebug(@"<getMainMenuTypeList> but getMainMenuList not implemented in home controller!");
        return NULL;
    }
}


