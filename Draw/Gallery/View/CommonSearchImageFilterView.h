//
//  CommonSearchImageFilterView.h
//  Draw
//
//  Created by Kira on 13-6-5.
//
//

#import <UIKit/UIKit.h>
#import "CommonInfoView.h"

@protocol CommonSearchImageFilterViewDelegate <NSObject>

- (void)didConfirmFilter:(NSDictionary*)filter;

@end

@interface CommonSearchImageFilterView : CommonInfoView

- (IBAction)clickFilterBtn:(id)sender;
- (IBAction)clickConfirmBtn:(id)sender;

+ (CommonSearchImageFilterView*)createViewWithFilter:(NSMutableDictionary*)filter
                                            delegate:(id<CommonSearchImageFilterViewDelegate>)delegate;
@property (retain, nonatomic) IBOutlet UIButton *confirmBtn;
@property (retain, nonatomic) IBOutlet UIButton *cancelBtn;

@end
