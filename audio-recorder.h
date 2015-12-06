//
//  Recorder.h
//  Snappy
//
//  Created by Paradox on 8/30/15.
//  Copyright (c) 2015 dlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface Recorder : NSObject
<AVAudioRecorderDelegate,AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSURL *audioFileAif;

- (IBAction)recordAudio:(id)sender;
- (IBAction)playAudio:(id)sender;
- (IBAction)stopAudio:(id)sender;
- (void)loadAudio;
+ (id)link;
- (id)init;

@end
