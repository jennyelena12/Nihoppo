//
//  QuizModel.swift
//  Nihoppo
//
//  Created by Elena Angkawi on 03/09/26.
//

import Foundation
import SwiftData

enum ProficiencyLevel: String, Codable, CaseIterable{
    case absoluteBeginner = "Absolute Beginner"
    case beginner = "Beginner"
    case elementary = "Elementary"
    case intermediate = "Intermediate"
    case upperIntermediate = "Upper Intermediate"
}

enum QuestionSkill: String, Codable, CaseIterable{
    case hiragana = "Hiragana"
    case katakana = "Katakana"
    case vocabulary = "Vocabulary"
    case grammar = "Grammar"
    case reading = "Reading"
    case comprehension = "Comprehension"
}

enum QuestionDifficulty: String, Codable, CaseIterable{
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

@Model
final class Question{
    @Attribute(.unique) var id: String
    var questionText : String
    var options: [String]
    var correctAnswerIndex: Int
    var level: ProficiencyLevel
    var skill: QuestionSkill
    var difficulty: QuestionDifficulty
    init(
        id: String,
        questionText: String,
        options: [String],
        correctAnswerIndex: Int,
        level: ProficiencyLevel,
        skill: QuestionSkill,
        difficulty: QuestionDifficulty,
    ) {
        self.id = id
        self.questionText = questionText
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.level = level
        self.skill = skill
        self.difficulty = difficulty
    }
}

enum QuestionSeedData {
    static var all: [Question] {
        absoluteBeginner + beginner + elementary + intermediate + upperIntermediate
    }
    static let absoluteBeginner: [Question] = [
        Question(
            id: "AB-HIRA-01",
            questionText: "Which hiragana character makes the sound \"a\"?",
            options: ["あ", "い", "う", "え"],
            correctAnswerIndex: 0,
            level: .absoluteBeginner, skill: .hiragana, difficulty: .easy
        ),
        Question(
            id: "AB-KATA-01",
            questionText: "Which katakana character makes the sound \"ka\"?",
            options: ["サ", "カ", "タ", "ナ"],
            correctAnswerIndex: 1,
            level: .absoluteBeginner, skill: .katakana, difficulty: .easy
        ),
        Question(
            id: "AB-VOCAB-01",
            questionText: "What does「ねこ」mean?",
            options: ["Dog", "Bird", "Cat", "Fish"],
            correctAnswerIndex: 2,
            level: .absoluteBeginner, skill: .vocabulary, difficulty: .easy
        ),
        Question(
            id: "AB-GRAM-01",
            questionText: "これ＿本です。Fill in the blank.",
            options: ["を", "は", "に", "で"],
            correctAnswerIndex: 1,
            level: .absoluteBeginner, skill: .grammar, difficulty: .easy
        ),
        Question(
            id: "AB-READ-01",
            questionText: "Read: 「わたしはがくせいです。」What is the speaker?",
            options: ["Teacher", "Student", "Doctor", "Cook"],
            correctAnswerIndex: 1,
            level: .absoluteBeginner, skill: .reading, difficulty: .easy
        ),
        Question(
            id: "AB-COMP-01",
            questionText: "A: 「おはようございます。」B replies with which greeting back?",
            options: ["さようなら", "おはようございます", "おやすみなさい", "ごめんなさい"],
            correctAnswerIndex: 1,
            level: .absoluteBeginner, skill: .comprehension, difficulty: .easy
        ),
    ]
    
    static let beginner: [Question] = [
        Question(
            id: "BEG-HIRA-01",
            questionText: "How do you read「ひらがな」in romaji?",
            options: ["katakana", "hiragana", "kanji", "romaji"],
            correctAnswerIndex: 1,
            level: .beginner, skill: .hiragana, difficulty: .easy
        ),
        Question(
            id: "BEG-KATA-01",
            questionText: "「コーヒー」is written in katakana because it is:",
            options: ["A Japanese name", "A loanword", "A verb", "A particle"],
            correctAnswerIndex: 1,
            level: .beginner, skill: .katakana, difficulty: .medium
        ),
        Question(
            id: "BEG-VOCAB-01",
            questionText: "What does「たべます」mean?",
            options: ["To drink", "To eat", "To sleep", "To walk"],
            correctAnswerIndex: 1,
            level: .beginner, skill: .vocabulary, difficulty: .easy
        ),
        Question(
            id: "BEG-GRAM-01",
            questionText: "わたし＿がっこうへいきます。Fill in the blank.",
            options: ["は", "を", "も", "や"],
            correctAnswerIndex: 0,
            level: .beginner, skill: .grammar, difficulty: .medium
        ),
        Question(
            id: "BEG-READ-01",
            questionText: "Read: 「きょうはあついです。」What is being described?",
            options: ["The weather", "A meal", "A person", "A place"],
            correctAnswerIndex: 0,
            level: .beginner, skill: .reading, difficulty: .medium
        ),
        Question(
            id: "BEG-COMP-01",
            questionText: "A: 「すみません、トイレはどこですか。」This question is asking for:",
            options: ["The time", "A location", "A price", "A name"],
            correctAnswerIndex: 1,
            level: .beginner, skill: .comprehension, difficulty: .medium
        ),
    ]
    
    static let elementary:[Question] = [
        Question(
            id: "ELE-HIRA-01",
            questionText: "Which word uses a small「っ」correctly for a doubled consonant sound?",
            options: ["がっこう", "がこう", "がっっこう", "がうこう"],
            correctAnswerIndex: 0,
            level: .elementary, skill: .hiragana, difficulty: .medium
        ),
        Question(
            id: "ELE-KATA-01",
            questionText: "「レストラン」refers to:",
            options: ["A restaurant", "A station", "A hospital", "A library"],
            correctAnswerIndex: 0,
            level: .elementary, skill: .katakana, difficulty: .easy
        ),
        Question(
            id: "ELE-VOCAB-01",
            questionText: "What does「いそがしい」mean?",
            options: ["Quiet", "Busy", "Cheap", "Far"],
            correctAnswerIndex: 1,
            level: .elementary, skill: .vocabulary, difficulty: .medium
        ),
        Question(
            id: "ELE-GRAM-01",
            questionText: "あめが＿から、かさをもっていきます。Fill in the blank.",
            options: ["ふります", "ふる", "ふって", "ふった"],
            correctAnswerIndex: 1,
            level: .elementary, skill: .grammar, difficulty: .medium
        ),
        Question(
            id: "ELE-READ-01",
            questionText: "Read: 「かれはまいあさろくじにおきます。」What time does he wake up?",
            options: ["5:00", "6:00", "7:00", "8:00"],
            correctAnswerIndex: 1,
            level: .elementary, skill: .reading, difficulty: .medium
        ),
        Question(
            id: "ELE-COMP-01",
            questionText: "A: 「てんきよほうによると、あしたはあめだそうです。」What is A conveying?",
            options: ["Personal opinion", "Reported information", "A question", "A command"],
            correctAnswerIndex: 1,
            level: .elementary, skill: .comprehension, difficulty: .hard
        ),
    ]
    
    static let intermediate:[Question] = [
        Question(
            id: "INT-HIRA-01",
            questionText: "Which reading correctly matches「一生懸命」when written with furigana in hiragana?",
            options: ["いっしょうけんめい", "いちしょうけんめい", "いっしょけんめい", "いっしょうげんめい"],
            correctAnswerIndex: 0,
            level: .intermediate, skill: .hiragana, difficulty: .hard
        ),
        Question(
            id: "INT-KATA-01",
            questionText: "「シミュレーション」most closely means:",
            options: ["Simulation", "Situation", "Solution", "Celebration"],
            correctAnswerIndex: 0,
            level: .intermediate, skill: .katakana, difficulty: .medium
        ),
        Question(
            id: "INT-VOCAB-01",
            questionText: "What does「したがって」mean in written Japanese?",
            options: ["However", "Therefore", "For example", "In addition"],
            correctAnswerIndex: 1,
            level: .intermediate, skill: .vocabulary, difficulty: .hard
        ),
        Question(
            id: "INT-GRAM-01",
            questionText: "この仕事は明日＿終わらせなければなりません。Fill in the blank.",
            options: ["までに", "まで", "から", "ので"],
            correctAnswerIndex: 0,
            level: .intermediate, skill: .grammar, difficulty: .hard
        ),
        Question(
            id: "INT-READ-01",
            questionText: "Read: 「彼女は忙しいにもかかわらず、パーティーに来た。」What does this imply?",
            options: [
                "She came because she was free",
                "She came despite being busy",
                "She didn't come at all",
                "She was too busy to plan the party"
            ],
            correctAnswerIndex: 1,
            level: .intermediate, skill: .reading, difficulty: .hard
        ),
        Question(
            id: "INT-COMP-01",
            questionText: "A conversation mentions 「値上げ」several times in a news segment about supermarkets. The segment is most likely about:",
            options: ["Store closures", "Price increases", "New product launches", "Employee hiring"],
            correctAnswerIndex: 1,
            level: .intermediate, skill: .comprehension, difficulty: .hard
        ),
    ]
    
    static let upperIntermediate: [Question] = [
        Question(
                    id: "UI-HIRA-01",
                    questionText: "Which hiragana reading correctly corresponds to「曖昧」?",
                    options: ["あいまい", "あんまい", "あいめい", "あいまえ"],
                    correctAnswerIndex: 0,
                    level: .upperIntermediate, skill: .hiragana, difficulty: .hard
                ),
                Question(
                    id: "UI-KATA-01",
                    questionText: "「コンプライアンス」is a business term that means:",
                    options: ["Compliance", "Complaint", "Completion", "Comparison"],
                    correctAnswerIndex: 0,
                    level: .upperIntermediate, skill: .katakana, difficulty: .hard
                ),
                Question(
                    id: "UI-VOCAB-01",
                    questionText: "What does「否めない」mean?",
                    options: ["Cannot deny", "Cannot decide", "Cannot understand", "Cannot forgive"],
                    correctAnswerIndex: 0,
                    level: .upperIntermediate, skill: .vocabulary, difficulty: .hard
                ),
                Question(
                    id: "UI-GRAM-01",
                    questionText: "彼の説明を聞く＿、ますますわからなくなった。Fill in the blank.",
                    options: ["につけ", "たびに", "からには", "ばかりに"],
                    correctAnswerIndex: 1,
                    level: .upperIntermediate, skill: .grammar, difficulty: .hard
                ),
                Question(
                    id: "UI-READ-01",
                    questionText: "Read: 「規制緩和により、新規参入が相次いでいる。」What is happening as a result of deregulation?",
                    options: [
                        "Companies are leaving the market",
                        "New businesses are entering one after another",
                        "Regulations are being strengthened",
                        "The market is shrinking"
                    ],
                    correctAnswerIndex: 1,
                    level: .upperIntermediate, skill: .reading, difficulty: .hard
                ),
                Question(
                    id: "UI-COMP-01",
                    questionText: "In a formal lecture, the speaker repeatedly uses「〜と言わざるを得ない」when discussing an issue. This phrasing signals the speaker's tone is:",
                    options: ["Enthusiastic and hopeful", "Reluctantly critical", "Completely neutral", "Purely humorous"],
                    correctAnswerIndex: 1,
                    level: .upperIntermediate, skill: .comprehension, difficulty: .hard
                ),
    ]
    
}
