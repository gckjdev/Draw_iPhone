//Error manager.


#define DRAW_ERROR(x) [DrawError errorWithCode:x]

@interface DrawError : NSObject {

}

+ (NSError *)errorWithCode:(NSInteger) code;
+ (void)postError:(NSError *)error;

@end