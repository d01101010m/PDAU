//
//  AudioUnitViewController.m
//  AU
//

//
//

#import "AudioUnitViewController.h"
#import "MyAudioUnit.h"
#import "PdDispatcher.h"

@interface AudioUnitViewController () <PdReceiverDelegate>

@end

@implementation AudioUnitViewController {
    AUAudioUnit *audioUnit;
    IBOutlet UILabel *label;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [PdBase setDelegate:self pollingEnabled:YES];
    
    if (!audioUnit) {
        return;
    }
    
    // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
}
- (IBAction)buttonPressed:(id)sender {
    [PdBase sendBangToReceiver:@"checkPatch"];
}

-(void)receivePrint:(NSString *)message {
    [label setText:message];
}

- (AUAudioUnit *)createAudioUnitWithComponentDescription:(AudioComponentDescription)desc error:(NSError **)error {
    audioUnit = [[MyAudioUnit alloc] initWithComponentDescription:desc error:error];
    
    return audioUnit;
}

@end
