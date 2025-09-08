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

@interface SpeechManager ()

@property (nonatomic, assign) PermissionStatus speechStatus;
@property (nonatomic, assign) PermissionStatus microphoneStatus;

@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;


@end

@implementation SpeechManager


#pragma mark - Public

+ (instancetype)sharedInstance {
    static SpeechManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.speechStatus = PermissionStatusUnknown;
        self.microphoneStatus = PermissionStatusUnknown;
        [self requestPermissions];
        self.audioEngine = [[AVAudioEngine alloc] init];
        self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"en-US"]];
    }
    return self;
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
                      options: AVAudioSessionCategoryOptionDuckOthers
                        error:&error];
    if (error == nil) {
        [audioSession setActive:true
                    withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                          error:&error];
        // TODO: handle error
        if (error != nil) {
            return false;
        }
    } else {
        // TODO: handle error
        return false;
    }
    
    AVAudioInputNode * inputNode = self.audioEngine.inputNode;
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];

    self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest
                                                               resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
            if (result) {
                NSString *spokenText = result.bestTranscription.formattedString;
                [self.delegate speechManager:self
                               handleCommand:spokenText];
            }

            if (error || result.isFinal) {
                [self.audioEngine stop];
                [inputNode removeTapOnBus:0];
                self.recognitionRequest = nil;
                self.recognitionTask = nil;
            }
        }];
    
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
    return true;
}

- (void)stopListening {
    [self.audioEngine stop];
    [self.audioEngine.inputNode removeTapOnBus:0];
    [self.recognitionRequest endAudio];
}

#pragma mark - Private

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

@end
