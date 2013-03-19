//
//  CommonItem.m
//  Draw
//
//  Created by 王 小涛 on 13-3-15.
//
//

#import "CommonItem.h"
#import "ItemType.h"
#import "FlowerItem.h"
#import "BlockArray.h"

@interface CommonItem()

@end

@implementation CommonItem

- (id)init
{
    self = [super init];
    _blockArray = [[BlockArray alloc] init];
    return self;
}

- (void)dealloc
{
    PPRelease(_blockArray);
    [super dealloc];
}


@end
