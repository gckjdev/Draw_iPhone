//
//  ShowDrawController.h
//  Draw
//
//  Created by  on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawGameService.h"

@class Word;
@class DrawView;
@interface ShowDrawController : UIViewController<DrawGameServiceDelegate>
{
    Word *_word;
    DrawGameService *drawGameService;
    DrawView *showView;
    NSString *candidateString;
}

@property(nonatomic, retain)Word *word;
- (IBAction)clickGuessDoneButton:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *guessMsgLabel;

@end
