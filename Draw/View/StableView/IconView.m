//
//  IconView.m
//  Draw
//
//  Created by Gamy on 13-11-13.
//
//

#import "IconView.h"
#import "UIImageView+WebCache.h"

@interface IconView()
@property(nonatomic, retain)UIImageView *imageView;

@property(nonatomic, retain)NSString *viewId;


@end

@implementation IconView

- (void)baseInit
{
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.userInteractionEnabled = YES;
    [self addSubview:_imageView];
    self.backgroundColor = COLOR_WHITE;
    SET_VIEW_ROUND(self);
    [self addTarget:self action:@selector(clickView:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clickView:(id)sender
{
    EXECUTE_BLOCK(self.clickHandler, self);
}

- (void)dealloc
{
    [_viewId release];
    PPRelease(_imageView);
    RELEASE_BLOCK(_clickHandler);
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self baseInit];
    }
    return self;
}

#define FRAME_SIZE (ISIPAD?68:32)

- (id)initWithID:(NSString *)viewId
        imageURL:(NSURL *)url
{
    self = [super initWithFrame:CGRectMake(0, 0, FRAME_SIZE, FRAME_SIZE)];
    if (self) {
        [self baseInit];
        [self setImageURL:url];
        [self setViewId:viewId];
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    [_imageView setImage:image];
}
- (void)setImageURL:(NSURL *)imageURL
{
    [_imageView setImageWithURL:imageURL];
}


@end


@implementation GroupIconView

- (void)setGroupId:(NSString *)groupId
{
    self.viewId = groupId;
}

- (NSString *)groupId
{
    return self.viewId;
}

+ (id)iconViewWithGroupID:(NSString *)groupId
                 imageURL:(NSURL *)url
{
    GroupIconView *view = [[GroupIconView alloc] initWithID:groupId imageURL:url];
    return [view autorelease];
}


@end