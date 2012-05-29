//
//  ShowRemoteDrawController.m
//  Draw
//
//  Created by haodong qiu on 12年5月17日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "ShowRemoteDrawController.h"
#import "GameBasic.pb.h"
#import "DrawAction.h"
#import "ShowDrawView.h"
#import "DrawUtils.h"
#import "HJManagedImageV.h"
#import "ShareImageManager.h"
#import "PPApplication.h"

@interface ShowRemoteDrawController ()

@end

@implementation ShowRemoteDrawController
@synthesize draw;
@synthesize titleLabel;
@synthesize wordLabel;
@synthesize holderView;
@synthesize avatarImage;


- (void)dealloc
{
    [draw release];
    [titleLabel release];
    [wordLabel release];
    [holderView release];
    [avatarImage release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithPBDraw:(PBDraw *)pbDraw;
{
    self = [super init];
    if (self) {
        self.draw = pbDraw;
    }
    return self;
}


//#define IPAD_WIDTH_SCALE 2.4
//#define IPAD_HEIGHT_SCALE 2.18
//#define DRAW_VEIW_FRAME_IPAD CGRectMake(18, 106, 304 * IPAD_WIDTH_SCALE, 320 * IPAD_HEIGHT_SCALE)
//#define DRAW_VEIW_FRAME_IPHONE CGRectMake(8, 46, 304, 320)

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = NSLS(@"kLookOverDraw");
    NSString *drewString = NSLS(@"kPainted");
    self.wordLabel.text = [NSString stringWithFormat:@"%@%@[%@]", draw.nickName, drewString, draw.word];
    
    
    ShowDrawView *showDrawView = [[ShowDrawView alloc] init];
    showDrawView.frame = DRAW_VEIW_FRAME;
    CGFloat multiple = self.holderView.frame.size.width / showDrawView.frame.size.width;
    showDrawView.center = CGPointMake(self.holderView.frame.size.width/2, self.holderView.frame.size.height/2);
    //self.holderView.center;
    //frame的缩放
    showDrawView.transform = CGAffineTransformMakeScale(multiple, multiple);
    
    
    NSMutableArray *drawActionList = [[NSMutableArray alloc] init];
    for (PBDrawAction *pbDrawAction in draw.drawDataList) {
        DrawAction *drawAction = [[DrawAction alloc] initWithPBDrawAction:pbDrawAction];
        [drawActionList addObject:drawAction];
        [drawAction release];
    }
    //画笔的缩放
    NSMutableArray *scaleActionList = nil;
    if ([DeviceDetection isIPAD]) {
        scaleActionList = [DrawAction scaleActionList:drawActionList 
                                               xScale:IPAD_WIDTH_SCALE 
                                               yScale:IPAD_HEIGHT_SCALE];
    } else {
        scaleActionList = drawActionList;
    }
    [showDrawView setDrawActionList:scaleActionList];
    [drawActionList release];
    
    
    [self.holderView addSubview:showDrawView];
    showDrawView.playSpeed = 2/40.0;
    [showDrawView play];
    [showDrawView release];
    
    
    //set avatar
    [avatarImage becomeFirstResponder];
    [avatarImage setImage:[[ShareImageManager defaultManager] femaleDefaultAvatarImage]];
    if ([draw.avatar length] > 0) {
        [avatarImage setUrl:[NSURL URLWithString:draw.avatar]];
        [GlobalGetImageCache() manage:avatarImage];
    }
}


- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setWordLabel:nil];
    [self setHolderView:nil];
    [self setAvatarImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.draw = nil;
}


- (IBAction)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
