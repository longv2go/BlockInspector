# BlockInspector

#Usage
Drag the BlockIspector.m and other files to your project. 

#Example
```objc
	id cap1 = @"hello world!";
    id cap2 = @[@"arr1", @"arr2"];
    
    void (^blk)(void) = ^{
        id b1 = cap1;
        id b2 = cap2;
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
    )
)
```

#Thanks
[fishhook:](https://github.com/facebook/fishhook) A library that enables dynamically rebinding symbols in Mach-O binaries running on iOS