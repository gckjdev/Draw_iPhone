//
//  SelectWordController.h
//  Draw
//
//  Created by  on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectWordController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_wordArray;
}

@property (retain, nonatomic) IBOutlet UITableView *wordTableView;
@property (retain, nonatomic) NSArray *wordArray;
- (IBAction)clickChangeWordButton:(id)sender;

@end
