//
//  ViewController.m
//  PDAU
//

//
//

#import "ViewController.h"
#import "PdBase.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [PdBase openFile:@"tone.pd" path:[[NSBundle mainBundle] bundlePath]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
