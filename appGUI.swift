import SwiftUI

// GrowingButton style
struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .font(.title)
            .frame(maxWidth: 300, maxHeight: 50)
            .background(.black)
            .foregroundStyle(.gray)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .scaleEffect(configuration.isPressed ? 1.5 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct HomeButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .font(.title)
            .frame(maxWidth: 50, maxHeight: 50)
            .background(.black)
            .foregroundStyle(.gray)
            .clipShape(Ellipse())
            .scaleEffect(configuration.isPressed ? 1.5 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Main ContentView
struct ContentView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var body: some View {
        NavigationStack {
            VStack {
                Spacer().frame(maxHeight: 50)
                Text("Capstone Car Control").font(.title)

                NavigationLink {
                    SetupScreen()
                        .navigationBarBackButtonHidden(true)  // Hide back button in SetupScreen
                } label: {
                    Text("Setup")
                }
                .buttonStyle(GrowingButton())

                Spacer().frame(maxHeight: 200)

                // Uncomment to enable "Forwards" button
                /*
                NavigationLink {
                    ForwardsScreen()
                        .navigationBarBackButtonHidden(true)  // Hide back button in ForwardsScreen
                } label: {
                    Text("Forwards")
                }
                .buttonStyle(GrowingButton())
                */

                Spacer().frame(maxHeight: 200)

                NavigationLink {
                    BackwardsScreen()
                        .navigationBarBackButtonHidden(true)  // Hide back button in BackwardsScreen
                } label: {
                    Text("Backwards")
                }
                .buttonStyle(GrowingButton())

                Spacer()
            }
            .frame(maxWidth: 1000, maxHeight: 1000)
            .padding()
            .background(LinearGradient(gradient: Gradient(stops: [
                .init(color: Color(red: 0.1, green: 0.3, blue: 0.2), location: 0.0),
                .init(color: Color.purple, location: 0.5),
                .init(color: Color.black, location: 1.0)
            ]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .ignoresSafeArea()
        }
    }
}

// SetupScreen
struct SetupScreen: View {
    @State private var bluetoothCamera = "default camera"
    let bluetoothCameras = ["id 1", "id 2", "id 3"]
    @State private var sensor = "default sensor"
    let sensors = ["id 1", "id 2", "id 3"]
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
            NavigationStack {
                VStack {
                    Text("Setup Screen").font(.largeTitle).padding()
                    Spacer()
                    Section {
                        HStack {
                            Text("Select Camera:")
                            Picker("Select Camera:)", selection: $bluetoothCamera) {
                                ForEach(bluetoothCameras, id: \.self) { camera in
                                    Text(camera)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .frame(minWidth: 300, maxWidth: 300, minHeight: 50, maxHeight: 50)
                            .background(Color.white)
                            .foregroundColor(.black)
                            //.clipShape(.capsule)
                        }
                    }

                    Section {
                        HStack {
                            Text("Select Sensor:")
                            Picker("Select Sensor", selection: $sensor) {
                                ForEach(sensors, id: \.self) { sensor in
                                    Text(sensor)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .frame(minWidth: 300, maxWidth: 300, minHeight: 50, maxHeight: 50)
                            .background(Color.white)
                            .foregroundColor(.black)
                        }
                    }
                    Spacer()
                    NavigationLink("Testing") {
                        TestingScreen()
                            .navigationBarBackButtonHidden(true)  // Hide back button in TestingScreen
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    Spacer()

                    NavigationLink {
                        ContentView()
                            .navigationBarBackButtonHidden(true)  // Hide back button in ContentView
                    } label: {
                        Text("Home")
                    }
                    .buttonStyle(HomeButton())
                }
                .frame(maxWidth: 1000, maxHeight: 1000)
                .background(Color.gray)
                .navigationBarBackButtonHidden(true)  // Hide back button in SetupScreen
            }
        }
    }
// ForwardsScreen
struct ForwardsScreen: View {
    let distances = [0, 1, 2, 3, 4]
    @State var distance = 4
    @State private var box1Filled = false
    @State private var box2Filled = false
    @State private var box3Filled = false
    @State private var box4Filled = false
    @State private var box5Filled = false
    
    var body: some View {
        VStack {
            Section {
                Text("proximity sensor test").font(.largeTitle)
                    Spacer()
                HStack{
                    Text("Sensor Distance")
                    Picker("Sensor Distance", selection: $distance) {
                        ForEach(distances, id: \.self) { distanceOption in
                            Text("\(distanceOption)")
                        }
                    }
                    .pickerStyle(.menu)
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .frame(minWidth: 300, maxWidth: 300, minHeight: 50, maxHeight: 50)
                    .background(Color.white)
                    .foregroundColor(.black)
                }
            }

            HStack {
                Rectangle().fill(box1Filled ? Color.red : Color.gray).frame(width: 50, height: 50)
                Rectangle().fill(box2Filled ? Color.red : Color.gray).frame(width: 50, height: 50)
                Rectangle().fill(box3Filled ? Color.red : Color.gray).frame(width: 50, height: 50)
                Rectangle().fill(box4Filled ? Color.red : Color.gray).frame(width: 50, height: 50)
                Rectangle().fill(box5Filled ? Color.red : Color.gray).frame(width: 50, height: 50)
            }
            .onChange(of: distance) { newDistance in
                updateBoxes(for: newDistance)
            }
            .padding()
            Spacer()
            NavigationLink {
                ContentView()
                    .navigationBarBackButtonHidden(true)  // Hide back button in ContentView
            } label: {
                Text("Home")
            }
            .buttonStyle(HomeButton())
            Spacer()
        }
        .frame(maxWidth: 1000, maxHeight: 1000)
        .background(LinearGradient(gradient: Gradient(stops: [
            .init(color: Color(red: 0.1, green: 0.3, blue: 0.2), location: 0.0),
            .init(color: Color.purple, location: 0.5),
            .init(color: Color.black, location: 1.0)
        ]), startPoint: .topLeading, endPoint: .bottomTrailing))
    }

    func updateBoxes(for distance: Int) {
        box1Filled = distance >= 0
        box2Filled = distance >= 1
        box3Filled = distance >= 2
        box4Filled = distance >= 3
        box5Filled = distance >= 4
    }
}

// BackwardsScreen
struct BackwardsScreen: View {
    let distances = [0, 1, 2, 3, 4]
    @State var distance = 4
    @State private var box1Filled = false
    @State private var box2Filled = false
    @State private var box3Filled = false
    @State private var box4Filled = false
    @State private var box5Filled = false
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        if verticalSizeClass == .regular {
            VStack{
                Text("Put your phone in landscape mode")
                    .frame(width: 150, height:50)
                    .clipShape(.capsule)
                    .background(.black)
                    .foregroundStyle(.gray)
                
            }.background(LinearGradient(gradient: Gradient(stops: [
                .init(color: Color(red: 0.1, green: 0.3, blue: 0.2), location: 0.0),
                .init(color: Color.purple, location: 0.5),
                .init(color: Color.black, location: 1.0)
            ]), startPoint: .topLeading, endPoint: .bottomTrailing))
        } else {
            VStack {
                Text("Backwards Screen")
                    .font(.title)
                    .padding()
                Image("Child")
                    .frame(minWidth: 500, minHeight: 150)
                    .background(.gray)
                Section {
                    HStack{
                        Text("Sensor Select").font(.headline)
                        Picker("Sensor Distance", selection: $distance) {
                            ForEach(distances, id: \.self) { distanceOption in
                                Text("\(distanceOption)")
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }

                HStack {
                    Rectangle().fill(box1Filled ? Color.red : Color.gray).frame(width: 50, height: 50)
                    Rectangle().fill(box2Filled ? Color.red : Color.gray).frame(width: 50, height: 50)
                    Rectangle().fill(box3Filled ? Color.red : Color.gray).frame(width: 50, height: 50)
                    Rectangle().fill(box4Filled ? Color.red : Color.gray).frame(width: 50, height: 50)
                    Rectangle().fill(box5Filled ? Color.red : Color.gray).frame(width: 50, height: 50)
                }
                .onChange(of: distance) { newDistance in
                    updateBoxes(for: newDistance)
                }
                .padding()
                
                NavigationLink {
                    ContentView()
                        .navigationBarBackButtonHidden(true)  // Hide back button in ContentView
                } label: {
                    Text("Home")
                }
                .buttonStyle(HomeButton())
            }
            Spacer()
        }
        
        }
    func updateBoxes(for distance: Int) {
        box1Filled = distance >= 0
        box2Filled = distance >= 1
        box3Filled = distance >= 2
        box4Filled = distance >= 3
        box5Filled = distance >= 4
    }
}

// TestingScreen
struct TestingScreen: View {
    var body: some View {
        VStack {
            VStack {
                Text("Testing Screen")
                    .font(.title)
                    .padding()
                    .frame(width: 200, height: 50)
                    .background(Color.red.opacity(0.5))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                Spacer()
                NavigationLink("Forwards") {
                    ForwardsScreen()
                        .navigationBarBackButtonHidden(true)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}

// Preview
#Preview {
    ContentView()
}

