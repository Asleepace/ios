//
//  Recorder.m
//  Snappy
//
//  Created by Paradox on 8/30/15.
//  Copyright (c) 2015 dlabs. All rights reserved.
//

#import "Recorder.h"
#import "AppDelegate.h"

@implementation Recorder
{
    AppDelegate *app;
}

@synthesize audioPlayer, audioRecorder, audioFileAif;

- (id)init {
    if (self = [super init]) {
        [self setUpAudio];
    } return self;
}

+ (id)link {
    static Recorder *recorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{recorder=[[self alloc] init];});
    return recorder;
}


- (void)setUpAudio {
    NSArray *dirPaths;
    NSString *docsDir;
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    NSString *soundFileName = [NSString stringWithFormat:@"%lu.aif",(long)index];
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:soundFileName];
    audioFileAif = [NSURL fileURLWithPath:soundFilePath];
    NSDictionary *recordSettings = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt:2],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0],
                                    AVSampleRateKey,
                                    nil];
    
    NSError *error = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    NSError *error2;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&error];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryMultiRoute error:&error];
    if (error2) NSLog(@"Error: %@",[error localizedDescription]);
    
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:audioFileAif
                                                settings:recordSettings error:&error];
    if (error)NSLog(@"error: %@", [error localizedDescription]);
    else [audioRecorder prepareToRecord];
}

- (IBAction)recordAudio:(id)sender {
    if (!audioRecorder.recording) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
        [audioRecorder record];
    }
}

- (IBAction)playAudio:(id)sender {
    if (!audioRecorder.recording) {
        NSLog(@"Playing Audio...");

        NSError *error;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioRecorder.url error:&error];
        audioPlayer.delegate = self;
        
        if (error) {
            NSLog(@"Error Playing Audio %@", error.localizedDescription);
        } else [audioPlayer play];
    }
}

- (IBAction)stopAudio:(id)sender {
    NSLog(@"Stopping Audio...");
    if (audioRecorder.recording) {
        [audioRecorder stop];
    } else if (audioPlayer.playing) {
        [audioPlayer stop];
    }
}

- (void)loadAudio {
    NSLog(@"Loading audio...");
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:audioFileAif options:NSDataReadingMappedIfSafe error:&error];
    
    if (error) NSLog(@"Error Loading Data: %@",error);
    NSLog(@"Audio Data Size: %lu",(unsigned long)data.length);
    
    audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
    audioPlayer.delegate = self;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&error];
    
    if (error) NSLog(@"Error Playing Audio: %@",error);
    else [audioPlayer play];
}

#pragma mark - Delegate Stuff

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"Audio PLayer Finished PLaying");
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"Audio Player Decode Error: %@",error);
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"Audio Recorder Finished Recording");
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    NSLog(@"Audio Recorder Encoding Error: %@",error);
}


@end
