//
//  SingHotCell.m
//  Draw
//
//  Created by 王 小涛 on 13-12-13.
//
//

#import "SingHotCell.h"
#import "RankView.h"

@interface SingHotCell()

@property (retain, nonatomic) RankView *view1;
@property (retain, nonatomic) RankView *view2;

@end

@implementation SingHotCell

- (void)dealloc {
    [_view1 release];
    [_view2 release];
    [_holderView1 release];
    [_holderView2 release];
    [super dealloc];
}

+ (id)createCell:(id)delegate{
    
    SingHotCell *cell = [super createCell:delegate];
    
    cell.holderView1.backgroundColor = [UIColor clearColor];
    cell.holderView2.backgroundColor = [UIColor clearColor];
    
    cell.view1 = [RankView createRankView:delegate type:RankViewTypeWhisper];
    cell.view2 = [RankView createRankView:delegate type:RankViewTypeWhisper];
    
    [cell.holderView1 addSubview:cell.view1];
    [cell.holderView2 addSubview:cell.view2];
    
    return cell;
}

+ (NSString *)getCellIdentifier{
    
    return @"SingHotCell";
}

- (void)setCellInfo:(NSArray *)feeds{
    
    if ([feeds count] < 2) {
        return;
    }
    
    DrawFeed *feed1 = [feeds objectAtIndex:0];
    DrawFeed *feed2 = [feeds objectAtIndex:1];
    
    [self.view1 setViewInfo:feed1];
    [self.view2 setViewInfo:feed2];
}

@end
