//
//  TagPackage.m
//  Draw
//
//  Created by Kira on 13-6-6.
//
//

#import "TagPackage.h"

@interface TagPackage ()

@property (retain, nonatomic) NSMutableArray* tagArray;
@property (retain, nonatomic) NSString* tagPackageName;

@end

@implementation TagPackage

- (id)initWithString:(NSString*)str
{
    self = [super init];
    if (self) {
        self.tagArray = [[[NSMutableArray alloc] initWithCapacity:6] autorelease];
        NSArray* array = [str componentsSeparatedByString:@"&"];
        if (array.count == 2) {
            self.tagPackageName = [array objectAtIndex:0];
            NSString* tagStr = [array objectAtIndex:1];
            NSArray* tags = [tagStr componentsSeparatedByString:@"^"];
            for (NSString* string in tags) {
                if (string.length > 0) {
                    [self.tagArray addObject:string];
                }
            }
        }
    }
    return self;
}

+ (NSArray*)createPackageArrayFromString:(NSString*)str
{
    NSArray* strArray = [str componentsSeparatedByString:@"$"];
    NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:strArray.count];
    for (NSString* string in strArray) {
        if (string && string.length > 1) {
            TagPackage* package = [[[TagPackage alloc] initWithString:string] autorelease];
            [array addObject:package];
        }
    }
    return array;
}

- (void)dealloc
{
    [_tagArray release];
    [_tagPackageName release];
    [super dealloc];
}

@end
