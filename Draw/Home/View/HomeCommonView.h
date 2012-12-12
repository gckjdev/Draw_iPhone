//
//  HomeCommonView.h
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import <UIKit/UIKit.h>

//#define ISIPAD [DeviceDetection isIPAD]

@protocol HomeCommonViewDelegate <NSObject>

@end

@protocol HomeCommonViewProtocol <NSObject>

+ (id)createView:(id<HomeCommonViewDelegate>)delegate;
+ (NSString *)getViewIdentifier;
- (void)updateView;
@end


@interface HomeCommonView : UIView
{
    
}
@property(nonatomic, assign)id delegate;


@end
