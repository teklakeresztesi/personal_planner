//
//  SpeechManager.m
//  PersonalPlanner
//
//  Created by Keresztesi Tekla on 04.09.2025.
//

#import "SpeechManager.h"

// https://developer.apple.com/documentation/speech/asking-permission-to-use-speech-recognition

typedef NS_ENUM(NSUInteger, PermissionStatus) {
    PermissionStatusApproved = 0,
    PermissionStatusDenied,
    PermissionStatusUnknown
};

@interface SpeechManager ()<SFSpeechRecognizerDelegate>

@property (nonatomic, assign) PermissionStatus speechStatus;
@property (nonatomic, assign) PermissionStatus microphoneStatus;

@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;
@property (nonatomic, strong) NSTimer * finalizationTimer;


@end

@implementation SpeechManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.speechStatus = PermissionStatusUnknown;
        self.microphoneStatus = PermissionStatusUnknown;
        [self requestPermissions];
        self.audioEngine = [[AVAudioEngine alloc] init];
        self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"en-US"]];
        self.speechRecognizer.delegate = self;
    }
    return self;
}

#pragma mark - Public

+ (instancetype)sharedInstance {
    static SpeechManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

- (BOOL)isAllApproved {
    return self.speechStatus == PermissionStatusApproved && self.microphoneStatus == PermissionStatusApproved;
}

-(BOOL)isAnyDenied {
    return self.speechStatus == PermissionStatusDenied || self.microphoneStatus == PermissionStatusDenied;
}

- (void)requestPermissions {
    [self requestSpeechPermission];
    [self requestMicrophonePermission];
}

/// Configures the audio session, starts listening to audio events and handles the events
- (BOOL)startListening {
    if (self.recognitionTask) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }
    // Configure the audio session for the app.
    NSError * error;
    AVAudioSession * audioSession = AVAudioSession.sharedInstance;
    [audioSession setCategory: AVAudioSessionCategoryRecord
                         mode: AVAudioSessionModeMeasurement
                      options: AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers
                        error:&error];
    if (error != nil) {
        NSLog(@"Error: %@", error.localizedDescription);
        return false;
    }
    
    [audioSession setActive:true
                withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                      error:&error];

    if (error != nil) {
        NSLog(@"Error: %@", error.localizedDescription);
        return false;
    }
    
    AVAudioInputNode * inputNode = self.audioEngine.inputNode;
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];

    self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest
                                                               resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
            NSString *spokenText = result.bestTranscription.formattedString;
            if (result) {
                [self.delegate speechManager:self
                               handleText:spokenText];
                [self startSilenceTimer];
            }

            if (error || result.isFinal) {
                [self stopSilenceTimer];
                [self stopListening];
                [self.delegate speechManager:self
                             handleFinalText:spokenText];
            }
        }];
    
    [inputNode removeTapOnBus:0];
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0
                    bufferSize:1024
                        format:recordingFormat
                         block:^(AVAudioPCMBuffer *buffer, AVAudioTime *when) {
        [self.recognitionRequest appendAudioPCMBuffer:buffer];
    }];

    [self.audioEngine prepare];
    [self.audioEngine startAndReturnError:&error];
    NSLog(@"Started listening");
    if (error) {
        NSLog(@"Failed to start audio engine: %@", error.localizedDescription);
    }
    self.isListening = YES;
    return true;
}

- (void)stopListening {
    [self.audioEngine stop];
    [self.audioEngine.inputNode removeTapOnBus:0];
    self.recognitionTask = nil;
    self.recognitionRequest = nil;
    self.isListening = NO;
    NSLog(@"Stopped listening");
}

#pragma mark - Private

- (void)startSilenceTimer {
    [self.finalizationTimer invalidate];
    self.finalizationTimer = [NSTimer scheduledTimerWithTimeInterval:1.5
                                                              target:self
                                                            selector:@selector(endRecognitionDueToSilence)
                                                            userInfo:nil
                                                             repeats:NO];
}

- (void)stopSilenceTimer {
    [self.finalizationTimer invalidate];
    self.finalizationTimer = nil;
}

-(void)endRecognitionDueToSilence {
    [self.recognitionTask finish];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startListening];
    });
}

- (void)requestSpeechPermission {
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
            self.speechStatus = PermissionStatusApproved;
        } else if (status == SFSpeechRecognizerAuthorizationStatusDenied) {
            self.speechStatus = PermissionStatusDenied;
        } else if (status == SFSpeechRecognizerAuthorizationStatusRestricted) {
            self.speechStatus = PermissionStatusDenied;
        } else if (status == SFSpeechRecognizerAuthorizationStatusNotDetermined) {
            self.speechStatus = PermissionStatusUnknown;
        }

        [self.delegate permissionsUpdated:self];
    }];
}

- (void)requestMicrophonePermission {
    [AVAudioApplication requestRecordPermissionWithCompletionHandler:^(BOOL granted) {
        if (granted) {
            self.microphoneStatus = PermissionStatusApproved;
        } else {
            self.microphoneStatus = PermissionStatusDenied;
        }

        [self.delegate permissionsUpdated:self];
    }];
}

#pragma mark - SFSpeechRecognitionDelegate

- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available {
    NSLog(@"speechRecognizer availabilityDidChange: %@", available ? @"true" : @"false");
}

@end
