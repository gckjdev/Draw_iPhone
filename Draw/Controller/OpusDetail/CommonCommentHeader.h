//
//  CommonCommentHeader.h
//  Draw
//
//  Created by 王 小涛 on 13-6-9.
//
//

#import <UIKit/UIKit.h>
#import "PPTableViewHeader.h"
#import "Opus.pb.h"
#import "Feed.h"

//typedef enum{
//    CommentTypeNO = 0,
//    CommentTypeGuess = 2,
//    CommentTypeComment = 3,
//    CommentTypeFlower = 6,
//    CommentTypeTomato = 7,
//    CommentTypeSave = 8,
//}CommentType;

@protocol CommonCommentHeaderDelegate <NSObject>

@optional
- (void)didSelectCommentType:(CommentType)type;

@end


@interface CommonCommentHeader : PPTableViewHeader{
    NSInteger _currentType;
}

- (void)setViewInfo:(PBOpus*)opus;
- (void)updateTimes:(PBOpus *)opus;

- (void)setSeletType:(CommentType)type;
- (CommentType)seletedType;


@end
