//
//  ImageBoardView.m
//  Draw
//
//  Created by  on 12-8-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ImageBoardView.h"
#import "HJManagedImageV.h"
#import "PPApplication.h"

@interface ImageBoardView()
{
    HJManagedImageV *_imageView;
}
- (void)initImageView;
@end

@implementation ImageBoardView



- (id)initWithBoard:(Board *)board
{
    self = [super initWithBoard:board];;
    if (self) {
        [self initImageView];
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_imageView);
    [super dealloc];
}


#pragma mark - Guesture Recognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return touch.view == _imageView;
}

- (void)didTapImageView:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded) {
        //respons to the delegate
        PPDebug(@"did tap the image, url = %@", [(ImageBoard *)self.board clickUrl]);
    }
}

- (void)initImageView
{
    _imageView = [[HJManagedImageV alloc] initWithFrame:self.bounds];
    [self addSubview:_imageView];
    _imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap setDelegate:self];
    [tap addTarget:self action:@selector(didTapImageView:)];
    [_imageView addGestureRecognizer:tap];
    [tap release];
}


- (void)loadView
{
    [_imageView clear];
    if ([self.board isKindOfClass:[ImageBoard class]]) {
        ImageBoard *board = (ImageBoard *)self.board;
        NSString *imageUrl = board.imageUrl;
        PPDebug(@"<ImageBoard> load view, image url = %@", imageUrl);
        [_imageView setUrl:[NSURL URLWithString:imageUrl]];        
    }
    
    [GlobalGetImageCache() manage:_imageView];
}



@end
