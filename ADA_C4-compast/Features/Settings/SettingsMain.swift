//
//  SettingsMain.swift
//  ADA_C4-compast
//
//  Created by Olaffiqih Wibowo on 21/08/25.
//

import SwiftUI

// MARK: - Data Models
struct CompostIssue: Identifiable {
    let id = UUID()
    let title: String
    let shortDescription: String
    let symptoms: [String]
    let causes: [String]
    let solutions: [String]
    let imageSymbol: String
}

struct IssueCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let issues: [CompostIssue]
}

// MARK: - Data
let compostData = [
    IssueCategory(
        name: "Moisture Issues",
        icon: "drop.fill",
        issues: [
            CompostIssue(
                title: "Compost Too Cold",
                shortDescription: "No heat generation • Slow decomposition • Frost on materials",
                symptoms: [
                    "Soggy materials",
                    "Water pooling",
                    "Slimy texture",
                    "No temperature rise",
                    "Decomposition halted"
                ],
                causes: [
                    "Too much rain exposure",
                    "Poor drainage",
                    "Too many wet materials",
                    "Insufficient nitrogen",
                    "Pile too small (under 3x3x3 feet)"
                ],
                solutions: [
                    "Add dry brown materials",
                    "Cover pile during heavy rain",
                    "Ensure proper drainage at base",
                    "Add nitrogen-rich materials",
                    "Build pile to minimum 3x3x3 feet"
                ],
                imageSymbol: "snowflake"
            ),
            CompostIssue(
                title: "Compost Too Hot",
                shortDescription: "Excessive steam • Very dry materials • Burning smell",
                symptoms: [
                    "Temperature over 170°F",
                    "Excessive steam",
                    "White ash appearance",
                    "Burning smell",
                    "Dried out materials"
                ],
                causes: [
                    "Too much nitrogen",
                    "Insufficient moisture",
                    "Pile too large",
                    "Not enough turning",
                    "Hot weather conditions"
                ],
                solutions: [
                    "Turn pile immediately",
                    "Add water while turning",
                    "Add carbon-rich browns",
                    "Reduce pile size",
                    "Provide shade in hot weather"
                ],
                imageSymbol: "flame.fill"
            ),
            CompostIssue(
                title: "Compost Too Wet",
                shortDescription: "Soggy pile • Slimy texture • Bad odors",
                symptoms: [
                    "Water dripping when squeezed",
                    "Slimy, matted materials",
                    "Foul odors",
                    "No air pockets",
                    "Slow decomposition"
                ],
                causes: [
                    "Excessive rain exposure",
                    "Too many green materials",
                    "Poor drainage",
                    "Overwatering",
                    "Lack of aeration"
                ],
                solutions: [
                    "Add dry brown materials",
                    "Turn pile frequently",
                    "Cover during rain",
                    "Improve drainage",
                    "Add wood chips or straw"
                ],
                imageSymbol: "drop.triangle.fill"
            ),
            CompostIssue(
                title: "Compost Too Dry",
                shortDescription: "Dusty materials • No decomposition • Ants present",
                symptoms: [
                    "Dusty, powdery texture",
                    "Materials not breaking down",
                    "Ant colonies present",
                    "Light colored materials",
                    "No heat generation"
                ],
                causes: [
                    "Insufficient water",
                    "Too many browns",
                    "Excessive sun exposure",
                    "Wind exposure",
                    "Low humidity climate"
                ],
                solutions: [
                    "Water thoroughly when turning",
                    "Add green materials",
                    "Cover pile to retain moisture",
                    "Move to shadier location",
                    "Add fresh grass clippings"
                ],
                imageSymbol: "sun.dust.fill"
            )
        ]
    ),
    IssueCategory(
        name: "Temperature Issues",
        icon: "thermometer",
        issues: [
            CompostIssue(
                title: "Won't Heat Up",
                shortDescription: "No temperature rise • Slow breakdown • Cold to touch",
                symptoms: [
                    "Temperature below 90°F",
                    "No steam visible",
                    "Materials unchanged after weeks",
                    "Cold to the touch",
                    "No microbial activity"
                ],
                causes: [
                    "Insufficient nitrogen",
                    "Pile too small",
                    "Too dry",
                    "Lack of oxygen",
                    "Cold weather"
                ],
                solutions: [
                    "Add nitrogen-rich greens",
                    "Increase pile size",
                    "Maintain proper moisture",
                    "Turn pile for aeration",
                    "Insulate in cold weather"
                ],
                imageSymbol: "thermometer.low"
            ),
            CompostIssue(
                title: "Overheating",
                shortDescription: "Temperature over 160°F • Risk of fire • Killing beneficial microbes",
                symptoms: [
                    "Temperature exceeding 170°F",
                    "Visible steam clouds",
                    "Ash-like appearance",
                    "Strong ammonia smell",
                    "Materials turning white"
                ],
                causes: [
                    "Excess nitrogen materials",
                    "Pile too dense",
                    "Insufficient turning",
                    "Too large pile",
                    "High ambient temperature"
                ],
                solutions: [
                    "Turn immediately to cool",
                    "Add browns to balance",
                    "Spread pile out temporarily",
                    "Add water while turning",
                    "Monitor with thermometer"
                ],
                imageSymbol: "thermometer.high"
            )
        ]
    ),
    IssueCategory(
        name: "Decomposition Issues",
        icon: "leaf.fill",
        issues: [
            CompostIssue(
                title: "Slow Breakdown",
                shortDescription: "Materials not decomposing • Large pieces remain • Taking months",
                symptoms: [
                    "Large pieces unchanged",
                    "Process taking many months",
                    "Materials recognizable",
                    "No volume reduction",
                    "Layers visible"
                ],
                causes: [
                    "Pieces too large",
                    "Wrong C:N ratio",
                    "Insufficient moisture",
                    "Lack of microbes",
                    "No turning"
                ],
                solutions: [
                    "Shred materials smaller",
                    "Balance greens and browns",
                    "Maintain moisture like wrung sponge",
                    "Add finished compost as starter",
                    "Turn pile weekly"
                ],
                imageSymbol: "clock.fill"
            ),
            CompostIssue(
                title: "Matted Layers",
                shortDescription: "Materials clumping • Poor air flow • Anaerobic pockets",
                symptoms: [
                    "Compressed layers",
                    "Slimy patches",
                    "Foul smell in spots",
                    "Grass clippings matted",
                    "No air circulation"
                ],
                causes: [
                    "Too much of one material",
                    "Grass clippings in thick layers",
                    "Wet leaves compressed",
                    "No mixing when adding",
                    "Materials too wet"
                ],
                solutions: [
                    "Break up matted areas",
                    "Mix materials when adding",
                    "Add bulky browns",
                    "Layer materials thinly",
                    "Turn more frequently"
                ],
                imageSymbol: "square.stack.3d.down.right.fill"
            ),
            CompostIssue(
                title: "Not Breaking Down",
                shortDescription: "No visible progress • Materials unchanged • Process stalled",
                symptoms: [
                    "No change after months",
                    "Original materials visible",
                    "No heat generation",
                    "No earthy smell",
                    "Volume unchanged"
                ],
                causes: [
                    "Lack of nitrogen",
                    "Too dry",
                    "No microorganisms",
                    "pH imbalance",
                    "Toxic materials present"
                ],
                solutions: [
                    "Add high nitrogen materials",
                    "Adjust moisture levels",
                    "Add compost activator",
                    "Test and adjust pH",
                    "Remove problematic materials"
                ],
                imageSymbol: "xmark.circle.fill"
            )
        ]
    ),
    IssueCategory(
        name: "Odor & Pest Issues",
        icon: "ant.fill",
        issues: [
            CompostIssue(
                title: "Bad Smell",
                shortDescription: "Rotten egg smell • Ammonia odor • Putrid stench",
                symptoms: [
                    "Rotten egg smell",
                    "Ammonia odor",
                    "Sewage-like stench",
                    "Sour smell",
                    "Neighbors complaining"
                ],
                causes: [
                    "Anaerobic conditions",
                    "Too much nitrogen",
                    "Meat/dairy added",
                    "Too wet",
                    "Poor aeration"
                ],
                solutions: [
                    "Turn pile immediately",
                    "Add brown materials",
                    "Remove meat/dairy",
                    "Improve drainage",
                    "Add lime to neutralize"
                ],
                imageSymbol: "nose.fill"
            ),
            CompostIssue(
                title: "Flies & Gnats",
                shortDescription: "Fruit flies • Fungus gnats • Flying insects",
                symptoms: [
                    "Clouds of small flies",
                    "Gnats around pile",
                    "Larvae visible",
                    "Flies when disturbed",
                    "Indoor infestation risk"
                ],
                causes: [
                    "Exposed food scraps",
                    "Too wet conditions",
                    "Sweet materials on top",
                    "Pile not hot enough",
                    "Fruit waste exposed"
                ],
                solutions: [
                    "Bury food scraps deep",
                    "Cover with browns",
                    "Set vinegar traps",
                    "Turn to heat pile",
                    "Add dry materials"
                ],
                imageSymbol: "ladybug.fill"
            ),
            CompostIssue(
                title: "Rodents",
                shortDescription: "Rats • Mice • Burrowing • Droppings visible",
                symptoms: [
                    "Tunnels in pile",
                    "Droppings present",
                    "Materials scattered",
                    "Gnaw marks",
                    "Nesting materials"
                ],
                causes: [
                    "Meat/dairy in pile",
                    "Cooked food added",
                    "Easy access",
                    "Warm nesting site",
                    "Food scraps exposed"
                ],
                solutions: [
                    "Remove meat/dairy/oils",
                    "Use rodent-proof bin",
                    "Turn pile frequently",
                    "Add hardware cloth barrier",
                    "Keep pile very hot"
                ],
                imageSymbol: "hare.fill"
            ),
            CompostIssue(
                title: "Ants",
                shortDescription: "Ant colonies • Dry conditions • No decomposition",
                symptoms: [
                    "Ant trails visible",
                    "Colonies in pile",
                    "Dry, dusty areas",
                    "Materials not decomposing",
                    "Eggs and larvae present"
                ],
                causes: [
                    "Pile too dry",
                    "Excess browns",
                    "Not enough moisture",
                    "Pile undisturbed",
                    "Sweet materials"
                ],
                solutions: [
                    "Water pile thoroughly",
                    "Add green materials",
                    "Turn pile to disturb",
                    "Maintain proper moisture",
                    "Remove ant colonies"
                ],
                imageSymbol: "ant.circle.fill"
            )
        ]
    )
]

// MARK: - Main Tab View
struct CompostMainTabView: View {
    @State private var selectedTab = 3
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MyCompostView()
                .tabItem {
                    Image(systemName: "leaf.circle.fill")
                    Text("My Compost")
                }
                .tag(1)
            
            ToDoView()
                .tabItem {
                    Image(systemName: "checklist")
                    Text("To Do")
                }
                .tag(2)
            
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Settings")
            }
            .tag(3)
        }
        .accentColor(.green)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @State private var isIndonesian = false  // false = EN, true = ID
    @State private var notifications = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) { // Use VStack to remove List's background
            HStack (spacing: 10) {
                Image("compost/logo-dark-green")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 32)
                Text("My Compost")
                    .font(.custom("KronaOne-Regular", size: 20))
                    .foregroundStyle(Color("BrandGreenDark"))
            }
            .padding()
            .padding(.bottom, 20)
            NavigationLink(destination: HelpView()) {
                HStack {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.secondary)
                    Text("Compost Help")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            .accentColor(.black)
            Divider()
            
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(.secondary)
                Text("Language")
                Spacer()
                
                // Corrected Custom Language Toggle (no changes here)
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 120, height: 36)
                    
                    HStack(spacing: 0) {
                        // EN Text with Tap Gesture
                        Text("🇬🇧 EN")
                            .font(.system(size: 14, weight: .medium))
                            .frame(width: 52, height: 28)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(isIndonesian ? Color.clear : Color.green)
                            )
                            .foregroundColor(isIndonesian ? .gray : .white)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isIndonesian = false
                                }
                            }
                            .padding(.leading, 4)
                        
                        Spacer()
                        
                        // ID Text with Tap Gesture
                        Text("🇮🇩 ID")
                            .font(.system(size: 14, weight: .medium))
                            .frame(width: 52, height: 28)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(isIndonesian ? Color.green : Color.clear)
                            )
                            .foregroundColor(isIndonesian ? .white : .gray)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isIndonesian = true
                                }
                            }
                            .padding(.trailing, 4)
                    }
                    .frame(width: 120)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            Divider()
            
            HStack {
                Image(systemName: "bell")
                    .foregroundColor(.secondary)
                Text("Notification")
                Spacer()
                Toggle("", isOn: $notifications)
                    .labelsHidden()
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            Divider()
            
            NavigationLink(destination: FeedbackView()) {
                HStack {
                    Image(systemName: "bubble.left")
                        .foregroundColor(.secondary)
                    Text("Feedback")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .accentColor(.black)
            }
            Divider()
            
            HStack {
                Image(systemName: "star")
                    .foregroundColor(.secondary)
                Text("Rate Compost")
                Spacer()
                Text("Version 1.0")
                    .foregroundColor(.gray)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            Spacer()
        }
//        .padding(.top, 28)
//        .navigationTitle("Settings")
//        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Help View
struct HelpView: View {
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hello there,")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Is there anything we can help you with about composting?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                            .frame(width: 60, height: 60)
                        Text("?")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.green)
                }
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search Issues", text: $searchText)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
            .background(Color.yellow.opacity(0.1))
            
            // Categories
            VStack(alignment: .leading, spacing: 8) {
                Text("Categories")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top)
                
                List {
                    ForEach(compostData) { category in
                        NavigationLink(destination: CategoryDetailView(category: category)) {
                            HStack {
                                Image(systemName: category.icon)
                                    .frame(width: 24)
                                Text(category.name)
                                Spacer()
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Category Detail View
struct CategoryDetailView: View {
    let category: IssueCategory
    
    var body: some View {
        List {
            ForEach(category.issues) { issue in
                NavigationLink(destination: IssueDetailView(issue: issue)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(issue.title)
                            .font(.headline)
                        Text(issue.shortDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Issue Detail View
struct IssueDetailView: View {
    let issue: CompostIssue
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Image placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 200)
                    
                    Image(systemName: issue.imageSymbol)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray.opacity(0.5))
                }
                .padding(.horizontal)
                
                // Symptoms
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("SYMPTOMS")
                            .font(.headline)
                            .foregroundColor(.orange)
                    }
                    
                    ForEach(issue.symptoms, id: \.self) { symptom in
                        HStack(alignment: .top) {
                            Text("•")
                                .foregroundColor(.orange)
                            Text(symptom)
                                .font(.body)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Possible Causes
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.yellow)
                        Text("Possible Cause")
                            .font(.headline)
                            .foregroundColor(.yellow)
                    }
                    
                    ForEach(issue.causes, id: \.self) { cause in
                        HStack(alignment: .top) {
                            Text("•")
                                .foregroundColor(.yellow)
                            Text(cause)
                                .font(.body)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Solutions
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Solution")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    
                    ForEach(issue.solutions, id: \.self) { solution in
                        HStack(alignment: .top) {
                            Text("•")
                                .foregroundColor(.green)
                            Text(solution)
                                .font(.body)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle(issue.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Placeholder Views
struct MyCompostView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "leaf.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.green)
                Text("My Compost")
                    .font(.title)
                    .padding()
                Text("Track your composting progress")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("My Compost")
        }
    }
}

struct ToDoView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "checklist")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.green)
                Text("To Do")
                    .font(.title)
                    .padding()
                Text("Your composting tasks")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("To Do")
        }
    }
}

struct FeedbackView: View {
    @State private var feedbackText = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("We'd love to hear your feedback!")
                .font(.headline)
                .padding(.horizontal)
            
            TextEditor(text: $feedbackText)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
            
            Button(action: {
                // Submit feedback
            }) {
                Text("Submit Feedback")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
        .navigationTitle("Feedback")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - SwiftUI Previews
struct CompostMainTabView_Previews: PreviewProvider {
    static var previews: some View {
        CompostMainTabView()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HelpView()
        }
    }
}

struct CategoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CategoryDetailView(category: compostData[0])
        }
    }
}

struct IssueDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            IssueDetailView(issue: compostData[0].issues[0])
        }
    }
}

struct MyCompostView_Previews: PreviewProvider {
    static var previews: some View {
        MyCompostView()
    }
}

struct ToDoView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoView()
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FeedbackView()
        }
    }
}
