AESubmixer
==========

TAAE Submixer to create Bus Sends from Channels to different Channelgroup

u can use addOutputReceiver: and addChannels: like this:

    // Make a instance
    self.dly_mixer = [[[AESubmixer alloc] init] autorelease];
 
    // Add Sum to any Channelgroup for Delay Reverb etc 
    [_audioController addChannels:[NSArray arrayWithObjects: _dly_mixer, nil] toChannelGroup:_channelgroup_dly];
 
    // 4 Send from Channels
    [_audioController addOutputReceiver:_dly_mixer  forChannel:_mysynti0];
    [_audioController addOutputReceiver:_dly_mixer  forChannel:_mysynti1];
    [_audioController addOutputReceiver:_dly_mixer  forChannel:_mysynti2];
    [_audioController addOutputReceiver:_dly_mixer  forChannel:_mysynti3];
