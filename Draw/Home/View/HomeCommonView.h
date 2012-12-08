//
//  HomeCommonView.h
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import <UIKit/UIKit.h>

@protocol HomeCommonViewProtocol <NSObject>

+ (id)createView:(id)delegate;
+ (NSString *)getViewIdentifier;
- (void)updateView;
@end

@interface HomeCommonView : UIView
{
    
}
@property(nonatomic, assign)id delegate;


@end
