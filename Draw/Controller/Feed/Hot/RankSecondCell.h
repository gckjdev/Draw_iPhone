//
//  RankSecondCell.h
//  Draw
//
//  Created by  on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPTableViewCell.h"

@class HJManagedImageV;
@interface RankSecondCell : PPTableViewCell
{
    
}
@property (retain, nonatomic) IBOutlet HJManagedImageV *secondDrawImage;
@property (retain, nonatomic) IBOutlet HJManagedImageV *thirdDrawImage;
@property (retain, nonatomic) IBOutlet UILabel *secondTitle;
@property (retain, nonatomic) IBOutlet UILabel *secondAuthor;
@property (retain, nonatomic) IBOutlet UILabel *thirdTitle;
@property (retain, nonatomic) IBOutlet UILabel *thirdAuthor;

@end
