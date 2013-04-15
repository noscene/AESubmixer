//
//  AESplitter.h
//  zMors
//
//  Created by Sven Braun on 26.03.13.
//  Copyright (c) 2013 zMors. All rights reserved.
//

#import "TheAmazingAudioEngine.h"

@interface AESubmixer : NSObject <AEAudioReceiver, AEAudioPlayable > {


    void *  bufferL;
    void *  bufferR;
    int     buffersize;
    float   levels[4];
    NSInteger     level_idx;    
}


-(void) setLevel: (float) level forIndex:(NSInteger) idx;
-(float*) levelForIndex: (NSInteger) idx;

@end
