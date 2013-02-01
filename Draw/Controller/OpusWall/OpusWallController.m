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

@interface OpusWallController ()

@property (assign, nonatomic) int wallOpusOrder;
@property (retain, nonatomic) Wall *wall;
@property (retain, nonatomic) UIView *wallView;
@property (retain, nonatomic) ChangeAvatar *photoCollection;

@end

@implementation OpusWallController

- (void)dealloc
{
    [_wall release];
    [_wallView release];
    [_backButton release];
    [_setLayoutButton release];
    [_submitButton release];
    [_bgImageView release];
    [_photoCollection release];
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
    self.wallView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [self.view addSubview:self.wallView];

    [self updateWallView];
}

- (void)updateWallView
{
    self.title = _wall.pbWall.wallName;

    if ([_wall bgImage] == nil) {
        [self.bgImageView setImageWithURL:[NSURL URLWithString:_wall.pbWall.layout.bgImage]];
    }else{
        [self.bgImageView setImage:[_wall bgImage]];
    }
    
    PBRect *pbRect = [DeviceDetection isIPAD] ? _wall.pbWall.layout.iPadRect : _wall.pbWall.layout.iPhoneRect;
    CGRect rect = CGRectMake(pbRect.x, pbRect.y, pbRect.width, pbRect.height);
    self.wallView.frame = rect;
    
    [self updateWallOpuses];
}

- (void)updateWallOpuses
{
    for (UIView *view in [self.wallView subviews]) {
        [view removeFromSuperview];
    }
    
    for (WallOpus *wallOpus in [_wall wallOpuses]) {
        [self.wallView addSubview:[self wallOpusBtn:wallOpus]];
    }
    

    [self.view bringSubviewToFront:self.backButton];
    [self.view bringSubviewToFront:self.setLayoutButton];
    [self.view bringSubviewToFront:self.submitButton];

}



- (UIButton *)wallOpusBtn:(WallOpus *)wallOpus
{
    PBFrame *frame = [_wall frameWithFrameIdOnWall:wallOpus.frameIdOnWall];
    PBRect *pbRect = [DeviceDetection isIPAD] ? frame.iPadRect : frame.iPhoneRect;
    CGRect rect = CGRectMake(pbRect.x, pbRect.y, pbRect.width, pbRect.height);
    UIButton *button = [[[UIButton alloc] initWithFrame:rect] autorelease];
    UIImage *image = [UIImage imageWithContentsOfFile:[[[FrameManager sharedFrameManager] frameWithFrameId:frame.frameId] image]];
    [button setImage:image forState:UIControlStateNormal];
    button.tag = wallOpus.frameIdOnWall;
    
    [button addTarget:self action:@selector(clickWallOpus:) forControlEvents:UIControlEventTouchUpInside];
    
    
    PBRect *pbOpusRect = [DeviceDetection isIPAD] ? frame.opusIpadRect : frame.opusIphoneRect;
    CGRect opusRect = CGRectMake(pbOpusRect.x, pbOpusRect.y, pbOpusRect.width, pbOpusRect.height);
    UIImageView *opusImageView = [[[UIImageView alloc] initWithFrame:opusRect] autorelease];
    [opusImageView setImageWithURL:[NSURL URLWithString:[wallOpus opus].drawImageUrl]];
    
    [button addSubview:opusImageView];
    
    return button;
}

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
    [super viewDidUnload];
}

- (IBAction)clickSetLayoutButton:(id)sender {
//    [_wall setLayout:[ProtocolUtil createTestData1]];
//    [self updateWallView];
    
    self.photoCollection = [[[ChangeAvatar alloc] init] autorelease];
    [self.photoCollection setAutoRoundRect:NO];
    [self.photoCollection setImageSize:CGSizeMake(320, 480)];
    [_photoCollection showSelectionView:self];
}

- (void)didImageSelected:(UIImage*)image
{
    [_wall setBgImage:image];
    [self updateWallView];
}

- (IBAction)clickSubmitButton:(id)sender {
    [[WallService sharedWallService] createWall:[_wall toPBWall] bgImage:[_wall bgImage] delegate:self];
}

- (void)didCreateWall:(int)resultCode wall:(PBWall *)wall
{
    PPDebug(@"didCreateWall: %d", resultCode);
    PPDebug(@"wallId: %@", wall.wallId);
    [_wall setWallId:wall.wallId];
}

@end
