//
//  Word.h
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{ 
    WordLevelLow = 1,
    WordLeveLMedium = 2,
    WordLevelHigh = 3
}WordLevel;

@interface Word : NSObject
{
    NSString *_text; 
    WordLevel _level;
}

@property(nonatomic, retain)NSString *text;
@property(nonatomic, assign)WordLevel level;

- (id)initWithText:(NSString *)text level:(WordLevel)level;
@end
