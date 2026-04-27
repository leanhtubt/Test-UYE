#import <Foundation/Foundation.h>

@interface YTVarispeedSwitchControllerImpl : NSObject
{
    NSArray* _options;
}
@property(copy, nonatomic) NSArray *options;
- (void)setOptions:(NSArray *)options;
@end
