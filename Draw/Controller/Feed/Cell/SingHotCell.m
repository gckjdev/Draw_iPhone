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
@property (retain, nonatomic) RankView *view3;

@end

@implementation SingHotCell

- (void)dealloc {
    [_view1 release];
    [_view2 release];
    [_view3 release];
    [_holderView1 release];
    [_holderView2 release];
    [_holderView3 release];
    [super dealloc];
}

+ (id)createCell:(id)delegate{
    
    SingHotCell *cell = [super createCell:delegate];
    
    cell.holderView1.backgroundColor = [UIColor clearColor];
    cell.holderView2.backgroundColor = [UIColor clearColor];
    cell.holderView3.backgroundColor = [UIColor clearColor];

    cell.view1 = [RankView createRankView:delegate type:RankViewTypeWhisper];
    cell.view2 = [RankView createRankView:delegate type:RankViewTypeWhisper];
    cell.view3 = [RankView createRankView:delegate type:RankViewTypeWhisper];

    [cell.holderView1 addSubview:cell.view1];
    [cell.holderView2 addSubview:cell.view2];
    [cell.holderView3 addSubview:cell.view3];

    return cell;
}

+ (NSString *)getCellIdentifier{
    
    return @"SingHotCell";
}

+ (CGFloat)getCellHeight{
    
    return ISIPAD ? 256 : 159;
}

- (void)setCellInfo:(NSArray *)feeds{
    
    if ([feeds count] <= 0) {
        return;
    }else if ([feeds count] == 1){
        
        DrawFeed *feed1 = [feeds objectAtIndex:0];
        [self.view1 setViewInfo:feed1];

        self.holderView1.hidden = NO;
        self.holderView2.hidden = YES;
        self.holderView3.hidden = YES;
    }else if ([feeds count] == 2){
        
        DrawFeed *feed1 = [feeds objectAtIndex:0];
        DrawFeed *feed2 = [feeds objectAtIndex:1];
        [self.view1 setViewInfo:feed1];
        [self.view2 setViewInfo:feed2];

        self.holderView1.hidden = NO;
        self.holderView2.hidden = NO;
        self.holderView3.hidden = YES;
    }else if ([feeds count] == 3){
        
        DrawFeed *feed1 = [feeds objectAtIndex:0];
        DrawFeed *feed2 = [feeds objectAtIndex:1];
        DrawFeed *feed3 = [feeds objectAtIndex:2];
        [self.view1 setViewInfo:feed1];
        [self.view2 setViewInfo:feed2];
        [self.view3 setViewInfo:feed3];
        
        self.holderView1.hidden = NO;
        self.holderView2.hidden = NO;
        self.holderView3.hidden = NO;
    }
}

@end
