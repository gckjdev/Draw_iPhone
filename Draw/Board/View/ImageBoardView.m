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
#import "AdService.h"
#import "BoardService.h"

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
        NSString *url = [(ImageBoard *)self.board clickUrl];
        NSURL *URL = [NSURL URLWithString:url];
        [self handleTap:URL];
        [[BoardService defaultService] updateBoardStatistic:self.board.boardId];
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


//override.
/*
- (void)innerJump:(NSURL *)URL
{
    //open a web view.
}
*/

//override.
- (void)loadView
{
    [_imageView clear];
    if ([self.board isKindOfClass:[ImageBoard class]]) {
        ImageBoard *board = (ImageBoard *)self.board;
        NSString *imageUrl = board.imageUrl;
        
        BOOL isShowAd = NO; //[[AdService defaultService] isShowAd];
        if (isShowAd) {
            if ([LocaleUtils isChinese]) {
                imageUrl = board.cnAdImageUrl;
            }else{
                imageUrl = board.adImageUrl;
            }
        }else{
            if ([LocaleUtils isChinese]) {
                imageUrl = board.cnImageUrl;
            }else{
                imageUrl = board.imageUrl;
            }
        }
//        PPDebug(@"<ImageBoard> load view, image url = %@", imageUrl);
        [_imageView setUrl:[NSURL URLWithString:imageUrl]];
    }
    
    [GlobalGetImageCache() manage:_imageView];
    [super loadView];
}


- (void)viewWillAppear
{
//    PPDebug(@"image board view will appear");
    
    BOOL isShowAd = [[AdService defaultService] isShowAd];
    isShowAd = NO; // set by Benson to disable Ad in board  
    
    if (isShowAd){
        PPDebug(@"image board refresh adview");
        [self clearAllAdView];
        ImageBoard *board = (ImageBoard *)self.board;
        
        if (board.platform == AdPlatformAuto){
            self.adView = [[AdService defaultService]
                       createAdInView:self 
                       frame:CGRectMake(0, 0, 320, 50) 
                       iPadFrame:CGRectMake(30, 40, 320, 50)];                
        }
        else{
            self.adView  = [[AdService defaultService]
                       createAdInView:self 
                       adPlatformType:board.platform 
                       adPublisherId:board.publishId
                       frame:CGRectMake(0, 0, 320, 50) 
                       iPadFrame:CGRectMake(30, 40, 320, 50)];
        }
    }
}

- (void)viewDidDisappear
{
//    [[AdService defaultService] clearAdView:self.adView];
//    PPDebug(@"image board viewDidDisappear, clear all ad view");
    [self clearAllAdView];
}

@end
