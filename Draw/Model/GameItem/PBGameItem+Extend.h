//
//  PBGameItem+Extend.h
//  Draw
//
//  Created by 王 小涛 on 13-3-15.
//
//

#import "GameBasic.pb.h"

@interface PBGameItem (Extend)

- (BOOL)isPromoting;
- (int)promotionPrice;
- (int)discount;

@end
