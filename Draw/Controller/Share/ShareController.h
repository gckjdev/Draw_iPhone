//
//  ShareController.h
//  Draw
//
//  Created by Orange on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
    NSMutableArray *_paints;
    int _currentSelectedPaint;
}
@property (retain, nonatomic) IBOutlet UISegmentedControl *paintsFilter;
@property (retain, nonatomic) IBOutlet UITableView *gallery;
@property (retain, nonatomic) NSMutableArray* paints;

@end
