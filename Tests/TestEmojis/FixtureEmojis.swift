import MockoloFramework


let emojiVars = """
/// \(String.mockAnnotation)
protocol EmojiVars: EmojiParent {
    @available(iOS 10.0, *)
    var π: Emoji { get set }
}

"""

let emojiParentMock =
"""
import Foundation

public class EmojiParentMock: EmojiParent {
    init(ππ³π: Emoji, dict: Dictionary<String, Int> = Dictionary<String, Int>()) {
        self.dict = dict
        self._ππ³π = ππ³π
    }

    private(set) var dictSetCallCount = 0
    var dict: Dictionary<String, Int> = Dictionary<String, Int>() { didSet { dictSetCallCount += 1 } }

    private(set) var πSetCallCount = 0
    private var _π: Emoji!  { didSet { πSetCallCount += 1 } }
    var π: Emoji {
        get { return _π }
        set { _π = newValue }
    }
    
    private(set) var ππ³πSetCallCount = 0
    private(set) var _ππ³π: Emoji! { didSet { ππ³πSetCallCount += 1 } }
    var ππ³π: Emoji {
        get { return _ππ³π }
        set { _ππ³π = newValue }
    }
}

"""


let emojiVarsMock = """
@available(iOS 10.0, *)
class EmojiVarsMock: EmojiVars {
    init() { }
    init(π: Emoji) {
        self._π = π
    }


    private(set) var πSetCallCount = 0
    private var _π: Emoji!  { didSet { πSetCallCount += 1 } }
    var π: Emoji {
        get { return _π }
        set { _π = newValue }
    }
}

"""


let emojiCombMock = """
import Foundation


@available(iOS 10.0, *)
class EmojiVarsMock: EmojiVars {
    init() { }
    init(π: Emoji, dict: Dictionary<String, Int> = Dictionary<String, Int>(), π: Emoji, ππ³π: Emoji) {
        self._π = π
        self.dict = dict
        self._π = π
        self._ππ³π = ππ³π
    }


    private(set) var πSetCallCount = 0
    private var _π: Emoji!  { didSet { πSetCallCount += 1 } }
    var π: Emoji {
        get { return _π }
        set { _π = newValue }
    }
    private(set) var dictSetCallCount = 0
    var dict: Dictionary<String, Int> = Dictionary<String, Int>() { didSet { dictSetCallCount += 1 } }
    private(set) var πSetCallCount = 0
    private var _π: Emoji!  { didSet { πSetCallCount += 1 } }
    var π: Emoji {
        get { return _π }
        set { _π = newValue }
    }
    
    private(set) var ππ³πSetCallCount = 0
    private(set) var _ππ³π: Emoji! { didSet { ππ³πSetCallCount += 1 } }
    var ππ³π: Emoji {
        get { return _ππ³π }
        set { _ππ³π = newValue }
    }
}

"""

let familyEmoji =
"""
/// \(String.mockAnnotation)
protocol Family: FamilyEmoji {
    var μλνμΈμ: String { get set }
}
"""

let familyEmojiParentMock =
"""
class FamilyEmojiMock: FamilyEmoji {
    init() {}
    init(πͺπ½: Int = 0) {
        self._πͺπ½ = πͺπ½
    }
    
    var πͺπ½SetCallCount = 0
    private var _πͺπ½: Int = 0
    var πͺπ½: Int {
        get { return _πͺπ½ }
        set { _πͺπ½ = newValue }
    }
}
"""

let familyEmojiMock =
"""
class FamilyMock: Family {
    init() {}
    init(μλνμΈμ: String = "", πͺπ½: Int = 0) {
        self.μλνμΈμ = μλνμΈμ
        self.πͺπ½ = πͺπ½
    }
    
    var μλνμΈμSetCallCount = 0
    var underlyingμλνμΈμ: String = ""
    var μλνμΈμ: String {
        get {
            return underlyingμλνμΈμ
        }
        set {
            underlyingμλνμΈμ = newValue
            μλνμΈμSetCallCount += 1
        }
    }
    var πͺπ½SetCallCount = 0
    var underlyingπͺπ½: Int = 0
    var πͺπ½: Int {
        get {
            return underlyingπͺπ½
        }
        set {
            underlyingπͺπ½ = newValue
            πͺπ½SetCallCount += 1
        }
    }
}
"""


let krJp =
"""
/// \(String.mockAnnotation)
protocol Hello: Hi {
    var ε€©ζ°γ: String { get set }
}
"""

let krJpParentMock =
"""
class HiMock: Hi {
    init() {}
    init(μ°λ½νκΈ°: Int = 0) {
        self._μ°λ½νκΈ° = μ°λ½νκΈ°
    }

    var μ°λ½νκΈ°SetCallCount = 0
    private var _μ°λ½νκΈ°: Int = 0
    var μ°λ½νκΈ°: Int {
        get { return _μ°λ½νκΈ° }
        set { _μ°λ½νκΈ° = newValue }
    }
}
"""

let krJpMock =
"""

class HelloMock: Hello {
    init() {}
    init(ε€©ζ°γ: String = "", μ°λ½νκΈ°: Int = 0) {
        self.ε€©ζ°γ = ε€©ζ°γ
        self.μ°λ½νκΈ° = μ°λ½νκΈ°
    }

    var ε€©ζ°γSetCallCount = 0
    var underlyingε€©ζ°γ: String = ""
    var ε€©ζ°γ: String {
        get {
            return underlyingε€©ζ°γ
        }
        set {
            underlyingε€©ζ°γ = newValue
            ε€©ζ°γSetCallCount += 1
        }
    }
    var μ°λ½νκΈ°SetCallCount = 0
    var underlyingμ°λ½νκΈ°: Int = 0
    var μ°λ½νκΈ°: Int {
        get {
            return underlyingμ°λ½νκΈ°
        }
        set {
            underlyingμ°λ½νκΈ° = newValue
            μ°λ½νκΈ°SetCallCount += 1
        }
    }
}

"""

