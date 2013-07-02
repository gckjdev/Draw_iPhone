//
//  SearchResultView.m
//  Draw
//
//  Created by Kira on 13-6-5.
//
//

#import "SearchResultView.h"
#import "UIImageView+WebCache.h"
#import "ImageSearchResult.h"
#import "ShareImageManager.h"
#import "UIColor+UIColorExt.h"

@interface SearchResultView ()

@property (retain, nonatomic) UIImageView* imageView;

@end

@implementation SearchResultView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0,0,frame.size.width, frame.size.height)] autorelease];
        [self addSubview:_imageView];
    }
    return self;
}

- (void)resizeSubviews
{
    self.imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)updateWithResult:(ImageSearchResult*)result
{
    self.searchResult = result;
//    NSMutableDictionary* dict = [[[NSMutableDictionary alloc] init] autorelease];
//    [dict setObject:[NSNumber numberWithFloat:result.width] forKey:@"width"];
//    [dict setObject:[NSNumber numberWithFloat:result.height] forKey:@"height"];
//    self.object = dict;
    
    [self.imageView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self updateWithUrl:result.url];
}

- (void)updateWithUrl:(NSString*)url
{
    UIImage *defaultImage = nil;
    
    //        if(feed.largeImage){
    //            defaultImage = feed.largeImage;
    //        }
    //        else{
    defaultImage = [[ShareImageManager defaultManager] unloadBg];
    //        }
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self setBackgroundColor:OPAQUE_COLOR(231, 231, 231)];
    [self.imageView setImageWithURL:[NSURL URLWithString:url]
                   placeholderImage:defaultImage
                            success:^(UIImage *image, BOOL cached) {
                                if (!cached) {
                                    self.imageView.alpha = 0;
                                }
                                
                                [UIView animateWithDuration:1 animations:^{
                                    self.imageView.alpha = 1.0;
                                }];
                                //            feed.largeImage = image;
                                [self.imageView setImage:image];
                            } failure:^(NSError *error) {
                                self.imageView.alpha = 1;
                            }];
}


- (void)didClickImage:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(didClickSearchResult:)]) {
        [_delegate didClickSearchResult:self.searchResult];
    }
}

- (void)dealloc
{
    [_imageView release];
    [_searchResult release];
    [super dealloc];
}
#define MARGIN 0.0
+ (CGFloat)heightForViewWithPhotoWidth:(float)photoWidth
                                height:(float)photoHeight
                         inColumnWidth:(CGFloat)columnWidth {
    CGFloat height = 0.0;
    CGFloat width = columnWidth - MARGIN * 2;
    
    height += MARGIN;
    
    // Image
    CGFloat scaledHeight = floorf(photoHeight / (photoWidth / width));
    height += scaledHeight;
    
    height += MARGIN;
    
    return height;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
//    self.captionLabel.text = nil;
}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//    
//    CGFloat width = self.frame.size.width - MARGIN * 2;
//    CGFloat top = MARGIN;
//    CGFloat left = MARGIN;
//    
//    // Image
//    CGFloat objectWidth = [[self.object objectForKey:@"width"] floatValue];
//    CGFloat objectHeight = [[self.object objectForKey:@"height"] floatValue];
//    CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
//    self.imageView.frame = CGRectMake(left, top, width, scaledHeight);
//    
//    // Label
////    CGSize labelSize = CGSizeZero;
////    labelSize = [self.captionLabel.text sizeWithFont:self.captionLabel.font constrainedToSize:CGSizeMake(width, INT_MAX) lineBreakMode:self.captionLabel.lineBreakMode];
//    top = self.imageView.frame.origin.y + self.imageView.frame.size.height + MARGIN;
//    
////    self.captionLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
