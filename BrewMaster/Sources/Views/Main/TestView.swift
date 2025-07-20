import SwiftUI

struct TestView: View {
    var body: some View {
        VStack {
            Text("测试视图")
                .font(.largeTitle)
                .padding()
            
            Text("如果你能看到这个，说明UI正在工作")
                .padding()
            
            Button("测试按钮") {
                print("测试按钮被点击")
            }
            .padding()
        }
        .onAppear {
            print("TestView appeared - UI is working!")
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}