//
//  CommonOpusInfoCell.m
//  Draw
//
//  Created by 王 小涛 on 13-6-8.
//
//

#import "CommonOpusInfoCell.h"
#import "UIButton+WebCache.h"
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

//    [[SDWebImageManager sharedManager] downloadWithURL:thumbURL delegate:nil options:SDWebImageCacheMemoryOnly success:^(UIImage *image, BOOL cached) {
//        bself.opus
//    }];
    
    [self.opusImageButton setImageWithURL:url placeholderImage:nil success:^(UIImage *image, BOOL cached) {
//        [bself.opusImageButton setImageWithURL:url placeholderImage:image];
    } failure:^(NSError *error) {
//        [bself.opusImageButton setImageWithURL:url placeholderImage:nil];
    }];
    
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
