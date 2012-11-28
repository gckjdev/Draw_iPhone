//
//  BBSBoardCell.h
//  Draw
//
//  Created by gamy on 12-11-15.
//
//

#import "PPTableViewCell.h"


@class PBBBSBoard;

@interface BBSBoardCell : PPTableViewCell


@property(nonatomic, assign)id delegate;

@property (retain, nonatomic) IBOutlet UIImageView *icon;
@property (retain, nonatomic) IBOutlet UILabel *name;
@property (retain, nonatomic) IBOutlet UILabel *statistic;
@property (retain, nonatomic) IBOutlet UILabel *lastPost;
@property (retain, nonatomic) IBOutlet UILabel *author;
@property (retain, nonatomic) IBOutlet UILabel *timestamp;
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UIImageView *splitLine;

+ (BBSBoardCell *)createCell:(id)delegate;

+ (CGFloat)getCellHeightLastBoard:(BOOL)isLastBoard;

- (void)updateCellWithBoard:(PBBBSBoard *)board
                isLastBoard:(BOOL)isLastBoard;

@end
