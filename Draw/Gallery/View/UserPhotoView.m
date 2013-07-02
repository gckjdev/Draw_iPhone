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
#import "ShareImageManager.h"

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
    UIImage *defaultImage = nil;
    defaultImage = [[ShareImageManager defaultManager] unloadBg];
    if (photo) {
        self.photo = photo;
        [self.nameLabel setText:photo.name];
        [self.photoImage setImageWithURL:[NSURL URLWithString:photo.url]
                       placeholderImage:defaultImage
                                success:^(UIImage *image, BOOL cached) {
                                    if (!cached) {
                                        self.photoImage.alpha = 0;
                                    }
                                    
                                    [UIView animateWithDuration:1 animations:^{
                                        self.photoImage.alpha = 1.0;
                                    }];
                                    //            feed.largeImage = image;
                                    [self.photoImage setImage:image];
                                } failure:^(NSError *error) {
                                    self.photoImage.alpha = 1;
                                }];
        
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:photo.createDate];
//        PPDebug(@"create date = %@", [date description]);
        if ([LocaleUtils isChinese]) {
            [self.createDateLabel setText:chineseBeforeTime(date)];
        } else {
            [self.createDateLabel setText:englishBeforeTime(date)];
        }
        
//        NSMutableDictionary* dict = [[[NSMutableDictionary alloc] init] autorelease];
//        [dict setObject:[NSNumber numberWithFloat:photo.width] forKey:@"width"];
//        [dict setObject:[NSNumber numberWithFloat:photo.height] forKey:@"height"];
//        self.object = dict;
    }
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.photoImage.image = nil;
    //    self.captionLabel.text = nil;
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

#define BLANK_WIDTH     8
#define BLANK_HEIGHT    (ISIPAD?32:18)
+ (CGFloat)heightForViewWithPhotoWidth:(float)photoWidth
                                height:(float)photoHeight
                         inColumnWidth:(CGFloat)columnWidth {
    CGFloat height = 0.0;
    CGFloat width = columnWidth - BLANK_WIDTH * 2;

    
    // Image
    CGFloat scaledHeight = floorf(photoHeight / (photoWidth / width));
    height += scaledHeight;
    
    return height + BLANK_HEIGHT;
}

@end
