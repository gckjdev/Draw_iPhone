//
//  WordFilterService.h
//  Draw
//
//  Created by qqn_pipi on 13-7-15.
//
//

#import <Foundation/Foundation.h>

@interface WordFilterService : NSObject

+ (WordFilterService*)defaultService;
- (BOOL)containForbiddenWord:(NSString*)text;
- (BOOL)checkForbiddenWord:(NSString*)inputText;

@end
