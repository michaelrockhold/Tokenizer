import XCTest
@testable import Tokenizer

final class TokenizerTests: XCTestCase {
    
    enum TestToken : Equatable {
        case name(String)
        case plus
        case divide
        case integer(Int)
        case float(Float)
    }
    
    func makeTokenizer(stream: InputStream) -> Tokenizer<TestToken>? {
        do {
            if let t = try Tokenizer<TestToken>(rules: [
                ("[abcdef]+",                                   { text in .name(text) }),
                ("\\+",                                         { text in .plus }),
                ("/",                                           { text in .divide }),
                ("[0123456789][0123456789]*",                   { text in .integer(Int(text)!) }),
                ("[0123456789][0123456789]*\\.[0123456789]+",   { text in .float(Float(text)!) }),
                ("[ \t\n]+",                                    nil),
            ],
                                            inputStream: stream) {
                return t
            } else {
                XCTFail()
            }
        } catch {
            print("Unexpected error: \(error).")
            XCTFail()
        }
        return nil
    }
    
    func testSimplest() {
        
        guard let t = makeTokenizer(stream: InputStream(data: "abc + 5 / 12.2".data(using: .macOSRoman)!)) else {
            return
        }
        
        var tokens = [TestToken]()
        do {
            if let token = try t.next() { tokens.append(token) }
            if let token = try t.next() { tokens.append(token) }
            if let token = try t.next() { tokens.append(token) }
            if let token = try t.next() { tokens.append(token) }
            if let token = try t.next() { tokens.append(token) }
            if let token = try t.next() { tokens.append(token) }

        } catch {
            print("Unexpected error: \(error).")
            XCTFail(); return
        }

        XCTAssertEqual(tokens.count, 5)
        XCTAssertEqual(tokens[0], .name("abc"))
        XCTAssertEqual(tokens[4], .float(12.2))
    }

    func simpleTokenCountTester(input: String, expectedTokenCount: Int) {
        guard let t = makeTokenizer(stream: InputStream(data: input.data(using: .macOSRoman)!)) else {
            return
        }

        var tokens = [TestToken]()
        do {
            while let token = try t.next() {
                tokens.append(token)
            }
        } catch {
            print("Unexpected error: \(error).")
            XCTFail(); return
        }

        XCTAssertEqual(tokens.count, expectedTokenCount)
    }
    
    func testShortStream() {
        simpleTokenCountTester(input: "     ", expectedTokenCount: 0)
    }

    func testLongStream() {
        simpleTokenCountTester(input: "abc      abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc\n abc abc abc abc abc    \n abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc     ",
                               expectedTokenCount: 90)
    }

    static var allTests = [
        ("testSimplest", testSimplest),
        ("testShortStream", testShortStream),
        ("testLongStream", testLongStream)
    ]
}
