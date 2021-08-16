//
//  OneWordWidget.swift
//  iWidget
//
//  Created by Littleor on 2020/6/27.
//

import WidgetKit
import SwiftUI
import Intents

struct OneWordProvider: IntentTimelineProvider {
    ///数据提供：placeholder
    func placeholder(in context: Context) -> OneWordEntry {
        return  OneWordEntry(date: Date(),data: OneWord(content: "人类的悲欢并不相通，我只觉得他们吵闹", length: 18))
    }
    
    ///数据提供：snapshot，选取小组件界面的预览视图
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (OneWordEntry) -> Void) {
        let entry = OneWordEntry(date: Date(),data: OneWord(content: "人类的悲欢并不相通，我只觉得他们吵闹", length: 18))
        completion(entry)
    }
    
    ///getTimeline
    ///方法就是Widget在桌面显示时的刷新事件，返回的是一个Timeline实例，其中包含要显示的所有条目：预期显示的时间（条目的日期）以及时间轴“过期”的时间。
    ///因为Widget程序无法像天气应用程序那样“预测”它的未来状态，因此只能用时间轴的形式告诉它什么时间显示什么数据。
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let currentDate = Date()
        //每60分钟获取数据显示，之后又重新运行一次getTimeline.(getTimeline最高的刷新频率是5分钟一次)
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 60, to: currentDate)!
        //逃逸闭包传入匿名函数 当调用completion时调用该匿名函数刷新Widget
        OneWordLoader.fetch { result in
            let oneWord: OneWord
            if case .success(let fetchedData) = result {
                oneWord = fetchedData
            } else {
                oneWord = OneWord(content: "很遗憾本次更新失败,等待下一次更新.", length: 18)
            }
            let entry = OneWordEntry(date: currentDate,data: oneWord)
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }
}

///数据模型
struct OneWordEntry: TimelineEntry {
    ///date保存的是显示数据的时间，不可删除
    public let date: Date
    
    //自定义属性
    
    public let data: OneWord
}

struct OneWordPlaceholderView : View {
    //这里是PlaceholderView - 提醒用户选择部件功能
    var body: some View {
        Text("人类的悲欢并不相通，我只觉得他们吵闹。")
    }
}

///Widget显示的View，在这个View上编辑界面，显示数据，也可以自定义View之后在这里调用。而且，一个Widget是可以直接支持3个尺寸的界面的。
struct OneWordEntryView : View {
    //这里是Widget的类型判断
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: OneWordProvider.Entry
    
    @ViewBuilder
    var body: some View {
        OneWordView(content: entry.data.content)
    }
    //    //支持3个尺寸的界面
    //    var body: some View {
    //        switch family {
    //        case .systemSmall: Text("小尺寸界面")
    //        case .systemMedium: Text("中尺寸界面")
    //        default: Text("大尺寸界面")
    //        }
    //    }
}


struct OneWordWidget: Widget {
    private let kind: String = "OneWordWidget"
    public var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: OneWordProvider()) { entry in
            OneWordEntryView(entry: entry)
        }
        .configurationDisplayName("一言")
        .description("每小时刷新一言")
        .supportedFamilies([.systemSmall, .systemMedium])
        
    }
}
