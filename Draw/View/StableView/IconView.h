//
//  IconView.h
//  Draw
//
//  Created by Gamy on 13-11-13.
//
//

#import <UIKit/UIKit.h>

@class IconView;

typedef void (^ClickHandler)(IconView *iconView);

@interface IconView : UIControl


@property(nonatomic, copy)ClickHandler clickHandler;

- (void)setImage:(UIImage *)image;
- (void)setImageURL:(NSURL *)imageURL;
- (void)setImageURL:(NSURL *)imageURL placeholderImage:(UIImage *)image;
- (void)setImageURLString:(NSString *)urlString;

@end


@interface GroupIconView : IconView

@property(nonatomic, retain)NSString *groupId;
+ (id)iconViewWithGroupID:(NSString *)groupId
                 imageURL:(NSURL *)url;

@end