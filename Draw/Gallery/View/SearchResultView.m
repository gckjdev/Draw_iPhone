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
    [self.imageView setImageWithURL:[NSURL URLWithString:result.url]];
}
- (void)updateWithUrl:(NSString*)url
{
    [self.imageView setImageWithURL:[NSURL URLWithString:url]];
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
