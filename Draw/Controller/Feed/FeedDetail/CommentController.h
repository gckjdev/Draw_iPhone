//
//  CommentController.h
//  Draw
//
//  Created by  on 12-9-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPViewController.h"

@interface CommentController : PPViewController<UITextViewDelegate>
{
    
}
@property (retain, nonatomic) IBOutlet UITextView *contentView;
@property (retain, nonatomic) IBOutlet UIImageView *inputBGView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)clickBack:(id)sender;

@end
