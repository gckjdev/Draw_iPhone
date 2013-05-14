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
    [self setType:type];
    
    if (!isMainMenuButton(type)) {
        title = nil;
    }
    if (self.title) {
        [self.title setText:title];
    }else{
        [self.button setTitle:title forState:UIControlStateNormal];
    }

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
            return [imageManager zjhHomeCharge];
        }
        case HomeMenuTypeZJHShop:{
            return [imageManager drawHomeShop];
        }
        case HomeMenuTypeZJHFreeCoins:
        {
            return [imageManager drawFreeCoins];
        }
        case HomeMenuTypeZJHMore:
        {
            return [imageManager zjhHomeMore];
        }

     
        //dice
        case HomeMenuTypeDiceStart:
            return [imageManager zjhHomeStart];
        case HomeMenuTypeDiceShop:
            return [imageManager diceHomeShop];
        case HomeMenuTypeDiceHelp:
            return [imageManager zjhHomeHelp];
        case HomeMenuTypeDiceHappyRoom:
            return [imageManager zjhHomeNormalSite];
        case HomeMenuTypeDiceHighRoom:
            return [imageManager zjhHomeRichSite];
        case HomeMenuTypeDiceSuperHighRoom:
            return [imageManager zjhHomeRichSite];
        case HomeMenuTypeDiceFreeCoins:
            return [imageManager drawFreeCoins];
        case HomeMenuTypeDiceMore:{
            return [imageManager diceHomeMore];
        }
        
        case HomeMenuTypeLearnDrawDraw:
            return [imageManager learnDrawDraw];
            
        case HomeMenuTypeLearnDrawDraft:
            return [imageManager learnDrawDraft];
            
        case HomeMenuTypeLearnDrawShop:
            return [imageManager learnDrawShop];
            
        case HomeMenuTypeLearnDrawMore:
            return [imageManager learnDrawMore];
            
        
        //dream avatar
        case HomeMenuTypeDreamAvatarDraw:
            return [imageManager dreamAvatarDraw];
            
        case HomeMenuTypeDreamAvatarDraft:
            return [imageManager dreamAvatarDraft];
        
        case HomeMenuTypeDreamAvatarShop:
            return [imageManager dreamAvatarShop];
            
        case HomeMenuTypeDreamAvatarFreeIngot:
            return [imageManager dreamAvatarFreeIngot];
        
        case HomeMenuTypeDreamAvatarMore:
            return [imageManager dreamAvatarMore];
            
            
        //dream lockscreen
        case HomeMenuTypeDreamLockscreenDraft:
            return [imageManager dreamLockscreenDraft];
            
        case HomeMenuTypeDreamLockscreenShop:
            return [imageManager dreamLockscreenShop];
            
        case HomeMenuTypeDreamLockscreenFreeIngot:
            return [imageManager dreamLockscreenFreeIngot];
            
        case HomeMenuTypeDreamLockscreenMore:
            return [imageManager dreamLockscreenMore];
            

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
        HomeMenuTypeDrawRank,
        HomeMenuTypeDrawContest,
        HomeMenuTypeDrawBBS,
        HomeMenuTypeDrawFreeCoins,
        HomeMenuTypeDrawBigShop,
//        HomeMenuTypeDrawCharge, //no icon now, when icon designed, revover it --kira
        HomeMenuTypeDrawMore,
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
        HomeMenuTypeDrawRank,
        HomeMenuTypeDrawContest,
        HomeMenuTypeDrawBBS,
        HomeMenuTypeDrawBigShop,
//        HomeMenuTypeDrawCharge, //no icon now, when icon designed, revover it --kira
        HomeMenuTypeDrawMore,
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
        HomeMenuTypeDrawTimeline,
        HomeMenuTypeDrawOpus,
        HomeMenuTypeDrawFriend,
        HomeMenuTypeDrawMessage,
        HomeMenuTypeDrawShop,
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
    return ([ConfigManager freeCoinsEnabled] ? getZJHMainMenuTypeListWithFreeCoins() : getZJHMainMenuTypeListWithoutFreeCoins());
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
    return ([ConfigManager freeCoinsEnabled] ? getDiceMainMenuTypeListWithFreeCoins() : getDiceMainMenuTypeListWithoutFreeCoins());
}

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
    return ([ConfigManager freeCoinsEnabled] ? getDreamAvatarBottomMenuTypeListtWithFreeIngots() : getDreamAvatarBottomMenuTypeListtWithoutFreeIngots());
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
    return ([ConfigManager freeCoinsEnabled] ? getDreamLockscreenBottomMenuTypeListtWithFreeIngots() : getDreamLockscreenBottomMenuTypeListtWithoutFreeIngots());
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
    if (typeInList(type, getDrawMainMenuTypeList())) {
        return YES;
    }
    if (typeInList(type, getDiceMainMenuTypeList())) {
        return YES;
    }
    if (typeInList(type, getZJHMainMenuTypeList())) {
        return YES;
    }
    return NO;
}

int *getBottomMenuTypeList()
{
    if (isDrawApp()) {
        return getDrawBottomMenuTypeList();
    }else if(isZhajinhuaApp()){
        return getZJHBottomMenuTypeList();
    }else if(isDiceApp()){
        return getDiceBottomMenuTypeList();
    }else if(isLearnDrawApp()){
        return getLearnDrawBottomMenuTypeList();
    }else if(isDreamAvatarApp() || isDreamAvatarFreeApp()){
        return getDreamAvatarBottomMenuTypeList();
    }else if(isDreamLockscreenApp() || isDreamLockscreenFreeApp()){
        return getDreamLockscreenBottomMenuTypeList();
    }else if (isLittleGeeAPP()) {
        return getLittleGeeBottomMenuTypeList();
    }
    return NULL;
}
int *getMainMenuTypeList()
{
    if (gameAppType() == GameAppTypeDraw) {
        return getDrawMainMenuTypeList();
    }else if(gameAppType() == GameAppTypeZJH){
        return getZJHMainMenuTypeList();
    }else if(gameAppType() == GameAppTypeDice){
        return getDiceMainMenuTypeList();
    }
    return NULL;
}


