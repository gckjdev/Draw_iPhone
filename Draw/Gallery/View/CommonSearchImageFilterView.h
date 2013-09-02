//
//  CommonSearchImageFilterView.h
//  Draw
//
//  Created by Kira on 13-6-5.
//
//

#import <UIKit/UIKit.h>
#import "CommonInfoView.h"

@interface CommonSearchImageFilterView : UIView

+ (CommonSearchImageFilterView*)createViewWithFilter:(NSMutableDictionary*)filter;

@property (retain, nonatomic) NSMutableDictionary* filter;

@end
