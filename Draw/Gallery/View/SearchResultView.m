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

@interface SearchResultView ()

@property (retain, nonatomic) UIImageView* imageView;

@end

@implementation SearchResultView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0,0,frame.size.width, frame.size.height)] autorelease];
        [self.imageView setAutoresizingMask:!UIViewAutoresizingNone];
        [self addSubview:_imageView];
    }
    return self;
}

- (void)updateWithResult:(ImageSearchResult*)result
{
    self.searchResult = result;
    NSMutableDictionary* dict = [[[NSMutableDictionary alloc] init] autorelease];
    [dict setObject:[NSNumber numberWithFloat:result.width] forKey:@"width"];
    [dict setObject:[NSNumber numberWithFloat:result.height] forKey:@"height"];
    self.object = dict;
    
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
    [self setBackgroundColor:[UIColor blackColor]];
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
+ (CGFloat)heightForViewWithObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    CGFloat height = 0.0;
    CGFloat width = columnWidth - MARGIN * 2;
    
    height += MARGIN;
    
    // Image
    CGFloat objectWidth = [[object objectForKey:@"width"] floatValue];
    CGFloat objectHeight = [[object objectForKey:@"height"] floatValue];
    CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
    height += scaledHeight;
    
    // Label
    NSString *caption = [object objectForKey:@"title"];
    CGSize labelSize = CGSizeZero;
    UIFont *labelFont = [UIFont boldSystemFontOfSize:14.0];
    labelSize = [caption sizeWithFont:labelFont constrainedToSize:CGSizeMake(width, INT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    height += labelSize.height;
    
    height += MARGIN;
    
    return height;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
//    self.captionLabel.text = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
