//
//  UserPhotoView.m
//  Draw
//
//  Created by Kira on 13-6-7.
//
//

#import "UserPhotoView.h"
#import "AutoCreateViewByXib.h"
#import "Photo.pb.h"
#import "UIImageView+WebCache.h"
#import "TimeUtils.h"
#import "LocaleUtils.h"

@interface UserPhotoView ()

@property (retain, nonatomic) PBUserPhoto* photo;
@property (retain, nonatomic) IBOutlet UIImageView *photoImage;

@end

@implementation UserPhotoView

AUTO_CREATE_VIEW_BY_XIB(UserPhotoView)

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)updateWithUserPhoto:(PBUserPhoto*)photo
{
    if (photo) {
        self.photo = photo;
        [self.nameLabel setText:photo.name];
        [self.photoImage setImageWithURL:[NSURL URLWithString:photo.url]];
        
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:photo.createDate];
//        PPDebug(@"create date = %@", [date description]);
        if ([LocaleUtils isChinese]) {
            [self.createDateLabel setText:chineseBeforeTime(date)];
        } else {
            [self.createDateLabel setText:englishBeforeTime(date)];
        }
    }
    
}

- (void)dealloc {
    [_photo release];
    [_nameLabel release];
    [_createDateLabel release];
    [_photoImage release];
    [super dealloc];
}

- (IBAction)clickPhoto:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(didClickPhoto:)]) {
        [_delegate didClickPhoto:self.photo];
    }
}

+ (UserPhotoView*)createViewWithPhoto:(PBUserPhoto*)photo
                             delegate:(id<UserPhotoViewDelegate>)delegate
{
    UserPhotoView* view = [self createView];
    view.delegate = delegate;
    [view updateWithUserPhoto:photo];
    return view;
}
@end