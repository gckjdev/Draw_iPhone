//
//  OpusWallController.m
//  Draw
//
//  Created by 王 小涛 on 13-1-25.
//
//

#import "OpusWallController.h"
#import "UIImageView+WebCache.h"
#import "UserManager.h"
#import "FrameManager.h"
#import "ProtocolUtil.h"
#import "UIImageView+WebCache.h"

@interface OpusWallController ()

@property (retain, nonatomic) UIImage *bgImage;
@property (assign, nonatomic) int wallOpusOrder;
@property (retain, nonatomic) Wall *wall;
@property (retain, nonatomic) UIView *wallView;
@property (retain, nonatomic) ChangeAvatar *photoCollection;

@end

@implementation OpusWallController

- (void)dealloc
{
    [_bgImage release];
    [_wall release];
    [_wallView release];
    [_backButton release];
    [_setLayoutButton release];
    [_submitButton release];
    [_bgImageView release];
    [_photoCollection release];
    [_setBgImageBtn release];
    [super dealloc];
}

- (id)initWithWall:(Wall *)wall
{
    if (self = [super init]) {
        self.wall = wall;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNavigationLeftButton:@"返回" action:@selector(clickBack:)];
    self.title = _wall.pbWall.name;

    [self updateLayout];
}

- (void)updateLayout
{
//    [self.wallView removeFromSuperview];
//
//    PBRect *pbRect = [DeviceDetection isIPAD] ? _wall.pbWall.layout.iPadRect : _wall.pbWall.layout.iPhoneRect;
//    CGRect rect = CGRectMake(pbRect.x, pbRect.y, pbRect.width, pbRect.height);
//    
//    if (_bgImage == nil) {
//        [self.bgImageView setImageWithURL:[NSURL URLWithString:_wall.pbWall.layout.bgImage] placeholderImage:nil success:^(UIImage *image, BOOL cached) {
//            self.bgImage = image;
//        } failure:^(NSError *error) {
//            self.bgImage = nil;
//        }];
//    }else{
//        self.bgImageView.image = _bgImage;
//    }
//    
//    if (_wall.pbWall.layout.displayMode == DISPLAY_MODE_PLANE) {
//
//        self.wallView = [[[UIView alloc] initWithFrame:rect] autorelease];
//        [self.view addSubview:self.wallView];
//        
//        [self updateWallOpuses];
//    }else{
//        self.wallView = [[[iCarousel alloc] initWithFrame:rect] autorelease];
//        ((iCarousel *)self.wallView).delegate = self;
//        ((iCarousel *)self.wallView).dataSource = self;
//        ((iCarousel *)self.wallView).decelerationRate = 0.5;
//
//        ((iCarousel *)self.wallView).type = _wall.pbWall.layout.coverFlowType;
//        [self.view addSubview:self.wallView];
//    }
//    
//    [self.view bringSubviewToFront:self.backButton];
//    [self.view bringSubviewToFront:self.setLayoutButton];
//    [self.view bringSubviewToFront:self.submitButton];
//    [self.view bringSubviewToFront:self.setBgImageBtn];
}

- (void)updateWallOpuses
{
//    if (_wall.pbWall.layout.displayMode == DISPLAY_MODE_PLANE) {
//        for (UIView *view in [self.wallView subviews]) {
//            [view removeFromSuperview];
//        }
//        
//        for (WallOpus *wallOpus in [_wall wallOpuses]) {
//            [self.wallView addSubview:[self wallOpusBtn:wallOpus]];
//        }
//        
//
//    }else{
//        [((iCarousel *)self.wallView) reloadData];
//    }
}


#define MAX_COVER_FLOW_FRAME_WIDTH 200.0f
#define MAX_COVER_FLOW_FRAME_HEIGHT 200.0f

//- (UIButton *)wallOpusBtn:(WallOpus *)wallOpus
//{
//    PBFrame *frame = [_wall frameWithFrameIdOnWall:wallOpus.frameIdOnWall];
//    
//    PBRect *pbRect = [DeviceDetection isIPAD] ? frame.iPadRect : frame.iPhoneRect;
//    CGRect rect = CGRectMake(pbRect.x, pbRect.y, pbRect.width, pbRect.height);
//
//    
//    UIButton *button = [[[UIButton alloc] initWithFrame:rect] autorelease];
//    
//    UIImageView *frameImageView  = [[[UIImageView alloc] initWithFrame:button.bounds] autorelease];
//    UIImage *image = [UIImage imageWithContentsOfFile:[[[FrameManager sharedFrameManager] frameWithFrameId:frame.frameId] image]];
//    if (image == nil) {
//        [frameImageView setImageWithURL:[NSURL URLWithString:frame.imageUrl]];
//    }else{
//        [frameImageView setImage:image];
//    }
//    
//    [button setImage:image forState:UIControlStateNormal];
//    button.tag = wallOpus.frameIdOnWall;
//    
//    [button addTarget:self action:@selector(clickWallOpus:) forControlEvents:UIControlEventTouchUpInside];
//    
//    
//    PBRect *pbOpusRect = [DeviceDetection isIPAD] ? frame.opusIpadRect : frame.opusIphoneRect;
//    CGRect opusRect = CGRectMake(pbOpusRect.x, pbOpusRect.y, pbOpusRect.width, pbOpusRect.height);
//    UIImageView *opusImageView = [[[UIImageView alloc] initWithFrame:opusRect] autorelease];
//    
//    [opusImageView setImageWithURL:[NSURL URLWithString:[wallOpus opus].drawImageUrl]];
//    
//    [button addSubview:opusImageView];
//    
//    CGFloat scale = MIN(MAX_COVER_FLOW_FRAME_WIDTH / rect.size.width, MAX_COVER_FLOW_FRAME_HEIGHT / rect.size.height);
//    button.transform = CGAffineTransformMakeScale(scale, scale);
//    
//    [button setBackgroundColor:[UIColor clearColor]];
//    return button;
//}

- (void)clickWallOpus:(id)sender
{
    self.wallOpusOrder = ((UIButton *)sender).tag;    
    
    PPDebug(@"click wallOpus: %d, opus:%@", self.wallOpusOrder, [[[_wall wallOpusWithFrameIdOnWall:self.wallOpusOrder] opus] wordText]);
    
    UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:nil otherButtonTitles:NSLS(@"kReplaceOpus"), NSLS(@"kReplaceFrame"), nil] autorelease];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:NSLS(@"kCancel")]) {
        return;
    }
    
    if ([title isEqualToString:NSLS(@"kReplaceOpus")]) {
        PPDebug(@"buttonIndex:%d", buttonIndex);
        OpusSelectController *vc  = [[[OpusSelectController alloc] init] autorelease];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
        [vc hideComfirmButton];
    }
    
    if ([title isEqualToString:NSLS(@"kReplaceFrame")]) {
        FrameSelectController *vc  = [[[FrameSelectController alloc] init] autorelease];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

- (void)didController:(OpusSelectController *)contorller clickOpus:(DrawFeed *)opus
{
    [contorller.navigationController popViewControllerAnimated:YES];
    [_wall replaceWallOpus:self.wallOpusOrder withOpus:opus];
    [self updateWallOpuses];
}

- (void)didController:(FrameSelectController *)contorller clickFrame:(PBFrame *)frame
{
    [contorller.navigationController popViewControllerAnimated:YES];
    [_wall replaceWallOpus:self.wallOpusOrder withFrame:frame];
    [self updateWallOpuses];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setBackButton:nil];
    [self setSetLayoutButton:nil];
    [self setSubmitButton:nil];
    [self setBgImageView:nil];
    [self setSetBgImageBtn:nil];
    [self setWallOpusView:nil];
    [self setFrameImageView:nil];
    [self setOpusImageView:nil];
    [super viewDidUnload];
}


static int layoutTest;
- (IBAction)clickSetLayoutButton:(id)sender {
    if (layoutTest) {
        [_wall setDisplayMode:layoutTest ];
        [self updateLayout];
    }else{
        [_wall setDisplayMode:layoutTest];
        [self updateLayout];
    }

//        [_wall setCoverFlowType:((++layoutTest)%12)];
//        [self updateLayout];
   
}

- (void)didImageSelected:(UIImage*)image
{
    self.bgImage = image;
    self.bgImageView.image = image;
}

- (IBAction)clickSubmitButton:(id)sender {
    if (_wall.pbWall.wallId == nil) {
        [[WallService sharedWallService] createWall:[_wall toPBWall] bgImage:_bgImage delegate:self];
    }else{
        [[WallService sharedWallService] updateWall:[_wall toPBWall] bgImage:_bgImage delegate:self];
    }
}

- (void)didCreateWall:(int)resultCode wall:(PBWall *)wall
{
//    if (resultCode == 0) {
//        PPDebug(@"new wall: %@", wall.wallId);
//        [_wall setWallId:wall.wallId];
//        [_wall setBgImage:wall.layout.bgImage];
//        self.bgImage = nil;
//    }else{
//        PPDebug(@"create wall failed!");
//    }
}

- (void)didUpdateWall:(int)resultCode wall:(PBWall *)wall
{
    PPDebug(@"UpdateWall done!");
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
//    return [_wall.pbWall.layout.framesList count];
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    //limit the number of items views loaded concurrently (for performance reasons)
    //this also affects the appearance of circular-type carousels
//    return [_wall.wallOpuses count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
	//create new view if no view is available for recycling
	if (view == nil)
	{
//        view = [self wallOpusBtn:[_wall.wallOpuses objectAtIndex:index]];
	}

	return view;
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
	//note: placeholder views are only displayed on some carousels if wrapping is disabled
	return 0;
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
	//create new view if no view is available for recycling
	return nil;
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    //usually this should be slightly wider than the item views
    
    return MAX_COVER_FLOW_FRAME_WIDTH * 1.05f;
}

- (CGFloat)carousel:(iCarousel *)carousel itemAlphaForOffset:(CGFloat)offset
{
	//set opacity based on distance from camera
    return 1.0f - fminf(fmaxf(offset, 0.0f), 1.0f);
}

- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * ((iCarousel *)self.wallView).itemWidth);
}

- (BOOL)carouselShouldWrap:(iCarousel *)carousel
{
    return YES;
}

- (IBAction)clickSetBgImageBtn:(id)sender {
    self.photoCollection = [[[ChangeAvatar alloc] init] autorelease];
    [self.photoCollection setAutoRoundRect:NO];
    [self.photoCollection setImageSize:CGSizeMake(320, 480)];
    [_photoCollection showSelectionView:self];
}

@end
