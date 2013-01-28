//
//  OpusWallController.m
//  Draw
//
//  Created by 王 小涛 on 13-1-25.
//
//

#import "OpusWallController.h"
#import "UIImageView+WebCache.h"

@interface OpusWallController ()

@property (retain, nonatomic) PBWall_Builder *wallBuilder;
@property (retain, nonatomic) UIView *wallView;

@end

@implementation OpusWallController

- (void)dealloc
{
    [_wallBuilder release];
    [_wallView release];
    [_backButton release];
    [super dealloc];
}


- (id)initWithWall:(PBWall *)wall
{
    if (self = [super init]) {
        self.wallBuilder = [PBWall builderWithPrototype:wall];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = _wallBuilder.wallName;
    
    [self setNavigationLeftButton:@"返回" action:@selector(clickBack:)];
    
    [self addWallView];
}

- (void)addWallView
{
    PBRect *pbRect = [DeviceDetection isIPAD] ? _wallBuilder.layout.iPadRect : _wallBuilder.layout.iPhoneRect;
    CGRect rect = CGRectMake(pbRect.x, pbRect.y, pbRect.width, pbRect.height);
    self.wallView  = [[[UIView alloc] initWithFrame:rect] autorelease];
    [self.view addSubview:self.wallView];
    
    for (PBFrame *frame in _wallBuilder.layout.framesList) {
        [self.wallView addSubview:[self frameBtn:frame]];
    }

    [self.view bringSubviewToFront:self.backButton];
}

- (PBWallOpus *)wallOpusWithFrameId:(int)frameId
{
    for (PBWallOpus *wallOpus in _wallBuilder.opusesList) {
        if (wallOpus.frameId == frameId) {
            return wallOpus;
        }
    }
    
    return nil;
}


- (PBWallOpus *)wallOpusWithOpusId:(NSString *)opusId
{
    for (PBWallOpus *wallOpus in _wallBuilder.opusesList) {
        if ([wallOpus.opus.feedId isEqualToString:opusId]) {
            return wallOpus;
        }
    }
    
    return nil;
}

- (UIImageView *)opusImageView:(PBFrame *)frame
{
    PBRect *pbOpusRect = [DeviceDetection isIPAD] ? frame.opusIpadRect : frame.opusIphoneRect;
    CGRect opusRect = CGRectMake(pbOpusRect.x, pbOpusRect.y, pbOpusRect.width, pbOpusRect.height);
    UIImageView *opusImageView = [[[UIImageView alloc] initWithFrame:opusRect] autorelease];
    
    PBWallOpus *wallOpus = [self wallOpusWithFrameId:frame.frameId];
    [opusImageView setImageWithURL:[NSURL URLWithString:wallOpus.opus.opusImage]];
    
    return opusImageView;
}

- (UIButton *)frameBtn:(PBFrame *)frame
{
    PBRect *pbRect = [DeviceDetection isIPAD] ? frame.iPadRect : frame.iPhoneRect;
    CGRect rect = CGRectMake(pbRect.x, pbRect.y, pbRect.width, pbRect.height);
    UIButton *button = [[[UIButton alloc] initWithFrame:rect] autorelease];
    [button setImage:[UIImage imageNamed:frame.image] forState:UIControlStateNormal];
    button.tag = frame.frameId;
    
    [button addTarget:self action:@selector(clickFrame:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)clickFrame:(id)sender
{
    UIButton *button = (UIButton *)sender;
    PPDebug(@"click frame: %d, opus:%@", button.tag, [self wallOpusWithFrameId:button.tag].opus.opusImage);
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
    [super viewDidUnload];
}
@end
