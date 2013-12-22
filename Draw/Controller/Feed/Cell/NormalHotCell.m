//
//  NormalHotCell.m
//  Draw
//
//  Created by 王 小涛 on 13-12-21.
//
//

#import "NormalHotCell.h"
#import "RankView.h"

@interface NormalHotCell()
@property (retain, nonatomic) IBOutlet UIView *holderView1;
@property (retain, nonatomic) IBOutlet UIView *holderView2;
@property (retain, nonatomic) IBOutlet UIView *holderView3;

@property (retain, nonatomic) RankView *view1;
@property (retain, nonatomic) RankView *view2;
@property (retain, nonatomic) RankView *view3;


@end

@implementation NormalHotCell

- (void)dealloc {
    
    [_holderView1 release];
    [_holderView2 release];
    [_holderView3 release];

    [_view1 release];
    [_view2 release];
    [_view3 release];
    
    [super dealloc];
}


+ (id)createOneRankCell:(id)delegate{
    
    NSArray *cells = [self getCellViewsWithNibName:@"NormalHotCell"];
    NormalHotCell *cell = [cells objectAtIndex:0];
    cell.delegate = delegate;

    cell.holderView1.backgroundColor = [UIColor clearColor];

    cell.view1 = [RankView createRankView:delegate type:RankViewTypeFirst];

    [cell.holderView1 addSubview:cell.view1];
    
    return cell;
}

+ (id)createTwoRankCell:(id)delegate{
    
    NSArray *cells = [self getCellViewsWithNibName:@"NormalHotCell"];
    NormalHotCell *cell = [cells objectAtIndex:1];
    cell.delegate = delegate;
    
    cell.holderView1.backgroundColor = [UIColor clearColor];
    cell.holderView2.backgroundColor = [UIColor clearColor];

    cell.view1 = [RankView createRankView:delegate type:RankViewTypeSecond];
    cell.view2 = [RankView createRankView:delegate type:RankViewTypeSecond];

    [cell.holderView1 addSubview:cell.view1];
    [cell.holderView2 addSubview:cell.view2];

    return cell;
}

+ (id)createThreeRankCell:(id)delegate{
    
    NSArray *cells = [self getCellViewsWithNibName:@"NormalHotCell"];
    NormalHotCell *cell = [cells objectAtIndex:2];
    cell.delegate = delegate;

    cell.holderView1.backgroundColor = [UIColor clearColor];
    cell.holderView2.backgroundColor = [UIColor clearColor];
    cell.holderView3.backgroundColor = [UIColor clearColor];

    cell.view1 = [RankView createRankView:delegate type:RankViewTypeNormal];
    cell.view2 = [RankView createRankView:delegate type:RankViewTypeNormal];
    cell.view3 = [RankView createRankView:delegate type:RankViewTypeNormal];

    [cell.holderView1 addSubview:cell.view1];
    [cell.holderView2 addSubview:cell.view2];
    [cell.holderView3 addSubview:cell.view3];

    return cell;
}

+ (NSString *)getOneRankCellIdentifier{
    
    return @"NormalHotCellOneRank";
}

+ (NSString *)getTwoRankCellIdentifier{
    
    return @"NormalHotCellTwoRank";
}

+ (NSString *)getThreeRankCellIdentifier{

    return @"NormalHotCellThreeRank";
}

+ (float)getOneRankCellHeight{
       
    return [RankView heightForRankViewType:RankViewTypeFirst] + 1;
}

+ (float)getTwoRankCellHeight{
    
    return [RankView heightForRankViewType:RankViewTypeSecond] + 1;
}

+ (float)getThreeRankCellHeight{
    
    return [RankView heightForRankViewType:RankViewTypeNormal] + 1;
}

- (void)setCellInfo:(NSArray *)feeds{
    
    if ([feeds count] <= 0) {
        
        self.holderView1.hidden = YES;
        self.holderView2.hidden = YES;
        self.holderView3.hidden = YES;
    }else if ([feeds count] == 1){
        
        DrawFeed *feed1 = [feeds objectAtIndex:0];
        [self.view1 setViewInfo:feed1];
        [self.view1 updateViewInfoForContestOpus:feed1];
        
        self.holderView1.hidden = NO;
        self.holderView2.hidden = YES;
        self.holderView3.hidden = YES;
    }else if ([feeds count] == 2){
        
        DrawFeed *feed1 = [feeds objectAtIndex:0];
        DrawFeed *feed2 = [feeds objectAtIndex:1];
        [self.view1 setViewInfo:feed1];
        [self.view2 setViewInfo:feed2];
        
        [self.view1 updateViewInfoForContestOpus:feed1];
        [self.view2 updateViewInfoForContestOpus:feed2];
        
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
        
        [self.view1 updateViewInfoForContestOpus:feed1];
        [self.view2 updateViewInfoForContestOpus:feed2];
        [self.view3 updateViewInfoForContestOpus:feed3];
        
        self.holderView1.hidden = NO;
        self.holderView2.hidden = NO;
        self.holderView3.hidden = NO;
    }
}



@end
