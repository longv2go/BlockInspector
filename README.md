# BlockInspector

#Usage
Drag the folder BlockIspector to your project. 

#Example
```objc
id cap1 = @"hello world!";
id cap2 = @[@"arr1", @"arr2"];
id obj = @"not captured";
__weak id obj2 = @"not captured 2";
__block int i = 3;
__block id block_id = @"block id";

void (^blk)(void) = ^{
    id b1 = cap1;
    id b2 = cap2;
    id b3 = obj2;
    i = 4;
    block_id = @"s";
};
[BlockInspector inspectBlock:blk];
```

Output:

```
2016-02-27 17:22:51.069 BlockInspectorTest[10158:390353] all capture objects : (
    "hello world!",
        (
        arr1,
        arr2
    ),
     "block id"
)
```

#Block internal
[block reference](http://clang.llvm.org/docs/Block-ABI-Apple.html)

#Thanks
[fishhook:](https://github.com/facebook/fishhook) A library that enables dynamically rebinding symbols in Mach-O binaries running on iOS