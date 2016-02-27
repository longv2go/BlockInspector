//
//  BlockInspector.m
//  BlockTest
//

#import "BlockInspector.h"
#import "fishhook.h"

enum {
    BLOCK_FIELD_IS_OBJECT   =  3,  // id, NSObject, __attribute__((NSObject)), block, ...
    BLOCK_FIELD_IS_BLOCK    =  7,  // a block variable
    BLOCK_FIELD_IS_BYREF    =  8,  // the on stack structure holding the __block variable
    
    BLOCK_FIELD_IS_WEAK     = 16,  // declared __weak
    
    BLOCK_BYREF_CALLER      = 128, // called from byref copy/dispose helpers
};

enum {
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    BLOCK_HAS_CTOR =          (1 << 26), // helpers have C++ code
    BLOCK_IS_GLOBAL =         (1 << 28),
    BLOCK_HAS_STRET =         (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE =     (1 << 30),
};

struct Block_literal_1 {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct Block_descriptor_1 {
        unsigned long int reserved; // NULL
        unsigned long int size;         // sizeof(struct Block_literal_1)
        // optional helper functions
        void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
        void (*dispose_helper)(void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        const char *signature;                         // IFF (1<<30)
    } *descriptor;
    // imported variables
};


static CFMutableArrayRef __capture_objects;

// void objc_storeStrong(id *location, id obj)
static void (*orig_storeStrong)(id *location, id obj);
static void (*orig_dispose)(void *, int);

void my_dispose_helper(void *this, int fd) {
    if (fd & BLOCK_FIELD_IS_BLOCK || fd & BLOCK_FIELD_IS_OBJECT) {
        CFArrayAppendValue(__capture_objects, this);
    }
    return;
}

void my_storeStrong(void* *location, void* obj)
{
    CFArrayAppendValue(__capture_objects, (void *)*location);
    return;
}

void bind_block_dispose()
{
    int ret = rebind_symbols((struct rebinding[1]){{"_Block_object_dispose", my_dispose_helper, (void *)&orig_dispose}}, 1);
    printf("rebind _Block_object_dispose : %d\n",ret);
    
    ret = rebind_symbols((struct rebinding[1]){{"objc_storeStrong", my_storeStrong, (void *)&orig_storeStrong}}, 1);
    printf("rebind objc_storeStrong : %d\n",ret);
}

void unbind_block_dispose()
{
    rebind_symbols((struct rebinding[1]){{"_Block_object_dispose", orig_dispose, NULL}}, 1);
    rebind_symbols((struct rebinding[1]){{"objc_storeStrong", orig_storeStrong, NULL}}, 1);
}

@implementation BlockInspector


+ (void)inspectBlock:(id)block
{
    if (!block) return;
    
    BlockInspector *ins = [[BlockInspector alloc] initWithBlock:block];
    [ins printCaptureObjects];
}


- (instancetype)initWithBlock:(id)block
{
    if (self = [super init]) {
        _block = block;
        [self setup];
    }
    return self;
}

- (void)setup
{
    struct Block_literal_1 real = *((__bridge struct Block_literal_1 *)_block);
    self.invoke = real.invoke;
    
    if (real.flags & BLOCK_HAS_SIGNATURE) {
        char *signature;
        if (real.flags & BLOCK_HAS_COPY_DISPOSE) {
            signature = (char *)(real.descriptor)->signature;
        } else {
            signature = (char *)(real.descriptor)->copy_helper;
        }
        self.signature = [NSMethodSignature signatureWithObjCTypes:signature];
    }
    
    if (real.flags & BLOCK_HAS_COPY_DISPOSE) {
        self.copy_helper = real.descriptor->copy_helper;
        self.dispose_helper = real.descriptor->dispose_helper;
    }
}

- (void)printCaptureObjects
{
    if (!__capture_objects) {
        __capture_objects = CFArrayCreateMutable(0, 10, NULL);
    }
    
    bind_block_dispose();
    
    [self invokeDisposeHelper];
    
    unbind_block_dispose();
    
    NSLog(@"all capture objects : %@", (__bridge NSString *)__capture_objects);
    CFArrayRemoveAllValues(__capture_objects);
}

- (void)invokeDisposeHelper
{
    ((void (*)(void *))self.dispose_helper)((__bridge void *)self.block);
}

@end
