//
//  MoreViewController.h
//  Draw
//
//  Created by ChaoSo on 14-7-14.
//
//

#import <UIKit/UIKit.h>

@interface MoreViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate> 
@property (retain, nonatomic) IBOutlet UICollectionView *collectionView;

+ (NSString*)getItemTitle:(NSUInteger)row;
+ (UIImage*)getItemImage:(NSUInteger)row;
- (void)handleClickItem:(NSUInteger)row;
+ (NSUInteger)totalMoreBadge;
+ (NSUInteger)getItemBadge:(NSUInteger)row;

@end
