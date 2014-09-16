//
//  DrawPlayer.m
//  Draw
//
//  Created by Gamy on 13-8-30.
//
//

#import "DrawPlayer.h"
#import "DrawHolderView.h"
#import "ShowDrawView.h"
#import "PPConfigManager.h"
#import "Draw.h"
#import "ChangeBGImageAction.h"
#import "BBSActionSheet.h"
#import "ShareService.h"

@implementation ReplayObject

+ (id)obj
{
    return [[[ReplayObject alloc] init] autorelease];
}

- (void)dealloc
{
    PPRelease(_opusDesc);
    PPRelease(_opusWord);
    PPRelease(_opusId);

    PPRelease(_opusUserId);
    PPRelease(_opusUserNick);
    
    PPRelease(_actionList);
    PPRelease(_bgImage);
    PPRelease(_layers);
    PPRelease(_finalImage);
    [super dealloc];
}

@end

@interface DrawPlayer ()
{
    BOOL superControllerCanDragBack;
}

@property (nonatomic, assign) PPViewController* superController;

@end

@implementation DrawPlayer


- (CGFloat)speedWithRate:(CGFloat)rate
{
    CGFloat maxSpeed = [PPConfigManager getMaxPlayDrawSpeed];
    CGFloat minSpeed = 0;//[PPConfigManager getMinPlayDrawSpeed];
    CGFloat speed = maxSpeed -  rate *(maxSpeed - minSpeed);
    PPDebug(@"speed with rate, rate = %f, speed = %f", rate, speed);
    return speed;
    
}


- (void)updateView
{
    self.showView = [ShowDrawView showViewWithFrame:CGRectFromCGSize(_replayObj.canvasSize)
                                     drawActionList:nil
                                           delegate:self];
    
    [self.showView updateLayers:_replayObj.layers];
    [self.showView setDrawActionList:_replayObj.actionList];
    
    if (_replayObj.bgImage) {
        [self.showView setBGImage:_replayObj.bgImage];
    }
    
    
    [self.showView setPressEnable:YES];
    
    self.playSlider.minValue = 0;
    self.playSlider.maxValue = [[_replayObj actionList] count];
    self.playSlider.value = 0;
    self.playPanel.backgroundColor = COLOR255(0, 0, 0, 0.6*255);
    self.playSlider.bgColor = self.speedSlider.bgColor = COLOR255(0, 0, 0, 0.45*255);
    self.playSlider.loaderColor = self.speedSlider.loaderColor = COLOR255(28, 243, 230, 0.8*255);
    self.playSlider.pointColor = self.speedSlider.pointColor = COLOR_YELLOW;
    
    self.playSlider.pointImage = [[ShareImageManager defaultManager] playProgressPoint];

    self.speedSlider.pointImage = [[ShareImageManager defaultManager] speedProgressPoint];

    self.showView.playSpeed = [self speedWithRate:self.speedSlider.value];
    
    self.showView.maxPlaySpeed = [PPConfigManager getMaxPlayDrawSpeed];
    
 

}

+ (DrawPlayer *)playerWithReplayObj:(ReplayObject *)obj
{
    DrawPlayer *player = [DrawPlayer createViewWithXibIdentifier:@"DrawPlayer" ofViewIndex:ISIPAD];
    player.replayObj = obj;
    [player updateView];
    return player;
}

//+ (DrawPlayer *)playerWithGifViewInSize:(CGSize)canvasSize
//{
//    DrawPlayer *player = [DrawPlayer createViewWithXibIdentifier:@"DrawPlayer" ofViewIndex:ISIPAD];
//    
//    player.showGifView=[[ShowGifView alloc]initWithFrame:
//                              CGRectMake(0, 0, canvasSize.width, canvasSize.height)];
//    [player.showGifView getGifDataFromPath:@"/Users/Linruin/Desktop/test.gif"];
//    [player.showGifView displayGifImageInSize:canvasSize];
//    
//    return player;
//}

- (void)showInController:(PPViewController *)controller
{
    self.superController = controller;
    
    //    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    //    self.frame = CGRectOffset([[UIScreen mainScreen] bounds], 0, -20);
    DrawHolderView *holderView = (id)self.showView.superview;
    holderView.autoresizingMask = (1<<6)-1;
    if (holderView == nil) {
        holderView = [DrawHolderView drawHolderViewWithFrame:self.bounds contentView:self.showView];
        [holderView addTarget:self action:@selector(clickHolderView:) forControlEvents:UIControlEventTouchUpInside];
        [holderView updateOriginY:STATUSBAR_DELTA];
    }
    [self insertSubview:holderView atIndex:0];
    [controller.view addSubview:self];
    self.frame = controller.view.bounds;
    
    if (_replayObj.isNewVersion) {
        POSTMSG(NSLS(@"kNewDrawVersionTip"));
    }
    [self start];
    [self performSelector:@selector(autoHidePanel) withObject:nil afterDelay:4];
    superControllerCanDragBack = controller.canDragBack;
    [controller setCanDragBack:NO];
}


- (void)dealloc {
    [_playPanel release];
    [_playSlider release];
    [_speedSlider release];
    [_playButton release];
    [_closeButton release];
    PPRelease(_replayObj);
    PPRelease(_showView);
    [_indexLabel release];
    self.superController = nil;
    [super dealloc];
}

- (IBAction)close:(id)sender {
    [self showOption];
}


#define TITLE_SHARE     NSLS(@"kReplayOptionShare")
#define TITLE_CLOSE     NSLS(@"kReplayOptionClose")
#define TITLE_BACK      NSLS(@"kReplayOptionBack")

- (void)showOption
{
    [self pause];
    
    NSArray *titles = @[TITLE_BACK,
                        TITLE_SHARE,
                        TITLE_CLOSE];
    
    BBSActionSheet *sheet = [[BBSActionSheet alloc] initWithTitles:titles callback:^(NSInteger index) {
        NSString *t = titles[index];
        if ([t isEqualToString:TITLE_SHARE]) {

            [[ShareService defaultService] shareAsGIF:_superController
                                            opusImage:self.replayObj.finalImage
                                               opusId:self.replayObj.opusId
                                       drawActionList:self.replayObj.actionList
                                               layers:self.replayObj.layers
                                           canvasSize:self.replayObj.canvasSize
                                             drawWord:self.replayObj.opusWord
                                             drawDesc:self.replayObj.opusDesc
                                           drawUserId:self.replayObj.opusUserId
                                       drawUserGender:self.replayObj.opusUserGender
                                        completeBlock:^{
                                            
                                            [self hidePanel:NO animated:NO];
                                            
                                        }];
            
            [self hidePanel:NO animated:NO];
            
        }else if([t isEqualToString:TITLE_CLOSE]){
            
            [self closeView];
        }
        else if([t isEqualToString:TITLE_BACK]){
            
            [self play];
            
        }
    }];

    [sheet showInView:self showAtPoint:self.center animated:YES];
    [sheet release];
}


- (void)closeView
{
    self.superController = nil;
    [(PPViewController *)[self theViewController] setCanDragBack:superControllerCanDragBack];
    self.showView.delegate = nil;
    [self.showView stop];
    [self.showView removeFromSuperview];
    self.showView = nil;
    [self removeAllSubviews];
    [self removeFromSuperview];
}

- (void)playToIndex:(NSNumber *)index
{
    [(PPViewController *)[self theViewController] hideActivity];
    NSInteger status = self.showView.status;
    [self.showView setStatus:Pause];
    [self.showView showToIndex:[index integerValue]];
    if (status == Playing) {
        [self play];
    }else{
        [self pause];
    }
    [self.playButton setSelected:(status == Playing)];
//    [self.showView performSelector:@selector(setDelegate:) withObject:self afterDelay:0.2];
}

- (void)showCurrentIndexAtLabel:(NSInteger)index
{
    NSString *str=[NSString stringWithFormat:@"%d",index];
    self.indexLabel.text=str;

}

- (IBAction)changeProcess:(CustomSlider *)sender {
    [(PPViewController *)[self theViewController] showActivityWithText:NSLS(@"kBuffering")];
    NSInteger index = sender.value;
    [self performSelector:@selector(playToIndex:) withObject:@(index) afterDelay:0.01];
    
#ifdef DEBUG
    [self showCurrentIndexAtLabel:index];
#endif
}

- (IBAction)changeSpeed:(CustomSlider *)sender {
    PPDebug(@"<changeSpeed> = %f", sender.value);
    self.showView.playSpeed = [self speedWithRate:self.speedSlider.value];
}

- (IBAction)clickPlayButton:(id)sender {
    if (![sender isSelected]) {
        if (self.playSlider.value <= self.playSlider.minValue || self.playSlider.value >= self.playSlider.maxValue) {
            [self start];
        }else{
            [self play];
        }
    }else{
        [self pause];
    }
}

- (void)play
{
    [self.showView resume];
    [self.playButton setSelected:YES];
}
- (void)pause
{
    [self.showView pause];
    [self.playButton setSelected:NO];
    
//    [self stopRecording];
    
}
- (void)stop
{
    [self.showView stop];
    [self.playButton setSelected:NO];
    
}
- (void)start
{    
//    [self startRecording];
    
    [self.showView play];
    [self.playButton setSelected:YES];    
}


- (void)hidePanel:(BOOL)hidden animated:(BOOL)animated
{
    CGFloat alpha = (hidden ? 0 : 1);
    if (animated) {
        [UIView animateWithDuration:0.8 animations:^{
            self.playPanel.alpha = alpha;
            self.closeButton.hidden = hidden;
        } completion:^(BOOL finished) {
            self.playPanel.alpha = alpha;
            self.playPanel.hidden = hidden;
            self.closeButton.hidden = hidden;
            self.closeButton.alpha = alpha;
        }];
        
    }else{
        self.playPanel.alpha = alpha;
        self.playPanel.hidden = hidden;
        
        self.closeButton.hidden = hidden;
        self.closeButton.alpha = alpha;
    }
}

- (void)didPlayDrawView:(ShowDrawView *)showDrawView
          AtActionIndex:(NSInteger)actionIndex
             pointIndex:(NSInteger)pointIndex
{
    if (![self.playSlider isOnTouch]) {
        [self.playSlider setValue:actionIndex];
        
        
#ifdef DEBUG
        [self showCurrentIndexAtLabel:actionIndex];
#endif
        
    }else{
//        showDrawView.delegate = nil;
    }
    
}

- (void)didPlayDrawView:(ShowDrawView *)showDrawView
{
    if (![self.playSlider isOnTouch]) {
        [self.playSlider setValue:self.playSlider.maxValue];
    }
    [self hidePanel:NO animated:NO];
    [self.playButton setSelected:NO];
}

- (void)didClickShowDrawView:(ShowDrawView *)showDrawView
{
    [self clickHolderView:nil];
}

- (void)clickHolderView:(id)sender
{
    if (self.playPanel.alpha < 1) {
        [self hidePanel:NO animated:NO];
    }else{
        [self hidePanel:YES animated:YES];
    }
}


- (void)autoHidePanel
{
    [self hidePanel:YES animated:YES];    
}

+ (void)playDrawData:(NSData**)drawData
                draw:(Draw**)retDraw
      viewController:(PPViewController*)viewController
             bgImage:(UIImage*)bgImage
         bgImageName:(NSString*)bgImageName
          startIndex:(int)startIndex
            endIndex:(int)endIndex
           drawImage:(UIImage*)drawImage
{
    __block PPViewController * cp = viewController;
    
    [viewController registerNotificationWithName:NOTIFICATION_DATA_PARSING usingBlock:^(NSNotification *note) {
        float progress = [[[note userInfo] objectForKey:KEY_DATA_PARSING_PROGRESS] floatValue];
        NSString* progressText = @"";
        if (progress == 1.0f){
            progress = 0.99f;
            progressText = [NSString stringWithFormat:NSLS(@"kDisplayProgress"), progress*100];
        }
        else{
            progressText = [NSString stringWithFormat:NSLS(@"kParsingProgress"), progress*100];
        }
        [viewController showProgressViewWithMessage:progressText progress:progress];
    }];
    
    [viewController showProgressViewWithMessage:NSLS(@"kParsingProgress") progress:0.01f];
    dispatch_async([viewController getWorkingQueue], ^{
        if (*retDraw == nil) {
            *retDraw = [Draw parseDrawData:*drawData];
            if (*retDraw != nil){
                *drawData = nil;
            }
            [(*retDraw) retain];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [viewController unregisterNotificationWithName:NOTIFICATION_DATA_PARSING];
            
            Draw* draw = (*retDraw);
            if (draw == nil){
                [viewController hideActivity];
                return;
            }
            
            NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
            
            ReplayObject *obj = [ReplayObject obj];
            obj.actionList = draw.drawActionList;
            obj.isNewVersion = [draw isNewVersion];
            obj.canvasSize = draw.canvasSize;
            obj.layers = draw.layers;
            obj.bgImage = bgImage;
            obj.finalImage = drawImage;
            obj.opusWord = draw.word.text;
            obj.opusUserId = draw.userId;
            obj.opusUserNick = draw.nickName;
            
            DrawPlayer *player = [DrawPlayer playerWithReplayObj:obj begin:startIndex end:endIndex bgImageName:bgImageName];
            [player showInController:cp];
            
            [pool drain];
            
            [viewController hideActivity];
        });
    });
    
}

+ (UIImage*)createImageByDrawData:(NSData**)drawData
                         draw:(Draw**)retDraw
               viewController:(PPViewController*)viewController
                      bgImage:(UIImage*)bgImage
                  bgImageName:(NSString*)bgImageName
                   startIndex:(int)startIndex
                     endIndex:(int)endIndex
{
    if (*retDraw == nil) {
        *retDraw = [Draw parseDrawData:*drawData];
        if (*retDraw != nil){
            *drawData = nil;
        }
        [(*retDraw) retain];
    }
    
    Draw* draw = (*retDraw);
    if (draw == nil){
        return nil;
    }
    
    ReplayObject *obj = [ReplayObject obj];
    obj.actionList = draw.drawActionList;
    obj.isNewVersion = [draw isNewVersion];
    obj.canvasSize = draw.canvasSize;
    obj.layers = draw.layers;
    obj.bgImage = bgImage;
    obj.opusWord = draw.word.text;
    obj.opusUserId = draw.userId;
    obj.opusUserNick = draw.nickName;
    
    return [DrawPlayer createImageWithReplayObj:obj
                                          begin:startIndex
                                            end:endIndex
                                    bgImageName:bgImageName
                                        bgColor:[UIColor whiteColor]];
}


#pragma mark - Period Replay

+ (void)updateReplayObjectPlayIndex:(ReplayObject *)obj
                              begin:(NSUInteger)begin
                                end:(NSUInteger)end
                      bgImageAction:(ChangeBGImageAction*)bgImageAction
{
    NSMutableArray* drawActionList = obj.actionList;
    int totalDrawActionListCount = [drawActionList count];
    
    if (end <= begin)
    {
        PPDebug(@"end less than begin, fail to play period!");
        return;
    }
    
    if (end >= totalDrawActionListCount || begin >= totalDrawActionListCount)
    {
        PPDebug(@"end > all action count, fail to play period!");
        return;
    }
    
    if (begin == 0 && (end >= (totalDrawActionListCount - 1))){
        // begin and end is the whole list, no need to do any extra actions
        obj.actionList = drawActionList;
        return;
    }
    
    // create sub action by [begin, end]
    NSMutableArray *subActionList;
    NSRange range = NSMakeRange(begin, (end-begin));
    subActionList = [[NSMutableArray alloc] initWithArray:[drawActionList subarrayWithRange:range]];
    obj.actionList = subActionList;
    if (bgImageAction){
        [obj.actionList insertObject:bgImageAction atIndex:0];
    }
    
    [subActionList release];
    
}

- (UIImage*)createBgImageByObj:(ReplayObject*)obj
                         begin:(NSUInteger)begin
                           end:(NSUInteger)end
{
    NSMutableArray* drawActionList = obj.actionList;
    
    if (end < begin)
    {
        PPDebug(@"<createBgImageByObj> end < begin, fail to play period!");
        return obj.bgImage;
    }
    
    int totalDrawActiontCount = [drawActionList count];
    if (end >= totalDrawActiontCount || begin >= totalDrawActiontCount)
    {
        PPDebug(@"<createBgImageByObj> end(%d)/begin(%d) >  total action count(%d), fail to play period!",
                end, begin, totalDrawActiontCount);
        return obj.bgImage;
    }
    
    if (begin == 0 && (end >= (totalDrawActiontCount - 1))){
        // begin and end is the whole list, no need to do any extra actions
        return obj.bgImage;
    }
    
    UIImage *retImg = obj.bgImage;
    
    // update background image
    UIImage *img = nil; // create bg image
    if (begin > 0){
        // if begin from 0, means no background image needed
        img = [self.showView createImageAtIndex:begin];
        PPDebug(@"<createBgImageByObj> image size=%@", NSStringFromCGSize(img.size));
    }
    
    if (img != nil){
        //用户木有使用背景图，返回index==begin时候的image;否则合并图片
        if (obj.bgImage == nil){
            retImg = img;
        }
        else{
            // 将obj生成的image放到用户使用的bgImage上面合并成新的UIImage
            retImg = [ShowDrawView addImage:img toImage:obj.bgImage];
        }
    }

    return retImg;
}

- (ChangeBGImageAction*)createBgImageActionByObj:(ReplayObject*)obj
                                           begin:(NSUInteger)begin
                                             end:(NSUInteger)end
                                     bgImageName:(NSString*)bgImageName
{
    NSMutableArray* drawActionList = obj.actionList;
    
    if ([bgImageName length] == 0){
        PPDebug(@"<createBgImageByObj> but image name nil!");
        return nil;
    }
    
    if (end < begin)
    {
        PPDebug(@"<createBgImageByObj> end < begin, fail to play period!");
        return nil;
    }
    
    int totalDrawActiontCount = [drawActionList count];
    if (end >= totalDrawActiontCount || begin >= totalDrawActiontCount)
    {
        PPDebug(@"<createBgImageByObj> end(%d)/begin(%d) >  total action count(%d), fail to play period!",
                end, begin, totalDrawActiontCount);
        return nil;
    }
    
    if (begin == 0 && (end >= (totalDrawActiontCount - 1))){
        // begin and end is the whole list, no need to do any extra actions
        return nil;
    }
    
    // update background image
    UIImage *img = nil; // create bg image
    if (begin > 0){
        // if begin from 0, means no background image needed
        img = [self.showView createImageAtIndex:begin bgColor:[UIColor clearColor]];
        PPDebug(@"<createBgImageByObj> image size=%@", NSStringFromCGSize(img.size));
    }

    ChangeBGImageAction* action = nil;
    if (img != nil){
        action = [ChangeBGImageAction actionForNormalDrawBg:PBDrawBgLayerTypeDrawBgLayerForeground
                                                    bgImage:img
                                                bgImageName:bgImageName
                                                   needSave:YES];
    }
    
    return action;
}

+ (UIImage*)createImageWithReplayObj:(ReplayObject *)obj
                               begin:(NSUInteger)begin
                                 end:(NSUInteger)end
                         bgImageName:(NSString*)bgImageName
                             bgColor:(UIColor*)bgColor
{
    PPDebug(@"<createImageWithReplayObj> begin=%d, end=%d", begin, end);
    
    DrawPlayer *playerForBgImage = [DrawPlayer playerWithReplayObj:obj];
    
    NSMutableArray* drawActionList = obj.actionList;
    if (end < begin)
    {
        PPDebug(@"<createImageWithReplayObj> end < begin, fail to play period!");
        return nil;
    }
    
    int totalDrawActiontCount = [drawActionList count];
    if (end >= totalDrawActiontCount || begin >= totalDrawActiontCount)
    {
        PPDebug(@"<createImageWithReplayObj> end(%d)/begin(%d) >  total action count(%d), fail to play period!",
                end, begin, totalDrawActiontCount);
        return nil;
    }
    
    if (begin == 0 && (end > (totalDrawActiontCount - 1))){
        // begin and end is the whole list, no need to do any extra actions
        return nil;
    }
    
    // update background image
    UIImage *img = nil; // create bg image
    if (end > 0){
        // if begin from 0, means no background image needed
        img = [playerForBgImage.showView createImageAtIndex:end bgColor:bgColor];
        PPDebug(@"<createImageWithReplayObj> image size=%@", NSStringFromCGSize(img.size));
    }
    
    return img;

}

+ (DrawPlayer*)playerWithReplayObj:(ReplayObject *)obj
                             begin:(NSUInteger)begin
                               end:(NSUInteger)end
                       bgImageName:(NSString*)bgImageName
{
    PPDebug(@"<playerWithReplayObj> begin=%d, end=%d", begin, end);

    // create background image, using the whole replay object
    DrawPlayer *playerForBgImage = [DrawPlayer playerWithReplayObj:obj];
    ChangeBGImageAction* action = [playerForBgImage createBgImageActionByObj:obj
                                                                       begin:begin
                                                                         end:end
                                                                 bgImageName:bgImageName];
    
    
    //using another player to update replay object
    DrawPlayer *player = [DrawPlayer createViewWithXibIdentifier:@"DrawPlayer" ofViewIndex:ISIPAD];
    [DrawPlayer updateReplayObjectPlayIndex:obj begin:begin end:end bgImageAction:action];
    
    //把已经upadate的obj属性赋值到player
    player.replayObj = obj;
    [player updateView];
    
    return player;
}

+ (DrawPlayer*)playerWithSingleLayer:(NSInteger)num
                       RepObj:(ReplayObject*)obj
{
    //用户单独layer播放，暂时无用。。。
    DrawLayer *singleLayer;
    singleLayer = [obj.layers objectAtIndex:num];
    NSMutableArray *cuttedLayerList = [[NSMutableArray alloc] init];
    [cuttedLayerList addObject:singleLayer];
    obj.layers = cuttedLayerList;
    [cuttedLayerList release];
    
    for(NSInteger i=0;i<[obj.actionList count];)
    {
        if([[obj.actionList objectAtIndex:i] layerTag]!= [singleLayer layerTag])
        {
            [obj.actionList removeObjectAtIndex:i];
        }
        else
            i++;
    }
    
    //把已经upadate的obj属性赋值到player
    DrawPlayer *player = [DrawPlayer createViewWithXibIdentifier:@"DrawPlayer" ofViewIndex:ISIPAD];
    player.replayObj = obj;
    [player updateView];
    
    return player;
}

+ (void) createImageOfLayer:(NSInteger)num
                     RepObj:(ReplayObject*)obj
{
    DrawLayer *singleLayer;
    singleLayer = [obj.layers objectAtIndex:num];
    NSMutableArray *cuttedLayerList = [[NSMutableArray alloc] init];
    [cuttedLayerList addObject:singleLayer];
    obj.layers = cuttedLayerList;
    [cuttedLayerList release];
    
    for(NSInteger i=0;i<[obj.actionList count];)
    {
        if([[obj.actionList objectAtIndex:i] layerTag]!= [singleLayer layerTag])
        {
            [obj.actionList removeObjectAtIndex:i];
        }
        else
            i++;
    }

    //把已经分离好的obj属性赋值到player
    DrawPlayer *player = [DrawPlayer createViewWithXibIdentifier:@"DrawPlayer" ofViewIndex:ISIPAD];
    player.replayObj = obj;
    [player updateView];

    NSString *path = [NSString stringWithFormat:@"/Users/Linruin/Desktop/Image_%d.png",num];
    [player.showView createImageOfLayer:num Path:path];
    
}



@end
