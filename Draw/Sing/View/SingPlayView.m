//
//  SingPlayView.m
//  Draw
//
//  Created by 王 小涛 on 13-10-26.
//
//

#import "SingPlayView.h"
#import "AutoCreateViewByXib.h"
#import "AudioStreamer.h"
#import "UIImageView+WebCache.h"

@interface SingPlayView()

@property (retain, nonatomic) DrawFeed *feed;
@property (retain, nonatomic) AudioStreamer *player;
@end

@implementation SingPlayView

AUTO_CREATE_VIEW_BY_XIB(SingPlayView);

- (void)dealloc{
    
    [_feed release];
    [_player release];
    [_imageView release];
    [super dealloc];
}

+ (id)createWithOpus:(DrawFeed *)feed{
    
    SingPlayView *v = [self createView];
    v.feed = feed;
    NSURL *url = [NSURL URLWithString:feed.drawDataUrl];
    v.player = [[[AudioStreamer alloc] initWithURL:url] autorelease];
    
    return v;
}

- (void)showInView:(UIView *)view{
    
    NSURL *url = [NSURL URLWithString:self.feed.drawImageUrl];
    [self.imageView setImageWithURL:url];
    
    [self.player start];
    
    [view addSubview:self];
}

- (IBAction)clickCloseButton:(id)sender {
    
    [_player stop];
    [self removeFromSuperview];
}

- (IBAction)clickPlayButton:(id)sender {
}

@end
