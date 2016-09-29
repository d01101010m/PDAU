//
//  MyAudioUnit.m
//  AU
//

//
//

#import "MyAudioUnit.h"

#import <AVFoundation/AVFoundation.h>

#import "PdBase.h"

@interface MyAudioUnit () {
    double renderPhase;
}
@property AUAudioUnitBus *outputBus;
@property AUAudioUnitBusArray *outputBusArray;
@property (nonatomic, readwrite) AUParameterTree *parameterTree;

@end


@implementation MyAudioUnit
@synthesize parameterTree = _parameterTree;

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription options:(AudioComponentInstantiationOptions)options error:(NSError **)outError {
    self = [super initWithComponentDescription:componentDescription options:options error:outError];
    
    if (self == nil) {
        return nil;
    }
    
    // Initialize a default format for the busses.
    AVAudioFormat *defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100. channels:2];
    
    // Create parameter objects.
    AUParameter *param1 = [AUParameterTree createParameterWithIdentifier:@"param1" name:@"Parameter 1" address:myParam1 min:0 max:100 unit:kAudioUnitParameterUnit_Percent unitName:nil flags:0 valueStrings:nil dependentParameters:nil];
    
    // Initialize the parameter values.
    param1.value = 0.5;
    
    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[ param1 ]];
    
    // Create the input and output busses (AUAudioUnitBus).
    _outputBus = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];
    
    // Create the input and output bus arrays (AUAudioUnitBusArray).
    _outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                             busType:AUAudioUnitBusTypeOutput
                                                              busses: @[_outputBus]];
    
    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;
        
        switch (param.address) {
            case myParam1:
                return [NSString stringWithFormat:@"%.f", value];
            default:
                return @"?";
        }
    };
    
    self.maximumFramesToRender = 512;
    
    [PdBase computeAudio:YES];
    [PdBase openFile:@"tone.pd" path:[[NSBundle mainBundle] bundlePath]];
    
    return self;
}

#pragma mark - AUAudioUnit Overrides

// If an audio unit has input, an audio unit's audio input connection points.
// Subclassers must override this property getter and should return the same object every time.
// See sample code.
/*
- (AUAudioUnitBusArray *)inputBusses {
#warning implementation must return non-nil AUAudioUnitBusArray
    return nil;
}
*/
// An audio unit's audio output connection points.
// Subclassers must override this property getter and should return the same object every time.
// See sample code.
- (AUAudioUnitBusArray *)outputBusses {
//#warning implementation must return non-nil AUAudioUnitBusArray
    return _outputBusArray;
}

// Allocate resources required to render.
// Subclassers should call the superclass implementation.
- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError {
    if (![super allocateRenderResourcesAndReturnError:outError]) {
        return NO;
    }
    
    // Validate that the bus formats are compatible.
    // Allocate your resources.
    
    return YES;
}

// Deallocate resources allocated in allocateRenderResourcesAndReturnError:
// Subclassers should call the superclass implementation.
- (void)deallocateRenderResources {
    // Deallocate your resources.
    [super deallocateRenderResources];
}

#pragma mark - AUAudioUnit (AUAudioUnitImplementation)
int log2int(int x) {
    int y = 0;
    while (x >>= 1) {
        ++y;
    }
    return y;
}
// Block which subclassers must provide to implement rendering.
- (AUInternalRenderBlock)internalRenderBlock {
    // Capture in locals to avoid Obj-C member lookups. If "self" is captured in render, we're doing it wrong. See sample code.
    
    return ^AUAudioUnitStatus(AudioUnitRenderActionFlags *actionFlags, const AudioTimeStamp *timestamp, AVAudioFrameCount frameCount, NSInteger outputBusNumber, AudioBufferList *outputData, const AURenderEvent *realtimeEventListHead, AURenderPullInputBlock pullInputBlock) {
        // Do event handling and signal processing here.
        
        Float32 * outputBuffer = (Float32 *)outputData->mBuffers[0].mData;
        
        /*
        //placing a test tone in the buffer works
        double currentPhase = renderPhase;
        const double frequency = 880.;
        const double phaseStep = (frequency / 44100.) * (M_PI * 2.);
        
        for(int i = 0; i < frameCount; i++) {
            outputBuffer[i] = sin(currentPhase);
            currentPhase += phaseStep;
        }
        renderPhase = currentPhase;
        */
        
        //trying to pull samples through libPD does not work
        int ticks = frameCount >> log2int([PdBase getBlockSize]);
        [PdBase processFloatWithInputBuffer:outputBuffer outputBuffer:outputBuffer ticks:ticks];
        
        return noErr;
    };
}

@end

