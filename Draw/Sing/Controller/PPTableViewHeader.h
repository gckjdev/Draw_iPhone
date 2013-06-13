//
//  PPTableViewHeader.h
//  Draw
//
//  Created by 王 小涛 on 13-6-9.
//
//

#import <UIKit/UIKit.h>

@interface PPTableViewHeader : UIView{
    id _delegate;
    NSIndexPath *_indexPath;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSIndexPath *indexPath;

+ (id)createHeader:(id)delegate;
+ (NSString*)getHeaderIdentifier;
+ (CGFloat)getHeaderHeight;

@end
