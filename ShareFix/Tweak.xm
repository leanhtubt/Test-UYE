#import <Foundation/Foundation.h>
#import <objc/runtime.h>

%hook YTIShareEntityEndpoint

+ (id)shareEntityEndpoint {
    return nil;
}

%end

%ctor {
    Class targetClass = objc_getClass("YTIShareEntityEndpoint");
    
    if (targetClass) {
        %init(YTIShareEntityEndpoint = targetClass);
    } else {
        NSLog(@"[ShareFix] YTIShareEntityEndpoint không tồn tại, bỏ qua hook.");
    }
}
