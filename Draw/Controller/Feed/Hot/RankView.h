//
//  RankView.h
//  Draw
//
//  Created by  on 12-9-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum{
     RankViewTypeFirst = 1,
     RankViewTypeSecond = 2,
     RankViewTypeNormal = 3,
}RankViewType;

@class DrawFeed;
@class HJManagedImageV;
@interface RankView : UIView
{
    
}

@property(nonatomic, assign)id delegate;
@property (retain, nonatomic) IBOutlet UILabel *title;
@property (retain, nonatomic) IBOutlet UILabel *author;
@property (retain, nonatomic) IBOutlet HJManagedImageV *drawImage;

+ (id)createRankView:(id)delegate type:(RankViewType)type;
+ (CGFloat)heightForRankViewType:(RankViewType)type;
+ (CGFloat)widthForRankViewType:(RankViewType)type;
- (void)setViewInfo:(DrawFeed *)feed;
@end
