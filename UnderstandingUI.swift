import SwiftUI

struct ContentView: View {
  var activities = ["Archery", "Baseball", "Basketball", "Bowling", "Boxing", "Cricket", "Curling", "Fencing", "Golf", "Hiking", "Lacrosse", "Rugby", "Squash"]

  @State private var selected = "Baseball"
  @State private var id = 1
  
  var body: some View {
    Vstack {
      Text("Why not try...")
        .font(.largeTitle.bold())
      
      Vstack{
        Circle()
          .fill(.blue)
          .padding()
          .overlay(
            Image(systemName: "figure.\(selected.lowercased())")
              .font(.system(size: 144))
              .foregroundColor(.white)
          )
        Text("\(selected)!")
          .font(.title)

        .transition(.slide)
        .id(id)
      }

      Button("Try again") {
        withAnimation(.easeInOut(duration: 1)) {
          selected = activities.randomElement() ?? "Archery"
          id += 1
      
        }
      }
      .buttonStyle(.borderedProminent)
    }
  }
}

struct ContentView_Previews:
  PreviewProvider {
  static var previews: some View
    {
    ContentView()
  }
}
