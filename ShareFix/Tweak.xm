#import <Foundation/Foundation.h>

%hook YTIShareEntityEndpoint

+ (id)shareEntityEndpoint {
    return nil;
}

%end
