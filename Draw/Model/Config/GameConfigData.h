//
//  GameConfigData.h
//  Draw
//
//  Created by qqn_pipi on 12-11-30.
//
//

#import <Foundation/Foundation.h>
#import "Config.pb.h"

@interface GameConfigData : NSObject

@property (nonatomic, retain) PBConfig* config;

- (id)initWithName:(NSString*)bundleName;



@end
