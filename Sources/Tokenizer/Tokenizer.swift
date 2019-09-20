import Foundation

//struct Token<V> {
//    var text: String
//    var value: V
//
//    init(_ text: String, value: V) {
//        self.text = text
//        self.value = value
//    }
//}

private let MAX_TOKEN_LEN = 80

class Tokenizer<Token> {
    
    public enum TokenizationError: Error {
        case UnrecognizedInputError(String)
    }
    
    typealias Action = (String)->Token
    typealias RuleInitializer = (String, Action?)
    
    private struct Rule<Token> {
        let regex: NSRegularExpression
        let action: Action?
    }

    private let rules: [Rule<Token>]
    private let inputStream: InputStream
    private var inputBuffer: [UInt8]!
    private var inputBufferContentsSize: Int = 0
    

    init?(rules: [RuleInitializer], inputStream: InputStream) throws {
        
        self.rules = try rules.map { initializer in
            let regex = try NSRegularExpression(pattern: initializer.0, options: [])
            return Rule(regex: regex, action: initializer.1)
        }
        self.inputStream = inputStream
        
        self.inputStream.open()

        var buffer = [UInt8](repeating: 0, count: MAX_TOKEN_LEN)
        self.inputBufferContentsSize = 0
        let readCount = self.inputStream.read(&buffer, maxLength: MAX_TOKEN_LEN)
        self.inputBuffer = buffer
        switch readCount {
        case 0, -1:  // reached end of stream
                     // TODO: handle errors differently to just running out of input
            break
            
        default:
            inputBufferContentsSize = readCount
        }
    }
    
    deinit {
        inputStream.close()
    }

    func next() throws -> Token? {
        
        if inputBufferContentsSize == 0 { // Have we consumed the entire input stream?
            return nil // if so, returning nil indicates normal end-of-stream
        }
        
        repeat {
            // try each rule in turn
            // if no rule recognises any input at all, either we are done or in error
            // This will get us out of the Forever loop, one way or another
            let (consumed, consumedText, ruleIndex) = bestRule()
            
            inputBufferContentsSize -= consumed
            
            if consumed == 0 {
                if inputBufferContentsSize > 0 {
                    throw TokenizationError.UnrecognizedInputError(String(cString: self.inputBuffer))
                } else {
                    return nil
                }
            }
            
            // otherwise, the rule that consumed the most text is the one we want
            // Call the action procedure for that rule and return the result, if it is non-nil
            // We handle the case of action rules that return nil but ignoring this result, and trying
            // to recognise more.
            
            self.inputBuffer.removeFirst(consumed)
            
            var more = [UInt8](repeating: 0, count: consumed)
            let readCount = inputStream.read(&more, maxLength: consumed)
            switch readCount {
            case 0, -1:  // reached end of stream
                         // TODO: handle errors differently to just running out of input
                break
            default:
                inputBufferContentsSize += readCount
            }
            self.inputBuffer.append(contentsOf: more)
            
            if let token = rules[ruleIndex].action?(consumedText) {
                return token // we've recognised the biggest possible token, return it
            } else {
                // just consume input and continue looking
            }
        } while true
    }
    
    func bestRule() -> (Int, String, Int) {
        var maxConsumed = 0
        var maxConsumingRuleIndex: Int?
        var greatestConsumedText: String?
        
        for (ridx, r) in rules.enumerated() {
            
            var consumed = 0
            r.regex.enumerateMatches(in: String(bytes: inputBuffer, encoding: .utf8)!,
                                     options: .anchored,
                                     range: NSMakeRange(0,inputBufferContentsSize))
                { (textCheckingResult, matchingFlags, pStop) in
                    pStop.pointee = true
                    let matchedRange = textCheckingResult!.range
                    if matchedRange.length > consumed {
                        consumed = matchedRange.length
                    }
                }
            if consumed > maxConsumed {
                maxConsumed = consumed
                maxConsumingRuleIndex = ridx
                greatestConsumedText = String(bytes: inputBuffer.prefix(upTo: maxConsumed), encoding: .utf8)
            }
        }
        
        return (maxConsumed, greatestConsumedText ?? "", maxConsumingRuleIndex ?? 0)
    }
}
