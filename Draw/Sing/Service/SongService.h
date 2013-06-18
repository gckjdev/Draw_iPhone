//
//  SongService.h
//  Draw
//
//  Created by 王 小涛 on 13-6-17.
//
//

#import <Foundation/Foundation.h>
#import "CommonService.h"

@protocol SongServiceDelegate <NSObject>

@optional
- (void)didGetSongs:(int)resultCode songs:(NSArray *)songs;

@end

@interface SongService : CommonService

@property (assign, nonatomic) id<SongServiceDelegate> delegate;

+ (id)defaultService;
- (void)randomSongs:(int)count;
- (void)randomSongsWithTag:(NSString *)tag count:(int)count;

@end
