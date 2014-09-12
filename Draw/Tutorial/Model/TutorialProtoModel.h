//
//  TutorialProtoModel.h
//  Draw
//
//  Created by ChaoSo on 14-9-11.
//
//

#import <Foundation/Foundation.h>

@interface TutorialProtoModel : NSObject

@property (nonatomic, retain) NSDictionary* dataDict;

-(NSString*) tutorialName;
-(NSString*) tutorialDesc;
-(NSString*) tutorialImageUrl;
-(NSArray*) stageList;
-(int) tutorialCategory;
-(int) tutorialType;


+ (id) objectWithDictionary:(NSDictionary*)dictionary;
- (id) initWithDictionary:(NSDictionary*)dictionary;
@end
