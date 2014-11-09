ANTracker
=========

This is an integrated statistical framework for better integration or switching multiple statistical platform, has access to UMAnalytics and BaiduMobStatistics, can be very well expand to more platforms, the platform can even customize friendly stand by.

这是一个统计集成框架，用于更好地集成或者切换多个的统计平台，目前已接入友盟统计和百度移动统计，可以非常很好扩展到更多的平台，即使定制平台也能友好支持。

![Screenshot](https://dl.dropboxusercontent.com/u/59801943/Screenshots/ANTracker-1.png)
![Screenshot](https://dl.dropboxusercontent.com/u/59801943/Screenshots/ANTracker-2.png)



### Usage(用法)

``` objective-c
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 初始化并加载自己定制的统计平台，UM表示友盟，BM表示百度移动，springox(20141108)
        ANUMTracker *umTracker = [[ANUMTracker alloc] init];
        ANBMTracker *bmTracker = [[ANBMTracker alloc] init];
        ANDIYTracker *diyTracker = [[ANDIYTracker alloc] init];
        [ANTrackServer startWithTrackers:[NSArray arrayWithObjects:umTracker, bmTracker, diyTracker, nil]];
    });
```

``` objective-c
    switch (button.tag) {
        case 1:
            // 最基本的统计，由模块Id和eventId组成(平台eventId=模块+event)，springox(20141108)
            [ANTrackServer track:@"ModuleA"
                           event:@"TestEvent1"];
            break;
            
        case 2:
            // 支持带上默认参数的统计，ParamValue是默认参数的一个string值，springox(20141108)
            [ANTrackServer track:@"ModuleB"
                           event:@"TestEvent2"
                           label:@"ParamValue"];
            break;
            
        case 3:
            // 添加累计的一次性统计，accumulation表示一次性统计的累计值，springox(20141108)
            [ANTrackServer track:@"ModuleC"
                           event:@"TestEvent3"
                           label:@"Accumulation"
                    accumulation:10];
            break;
            
        case 4:
            // 添加非整数值时长的统计，durations表示统计的时长，springox(20141108)
            [ANTrackServer track:@"ModuleD"
                           event:@"TestEvent4"
                           label:@"Durations"
                       durations:3.f];
            break;
            
        case 5:
            // 事件开始的统计，支持以默认的标签参数值加以标记该次事件，springox(20141108)
            [ANTrackServer trackEventBegin:@"ModuleE"
                                     event:@"ActivityEvent"
                                     label:@"ParamValue"];
            break;
            
        case 6:
            // 事件结束的统计，支持以默认的标签参数值加以标记该次事件，springox(20141108)
            [ANTrackServer trackEventEnd:@"ModuleE"
                                   event:@"ActivityEvent"
                                   label:@"ParamValue"];
            break;
            
        case 7:
            // 自定义统计Info，springox(20141108)
            [self trackWithTrackInfo];
            break;
        
        case 8:
            // 页面的进入退出的统计例子，springox(20141108)
            [self presentPageController];
            break;
        
        default:
            break;
    }
    
```

``` objective-c
    ANDIYTrackInfo *info = [[ANDIYTrackInfo alloc] initWithType:ANTrackTypeNormal diy:@"This is diy conent!"];
    [ANTrackServer trackWithInfo:info];
```

## Contact(联系)

- [GitHub](https://github.com/SpringOx)
- [Email](jiachunke@gmail.com)
