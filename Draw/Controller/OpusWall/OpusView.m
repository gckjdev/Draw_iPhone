////
////  OpusView.m
////  Draw
////
////  Created by 王 小涛 on 13-1-30.
////
////
//
//#import "OpusView.h"
//#import "AutoCreateViewByXib.h"
//#import "UIImageView+WebCache.h"
//
//
//@interface OpusView()
//
//@property (retain, nonatomic) DrawFeed *opus;
//
//@end
//
//
//@implementation OpusView
//
//AUTO_CREATE_VIEW_BY_XIB(OpusView);
//
//- (void)dealloc {
//    [_opus release];
//    [_button release];
//    [_imageView release];
//    [super dealloc];
//}
//
//- (void)setDrawFeed:(DrawFeed *)opus
//{
//    self.opus = opus;
//    
//    [self.imageView setImageWithURL:[NSURL URLWithString:opus.drawImageUrl]];
//    
//    [self.button addTarget:self action:@selector(clickOpus:) forControlEvents:UIControlEventTouchUpInside];
//}
//
//- (void)clickOpus:(id)sender
//{
//    if ([_delegate respondsToSelector:@selector(didClickOpus:)]) {
//        [_delegate didClickOpus:_opus];
//    }
//}
//
//@end
