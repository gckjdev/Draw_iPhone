//
//  PBTutorial+Extend.h
//  Draw
//
//  Created by qqn_pipi on 14-6-28.
//
//

#import "Tutorial.pb.h"

@interface PBTutorial (Extend)

- (NSString*)name;
- (NSString*)desc;

- (NSString*)categoryName;

@end


@interface PBStage (Extend2)

-(NSString *) name;
-(NSString *) desc;

@end