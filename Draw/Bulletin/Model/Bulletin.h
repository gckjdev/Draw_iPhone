//
//  Bulletin.h
//  Draw
//
//  Created by Kira on 12-12-17.
//
//

#import <Foundation/Foundation.h>



@interface Bulletin : NSObject <NSCoding>

@property (retain, nonatomic) NSDate* date;
@property (retain, nonatomic) NSString* message;
@property (assign, nonatomic) NSInteger type;
@property (retain, nonatomic) NSString* bulletinId;
@property (retain, nonatomic) NSString* gameId;
@property (retain, nonatomic) NSString* function;
@property (assign, nonatomic) BOOL hasRead;

- (id)initWithDict:(NSDictionary*)dict;


@end
