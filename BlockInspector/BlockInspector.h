//
//  BlockInspector.h
//  BlockTest
//

#import <Foundation/Foundation.h>

@interface BlockInspector : NSObject

@property (nonatomic, assign) void (*invoke)(void *, ...);
@property (nonatomic, assign) void(*copy_helper)(void *dst, void *src);
@property (nonatomic, assign) void(*dispose_helper)(void *src);
@property (nonatomic, strong) NSMethodSignature *signature;
@property (nonatomic, strong) id block;

- (instancetype)initWithBlock:(id)block;
- (void)printCaptureObjects;

+ (void)inspectBlock:(id)block;

@end

