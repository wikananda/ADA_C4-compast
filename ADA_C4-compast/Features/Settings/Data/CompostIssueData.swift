//
//  CompostIssueData.swift
//  ADA_C4-compast
//
//  Settings Module - Data Models and Static Data
//

import Foundation

// MARK: - Data Models

/// Represents a specific compost issue with symptoms, causes, and solutions.
struct CompostIssue: Identifiable {
    let id = UUID()
    let title: String
    let shortDescription: String
    let symptoms: [String]
    let causes: [String]
    let solutions: [String]
    let imageSymbol: String
}

/// Represents a category of compost issues.
struct IssueCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let issues: [CompostIssue]
}

// MARK: - Static Data

/// Comprehensive database of compost issues organized by category.
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
