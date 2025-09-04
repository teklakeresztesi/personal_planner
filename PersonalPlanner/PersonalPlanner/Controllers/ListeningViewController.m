//
//  ListeningViewController.m
//  PersonalPlanner
//
//  Created by Keresztesi Tekla on 04.09.2025.
//

#import "ListeningViewController.h"
#import <Speech/Speech.h>

@interface ListeningViewController ()
@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@end

@implementation ListeningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.audioEngine = [[AVAudioEngine alloc] init];
    [self configureAudioSession];
    // TODO: animate something to show the microphone is listening
}

/// Configures the audio session, starts listening to audio events and handles the events
- (void)configureAudioSession {
    // Configure the audio session for the app.
    NSError * error;
    AVAudioSession * audioSession = AVAudioSession.sharedInstance;
    [audioSession setCategory: AVAudioSessionCategoryRecord
                         mode: AVAudioSessionModeMeasurement
                      options: AVAudioSessionCategoryOptionDuckOthers
                        error:&error];
    if (error == nil) {
        [audioSession setActive:true
                    withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                          error:&error];
        // TODO: handle error
        if (error != nil) {
            return;
        }
    } else {
        // TODO: handle error
        return;
    }
    
    AVAudioInputNode * inputNode = self.audioEngine.inputNode;
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];

    self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest
                                                               resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
            if (result) {
                NSString *spokenText = result.bestTranscription.formattedString;
                [self handleCommand:spokenText];
            }

            if (error || result.isFinal) {
                [self.audioEngine stop];
                [inputNode removeTapOnBus:0];
                self.recognitionRequest = nil;
                self.recognitionTask = nil;
            }
        }];
    
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer *buffer, AVAudioTime *when) {
        [self.recognitionRequest appendAudioPCMBuffer:buffer];
    }];

    [self.audioEngine prepare];
    [self.audioEngine startAndReturnError:&error];
}

/// Handles the text that was passed as a command
- (void)handleCommand:(NSString *)command {
    NSLog(@"Handle command: %@", command);
}

- (IBAction)stopButtonPressed:(id)sender {
    NSLog(@"Stop button pressed");
    
}


@end

