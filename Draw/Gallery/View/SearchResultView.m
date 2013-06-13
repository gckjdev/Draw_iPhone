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
@property (retain, nonatomic) UIControl* control;

@end

@implementation SearchResultView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0,0,frame.size.width, frame.size.height)] autorelease];
        self.control = [[[UIControl alloc] initWithFrame:CGRectMake(0,0,frame.size.width, frame.size.height)] autorelease];
        [self.control setBackgroundColor:[UIColor clearColor]];
        [self.control addTarget:self action:@selector(didClickImage:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_imageView];
        [self addSubview:_control];
    }
    return self;
}

- (void)updateWithResult:(ImageSearchResult*)result
{
    self.searchResult = result;
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
    [_control release];
    [_searchResult release];
    [super dealloc];
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
