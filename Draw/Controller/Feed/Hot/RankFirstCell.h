//
//  RankFirstCell.h
//  Draw
//
//  Created by  on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPTableViewCell.h"

@class HJManagedImageV;
@class DrawFeed;
@interface RankFirstCell : PPTableViewCell
{
    DrawFeed *_feed;
}

@property (retain, nonatomic) IBOutlet HJManagedImageV *drawImage;
@property (retain, nonatomic) IBOutlet UILabel *drawTitle;
@property (retain, nonatomic) IBOutlet UILabel *drawAutor;
@property (retain, nonatomic) DrawFeed *feed;

- (void)setCellInfo:(DrawFeed *)feed;

@end
