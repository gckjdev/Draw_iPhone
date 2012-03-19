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
}

@property(nonatomic, retain)Word *word;

- (id)initWithWord:(Word *)word;

@end
