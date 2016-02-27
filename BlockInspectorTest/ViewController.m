//
//  ViewController.m
//  BlockInspectorTest
//
//  Created by didi on 16/2/27.
//
//

#import "ViewController.h"
#import "BlockInspector.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    id cap1 = @"hello world!";
    id cap2 = @[@"arr1", @"arr2"];
    id obj = @"not captured";
    
    void (^blk)(void) = ^{
        id b1 = cap1;
        id b2 = cap2;
    };
    
    [BlockInspector inspectBlock:blk];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
