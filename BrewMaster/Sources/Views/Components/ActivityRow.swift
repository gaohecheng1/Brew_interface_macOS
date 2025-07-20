import SwiftUI

struct ActivityRow: View {
    let activity: BrewActivity
    var showTime: Bool = true
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activity.icon)
                .foregroundColor(activity.iconColor)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.headline)
                
                Text(activity.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if showTime {
                Text(activity.timeString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct ActivityList: View {
    let activities: [BrewActivity]
    var emptyMessage: String = "暂无活动记录"
    
    var body: some View {
        if activities.isEmpty {
            Text(emptyMessage)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
        } else {
            ForEach(activities) { activity in
                ActivityRow(activity: activity)
                
                if activity.id != activities.last?.id {
                    Divider()
                }
            }
        }
    }
}

struct ActivityRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ActivityRow(
                activity: BrewActivity(
                    id: "1",
                    title: "安装包",
                    description: "成功安装 nginx 1.21.6",
                    icon: "plus.circle.fill",
                    iconColor: .green,
                    timeString: "5分钟前"
                )
            )
            
            Divider()
            
            ActivityRow(
                activity: BrewActivity(
                    id: "2",
                    title: "更新 Homebrew",
                    description: "Homebrew 已更新到 3.6.21",
                    icon: "arrow.triangle.2.circlepath",
                    iconColor: .blue,
                    timeString: "1小时前"
                )
            )
            
            Divider()
            
            ActivityRow(
                activity: BrewActivity(
                    id: "3",
                    title: "启动服务",
                    description: "mysql 服务已启动",
                    icon: "play.circle.fill",
                    iconColor: .green,
                    timeString: "昨天"
                )
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}