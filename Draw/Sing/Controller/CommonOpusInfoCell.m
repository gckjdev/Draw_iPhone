//
//  CommonOpusInfoCell.m
//  Draw
//
//  Created by 王 小涛 on 13-6-8.
//
//

#import "CommonOpusInfoCell.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "TimeUtils.h"

@interface CommonOpusInfoCell()

@property (retain, nonatomic) PBOpus *opus;

@end

@implementation CommonOpusInfoCell

- (void)dealloc{
    [_opus release];
    
    [_opusImageButton release];
    [_createTimeLabel release];
    [_targetUserButton release];
    [_opusDescTextView release];
    [super dealloc];
}

+ (CGFloat)getCellHeightWithOpus:(PBOpus *)opus{
    return 0;
}

- (void)setOpusInfo:(PBOpus *)opus{
    
    self.opus = opus;
    
    // set opus image.
    NSURL *thumbUrl =[NSURL URLWithString:opus.thumbImage];
    NSURL *url = [NSURL URLWithString:opus.image];
    
    __block typeof(self) bself  = self;

    UIImage *defaultImage = nil;
    
    UIImageView *thumbImageView = nil;
    if (thumbUrl != nil) {
        thumbImageView = [[[UIImageView alloc] initWithFrame:self.opusImageButton.bounds] autorelease];
        thumbImageView.userInteractionEnabled = NO;
        [self.opusImageButton addSubview:thumbImageView];
        [thumbImageView setImageWithURL:thumbUrl placeholderImage:defaultImage];
    }

    if (url != nil) {
        [self.opusImageButton setImageWithURL:url placeholderImage:defaultImage success:^(UIImage *image, BOOL cached) {
            [thumbImageView removeFromSuperview];
        } failure:^(NSError *error) {
            [thumbImageView removeFromSuperview];
        }];
    }
    
    [self.opusImageButton addTarget:self action:@selector(clickOpusImageButton:) forControlEvents:UIControlEventTouchUpInside];
    
    // set opus create time.
    NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:opus.createDate];
    self.createTimeLabel.text = dateToTimeLineString(createDate);
    
    // set target user.
    if (opus.targetUser == nil) {
        [self.targetUserButton removeFromSuperview];
    }else{
        NSString *drawTo = [NSString stringWithFormat:NSLS(@"kDrawToUserByUser"), opus.targetUser.nickName];
        [self.targetUserButton setTitle:drawTo forState:UIControlStateNormal];
        [self.targetUserButton addTarget:self action:@selector(clickTargetUserButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if ([opus.desc length] <= 0){
        [self.opusDescTextView removeFromSuperview];
    }else{
        self.opusDescTextView.editable = NO;
        self.opusDescTextView.text = opus.desc;
    }
}

- (void)clickOpusImageButton:(id)sender{
    
    if ([delegate respondsToSelector:@selector(didClickOpusImageButton:)]) {
        [delegate didClickOpusImageButton:_opus];
    }
}

- (void)clickTargetUserButton:(id)sender{
    
    if ([delegate respondsToSelector:@selector(didClickTargetUserButton:)]) {
        [delegate didClickTargetUserButton:_opus.targetUser];
    }
}

@end
