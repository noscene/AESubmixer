//
//  AESubmixer.m
//  zMors
//
//  Created by Sven Braun on 26.03.13.
//  Copyright (c) 2013 zMors. All rights reserved.
//

#import "AESubmixer.h"


// TODO: free buffers if frame count is changed!!!!

@implementation AESubmixer


- (id)init{
    self = [super init];
    if (self) {
        buffersize = 0;
        levels[0] = 0.0f;
        levels[1] = 0.0f;
        levels[2] = 0.0f;
        levels[3] = 0.0f;
        
    }
    return self;
}


        
static OSStatus renderCallback(AESubmixer *THIS,
                               AEAudioController *audioController,
                               const AudioTimeStamp *time,
                               UInt32 frames,
                               AudioBufferList *audio) {
    // TODO: Generate audio in 'audio'
    // printf("> %f \n",time->mSampleTime);
    // float db0=0.0;

    if(frames==THIS->buffersize){
        // Kopie Summe aus 4 in den Audiobuffer
        memcpy(audio->mBuffers[0].mData, THIS->bufferL, frames * sizeof(float));
        memcpy(audio->mBuffers[1].mData, THIS->bufferR, frames * sizeof(float));

        // Puffer wieder zum aufaddieren auf 0 setzen
        vDSP_vclr(THIS->bufferL, 1, frames);
        vDSP_vclr(THIS->bufferR, 1, frames);
        THIS->level_idx=0;
    }else{
        // alloc buffer + clear
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
    
    /*
    // Leider nur der RenderCallback
    mo_ausynth * xx = source;
    NSLog(@"xx %ld",xx);
    */
    // Sum Audio from Channels
    AESubmixer *THIS = (AESubmixer*)receiver;
    if(THIS->buffersize==frames && THIS->level_idx<4 ){
        // printf("< %f %ld \n",time->mSampleTime,frames);

        if(THIS->levels[THIS->level_idx] > 0.0f ) {
            // Multiplizieren und aufaddieren
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
    }
    THIS->level_idx++;
}


-(float*) levelForIndex: (NSInteger) idx {
    return &levels[idx];

}

-(void) setLevel: (float) level forIndex:(NSInteger) idx{
    if(idx>=0 && idx<4){
        printf("AESubmixer setLevel: %f forIndex:%d",level,idx);
        levels[idx]=level;
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
