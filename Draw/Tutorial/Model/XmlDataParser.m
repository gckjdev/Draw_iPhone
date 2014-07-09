//
//  XmlDataParser.m
//  Draw
//
//  Created by ChaoSo on 14-7-9.
//
//

#import "XmlDataParser.h"

@implementation XmlDataParser

@synthesize nameArray=_nameArray;
@synthesize descArray=_descArray;
@synthesize dict=_dict;


-(void)parserDidStartDocument:(NSXMLParser *)parser{
    _nameArray = [[NSMutableArray alloc]init];
    _descArray = [[NSMutableArray alloc]init];
    _dict = [[NSMutableDictionary alloc]init];
}
-(void)dealloc{
    PPRelease(_nameArray);
    PPRelease(_dict);
    PPRelease(_descArray);
    [super dealloc];
    
}



@end
