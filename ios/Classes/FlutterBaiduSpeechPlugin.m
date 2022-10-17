//识别
#import "FlutterBaiduSpeechPlugin.h"
#import "BDSEventManager.h"
#import "BDSASRDefines.h"
#import "BDSASRParameters.h"
//唤醒
#import "BDSWakeupDefines.h"
#import "BDSWakeupParameters.h"
#import <AVKit/AVKit.h>

@interface FlutterBaiduSpeechPlugin ()
<
BDSClientASRDelegate,
BDSClientWakeupDelegate,
FlutterStreamHandler
>
@property (nonatomic, copy) FlutterEventSink eventSink;
@property (strong, nonatomic) BDSEventManager *wakeUpManager;
@property (strong, nonatomic) BDSEventManager *commandManager;
@property (nonatomic, assign) BOOL isWakeUping;
@end

@implementation FlutterBaiduSpeechPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterBaiduSpeechPlugin * instance = [[FlutterBaiduSpeechPlugin alloc] init];
    FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_baidu_speech_plugin"
            binaryMessenger:[registrar messenger]];
    FlutterEventChannel* changingChannel = [FlutterEventChannel eventChannelWithName:@"flutter_baidu_speech_plugin/event" binaryMessenger: [registrar messenger]];
      
    [changingChannel setStreamHandler: instance];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserverForName:AVAudioSessionRouteChangeNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
            NSDictionary *interuptionDict = note.userInfo;
            NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
            switch (routeChangeReason) {
                case AVAudioSessionRouteChangeReasonCategoryChange:
                {
                    NSLog(@"[AVAudioSession sharedInstance].category = %@",[AVAudioSession sharedInstance].category);
                    //让录音时视频等播放有声音
                    if ([[AVAudioSession sharedInstance].category isEqualToString:AVAudioSessionCategoryPlayAndRecord]) {
                        if (self.isWakeUping) { return; }
                        if ([self hasHeadset]) { return; }
                        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
                    }
                }
                    break;
                case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
                {
                    NSLog(@"AVAudioSessionRouteChangeReasonNewDeviceAvailable");
                    //插入耳机时关闭扬声器播放
                    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
                }
                    break;
                case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
                {
                    NSLog(@"AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
                    //拔出耳机时的处理为开启扬声器播放
                    if ([[AVAudioSession sharedInstance].category isEqualToString:AVAudioSessionCategoryPlayAndRecord]) {
                        if (self.isWakeUping) { return; }
                        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }];
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"create" isEqualToString:call.method]) {
      NSInteger type = [[call.arguments valueForKey:@"type"] integerValue];
      NSString * appId = [call.arguments valueForKey:@"appId"];
      NSString * appKey = [call.arguments valueForKey:@"appKey"];
      NSString * appSecret = [call.arguments valueForKey:@"appSecret"];
      if (type == 0) {
          //识别
          self.commandManager = [BDSEventManager createEventManagerWithName:BDS_ASR_NAME];
          [self.commandManager setParameter:@[appKey, appSecret] forKey:BDS_ASR_API_SECRET_KEYS];
          [self.commandManager setParameter:appId forKey:BDS_ASR_OFFLINE_APP_CODE];
          NSString *modelVAD_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_basic_model" ofType:@"dat"];
          [self.commandManager setParameter:modelVAD_filepath forKey:BDS_ASR_MODEL_VAD_DAT_FILE];
          [self.commandManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_MODEL_VAD];
          [self.commandManager setDelegate:self];
          NSLog(@"语音识别创建成功");
      } else if (type == 1) {
          //唤醒
          self.wakeUpManager = [BDSEventManager createEventManagerWithName:BDS_WAKEUP_NAME];
          //配置key
          [self.wakeUpManager setParameter:appId forKey:BDS_WAKEUP_APP_CODE];
          [self.wakeUpManager setParameter:@[appKey,appSecret] forKey:BDS_ASR_API_SECRET_KEYS];
          [self.wakeUpManager setParameter:appId forKey:BDS_ASR_OFFLINE_APP_CODE];
          NSString* dat = [[NSBundle mainBundle] pathForResource:@"bds_easr_basic_model" ofType:@"dat"];
          NSString* wakeupWords = [[NSBundle mainBundle] pathForResource:@"WakeUp" ofType:@".bin"];
          [self.wakeUpManager setParameter:dat forKey:BDS_WAKEUP_DAT_FILE_PATH];
          [self.wakeUpManager setParameter:wakeupWords forKey:BDS_WAKEUP_WORDS_FILE_PATH];
          [self.wakeUpManager setDelegate:self];
          NSLog(@"语音唤醒创建成功");
      }
  } else if ([@"startRecognition" isEqualToString:call.method]) {
      if (call.arguments != nil) {
          [self.commandManager setParameter:call.arguments forKey:BDS_ASR_OFFLINE_ENGINE_TRIGGERED_WAKEUP_WORD];
      }
      [self.commandManager sendCommand:BDS_ASR_CMD_START];
      NSLog(@"开始语音识别");
      
  } else if ([@"stopRecognition" isEqualToString:call.method]) {
      
      [self.commandManager sendCommand:BDS_ASR_CMD_STOP];
      NSLog(@"关闭语音识别");
      
  } else if ([@"startMonitorWakeUp" isEqualToString:call.method]) {
      
      [self.wakeUpManager sendCommand:BDS_WP_CMD_LOAD_ENGINE];
      [self.wakeUpManager sendCommand:BDS_WP_CMD_START];
      NSLog(@"开始语音唤醒");
      
  } else if ([@"stopMonitorWakeUp" isEqualToString:call.method]) {
      
      [self.wakeUpManager sendCommand:BDS_WP_CMD_STOP];
      [self.wakeUpManager sendCommand:BDS_WP_CMD_UNLOAD_ENGINE];
      NSLog(@"关闭语音唤醒");
  }
  else {
    result(FlutterMethodNotImplemented);
  }
}

#pragma mark - BDSClientWakeupDelegate
- (void)WakeupClientWorkStatus:(int)workStatus obj:(id)aObj
{
    switch (workStatus) {
        case EWakeupEngineWorkStatusStarted: {
            NSLog(@"WAKEUP CALLBACK: Started.\n");
            break;
        }
        case EWakeupEngineWorkStatusStopped: {
            NSLog(@"WAKEUP CALLBACK: Stopped.\n");
            break;
        }
        case EWakeupEngineWorkStatusLoaded: {
            NSLog(@"WAKEUP CALLBACK: Loaded.\n");
            break;
        }
        case EWakeupEngineWorkStatusUnLoaded: {
            NSLog(@"WAKEUP CALLBACK: UnLoaded.\n");
            break;
        }
        case EWakeupEngineWorkStatusTriggered: {
            NSLog(@"唤醒 = %@",aObj);
            self.isWakeUping = YES;
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
            [self configResultStatus:@"statusTriggered" type:1 data:aObj];
            break;
        }
        case EWakeupEngineWorkStatusError: {
            NSString * text = [NSString stringWithFormat:@"WAKEUP CALLBACK: encount error - %@.\n", (NSError *)aObj];
            NSLog(@"%@",text);
            NSError * error = (NSError *)aObj;
            self.isWakeUping = NO;
            [self configResultStatus:@"statusError" type:1 data:error.localizedDescription];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - BDSClientASRDelegate
- (void)VoiceRecognitionClientWorkStatus:(int)workStatus obj:(id)aObj
{
    switch (workStatus) {
        case EVoiceRecognitionClientWorkStatusNewRecordData: {
            NSLog(@"====EVoiceRecognitionClientWorkStatusNewRecordData\n");
            break;
        }
            
        case EVoiceRecognitionClientWorkStatusStartWorkIng: {
            NSLog(@"====EVoiceRecognitionClientWorkStatusStartWorkIng\n");
            break;
        }
        case EVoiceRecognitionClientWorkStatusStart: {
            NSLog(@"====EVoiceRecognitionClientWorkStatusStart:%@",@"CALLBACK: detect voice start point.\n");
            break;
        }
        case EVoiceRecognitionClientWorkStatusEnd: {
            NSLog(@"====EVoiceRecognitionClientWorkStatusEnd:%@",@"CALLBACK: detect voice end point.\n");
            break;
        }
        case EVoiceRecognitionClientWorkStatusFlushData: {
            NSLog(@"====EVoiceRecognitionClientWorkStatusFlushData%@",@"CALLBACK: partial result");
            NSLog(@"EVoiceRecognitionClientWorkStatusFlushData------=====%@",[NSString stringWithFormat:@"CALLBACK: final result - %@.\n\n", [self getDescriptionForDic:aObj]]);
            NSDictionary * result = (NSDictionary *)aObj;
            NSArray *voiceResultsArr = result[@"results_recognition"];
            self.isWakeUping = NO;
            if (voiceResultsArr.count > 0) {
                [self configResultStatus:@"flushData" type:0 data:voiceResultsArr.firstObject];
            }
            break;
        }
        case EVoiceRecognitionClientWorkStatusFinish: {
            NSLog(@"EVoiceRecognitionClientWorkStatusFinish------=====%@",[NSString stringWithFormat:@"CALLBACK: final result - %@.\n\n", [self getDescriptionForDic:aObj]]);
            
            NSDictionary * result = (NSDictionary *)aObj;
            NSArray *voiceResultsArr = result[@"results_recognition"];
            if (![self hasHeadset] && self.isWakeUping) {
                [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
            }
            self.isWakeUping = NO;
            if (voiceResultsArr.count > 0) {
                [self configResultStatus:@"statusFinish" type:0 data:voiceResultsArr.firstObject];
            }
            break;
        }
        case EVoiceRecognitionClientWorkStatusMeterLevel: {
            NSLog(@"当前音量回调------=====%ld",[aObj integerValue]);
            
            [self configResultStatus:@"volumeChanged" type:0 data:[NSString stringWithFormat:@"%@",aObj]];
            break;
        }
        case EVoiceRecognitionClientWorkStatusCancel: {
            NSLog(@"====EVoiceRecognitionClientWorkStatusCancel:%@",@"CALLBACK: user press cancel.\n");
            
            break;
        }
        case EVoiceRecognitionClientWorkStatusError: {
            NSLog(@"====EVoiceRecognitionClientWorkStatusError%@",[NSString stringWithFormat:@"CALLBACK: encount error - %@.\n", (NSError *)aObj]);
            
            NSError * error = (NSError *)aObj;
            self.isWakeUping = NO;
            [self configResultStatus:@"statusError" type:0 data:error.localizedDescription];
            break;
        }
        default:
            break;
    }
}

- (NSString *)getDescriptionForDic:(NSDictionary *)dic {
    if (dic) {
        return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic
                                                                              options:NSJSONWritingPrettyPrinted
                                                                                error:nil] encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (void)configResultStatus:(NSString *)status type:(NSInteger)type data:(NSString *)data
{
    NSDictionary * resultDic = @{@"status" : status, @"data" : data, @"type" : @(type)};
    self.eventSink(resultDic);
}

#pragma mark - listen
- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.eventSink = nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    if (_eventSink == nil) {
        self.eventSink = events;
    }
    return nil;
}

#pragma mark - privite
/**
 *  判断是否有耳机
 */
- (BOOL)hasHeadset
{
      AVAudioSession *audioSession = [AVAudioSession sharedInstance];

      AVAudioSessionRouteDescription *currentRoute = [audioSession currentRoute];

      for (AVAudioSessionPortDescription *output in currentRoute.outputs) {
            if ([[output portType] isEqualToString:AVAudioSessionPortHeadphones] ||
                [[output portType] isEqualToString:AVAudioSessionPortBluetoothA2DP]) {
                  return YES;
            }
      }
      return NO;
}

@end
