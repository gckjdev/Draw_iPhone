//
//  IconView.m
//  Draw
//
//  Created by Gamy on 13-11-13.
//
//

#import "IconView.h"
#import "UIImageView+WebCache.h"
#import "GroupTopicController.h"
#import "ImagePlayer.h"


@interface IconView()
@property(nonatomic, retain)UIImageView *imageView;

@property(nonatomic, retain)NSString *viewId;
@property(nonatomic, retain)NSURL *imgURL;

@end

@implementation IconView

- (void)baseInit
{
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.userInteractionEnabled = NO;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_imageView];
    SET_VIEW_ROUND(self);
    [self addTarget:self action:@selector(clickView:) forControlEvents:UIControlEventTouchUpInside];
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)clickView:(id)sender
{
    EXECUTE_BLOCK(self.clickHandler, self);
}

- (void)dealloc
{
    [_viewId release];
    PPRelease(_imgURL);
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
    self.imgURL = imageURL;
    [_imageView setImageWithURL:imageURL];
}

- (void)setImageURL:(NSURL *)imageURL placeholderImage:(UIImage *)image
{
    self.imgURL = imageURL;
    [_imageView setImageWithURL:imageURL placeholderImage:image];
}

- (void)setImageURLString:(NSString *)urlString
{
    self.imgURL = [NSURL URLWithString:urlString];
    [_imageView setImageWithURL:self.imgURL];
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

- (void)clickView:(id)sender
{
    if (self.clickHandler == NULL) {
        if(self.imageURL){
            [[ImagePlayer defaultPlayer] playWithUrl:self.imgURL
                                 displayActionButton:YES
                                    onViewController:[self theViewController]];
        }else{
            [[ImagePlayer defaultPlayer] playWithImage:self.imageView.image onViewController:[self theViewController]];            
        }
    }else{
        [super clickView:sender];
    }
}
@end