//
//  AESubmixer.m
//  zMors
//
//  Created by Sven Braun on 26.03.13.
//  Copyright (c) 2013 zMors. All rights reserved.
//

#import "AESubmixer.h"



@implementation AESubmixer


- (id)init{
    self = [super init];
    if (self) {
        buffersize = 0;
        // Set default to non send
        for(int i=0; i< MAX_INPUT_BUS_COUNT ; i++){
            levels[i] = 0.0f;
        }
        // alloc any buffer if size chained we re alloc
        bufferL = malloc(512*(sizeof(float)));
        bufferR = malloc(512*(sizeof(float)));
        
    }
    return self;
}


        
static OSStatus renderCallback(AESubmixer *THIS,
                               AEAudioController *audioController,
                               const AudioTimeStamp *time,
                               UInt32 frames,
                               AudioBufferList *audio) {

    if(frames==THIS->buffersize){
        // Copy current Sum to Audiobuffer
        memcpy(audio->mBuffers[0].mData, THIS->bufferL, frames * sizeof(float));
        memcpy(audio->mBuffers[1].mData, THIS->bufferR, frames * sizeof(float));

        // Clear for refill
        vDSP_vclr(THIS->bufferL, 1, frames);
        vDSP_vclr(THIS->bufferR, 1, frames);
        THIS->level_idx=0;
    }else{
        // if System Buffersize will changed... we re-alloc
        free(THIS->bufferL);
        free(THIS->bufferR);
        THIS->bufferL = malloc(frames*(sizeof(float)));
        THIS->bufferR = malloc(frames*(sizeof(float)));
        vDSP_vclr(THIS->bufferL, 1, frames);
        vDSP_vclr(THIS->bufferR, 1, frames);
        THIS->buffersize = frames;
    }
    
    
    
    
    return noErr;
}
-(AEAudioControllerRenderCallback)renderCallback {
    return &renderCallback;
}



static void receiverCallback(id                        receiver,
                             AEAudioController         *audioController,
                             void                      *source,
                             const AudioTimeStamp     *time,
                             UInt32                    frames,
                             AudioBufferList          *audio) {

    // cant use *source to identify the src channel :-(
    // Sum Audio from Channels
    AESubmixer *THIS = (AESubmixer*)receiver;
    if(THIS->buffersize==frames && THIS->level_idx<MAX_INPUT_BUS_COUNT ) {


        if(THIS->levels[THIS->level_idx] > 0.0f ) {
            // dest[n] =  dest[n] + (in[n] * level )
            vDSP_vsma(audio->mBuffers[0].mData,1,
                   &THIS->levels[THIS->level_idx],
                   THIS->bufferL , 1,
                   THIS->bufferL , 1,
                   frames);
            vDSP_vsma(audio->mBuffers[1].mData,1,
                  &THIS->levels[THIS->level_idx],
                  THIS->bufferR , 1,
                  THIS->bufferR , 1,
                  frames);
        }
    }else{
        NSLog(@"AESubmixer:receiverCallback   no Receiver or Buffersize changed ? ");
    }
    THIS->level_idx++;
}

// its a pointer !
-(float*) levelForIndex: (NSInteger) idx {
    return &levels[idx];

}

-(void) setLevel: (float) level forIndex:(NSInteger) idx{
    if(idx>=0 && idx<MAX_INPUT_BUS_COUNT) {
        // printf("AESubmixer setLevel: %f forIndex:%d",level,idx);
        levels[idx]=level;
    }else{
        NSLog(@"AESubmixer:setLevel  invalid Index! ");
    }
}


-(AEAudioControllerAudioCallback)receiverCallback {
    return receiverCallback;
}



- (AudioStreamBasicDescription) audioDescription {
    return [AEAudioController nonInterleavedFloatStereoAudioDescription];
}


-(void) dealloc{
    free(bufferL);
    free(bufferR);
    [super dealloc];
}


@end
