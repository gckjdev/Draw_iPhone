//
//  XmlDataParser.h
//  Draw
//
//  Created by ChaoSo on 14-7-9.
//
//

#import <Foundation/Foundation.h>

@interface XmlDataParser : NSObject<NSXMLParserDelegate>

@property(strong,nonatomic) NSMutableArray *nameArray;
@property(strong,nonatomic) NSMutableArray *descArray;
@property(strong,nonatomic) NSMutableDictionary *dict;


@end
