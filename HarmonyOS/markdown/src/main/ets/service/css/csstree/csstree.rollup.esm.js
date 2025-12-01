// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

// CSS Syntax Module Level 3
// https://www.w3.org/TR/css-syntax-3/
const EOF$1 = 0;                 // <EOF-token>
const Ident = 1;               // <ident-token>
const Function$1 = 2;            // <function-token>
const AtKeyword = 3;           // <at-keyword-token>
const Hash$1 = 4;                // <hash-token>
const String$2 = 5;              // <string-token>
const BadString = 6;           // <bad-string-token>
const Url$1 = 7;                 // <url-token>
const BadUrl = 8;              // <bad-url-token>
const Delim = 9;               // <delim-token>
const Number$2 = 10;             // <number-token>
const Percentage$1 = 11;         // <percentage-token>
const Dimension$1 = 12;          // <dimension-token>
const WhiteSpace$1 = 13;         // <whitespace-token>
const CDO$1 = 14;                // <CDO-token>
const CDC$1 = 15;                // <CDC-token>
const Colon = 16;              // <colon-token>     :
const Semicolon = 17;          // <semicolon-token> ;
const Comma = 18;              // <comma-token>     ,
const LeftSquareBracket = 19;  // <[-token>
const RightSquareBracket = 20; // <]-token>
const LeftParenthesis = 21;    // <(-token>
const RightParenthesis = 22;   // <)-token>
const LeftCurlyBracket = 23;   // <{-token>
const RightCurlyBracket = 24;  // <}-token>
const Comment$1 = 25;

var types = /*#__PURE__*/Object.freeze({
    __proto__: null,
    EOF: EOF$1,
    Ident: Ident,
    Function: Function$1,
    AtKeyword: AtKeyword,
    Hash: Hash$1,
    String: String$2,
    BadString: BadString,
    Url: Url$1,
    BadUrl: BadUrl,
    Delim: Delim,
    Number: Number$2,
    Percentage: Percentage$1,
    Dimension: Dimension$1,
    WhiteSpace: WhiteSpace$1,
    CDO: CDO$1,
    CDC: CDC$1,
    Colon: Colon,
    Semicolon: Semicolon,
    Comma: Comma,
    LeftSquareBracket: LeftSquareBracket,
    RightSquareBracket: RightSquareBracket,
    LeftParenthesis: LeftParenthesis,
    RightParenthesis: RightParenthesis,
    LeftCurlyBracket: LeftCurlyBracket,
    RightCurlyBracket: RightCurlyBracket,
    Comment: Comment$1
});

const EOF = 0;

// https://drafts.csswg.org/css-syntax-3/
// § 4.2. Definitions

// digit
// A code point between U+0030 DIGIT ZERO (0) and U+0039 DIGIT NINE (9).
function isDigit(code) {
    return code >= 0x0030 && code <= 0x0039;
}

// hex digit
// A digit, or a code point between U+0041 LATIN CAPITAL LETTER A (A) and U+0046 LATIN CAPITAL LETTER F (F),
// or a code point between U+0061 LATIN SMALL LETTER A (a) and U+0066 LATIN SMALL LETTER F (f).
function isHexDigit(code) {
    return (
        isDigit(code) || // 0 .. 9
        (code >= 0x0041 && code <= 0x0046) || // A .. F
        (code >= 0x0061 && code <= 0x0066)    // a .. f
    );
}

// uppercase letter
// A code point between U+0041 LATIN CAPITAL LETTER A (A) and U+005A LATIN CAPITAL LETTER Z (Z).
function isUppercaseLetter(code) {
    return code >= 0x0041 && code <= 0x005A;
}

// lowercase letter
// A code point between U+0061 LATIN SMALL LETTER A (a) and U+007A LATIN SMALL LETTER Z (z).
function isLowercaseLetter(code) {
    return code >= 0x0061 && code <= 0x007A;
}

// letter
// An uppercase letter or a lowercase letter.
function isLetter(code) {
    return isUppercaseLetter(code) || isLowercaseLetter(code);
}

// non-ASCII code point
// A code point with a value equal to or greater than U+0080 <control>.
//
// 2024-09-02: The latest spec narrows the range for non-ASCII characters (see https://github.com/csstree/csstree/issues/188).
// However, all modern browsers support a wider range, and strictly following the latest spec could result
// in some CSS being parsed incorrectly, even though it works in the browser. Therefore, this function adheres
// to the previous, broader definition of non-ASCII characters.
function isNonAscii(code) {
    return code >= 0x0080;
}

// name-start code point
// A letter, a non-ASCII code point, or U+005F LOW LINE (_).
function isNameStart(code) {
    return isLetter(code) || isNonAscii(code) || code === 0x005F;
}

// name code point
// A name-start code point, a digit, or U+002D HYPHEN-MINUS (-).
function isName(code) {
    return isNameStart(code) || isDigit(code) || code === 0x002D;
}

// non-printable code point
// A code point between U+0000 NULL and U+0008 BACKSPACE, or U+000B LINE TABULATION,
// or a code point between U+000E SHIFT OUT and U+001F INFORMATION SEPARATOR ONE, or U+007F DELETE.
function isNonPrintable(code) {
    return (
        (code >= 0x0000 && code <= 0x0008) ||
        (code === 0x000B) ||
        (code >= 0x000E && code <= 0x001F) ||
        (code === 0x007F)
    );
}

// newline
// U+000A LINE FEED. Note that U+000D CARRIAGE RETURN and U+000C FORM FEED are not included in this definition,
// as they are converted to U+000A LINE FEED during preprocessing.
// TODO: we doesn't do a preprocessing, so check a code point for U+000D CARRIAGE RETURN and U+000C FORM FEED
function isNewline(code) {
    return code === 0x000A || code === 0x000D || code === 0x000C;
}

// whitespace
// A newline, U+0009 CHARACTER TABULATION, or U+0020 SPACE.
function isWhiteSpace(code) {
    return isNewline(code) || code === 0x0020 || code === 0x0009;
}

// § 4.3.8. Check if two code points are a valid escape
function isValidEscape(first, second) {
    // If the first code point is not U+005C REVERSE SOLIDUS (\), return false.
    if (first !== 0x005C) {
        return false;
    }

    // Otherwise, if the second code point is a newline or EOF, return false.
    if (isNewline(second) || second === EOF) {
        return false;
    }

    // Otherwise, return true.
    return true;
}

// § 4.3.9. Check if three code points would start an identifier
function isIdentifierStart(first, second, third) {
    // Look at the first code point:

    // U+002D HYPHEN-MINUS
    if (first === 0x002D) {
        // If the second code point is a name-start code point or a U+002D HYPHEN-MINUS,
        // or the second and third code points are a valid escape, return true. Otherwise, return false.
        return (
            isNameStart(second) ||
            second === 0x002D ||
            isValidEscape(second, third)
        );
    }

    // name-start code point
    if (isNameStart(first)) {
        // Return true.
        return true;
    }

    // U+005C REVERSE SOLIDUS (\)
    if (first === 0x005C) {
        // If the first and second code points are a valid escape, return true. Otherwise, return false.
        return isValidEscape(first, second);
    }

    // anything else
    // Return false.
    return false;
}

// § 4.3.10. Check if three code points would start a number
function isNumberStart(first, second, third) {
    // Look at the first code point:

    // U+002B PLUS SIGN (+)
    // U+002D HYPHEN-MINUS (-)
    if (first === 0x002B || first === 0x002D) {
        // If the second code point is a digit, return true.
        if (isDigit(second)) {
            return 2;
        }

        // Otherwise, if the second code point is a U+002E FULL STOP (.)
        // and the third code point is a digit, return true.
        // Otherwise, return false.
        return second === 0x002E && isDigit(third) ? 3 : 0;
    }

    // U+002E FULL STOP (.)
    if (first === 0x002E) {
        // If the second code point is a digit, return true. Otherwise, return false.
        return isDigit(second) ? 2 : 0;
    }

    // digit
    if (isDigit(first)) {
        // Return true.
        return 1;
    }

    // anything else
    // Return false.
    return 0;
}

//
// Misc
//

// detect BOM (https://en.wikipedia.org/wiki/Byte_order_mark)
function isBOM(code) {
    // UTF-16BE
    if (code === 0xFEFF) {
        return 1;
    }

    // UTF-16LE
    if (code === 0xFFFE) {
        return 1;
    }

    return 0;
}

// Fast code category
// Only ASCII code points has a special meaning, that's why we define a maps for 0..127 codes only
const CATEGORY = new Array(0x80);
const EofCategory = 0x80;
const WhiteSpaceCategory = 0x82;
const DigitCategory = 0x83;
const NameStartCategory = 0x84;
const NonPrintableCategory = 0x85;

for (let i = 0; i < CATEGORY.length; i++) {
    CATEGORY[i] =
        isWhiteSpace(i) && WhiteSpaceCategory ||
        isDigit(i) && DigitCategory ||
        isNameStart(i) && NameStartCategory ||
        isNonPrintable(i) && NonPrintableCategory ||
        i || EofCategory;
}

function charCodeCategory(code) {
    return code < 0x80 ? CATEGORY[code] : NameStartCategory;
}

function getCharCode(source, offset) {
    return offset < source.length ? source.charCodeAt(offset) : 0;
}

function getNewlineLength(source, offset, code) {
    if (code === 13 /* \r */ && getCharCode(source, offset + 1) === 10 /* \n */) {
        return 2;
    }

    return 1;
}

function cmpChar(testStr, offset, referenceCode) {
    let code = testStr.charCodeAt(offset);

    // code.toLowerCase() for A..Z
    if (isUppercaseLetter(code)) {
        code = code | 32;
    }

    return code === referenceCode;
}

function cmpStr(testStr, start, end, referenceStr) {
    if (end - start !== referenceStr.length) {
        return false;
    }

    if (start < 0 || end > testStr.length) {
        return false;
    }

    for (let i = start; i < end; i++) {
        const referenceCode = referenceStr.charCodeAt(i - start);
        let testCode = testStr.charCodeAt(i);

        // testCode.toLowerCase() for A..Z
        if (isUppercaseLetter(testCode)) {
            testCode = testCode | 32;
        }

        if (testCode !== referenceCode) {
            return false;
        }
    }

    return true;
}

function findWhiteSpaceStart(source, offset) {
    for (; offset >= 0; offset--) {
        if (!isWhiteSpace(source.charCodeAt(offset))) {
            break;
        }
    }

    return offset + 1;
}

function findWhiteSpaceEnd(source, offset) {
    for (; offset < source.length; offset++) {
        if (!isWhiteSpace(source.charCodeAt(offset))) {
            break;
        }
    }

    return offset;
}

function findDecimalNumberEnd(source, offset) {
    for (; offset < source.length; offset++) {
        if (!isDigit(source.charCodeAt(offset))) {
            break;
        }
    }

    return offset;
}

// § 4.3.7. Consume an escaped code point
function consumeEscaped(source, offset) {
    // It assumes that the U+005C REVERSE SOLIDUS (\) has already been consumed and
    // that the next input code point has already been verified to be part of a valid escape.
    offset += 2;

    // hex digit
    if (isHexDigit(getCharCode(source, offset - 1))) {
        // Consume as many hex digits as possible, but no more than 5.
        // Note that this means 1-6 hex digits have been consumed in total.
        for (const maxOffset = Math.min(source.length, offset + 5); offset < maxOffset; offset++) {
            if (!isHexDigit(getCharCode(source, offset))) {
                break;
            }
        }

        // If the next input code point is whitespace, consume it as well.
        const code = getCharCode(source, offset);
        if (isWhiteSpace(code)) {
            offset += getNewlineLength(source, offset, code);
        }
    }

    return offset;
}

// §4.3.11. Consume a name
// Note: This algorithm does not do the verification of the first few code points that are necessary
// to ensure the returned code points would constitute an <ident-token>. If that is the intended use,
// ensure that the stream starts with an identifier before calling this algorithm.
function consumeName(source, offset) {
    // Let result initially be an empty string.
    // Repeatedly consume the next input code point from the stream:
    for (; offset < source.length; offset++) {
        const code = source.charCodeAt(offset);

        // name code point
        if (isName(code)) {
            // Append the code point to result.
            continue;
        }

        // the stream starts with a valid escape
        if (isValidEscape(code, getCharCode(source, offset + 1))) {
            // Consume an escaped code point. Append the returned code point to result.
            offset = consumeEscaped(source, offset) - 1;
            continue;
        }

        // anything else
        // Reconsume the current input code point. Return result.
        break;
    }

    return offset;
}

// §4.3.12. Consume a number
function consumeNumber(source, offset) {
    let code = source.charCodeAt(offset);

    // 2. If the next input code point is U+002B PLUS SIGN (+) or U+002D HYPHEN-MINUS (-),
    // consume it and append it to repr.
    if (code === 0x002B || code === 0x002D) {
        code = source.charCodeAt(offset += 1);
    }

    // 3. While the next input code point is a digit, consume it and append it to repr.
    if (isDigit(code)) {
        offset = findDecimalNumberEnd(source, offset + 1);
        code = source.charCodeAt(offset);
    }

    // 4. If the next 2 input code points are U+002E FULL STOP (.) followed by a digit, then:
    if (code === 0x002E && isDigit(source.charCodeAt(offset + 1))) {
        // 4.1 Consume them.
        // 4.2 Append them to repr.
        offset += 2;

        // 4.3 Set type to "number".
        // TODO

        // 4.4 While the next input code point is a digit, consume it and append it to repr.

        offset = findDecimalNumberEnd(source, offset);
    }

    // 5. If the next 2 or 3 input code points are U+0045 LATIN CAPITAL LETTER E (E)
    // or U+0065 LATIN SMALL LETTER E (e), ... , followed by a digit, then:
    if (cmpChar(source, offset, 101 /* e */)) {
        let sign = 0;
        code = source.charCodeAt(offset + 1);

        // ... optionally followed by U+002D HYPHEN-MINUS (-) or U+002B PLUS SIGN (+) ...
        if (code === 0x002D || code === 0x002B) {
            sign = 1;
            code = source.charCodeAt(offset + 2);
        }

        // ... followed by a digit
        if (isDigit(code)) {
            // 5.1 Consume them.
            // 5.2 Append them to repr.

            // 5.3 Set type to "number".
            // TODO

            // 5.4 While the next input code point is a digit, consume it and append it to repr.
            offset = findDecimalNumberEnd(source, offset + 1 + sign + 1);
        }
    }

    return offset;
}

// § 4.3.14. Consume the remnants of a bad url
// ... its sole use is to consume enough of the input stream to reach a recovery point
// where normal tokenizing can resume.
function consumeBadUrlRemnants(source, offset) {
    // Repeatedly consume the next input code point from the stream:
    for (; offset < source.length; offset++) {
        const code = source.charCodeAt(offset);

        // U+0029 RIGHT PARENTHESIS ())
        // EOF
        if (code === 0x0029) {
            // Return.
            offset++;
            break;
        }

        if (isValidEscape(code, getCharCode(source, offset + 1))) {
            // Consume an escaped code point.
            // Note: This allows an escaped right parenthesis ("\)") to be encountered
            // without ending the <bad-url-token>. This is otherwise identical to
            // the "anything else" clause.
            offset = consumeEscaped(source, offset);
        }
    }

    return offset;
}

// § 4.3.7. Consume an escaped code point
// Note: This algorithm assumes that escaped is valid without leading U+005C REVERSE SOLIDUS (\)
function decodeEscaped(escaped) {
    // Single char escaped that's not a hex digit
    if (escaped.length === 1 && !isHexDigit(escaped.charCodeAt(0))) {
        return escaped[0];
    }

    // Interpret the hex digits as a hexadecimal number.
    let code = parseInt(escaped, 16);

    if (
        (code === 0) ||                       // If this number is zero,
        (code >= 0xD800 && code <= 0xDFFF) || // or is for a surrogate,
        (code > 0x10FFFF)                     // or is greater than the maximum allowed code point
    ) {
        // ... return U+FFFD REPLACEMENT CHARACTER
        code = 0xFFFD;
    }

    // Otherwise, return the code point with that value.
    return String.fromCodePoint(code);
}

var tokenNames = [
    'EOF-token',
    'ident-token',
    'function-token',
    'at-keyword-token',
    'hash-token',
    'string-token',
    'bad-string-token',
    'url-token',
    'bad-url-token',
    'delim-token',
    'number-token',
    'percentage-token',
    'dimension-token',
    'whitespace-token',
    'CDO-token',
    'CDC-token',
    'colon-token',
    'semicolon-token',
    'comma-token',
    '[-token',
    ']-token',
    '(-token',
    ')-token',
    '{-token',
    '}-token',
    'comment-token'
];

const MIN_SIZE = 16 * 1024;

function adoptBuffer(buffer = null, size) {
    if (buffer === null || buffer.length < size) {
        return new Uint32Array(Math.max(size + 1024, MIN_SIZE));
    }

    return buffer;
}

const N$4 = 10;
const F$2 = 12;
const R$2 = 13;

function computeLinesAndColumns(host) {
    const source = host.source;
    const sourceLength = source.length;
    const startOffset = source.length > 0 ? isBOM(source.charCodeAt(0)) : 0;
    const lines = adoptBuffer(host.lines, sourceLength);
    const columns = adoptBuffer(host.columns, sourceLength);
    let line = host.startLine;
    let column = host.startColumn;

    for (let i = startOffset; i < sourceLength; i++) {
        const code = source.charCodeAt(i);

        lines[i] = line;
        columns[i] = column++;

        if (code === N$4 || code === R$2 || code === F$2) {
            if (code === R$2 && i + 1 < sourceLength && source.charCodeAt(i + 1) === N$4) {
                i++;
                lines[i] = line;
                columns[i] = column;
            }

            line++;
            column = 1;
        }
    }

    lines[sourceLength] = line;
    columns[sourceLength] = column;

    host.lines = lines;
    host.columns = columns;
    host.computed = true;
}

class OffsetToLocation {
    constructor(source, startOffset, startLine, startColumn) {
        this.setSource(source, startOffset, startLine, startColumn);
        this.lines = null;
        this.columns = null;
    }
    setSource(source = '', startOffset = 0, startLine = 1, startColumn = 1) {
        this.source = source;
        this.startOffset = startOffset;
        this.startLine = startLine;
        this.startColumn = startColumn;
        this.computed = false;
    }
    getLocation(offset, filename) {
        if (!this.computed) {
            computeLinesAndColumns(this);
        }

        return {
            source: filename,
            offset: this.startOffset + offset,
            line: this.lines[offset],
            column: this.columns[offset]
        };
    }
    getLocationRange(start, end, filename) {
        if (!this.computed) {
            computeLinesAndColumns(this);
        }

        return {
            source: filename,
            start: {
                offset: this.startOffset + start,
                line: this.lines[start],
                column: this.columns[start]
            },
            end: {
                offset: this.startOffset + end,
                line: this.lines[end],
                column: this.columns[end]
            }
        };
    }
}

const OFFSET_MASK = 0x00FFFFFF;
const TYPE_SHIFT = 24;
const BLOCK_OPEN_TOKEN = 1;
const BLOCK_CLOSE_TOKEN = 2;
const balancePair$1 = new Uint8Array(32); // 32b of memory ought to be enough for anyone (any number of tokens)
balancePair$1[Function$1] = RightParenthesis;
balancePair$1[LeftParenthesis] = RightParenthesis;
balancePair$1[LeftSquareBracket] = RightSquareBracket;
balancePair$1[LeftCurlyBracket] = RightCurlyBracket;

const blockTokens = new Uint8Array(32);
blockTokens[Function$1] = BLOCK_OPEN_TOKEN;
blockTokens[LeftParenthesis] = BLOCK_OPEN_TOKEN;
blockTokens[LeftSquareBracket] = BLOCK_OPEN_TOKEN;
blockTokens[LeftCurlyBracket] = BLOCK_OPEN_TOKEN;
blockTokens[RightParenthesis] = BLOCK_CLOSE_TOKEN;
blockTokens[RightSquareBracket] = BLOCK_CLOSE_TOKEN;
blockTokens[RightCurlyBracket] = BLOCK_CLOSE_TOKEN;

function boundIndex(index, min, max) {
    return index < min ? min : index > max ? max : index;
}

class TokenStream {
    constructor(source, tokenize) {
        this.setSource(source, tokenize);
    }
    reset() {
        this.eof = false;
        this.tokenIndex = -1;
        this.tokenType = 0;
        this.tokenStart = this.firstCharOffset;
        this.tokenEnd = this.firstCharOffset;
    }
    setSource(source = '', tokenize = () => {}) {
        source = String(source || '');

        const sourceLength = source.length;
        const offsetAndType = adoptBuffer(this.offsetAndType, source.length + 1); // +1 because of eof-token
        const balance = adoptBuffer(this.balance, source.length + 1);
        let tokenCount = 0;
        let firstCharOffset = -1;
        let balanceCloseType = 0;
        let balanceStart = source.length;

        // capture buffers
        this.offsetAndType = null;
        this.balance = null;
        balance.fill(0);

        tokenize(source, (type, start, end) => {
            const index = tokenCount++;

            // type & offset
            offsetAndType[index] = (type << TYPE_SHIFT) | end;

            if (firstCharOffset === -1) {
                firstCharOffset = start;
            }

            // balance
            balance[index] = balanceStart;

            if (type === balanceCloseType) {
                const prevBalanceStart = balance[balanceStart];

                // set reference to balance end for a block opener
                balance[balanceStart] = index;

                // pop state
                balanceStart = prevBalanceStart;
                balanceCloseType = balancePair$1[offsetAndType[prevBalanceStart] >> TYPE_SHIFT];
            } else if (this.isBlockOpenerTokenType(type)) { // check for FunctionToken, <(-token>, <[-token> and <{-token>
                // push state
                balanceStart = index;
                balanceCloseType = balancePair$1[type];
            }
        });

        // finalize buffers
        offsetAndType[tokenCount] = (EOF$1 << TYPE_SHIFT) | sourceLength; // <EOF-token>
        balance[tokenCount] = tokenCount; // prevents false positive balance match with any token

        // reverse references from balance start to end
        // tokens
        //   token:   a ( [ b c ] d e ) {
        //   index:   0 1 2 3 4 5 6 7 8 9
        // before
        //   balance: 0 8 5 2 2 2 1 1 1 0
        //            - > > < < < < < < -
        // after
        //   balance: 9 8 5 5 5 2 8 8 1 9
        //            > > > > > < > > < >
        for (let i = 0; i < tokenCount; i++) {
            const balanceStart = balance[i];

            if (balanceStart <= i) {
                const balanceEnd = balance[balanceStart];

                if (balanceEnd !== i) {
                    balance[i] = balanceEnd;
                }
            } else if (balanceStart > tokenCount) {
                balance[i] = tokenCount;
            }
        }

        // balance[0] = tokenCount;

        this.source = source;
        this.firstCharOffset = firstCharOffset === -1 ? 0 : firstCharOffset;
        this.tokenCount = tokenCount;
        this.offsetAndType = offsetAndType;
        this.balance = balance;

        this.reset();
        this.next();
    }

    lookupType(offset) {
        offset += this.tokenIndex;

        if (offset < this.tokenCount) {
            return this.offsetAndType[offset] >> TYPE_SHIFT;
        }

        return EOF$1;
    }
    lookupTypeNonSC(idx) {
        for (let offset = this.tokenIndex; offset < this.tokenCount; offset++) {
            const tokenType = this.offsetAndType[offset] >> TYPE_SHIFT;

            if (tokenType !== WhiteSpace$1 && tokenType !== Comment$1) {
                if (idx-- === 0) {
                    return tokenType;
                }
            }
        }

        return EOF$1;
    }
    lookupOffset(offset) {
        offset += this.tokenIndex;

        if (offset < this.tokenCount) {
            return this.offsetAndType[offset - 1] & OFFSET_MASK;
        }

        return this.source.length;
    }
    lookupOffsetNonSC(idx) {
        for (let offset = this.tokenIndex; offset < this.tokenCount; offset++) {
            const tokenType = this.offsetAndType[offset] >> TYPE_SHIFT;

            if (tokenType !== WhiteSpace$1 && tokenType !== Comment$1) {
                if (idx-- === 0) {
                    return offset - this.tokenIndex;
                }
            }
        }

        return EOF$1;
    }
    lookupValue(offset, referenceStr) {
        offset += this.tokenIndex;

        if (offset < this.tokenCount) {
            return cmpStr(
                this.source,
                this.offsetAndType[offset - 1] & OFFSET_MASK,
                this.offsetAndType[offset] & OFFSET_MASK,
                referenceStr
            );
        }

        return false;
    }
    getTokenStart(tokenIndex) {
        if (tokenIndex === this.tokenIndex) {
            return this.tokenStart;
        }

        if (tokenIndex > 0) {
            return tokenIndex < this.tokenCount
                ? this.offsetAndType[tokenIndex - 1] & OFFSET_MASK
                : this.offsetAndType[this.tokenCount] & OFFSET_MASK;
        }

        return this.firstCharOffset;
    }
    getTokenEnd(tokenIndex) {
        if (tokenIndex === this.tokenIndex) {
            return this.tokenEnd;
        }

        return this.offsetAndType[boundIndex(tokenIndex, 0, this.tokenCount)] & OFFSET_MASK;
    }
    getTokenType(tokenIndex) {
        if (tokenIndex === this.tokenIndex) {
            return this.tokenType;
        }

        return this.offsetAndType[boundIndex(tokenIndex, 0, this.tokenCount)] >> TYPE_SHIFT;
    }
    substrToCursor(start) {
        return this.source.substring(start, this.tokenStart);
    }

    isBlockOpenerTokenType(tokenType) {
        return blockTokens[tokenType] === BLOCK_OPEN_TOKEN;
    }
    isBlockCloserTokenType(tokenType) {
        return blockTokens[tokenType] === BLOCK_CLOSE_TOKEN;
    }
    getBlockTokenPairIndex(tokenIndex) {
        const type = this.getTokenType(tokenIndex);

        if (blockTokens[type] === 1) {
            // block open token
            const pairIndex = this.balance[tokenIndex];
            const closeType = this.getTokenType(pairIndex);

            return balancePair$1[type] === closeType ? pairIndex : -1;
        } else if (blockTokens[type] === 2) {
            // block close token
            const pairIndex = this.balance[tokenIndex];
            const openType = this.getTokenType(pairIndex);

            return balancePair$1[openType] === type ? pairIndex : -1;
        }

        return -1;
    }
    isBalanceEdge(tokenIndex) {
        return this.balance[this.tokenIndex] < tokenIndex;
    }

    isDelim(code, offset) {
        if (offset) {
            return (
                this.lookupType(offset) === Delim &&
                this.source.charCodeAt(this.lookupOffset(offset)) === code
            );
        }

        return (
            this.tokenType === Delim &&
            this.source.charCodeAt(this.tokenStart) === code
        );
    }

    skip(tokenCount) {
        let next = this.tokenIndex + tokenCount;

        if (next < this.tokenCount) {
            this.tokenIndex = next;
            this.tokenStart = this.offsetAndType[next - 1] & OFFSET_MASK;
            next = this.offsetAndType[next];
            this.tokenType = next >> TYPE_SHIFT;
            this.tokenEnd = next & OFFSET_MASK;
        } else {
            this.tokenIndex = this.tokenCount;
            this.next();
        }
    }
    next() {
        let next = this.tokenIndex + 1;

        if (next < this.tokenCount) {
            this.tokenIndex = next;
            this.tokenStart = this.tokenEnd;
            next = this.offsetAndType[next];
            this.tokenType = next >> TYPE_SHIFT;
            this.tokenEnd = next & OFFSET_MASK;
        } else {
            this.eof = true;
            this.tokenIndex = this.tokenCount;
            this.tokenType = EOF$1;
            this.tokenStart = this.tokenEnd = this.source.length;
        }
    }
    skipSC() {
        while (this.tokenType === WhiteSpace$1 || this.tokenType === Comment$1) {
            this.next();
        }
    }
    skipUntilBalanced(startToken, stopConsume) {
        let cursor = startToken;
        let balanceEnd = 0;
        let offset = 0;

        loop:
        for (; cursor < this.tokenCount; cursor++) {
            balanceEnd = this.balance[cursor];

            // stop scanning on balance edge that points to offset before start token
            if (balanceEnd < startToken) {
                break loop;
            }

            offset = cursor > 0 ? this.offsetAndType[cursor - 1] & OFFSET_MASK : this.firstCharOffset;

            // check stop condition
            switch (stopConsume(this.source.charCodeAt(offset))) {
                case 1: // just stop
                    break loop;

                case 2: // stop & included
                    cursor++;
                    break loop;

                default:
                    // fast forward to the end of balanced block for an open block tokens
                    if (this.isBlockOpenerTokenType(this.offsetAndType[cursor] >> TYPE_SHIFT)) {
                        cursor = balanceEnd;
                    }
            }
        }

        this.skip(cursor - this.tokenIndex);
    }

    forEachToken(fn) {
        for (let i = 0, offset = this.firstCharOffset; i < this.tokenCount; i++) {
            const start = offset;
            const item = this.offsetAndType[i];
            const end = item & OFFSET_MASK;
            const type = item >> TYPE_SHIFT;

            offset = end;

            fn(type, start, end, i);
        }
    }
    dump() {
        const tokens = new Array(this.tokenCount);

        this.forEachToken((type, start, end, index) => {
            tokens[index] = {
                idx: index,
                type: tokenNames[type],
                chunk: this.source.substring(start, end),
                balance: this.balance[index]
            };
        });

        return tokens;
    }
}

function tokenize$1(source, onToken) {
    function getCharCode(offset) {
        return offset < sourceLength ? source.charCodeAt(offset) : 0;
    }

    // § 4.3.3. Consume a numeric token
    function consumeNumericToken() {
        // Consume a number and let number be the result.
        offset = consumeNumber(source, offset);

        // If the next 3 input code points would start an identifier, then:
        if (isIdentifierStart(getCharCode(offset), getCharCode(offset + 1), getCharCode(offset + 2))) {
            // Create a <dimension-token> with the same value and type flag as number, and a unit set initially to the empty string.
            // Consume a name. Set the <dimension-token>’s unit to the returned value.
            // Return the <dimension-token>.
            type = Dimension$1;
            offset = consumeName(source, offset);
            return;
        }

        // Otherwise, if the next input code point is U+0025 PERCENTAGE SIGN (%), consume it.
        if (getCharCode(offset) === 0x0025) {
            // Create a <percentage-token> with the same value as number, and return it.
            type = Percentage$1;
            offset++;
            return;
        }

        // Otherwise, create a <number-token> with the same value and type flag as number, and return it.
        type = Number$2;
    }

    // § 4.3.4. Consume an ident-like token
    function consumeIdentLikeToken() {
        const nameStartOffset = offset;

        // Consume a name, and let string be the result.
        offset = consumeName(source, offset);

        // If string’s value is an ASCII case-insensitive match for "url",
        // and the next input code point is U+0028 LEFT PARENTHESIS ((), consume it.
        if (cmpStr(source, nameStartOffset, offset, 'url') && getCharCode(offset) === 0x0028) {
            // While the next two input code points are whitespace, consume the next input code point.
            offset = findWhiteSpaceEnd(source, offset + 1);

            // If the next one or two input code points are U+0022 QUOTATION MARK ("), U+0027 APOSTROPHE ('),
            // or whitespace followed by U+0022 QUOTATION MARK (") or U+0027 APOSTROPHE ('),
            // then create a <function-token> with its value set to string and return it.
            if (getCharCode(offset) === 0x0022 ||
                getCharCode(offset) === 0x0027) {
                type = Function$1;
                offset = nameStartOffset + 4;
                return;
            }

            // Otherwise, consume a url token, and return it.
            consumeUrlToken();
            return;
        }

        // Otherwise, if the next input code point is U+0028 LEFT PARENTHESIS ((), consume it.
        // Create a <function-token> with its value set to string and return it.
        if (getCharCode(offset) === 0x0028) {
            type = Function$1;
            offset++;
            return;
        }

        // Otherwise, create an <ident-token> with its value set to string and return it.
        type = Ident;
    }

    // § 4.3.5. Consume a string token
    function consumeStringToken(endingCodePoint) {
        // This algorithm may be called with an ending code point, which denotes the code point
        // that ends the string. If an ending code point is not specified,
        // the current input code point is used.
        if (!endingCodePoint) {
            endingCodePoint = getCharCode(offset++);
        }

        // Initially create a <string-token> with its value set to the empty string.
        type = String$2;

        // Repeatedly consume the next input code point from the stream:
        for (; offset < source.length; offset++) {
            const code = source.charCodeAt(offset);

            switch (charCodeCategory(code)) {
                // ending code point
                case endingCodePoint:
                    // Return the <string-token>.
                    offset++;
                    return;

                    // EOF
                    // case EofCategory:
                    // This is a parse error. Return the <string-token>.
                    // return;

                // newline
                case WhiteSpaceCategory:
                    if (isNewline(code)) {
                        // This is a parse error. Reconsume the current input code point,
                        // create a <bad-string-token>, and return it.
                        offset += getNewlineLength(source, offset, code);
                        type = BadString;
                        return;
                    }
                    break;

                // U+005C REVERSE SOLIDUS (\)
                case 0x005C:
                    // If the next input code point is EOF, do nothing.
                    if (offset === source.length - 1) {
                        break;
                    }

                    const nextCode = getCharCode(offset + 1);

                    // Otherwise, if the next input code point is a newline, consume it.
                    if (isNewline(nextCode)) {
                        offset += getNewlineLength(source, offset + 1, nextCode);
                    } else if (isValidEscape(code, nextCode)) {
                        // Otherwise, (the stream starts with a valid escape) consume
                        // an escaped code point and append the returned code point to
                        // the <string-token>’s value.
                        offset = consumeEscaped(source, offset) - 1;
                    }
                    break;

                // anything else
                // Append the current input code point to the <string-token>’s value.
            }
        }
    }

    // § 4.3.6. Consume a url token
    // Note: This algorithm assumes that the initial "url(" has already been consumed.
    // This algorithm also assumes that it’s being called to consume an "unquoted" value, like url(foo).
    // A quoted value, like url("foo"), is parsed as a <function-token>. Consume an ident-like token
    // automatically handles this distinction; this algorithm shouldn’t be called directly otherwise.
    function consumeUrlToken() {
        // Initially create a <url-token> with its value set to the empty string.
        type = Url$1;

        // Consume as much whitespace as possible.
        offset = findWhiteSpaceEnd(source, offset);

        // Repeatedly consume the next input code point from the stream:
        for (; offset < source.length; offset++) {
            const code = source.charCodeAt(offset);

            switch (charCodeCategory(code)) {
                // U+0029 RIGHT PARENTHESIS ())
                case 0x0029:
                    // Return the <url-token>.
                    offset++;
                    return;

                    // EOF
                    // case EofCategory:
                    // This is a parse error. Return the <url-token>.
                    // return;

                // whitespace
                case WhiteSpaceCategory:
                    // Consume as much whitespace as possible.
                    offset = findWhiteSpaceEnd(source, offset);

                    // If the next input code point is U+0029 RIGHT PARENTHESIS ()) or EOF,
                    // consume it and return the <url-token>
                    // (if EOF was encountered, this is a parse error);
                    if (getCharCode(offset) === 0x0029 || offset >= source.length) {
                        if (offset < source.length) {
                            offset++;
                        }
                        return;
                    }

                    // otherwise, consume the remnants of a bad url, create a <bad-url-token>,
                    // and return it.
                    offset = consumeBadUrlRemnants(source, offset);
                    type = BadUrl;
                    return;

                // U+0022 QUOTATION MARK (")
                // U+0027 APOSTROPHE (')
                // U+0028 LEFT PARENTHESIS (()
                // non-printable code point
                case 0x0022:
                case 0x0027:
                case 0x0028:
                case NonPrintableCategory:
                    // This is a parse error. Consume the remnants of a bad url,
                    // create a <bad-url-token>, and return it.
                    offset = consumeBadUrlRemnants(source, offset);
                    type = BadUrl;
                    return;

                // U+005C REVERSE SOLIDUS (\)
                case 0x005C:
                    // If the stream starts with a valid escape, consume an escaped code point and
                    // append the returned code point to the <url-token>’s value.
                    if (isValidEscape(code, getCharCode(offset + 1))) {
                        offset = consumeEscaped(source, offset) - 1;
                        break;
                    }

                    // Otherwise, this is a parse error. Consume the remnants of a bad url,
                    // create a <bad-url-token>, and return it.
                    offset = consumeBadUrlRemnants(source, offset);
                    type = BadUrl;
                    return;

                // anything else
                // Append the current input code point to the <url-token>’s value.
            }
        }
    }

    // ensure source is a string
    source = String(source || '');

    const sourceLength = source.length;
    let start = isBOM(getCharCode(0));
    let offset = start;
    let type;

    // https://drafts.csswg.org/css-syntax-3/#consume-token
    // § 4.3.1. Consume a token
    while (offset < sourceLength) {
        const code = source.charCodeAt(offset);

        switch (charCodeCategory(code)) {
            // whitespace
            case WhiteSpaceCategory:
                // Consume as much whitespace as possible. Return a <whitespace-token>.
                type = WhiteSpace$1;
                offset = findWhiteSpaceEnd(source, offset + 1);
                break;

            // U+0022 QUOTATION MARK (")
            case 0x0022:
                // Consume a string token and return it.
                consumeStringToken();
                break;

            // U+0023 NUMBER SIGN (#)
            case 0x0023:
                // If the next input code point is a name code point or the next two input code points are a valid escape, then:
                if (isName(getCharCode(offset + 1)) || isValidEscape(getCharCode(offset + 1), getCharCode(offset + 2))) {
                    // Create a <hash-token>.
                    type = Hash$1;

                    // If the next 3 input code points would start an identifier, set the <hash-token>’s type flag to "id".
                    // if (isIdentifierStart(getCharCode(offset + 1), getCharCode(offset + 2), getCharCode(offset + 3))) {
                    //     // TODO: set id flag
                    // }

                    // Consume a name, and set the <hash-token>’s value to the returned string.
                    offset = consumeName(source, offset + 1);

                    // Return the <hash-token>.
                } else {
                    // Otherwise, return a <delim-token> with its value set to the current input code point.
                    type = Delim;
                    offset++;
                }

                break;

            // U+0027 APOSTROPHE (')
            case 0x0027:
                // Consume a string token and return it.
                consumeStringToken();
                break;

            // U+0028 LEFT PARENTHESIS (()
            case 0x0028:
                // Return a <(-token>.
                type = LeftParenthesis;
                offset++;
                break;

            // U+0029 RIGHT PARENTHESIS ())
            case 0x0029:
                // Return a <)-token>.
                type = RightParenthesis;
                offset++;
                break;

            // U+002B PLUS SIGN (+)
            case 0x002B:
                // If the input stream starts with a number, ...
                if (isNumberStart(code, getCharCode(offset + 1), getCharCode(offset + 2))) {
                    // ... reconsume the current input code point, consume a numeric token, and return it.
                    consumeNumericToken();
                } else {
                    // Otherwise, return a <delim-token> with its value set to the current input code point.
                    type = Delim;
                    offset++;
                }
                break;

            // U+002C COMMA (,)
            case 0x002C:
                // Return a <comma-token>.
                type = Comma;
                offset++;
                break;

            // U+002D HYPHEN-MINUS (-)
            case 0x002D:
                // If the input stream starts with a number, reconsume the current input code point, consume a numeric token, and return it.
                if (isNumberStart(code, getCharCode(offset + 1), getCharCode(offset + 2))) {
                    consumeNumericToken();
                } else {
                    // Otherwise, if the next 2 input code points are U+002D HYPHEN-MINUS U+003E GREATER-THAN SIGN (->), consume them and return a <CDC-token>.
                    if (getCharCode(offset + 1) === 0x002D &&
                        getCharCode(offset + 2) === 0x003E) {
                        type = CDC$1;
                        offset = offset + 3;
                    } else {
                        // Otherwise, if the input stream starts with an identifier, ...
                        if (isIdentifierStart(code, getCharCode(offset + 1), getCharCode(offset + 2))) {
                            // ... reconsume the current input code point, consume an ident-like token, and return it.
                            consumeIdentLikeToken();
                        } else {
                            // Otherwise, return a <delim-token> with its value set to the current input code point.
                            type = Delim;
                            offset++;
                        }
                    }
                }
                break;

            // U+002E FULL STOP (.)
            case 0x002E:
                // If the input stream starts with a number, ...
                if (isNumberStart(code, getCharCode(offset + 1), getCharCode(offset + 2))) {
                    // ... reconsume the current input code point, consume a numeric token, and return it.
                    consumeNumericToken();
                } else {
                    // Otherwise, return a <delim-token> with its value set to the current input code point.
                    type = Delim;
                    offset++;
                }

                break;

            // U+002F SOLIDUS (/)
            case 0x002F:
                // If the next two input code point are U+002F SOLIDUS (/) followed by a U+002A ASTERISK (*),
                if (getCharCode(offset + 1) === 0x002A) {
                    // ... consume them and all following code points up to and including the first U+002A ASTERISK (*)
                    // followed by a U+002F SOLIDUS (/), or up to an EOF code point.
                    type = Comment$1;
                    offset = source.indexOf('*/', offset + 2);
                    offset = offset === -1 ? source.length : offset + 2;
                } else {
                    type = Delim;
                    offset++;
                }
                break;

            // U+003A COLON (:)
            case 0x003A:
                // Return a <colon-token>.
                type = Colon;
                offset++;
                break;

            // U+003B SEMICOLON (;)
            case 0x003B:
                // Return a <semicolon-token>.
                type = Semicolon;
                offset++;
                break;

            // U+003C LESS-THAN SIGN (<)
            case 0x003C:
                // If the next 3 input code points are U+0021 EXCLAMATION MARK U+002D HYPHEN-MINUS U+002D HYPHEN-MINUS (!--), ...
                if (getCharCode(offset + 1) === 0x0021 &&
                    getCharCode(offset + 2) === 0x002D &&
                    getCharCode(offset + 3) === 0x002D) {
                    // ... consume them and return a <CDO-token>.
                    type = CDO$1;
                    offset = offset + 4;
                } else {
                    // Otherwise, return a <delim-token> with its value set to the current input code point.
                    type = Delim;
                    offset++;
                }

                break;

            // U+0040 COMMERCIAL AT (@)
            case 0x0040:
                // If the next 3 input code points would start an identifier, ...
                if (isIdentifierStart(getCharCode(offset + 1), getCharCode(offset + 2), getCharCode(offset + 3))) {
                    // ... consume a name, create an <at-keyword-token> with its value set to the returned value, and return it.
                    type = AtKeyword;
                    offset = consumeName(source, offset + 1);
                } else {
                    // Otherwise, return a <delim-token> with its value set to the current input code point.
                    type = Delim;
                    offset++;
                }

                break;

            // U+005B LEFT SQUARE BRACKET ([)
            case 0x005B:
                // Return a <[-token>.
                type = LeftSquareBracket;
                offset++;
                break;

            // U+005C REVERSE SOLIDUS (\)
            case 0x005C:
                // If the input stream starts with a valid escape, ...
                if (isValidEscape(code, getCharCode(offset + 1))) {
                    // ... reconsume the current input code point, consume an ident-like token, and return it.
                    consumeIdentLikeToken();
                } else {
                    // Otherwise, this is a parse error. Return a <delim-token> with its value set to the current input code point.
                    type = Delim;
                    offset++;
                }
                break;

            // U+005D RIGHT SQUARE BRACKET (])
            case 0x005D:
                // Return a <]-token>.
                type = RightSquareBracket;
                offset++;
                break;

            // U+007B LEFT CURLY BRACKET ({)
            case 0x007B:
                // Return a <{-token>.
                type = LeftCurlyBracket;
                offset++;
                break;

            // U+007D RIGHT CURLY BRACKET (})
            case 0x007D:
                // Return a <}-token>.
                type = RightCurlyBracket;
                offset++;
                break;

            // digit
            case DigitCategory:
                // Reconsume the current input code point, consume a numeric token, and return it.
                consumeNumericToken();
                break;

            // name-start code point
            case NameStartCategory:
                // Reconsume the current input code point, consume an ident-like token, and return it.
                consumeIdentLikeToken();
                break;

                // EOF
                // case EofCategory:
                // Return an <EOF-token>.
                // break;

            // anything else
            default:
                // Return a <delim-token> with its value set to the current input code point.
                type = Delim;
                offset++;
        }

        // put token to stream
        onToken(type, start, start = offset);
    }
}

//
//                              list
//                            ┌──────┐
//             ┌──────────────┼─head │
//             │              │ tail─┼──────────────┐
//             │              └──────┘              │
//             ▼                                    ▼
//            item        item        item        item
//          ┌──────┐    ┌──────┐    ┌──────┐    ┌──────┐
//  null ◀──┼─prev │◀───┼─prev │◀───┼─prev │◀───┼─prev │
//          │ next─┼───▶│ next─┼───▶│ next─┼───▶│ next─┼──▶ null
//          ├──────┤    ├──────┤    ├──────┤    ├──────┤
//          │ data │    │ data │    │ data │    │ data │
//          └──────┘    └──────┘    └──────┘    └──────┘
//

let releasedCursors = null;

class List {
    static createItem(data) {
        return {
            prev: null,
            next: null,
            data
        };
    }

    constructor() {
        this.head = null;
        this.tail = null;
        this.cursor = null;
    }
    createItem(data) {
        return List.createItem(data);
    }

    // cursor helpers
    allocateCursor(prev, next) {
        let cursor;

        if (releasedCursors !== null) {
            cursor = releasedCursors;
            releasedCursors = releasedCursors.cursor;
            cursor.prev = prev;
            cursor.next = next;
            cursor.cursor = this.cursor;
        } else {
            cursor = {
                prev,
                next,
                cursor: this.cursor
            };
        }

        this.cursor = cursor;

        return cursor;
    }
    releaseCursor() {
        const { cursor } = this;

        this.cursor = cursor.cursor;
        cursor.prev = null;
        cursor.next = null;
        cursor.cursor = releasedCursors;
        releasedCursors = cursor;
    }
    updateCursors(prevOld, prevNew, nextOld, nextNew) {
        let { cursor } = this;

        while (cursor !== null) {
            if (cursor.prev === prevOld) {
                cursor.prev = prevNew;
            }

            if (cursor.next === nextOld) {
                cursor.next = nextNew;
            }

            cursor = cursor.cursor;
        }
    }
    *[Symbol.iterator]() {
        for (let cursor = this.head; cursor !== null; cursor = cursor.next) {
            yield cursor.data;
        }
    }

    // getters
    get size() {
        let size = 0;

        for (let cursor = this.head; cursor !== null; cursor = cursor.next) {
            size++;
        }

        return size;
    }
    get isEmpty() {
        return this.head === null;
    }
    get first() {
        return this.head && this.head.data;
    }
    get last() {
        return this.tail && this.tail.data;
    }

    // convertors
    fromArray(array) {
        let cursor = null;
        this.head = null;

        for (let data of array) {
            const item = List.createItem(data);

            if (cursor !== null) {
                cursor.next = item;
            } else {
                this.head = item;
            }

            item.prev = cursor;
            cursor = item;
        }

        this.tail = cursor;
        return this;
    }
    toArray() {
        return [...this];
    }
    toJSON() {
        return [...this];
    }

    // array-like methods
    forEach(fn, thisArg = this) {
        // push cursor
        const cursor = this.allocateCursor(null, this.head);

        while (cursor.next !== null) {
            const item = cursor.next;
            cursor.next = item.next;
            fn.call(thisArg, item.data, item, this);
        }

        // pop cursor
        this.releaseCursor();
    }
    forEachRight(fn, thisArg = this) {
        // push cursor
        const cursor = this.allocateCursor(this.tail, null);

        while (cursor.prev !== null) {
            const item = cursor.prev;
            cursor.prev = item.prev;
            fn.call(thisArg, item.data, item, this);
        }

        // pop cursor
        this.releaseCursor();
    }
    reduce(fn, initialValue, thisArg = this) {
        // push cursor
        let cursor = this.allocateCursor(null, this.head);
        let acc = initialValue;
        let item;

        while (cursor.next !== null) {
            item = cursor.next;
            cursor.next = item.next;

            acc = fn.call(thisArg, acc, item.data, item, this);
        }

        // pop cursor
        this.releaseCursor();

        return acc;
    }
    reduceRight(fn, initialValue, thisArg = this) {
        // push cursor
        let cursor = this.allocateCursor(this.tail, null);
        let acc = initialValue;
        let item;

        while (cursor.prev !== null) {
            item = cursor.prev;
            cursor.prev = item.prev;

            acc = fn.call(thisArg, acc, item.data, item, this);
        }

        // pop cursor
        this.releaseCursor();

        return acc;
    }
    some(fn, thisArg = this) {
        for (let cursor = this.head; cursor !== null; cursor = cursor.next) {
            if (fn.call(thisArg, cursor.data, cursor, this)) {
                return true;
            }
        }

        return false;
    }
    map(fn, thisArg = this) {
        const result = new List();

        for (let cursor = this.head; cursor !== null; cursor = cursor.next) {
            result.appendData(fn.call(thisArg, cursor.data, cursor, this));
        }

        return result;
    }
    filter(fn, thisArg = this) {
        const result = new List();

        for (let cursor = this.head; cursor !== null; cursor = cursor.next) {
            if (fn.call(thisArg, cursor.data, cursor, this)) {
                result.appendData(cursor.data);
            }
        }

        return result;
    }

    nextUntil(start, fn, thisArg = this) {
        if (start === null) {
            return;
        }

        // push cursor
        const cursor = this.allocateCursor(null, start);

        while (cursor.next !== null) {
            const item = cursor.next;
            cursor.next = item.next;
            if (fn.call(thisArg, item.data, item, this)) {
                break;
            }
        }

        // pop cursor
        this.releaseCursor();
    }
    prevUntil(start, fn, thisArg = this) {
        if (start === null) {
            return;
        }

        // push cursor
        const cursor = this.allocateCursor(start, null);

        while (cursor.prev !== null) {
            const item = cursor.prev;
            cursor.prev = item.prev;
            if (fn.call(thisArg, item.data, item, this)) {
                break;
            }
        }

        // pop cursor
        this.releaseCursor();
    }

    // mutation
    clear() {
        this.head = null;
        this.tail = null;
    }
    copy() {
        const result = new List();

        for (let data of this) {
            result.appendData(data);
        }

        return result;
    }
    prepend(item) {
        //      head
        //    ^
        // item
        this.updateCursors(null, item, this.head, item);

        // insert to the beginning of the list
        if (this.head !== null) {
            // new item <- first item
            this.head.prev = item;
            // new item -> first item
            item.next = this.head;
        } else {
            // if list has no head, then it also has no tail
            // in this case tail points to the new item
            this.tail = item;
        }

        // head always points to new item
        this.head = item;
        return this;
    }
    prependData(data) {
        return this.prepend(List.createItem(data));
    }
    append(item) {
        return this.insert(item);
    }
    appendData(data) {
        return this.insert(List.createItem(data));
    }
    insert(item, before = null) {
        if (before !== null) {
            // prev   before
            //      ^
            //     item
            this.updateCursors(before.prev, item, before, item);

            if (before.prev === null) {
                // insert to the beginning of list
                if (this.head !== before) {
                    throw new Error('before doesn\'t belong to list');
                }
                // since head points to before therefore list doesn't empty
                // no need to check tail
                this.head = item;
                before.prev = item;
                item.next = before;
                this.updateCursors(null, item);
            } else {
                // insert between two items
                before.prev.next = item;
                item.prev = before.prev;
                before.prev = item;
                item.next = before;
            }
        } else {
            // tail
            //      ^
            //      item
            this.updateCursors(this.tail, item, null, item);

            // insert to the ending of the list
            if (this.tail !== null) {
                // last item -> new item
                this.tail.next = item;
                // last item <- new item
                item.prev = this.tail;
            } else {
                // if list has no tail, then it also has no head
                // in this case head points to new item
                this.head = item;
            }

            // tail always points to new item
            this.tail = item;
        }

        return this;
    }
    insertData(data, before) {
        return this.insert(List.createItem(data), before);
    }
    remove(item) {
        //      item
        //       ^
        // prev     next
        this.updateCursors(item, item.prev, item, item.next);

        if (item.prev !== null) {
            item.prev.next = item.next;
        } else {
            if (this.head !== item) {
                throw new Error('item doesn\'t belong to list');
            }

            this.head = item.next;
        }

        if (item.next !== null) {
            item.next.prev = item.prev;
        } else {
            if (this.tail !== item) {
                throw new Error('item doesn\'t belong to list');
            }

            this.tail = item.prev;
        }

        item.prev = null;
        item.next = null;

        return item;
    }
    push(data) {
        this.insert(List.createItem(data));
    }
    pop() {
        return this.tail !== null ? this.remove(this.tail) : null;
    }
    unshift(data) {
        this.prepend(List.createItem(data));
    }
    shift() {
        return this.head !== null ? this.remove(this.head) : null;
    }
    prependList(list) {
        return this.insertList(list, this.head);
    }
    appendList(list) {
        return this.insertList(list);
    }
    insertList(list, before) {
        // ignore empty lists
        if (list.head === null) {
            return this;
        }

        if (before !== undefined && before !== null) {
            this.updateCursors(before.prev, list.tail, before, list.head);

            // insert in the middle of dist list
            if (before.prev !== null) {
                // before.prev <-> list.head
                before.prev.next = list.head;
                list.head.prev = before.prev;
            } else {
                this.head = list.head;
            }

            before.prev = list.tail;
            list.tail.next = before;
        } else {
            this.updateCursors(this.tail, list.tail, null, list.head);

            // insert to end of the list
            if (this.tail !== null) {
                // if destination list has a tail, then it also has a head,
                // but head doesn't change
                // dest tail -> source head
                this.tail.next = list.head;
                // dest tail <- source head
                list.head.prev = this.tail;
            } else {
                // if list has no a tail, then it also has no a head
                // in this case points head to new item
                this.head = list.head;
            }

            // tail always start point to new item
            this.tail = list.tail;
        }

        list.head = null;
        list.tail = null;
        return this;
    }
    replace(oldItem, newItemOrList) {
        if ('head' in newItemOrList) {
            this.insertList(newItemOrList, oldItem);
        } else {
            this.insert(newItemOrList, oldItem);
        }

        this.remove(oldItem);
    }
}

function createCustomError(name, message) {
    // use Object.create(), because some VMs prevent setting line/column otherwise
    // (iOS Safari 10 even throws an exception)
    const error = Object.create(SyntaxError.prototype);
    const errorStack = new Error();

    return Object.assign(error, {
        name,
        message,
        get stack() {
            return (errorStack.stack || '').replace(/^(.+\n){1,3}/, `${name}: ${message}\n`);
        }
    });
}

const MAX_LINE_LENGTH = 100;
const OFFSET_CORRECTION = 60;
const TAB_REPLACEMENT = '    ';

function sourceFragment({ source, line, column, baseLine, baseColumn }, extraLines) {
    function processLines(start, end) {
        return lines
            .slice(start, end)
            .map((line, idx) =>
                String(start + idx + 1).padStart(maxNumLength) + ' |' + line
            ).join('\n');
    }

    const prelines = '\n'.repeat(Math.max(baseLine - 1, 0));
    const precolumns = ' '.repeat(Math.max(baseColumn - 1, 0));
    const lines = (prelines + precolumns + source).split(/\r\n?|\n|\f/);
    const startLine = Math.max(1, line - extraLines) - 1;
    const endLine = Math.min(line + extraLines, lines.length + 1);
    const maxNumLength = Math.max(4, String(endLine).length) + 1;
    let cutLeft = 0;

    // column correction according to replaced tab before column
    column += (TAB_REPLACEMENT.length - 1) * (lines[line - 1].substr(0, column - 1).match(/\t/g) || []).length;

    if (column > MAX_LINE_LENGTH) {
        cutLeft = column - OFFSET_CORRECTION + 3;
        column = OFFSET_CORRECTION - 2;
    }

    for (let i = startLine; i <= endLine; i++) {
        if (i >= 0 && i < lines.length) {
            lines[i] = lines[i].replace(/\t/g, TAB_REPLACEMENT);
            lines[i] =
                (cutLeft > 0 && lines[i].length > cutLeft ? '\u2026' : '') +
                lines[i].substr(cutLeft, MAX_LINE_LENGTH - 2) +
                (lines[i].length > cutLeft + MAX_LINE_LENGTH - 1 ? '\u2026' : '');
        }
    }

    return [
        processLines(startLine, line),
        new Array(column + maxNumLength + 2).join('-') + '^',
        processLines(line, endLine)
    ].filter(Boolean)
        .join('\n')
        .replace(/^(\s+\d+\s+\|\n)+/, '')
        .replace(/\n(\s+\d+\s+\|)+$/, '');
}

function SyntaxError$2(message, source, offset, line, column, baseLine = 1, baseColumn = 1) {
    const error = Object.assign(createCustomError('SyntaxError', message), {
        source,
        offset,
        line,
        column,
        sourceFragment(extraLines) {
            return sourceFragment({ source, line, column, baseLine, baseColumn }, isNaN(extraLines) ? 0 : extraLines);
        },
        get formattedMessage() {
            return (
                `Parse error: ${message}\n` +
                sourceFragment({ source, line, column, baseLine, baseColumn }, 2)
            );
        }
    });

    return error;
}

function readSequence(recognizer) {
    const children = this.createList();
    let space = false;
    const context = {
        recognizer
    };

    while (!this.eof) {
        switch (this.tokenType) {
            case Comment$1:
                this.next();
                continue;

            case WhiteSpace$1:
                space = true;
                this.next();
                continue;
        }

        let child = recognizer.getNode.call(this, context);

        if (child === undefined) {
            break;
        }

        if (space) {
            if (recognizer.onWhiteSpace) {
                recognizer.onWhiteSpace.call(this, child, children, context);
            }
            space = false;
        }

        children.push(child);
    }

    if (space && recognizer.onWhiteSpace) {
        recognizer.onWhiteSpace.call(this, null, children, context);
    }

    return children;
}

const NOOP = () => {};
const EXCLAMATIONMARK$3 = 0x0021;  // U+0021 EXCLAMATION MARK (!)
const NUMBERSIGN$4 = 0x0023;       // U+0023 NUMBER SIGN (#)
const SEMICOLON = 0x003B;        // U+003B SEMICOLON (;)
const LEFTCURLYBRACKET$1 = 0x007B; // U+007B LEFT CURLY BRACKET ({)
const NULL = 0;

function createParseContext(name) {
    return function() {
        return this[name]();
    };
}

function fetchParseValues(dict) {
    const result = Object.create(null);

    for (const name of Object.keys(dict)) {
        const item = dict[name];
        const fn = item.parse || item;

        if (fn) {
            result[name] = fn;
        }
    }

    return result;
}

function processConfig(config) {
    const parseConfig = {
        context: Object.create(null),
        features: Object.assign(Object.create(null), config.features),
        scope: Object.assign(Object.create(null), config.scope),
        atrule: fetchParseValues(config.atrule),
        pseudo: fetchParseValues(config.pseudo),
        node: fetchParseValues(config.node)
    };

    for (const [name, context] of Object.entries(config.parseContext)) {
        switch (typeof context) {
            case 'function':
                parseConfig.context[name] = context;
                break;

            case 'string':
                parseConfig.context[name] = createParseContext(context);
                break;
        }
    }

    return {
        config: parseConfig,
        ...parseConfig,
        ...parseConfig.node
    };
}

function createParser(config) {
    let source = '';
    let filename = '<unknown>';
    let needPositions = false;
    let onParseError = NOOP;
    let onParseErrorThrow = false;

    const locationMap = new OffsetToLocation();
    const parser = Object.assign(new TokenStream(), processConfig(config || {}), {
        parseAtrulePrelude: true,
        parseRulePrelude: true,
        parseValue: true,
        parseCustomProperty: false,

        readSequence,

        consumeUntilBalanceEnd: () => 0,
        consumeUntilLeftCurlyBracket(code) {
            return code === LEFTCURLYBRACKET$1 ? 1 : 0;
        },
        consumeUntilLeftCurlyBracketOrSemicolon(code) {
            return code === LEFTCURLYBRACKET$1 || code === SEMICOLON ? 1 : 0;
        },
        consumeUntilExclamationMarkOrSemicolon(code) {
            return code === EXCLAMATIONMARK$3 || code === SEMICOLON ? 1 : 0;
        },
        consumeUntilSemicolonIncluded(code) {
            return code === SEMICOLON ? 2 : 0;
        },

        createList() {
            return new List();
        },
        createSingleNodeList(node) {
            return new List().appendData(node);
        },
        getFirstListNode(list) {
            return list && list.first;
        },
        getLastListNode(list) {
            return list && list.last;
        },

        parseWithFallback(consumer, fallback) {
            const startIndex = this.tokenIndex;

            try {
                return consumer.call(this);
            } catch (e) {
                if (onParseErrorThrow) {
                    throw e;
                }

                this.skip(startIndex - this.tokenIndex);
                const fallbackNode = fallback.call(this);

                onParseErrorThrow = true;
                onParseError(e, fallbackNode);
                onParseErrorThrow = false;

                return fallbackNode;
            }
        },

        lookupNonWSType(offset) {
            let type;

            do {
                type = this.lookupType(offset++);
                if (type !== WhiteSpace$1 && type !== Comment$1) {
                    return type;
                }
            } while (type !== NULL);

            return NULL;
        },

        charCodeAt(offset) {
            return offset >= 0 && offset < source.length ? source.charCodeAt(offset) : 0;
        },
        substring(offsetStart, offsetEnd) {
            return source.substring(offsetStart, offsetEnd);
        },
        substrToCursor(start) {
            return this.source.substring(start, this.tokenStart);
        },

        cmpChar(offset, charCode) {
            return cmpChar(source, offset, charCode);
        },
        cmpStr(offsetStart, offsetEnd, str) {
            return cmpStr(source, offsetStart, offsetEnd, str);
        },

        consume(tokenType) {
            const start = this.tokenStart;

            this.eat(tokenType);

            return this.substrToCursor(start);
        },
        consumeFunctionName() {
            const name = source.substring(this.tokenStart, this.tokenEnd - 1);

            this.eat(Function$1);

            return name;
        },
        consumeNumber(type) {
            const number = source.substring(this.tokenStart, consumeNumber(source, this.tokenStart));

            this.eat(type);

            return number;
        },

        eat(tokenType) {
            if (this.tokenType !== tokenType) {
                const tokenName = tokenNames[tokenType].slice(0, -6).replace(/-/g, ' ').replace(/^./, m => m.toUpperCase());
                let message = `${/[[\](){}]/.test(tokenName) ? `"${tokenName}"` : tokenName} is expected`;
                let offset = this.tokenStart;

                // tweak message and offset
                switch (tokenType) {
                    case Ident:
                        // when identifier is expected but there is a function or url
                        if (this.tokenType === Function$1 || this.tokenType === Url$1) {
                            offset = this.tokenEnd - 1;
                            message = 'Identifier is expected but function found';
                        } else {
                            message = 'Identifier is expected';
                        }
                        break;

                    case Hash$1:
                        if (this.isDelim(NUMBERSIGN$4)) {
                            this.next();
                            offset++;
                            message = 'Name is expected';
                        }
                        break;

                    case Percentage$1:
                        if (this.tokenType === Number$2) {
                            offset = this.tokenEnd;
                            message = 'Percent sign is expected';
                        }
                        break;
                }

                this.error(message, offset);
            }

            this.next();
        },
        eatIdent(name) {
            if (this.tokenType !== Ident || this.lookupValue(0, name) === false) {
                this.error(`Identifier "${name}" is expected`);
            }

            this.next();
        },
        eatDelim(code) {
            if (!this.isDelim(code)) {
                this.error(`Delim "${String.fromCharCode(code)}" is expected`);
            }

            this.next();
        },

        getLocation(start, end) {
            if (needPositions) {
                return locationMap.getLocationRange(
                    start,
                    end,
                    filename
                );
            }

            return null;
        },
        getLocationFromList(list) {
            if (needPositions) {
                const head = this.getFirstListNode(list);
                const tail = this.getLastListNode(list);
                return locationMap.getLocationRange(
                    head !== null ? head.loc.start.offset - locationMap.startOffset : this.tokenStart,
                    tail !== null ? tail.loc.end.offset - locationMap.startOffset : this.tokenStart,
                    filename
                );
            }

            return null;
        },

        error(message, offset) {
            const location = typeof offset !== 'undefined' && offset < source.length
                ? locationMap.getLocation(offset)
                : this.eof
                    ? locationMap.getLocation(findWhiteSpaceStart(source, source.length - 1))
                    : locationMap.getLocation(this.tokenStart);

            throw new SyntaxError$2(
                message || 'Unexpected input',
                source,
                location.offset,
                location.line,
                location.column,
                locationMap.startLine,
                locationMap.startColumn
            );
        }
    });
    const createTokenIterateAPI = () => ({
        filename,
        source,
        tokenCount: parser.tokenCount,

        getTokenType: (index) =>
            parser.getTokenType(index),
        getTokenTypeName: (index) =>
            tokenNames[parser.getTokenType(index)],
        getTokenStart: (index) =>
            parser.getTokenStart(index),
        getTokenEnd: (index) =>
            parser.getTokenEnd(index),
        getTokenValue: (index) =>
            parser.source.substring(parser.getTokenStart(index), parser.getTokenEnd(index)),

        substring: (start, end) =>
            parser.source.substring(start, end),

        balance: parser.balance.subarray(0, parser.tokenCount + 1),
        isBlockOpenerTokenType: parser.isBlockOpenerTokenType,
        isBlockCloserTokenType: parser.isBlockCloserTokenType,
        getBlockTokenPairIndex: (index) =>
            parser.getBlockTokenPairIndex(index),

        getLocation: (offset) =>
            locationMap.getLocation(offset, filename),
        getRangeLocation: (start, end) =>
            locationMap.getLocationRange(start, end, filename)
    });

    const parse = function(source_, options) {
        source = source_;
        options = options || {};

        parser.setSource(source, tokenize$1);
        locationMap.setSource(
            source,
            options.offset,
            options.line,
            options.column
        );

        filename = options.filename || '<unknown>';
        needPositions = Boolean(options.positions);
        onParseError = typeof options.onParseError === 'function' ? options.onParseError : NOOP;
        onParseErrorThrow = false;

        parser.parseAtrulePrelude = 'parseAtrulePrelude' in options ? Boolean(options.parseAtrulePrelude) : true;
        parser.parseRulePrelude = 'parseRulePrelude' in options ? Boolean(options.parseRulePrelude) : true;
        parser.parseValue = 'parseValue' in options ? Boolean(options.parseValue) : true;
        parser.parseCustomProperty = 'parseCustomProperty' in options ? Boolean(options.parseCustomProperty) : false;

        const { context = 'default', onComment, onToken } = options;

        if (context in parser.context === false) {
            throw new Error('Unknown context `' + context + '`');
        }

        if (Array.isArray(onToken)) {
            parser.forEachToken((type, start, end) => {
                onToken.push({ type, start, end });
            });
        } else if (typeof onToken === 'function') {
            parser.forEachToken(onToken.bind(createTokenIterateAPI()));
        }

        if (typeof onComment === 'function') {
            parser.forEachToken((type, start, end) => {
                if (type === Comment$1) {
                    const loc = parser.getLocation(start, end);
                    const value = cmpStr(source, end - 2, end, '*/')
                        ? source.slice(start + 2, end - 2)
                        : source.slice(start + 2, end);

                    onComment(value, loc);
                }
            });
        }

        const ast = parser.context[context].call(parser, options);

        if (!parser.eof) {
            parser.error();
        }

        return ast;
    };

    return Object.assign(parse, {
        SyntaxError: SyntaxError$2,
        config: parser.config
    });
}

var sourceMapGenerator = {};

var base64Vlq = {};

var base64 = {};

/* -*- Mode: js; js-indent-level: 2; -*- */

var hasRequiredBase64;

function requireBase64 () {
	if (hasRequiredBase64) return base64;
	hasRequiredBase64 = 1;
	/*
	 * Copyright 2011 Mozilla Foundation and contributors
	 * Licensed under the New BSD license. See LICENSE or:
	 * http://opensource.org/licenses/BSD-3-Clause
	 */

	var intToCharMap = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'.split('');

	/**
	 * Encode an integer in the range of 0 to 63 to a single base 64 digit.
	 */
	base64.encode = function (number) {
	  if (0 <= number && number < intToCharMap.length) {
	    return intToCharMap[number];
	  }
	  throw new TypeError("Must be between 0 and 63: " + number);
	};

	/**
	 * Decode a single base 64 character code digit to an integer. Returns -1 on
	 * failure.
	 */
	base64.decode = function (charCode) {
	  var bigA = 65;     // 'A'
	  var bigZ = 90;     // 'Z'

	  var littleA = 97;  // 'a'
	  var littleZ = 122; // 'z'

	  var zero = 48;     // '0'
	  var nine = 57;     // '9'

	  var plus = 43;     // '+'
	  var slash = 47;    // '/'

	  var littleOffset = 26;
	  var numberOffset = 52;

	  // 0 - 25: ABCDEFGHIJKLMNOPQRSTUVWXYZ
	  if (bigA <= charCode && charCode <= bigZ) {
	    return (charCode - bigA);
	  }

	  // 26 - 51: abcdefghijklmnopqrstuvwxyz
	  if (littleA <= charCode && charCode <= littleZ) {
	    return (charCode - littleA + littleOffset);
	  }

	  // 52 - 61: 0123456789
	  if (zero <= charCode && charCode <= nine) {
	    return (charCode - zero + numberOffset);
	  }

	  // 62: +
	  if (charCode == plus) {
	    return 62;
	  }

	  // 63: /
	  if (charCode == slash) {
	    return 63;
	  }

	  // Invalid base64 digit.
	  return -1;
	};
	return base64;
}

/* -*- Mode: js; js-indent-level: 2; -*- */

var hasRequiredBase64Vlq;

function requireBase64Vlq () {
	if (hasRequiredBase64Vlq) return base64Vlq;
	hasRequiredBase64Vlq = 1;
	/*
	 * Copyright 2011 Mozilla Foundation and contributors
	 * Licensed under the New BSD license. See LICENSE or:
	 * http://opensource.org/licenses/BSD-3-Clause
	 *
	 * Based on the Base 64 VLQ implementation in Closure Compiler:
	 * https://code.google.com/p/closure-compiler/source/browse/trunk/src/com/google/debugging/sourcemap/Base64VLQ.java
	 *
	 * Copyright 2011 The Closure Compiler Authors. All rights reserved.
	 * Redistribution and use in source and binary forms, with or without
	 * modification, are permitted provided that the following conditions are
	 * met:
	 *
	 *  * Redistributions of source code must retain the above copyright
	 *    notice, this list of conditions and the following disclaimer.
	 *  * Redistributions in binary form must reproduce the above
	 *    copyright notice, this list of conditions and the following
	 *    disclaimer in the documentation and/or other materials provided
	 *    with the distribution.
	 *  * Neither the name of Google Inc. nor the names of its
	 *    contributors may be used to endorse or promote products derived
	 *    from this software without specific prior written permission.
	 *
	 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
	 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
	 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
	 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
	 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
	 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
	 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
	 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	 */

	var base64 = requireBase64();

	// A single base 64 digit can contain 6 bits of data. For the base 64 variable
	// length quantities we use in the source map spec, the first bit is the sign,
	// the next four bits are the actual value, and the 6th bit is the
	// continuation bit. The continuation bit tells us whether there are more
	// digits in this value following this digit.
	//
	//   Continuation
	//   |    Sign
	//   |    |
	//   V    V
	//   101011

	var VLQ_BASE_SHIFT = 5;

	// binary: 100000
	var VLQ_BASE = 1 << VLQ_BASE_SHIFT;

	// binary: 011111
	var VLQ_BASE_MASK = VLQ_BASE - 1;

	// binary: 100000
	var VLQ_CONTINUATION_BIT = VLQ_BASE;

	/**
	 * Converts from a two-complement value to a value where the sign bit is
	 * placed in the least significant bit.  For example, as decimals:
	 *   1 becomes 2 (10 binary), -1 becomes 3 (11 binary)
	 *   2 becomes 4 (100 binary), -2 becomes 5 (101 binary)
	 */
	function toVLQSigned(aValue) {
	  return aValue < 0
	    ? ((-aValue) << 1) + 1
	    : (aValue << 1) + 0;
	}

	/**
	 * Converts to a two-complement value from a value where the sign bit is
	 * placed in the least significant bit.  For example, as decimals:
	 *   2 (10 binary) becomes 1, 3 (11 binary) becomes -1
	 *   4 (100 binary) becomes 2, 5 (101 binary) becomes -2
	 */
	function fromVLQSigned(aValue) {
	  var isNegative = (aValue & 1) === 1;
	  var shifted = aValue >> 1;
	  return isNegative
	    ? -shifted
	    : shifted;
	}

	/**
	 * Returns the base 64 VLQ encoded value.
	 */
	base64Vlq.encode = function base64VLQ_encode(aValue) {
	  var encoded = "";
	  var digit;

	  var vlq = toVLQSigned(aValue);

	  do {
	    digit = vlq & VLQ_BASE_MASK;
	    vlq >>>= VLQ_BASE_SHIFT;
	    if (vlq > 0) {
	      // There are still more digits in this value, so we must make sure the
	      // continuation bit is marked.
	      digit |= VLQ_CONTINUATION_BIT;
	    }
	    encoded += base64.encode(digit);
	  } while (vlq > 0);

	  return encoded;
	};

	/**
	 * Decodes the next base 64 VLQ value from the given string and returns the
	 * value and the rest of the string via the out parameter.
	 */
	base64Vlq.decode = function base64VLQ_decode(aStr, aIndex, aOutParam) {
	  var strLen = aStr.length;
	  var result = 0;
	  var shift = 0;
	  var continuation, digit;

	  do {
	    if (aIndex >= strLen) {
	      throw new Error("Expected more digits in base 64 VLQ value.");
	    }

	    digit = base64.decode(aStr.charCodeAt(aIndex++));
	    if (digit === -1) {
	      throw new Error("Invalid base64 digit: " + aStr.charAt(aIndex - 1));
	    }

	    continuation = !!(digit & VLQ_CONTINUATION_BIT);
	    digit &= VLQ_BASE_MASK;
	    result = result + (digit << shift);
	    shift += VLQ_BASE_SHIFT;
	  } while (continuation);

	  aOutParam.value = fromVLQSigned(result);
	  aOutParam.rest = aIndex;
	};
	return base64Vlq;
}

var util = {};

/* -*- Mode: js; js-indent-level: 2; -*- */

var hasRequiredUtil;

function requireUtil () {
	if (hasRequiredUtil) return util;
	hasRequiredUtil = 1;
	(function (exports) {
		/*
		 * Copyright 2011 Mozilla Foundation and contributors
		 * Licensed under the New BSD license. See LICENSE or:
		 * http://opensource.org/licenses/BSD-3-Clause
		 */

		/**
		 * This is a helper function for getting values from parameter/options
		 * objects.
		 *
		 * @param args The object we are extracting values from
		 * @param name The name of the property we are getting.
		 * @param defaultValue An optional value to return if the property is missing
		 * from the object. If this is not specified and the property is missing, an
		 * error will be thrown.
		 */
		function getArg(aArgs, aName, aDefaultValue) {
		  if (aName in aArgs) {
		    return aArgs[aName];
		  } else if (arguments.length === 3) {
		    return aDefaultValue;
		  } else {
		    throw new Error('"' + aName + '" is a required argument.');
		  }
		}
		exports.getArg = getArg;

		var urlRegexp = /^(?:([\w+\-.]+):)?\/\/(?:(\w+:\w+)@)?([\w.-]*)(?::(\d+))?(.*)$/;
		var dataUrlRegexp = /^data:.+\,.+$/;

		function urlParse(aUrl) {
		  var match = aUrl.match(urlRegexp);
		  if (!match) {
		    return null;
		  }
		  return {
		    scheme: match[1],
		    auth: match[2],
		    host: match[3],
		    port: match[4],
		    path: match[5]
		  };
		}
		exports.urlParse = urlParse;

		function urlGenerate(aParsedUrl) {
		  var url = '';
		  if (aParsedUrl.scheme) {
		    url += aParsedUrl.scheme + ':';
		  }
		  url += '//';
		  if (aParsedUrl.auth) {
		    url += aParsedUrl.auth + '@';
		  }
		  if (aParsedUrl.host) {
		    url += aParsedUrl.host;
		  }
		  if (aParsedUrl.port) {
		    url += ":" + aParsedUrl.port;
		  }
		  if (aParsedUrl.path) {
		    url += aParsedUrl.path;
		  }
		  return url;
		}
		exports.urlGenerate = urlGenerate;

		var MAX_CACHED_INPUTS = 32;

		/**
		 * Takes some function `f(input) -> result` and returns a memoized version of
		 * `f`.
		 *
		 * We keep at most `MAX_CACHED_INPUTS` memoized results of `f` alive. The
		 * memoization is a dumb-simple, linear least-recently-used cache.
		 */
		function lruMemoize(f) {
		  var cache = [];

		  return function(input) {
		    for (var i = 0; i < cache.length; i++) {
		      if (cache[i].input === input) {
		        var temp = cache[0];
		        cache[0] = cache[i];
		        cache[i] = temp;
		        return cache[0].result;
		      }
		    }

		    var result = f(input);

		    cache.unshift({
		      input,
		      result,
		    });

		    if (cache.length > MAX_CACHED_INPUTS) {
		      cache.pop();
		    }

		    return result;
		  };
		}

		/**
		 * Normalizes a path, or the path portion of a URL:
		 *
		 * - Replaces consecutive slashes with one slash.
		 * - Removes unnecessary '.' parts.
		 * - Removes unnecessary '<dir>/..' parts.
		 *
		 * Based on code in the Node.js 'path' core module.
		 *
		 * @param aPath The path or url to normalize.
		 */
		var normalize = lruMemoize(function normalize(aPath) {
		  var path = aPath;
		  var url = urlParse(aPath);
		  if (url) {
		    if (!url.path) {
		      return aPath;
		    }
		    path = url.path;
		  }
		  var isAbsolute = exports.isAbsolute(path);
		  // Split the path into parts between `/` characters. This is much faster than
		  // using `.split(/\/+/g)`.
		  var parts = [];
		  var start = 0;
		  var i = 0;
		  while (true) {
		    start = i;
		    i = path.indexOf("/", start);
		    if (i === -1) {
		      parts.push(path.slice(start));
		      break;
		    } else {
		      parts.push(path.slice(start, i));
		      while (i < path.length && path[i] === "/") {
		        i++;
		      }
		    }
		  }

		  for (var part, up = 0, i = parts.length - 1; i >= 0; i--) {
		    part = parts[i];
		    if (part === '.') {
		      parts.splice(i, 1);
		    } else if (part === '..') {
		      up++;
		    } else if (up > 0) {
		      if (part === '') {
		        // The first part is blank if the path is absolute. Trying to go
		        // above the root is a no-op. Therefore we can remove all '..' parts
		        // directly after the root.
		        parts.splice(i + 1, up);
		        up = 0;
		      } else {
		        parts.splice(i, 2);
		        up--;
		      }
		    }
		  }
		  path = parts.join('/');

		  if (path === '') {
		    path = isAbsolute ? '/' : '.';
		  }

		  if (url) {
		    url.path = path;
		    return urlGenerate(url);
		  }
		  return path;
		});
		exports.normalize = normalize;

		/**
		 * Joins two paths/URLs.
		 *
		 * @param aRoot The root path or URL.
		 * @param aPath The path or URL to be joined with the root.
		 *
		 * - If aPath is a URL or a data URI, aPath is returned, unless aPath is a
		 *   scheme-relative URL: Then the scheme of aRoot, if any, is prepended
		 *   first.
		 * - Otherwise aPath is a path. If aRoot is a URL, then its path portion
		 *   is updated with the result and aRoot is returned. Otherwise the result
		 *   is returned.
		 *   - If aPath is absolute, the result is aPath.
		 *   - Otherwise the two paths are joined with a slash.
		 * - Joining for example 'http://' and 'www.example.com' is also supported.
		 */
		function join(aRoot, aPath) {
		  if (aRoot === "") {
		    aRoot = ".";
		  }
		  if (aPath === "") {
		    aPath = ".";
		  }
		  var aPathUrl = urlParse(aPath);
		  var aRootUrl = urlParse(aRoot);
		  if (aRootUrl) {
		    aRoot = aRootUrl.path || '/';
		  }

		  // `join(foo, '//www.example.org')`
		  if (aPathUrl && !aPathUrl.scheme) {
		    if (aRootUrl) {
		      aPathUrl.scheme = aRootUrl.scheme;
		    }
		    return urlGenerate(aPathUrl);
		  }

		  if (aPathUrl || aPath.match(dataUrlRegexp)) {
		    return aPath;
		  }

		  // `join('http://', 'www.example.com')`
		  if (aRootUrl && !aRootUrl.host && !aRootUrl.path) {
		    aRootUrl.host = aPath;
		    return urlGenerate(aRootUrl);
		  }

		  var joined = aPath.charAt(0) === '/'
		    ? aPath
		    : normalize(aRoot.replace(/\/+$/, '') + '/' + aPath);

		  if (aRootUrl) {
		    aRootUrl.path = joined;
		    return urlGenerate(aRootUrl);
		  }
		  return joined;
		}
		exports.join = join;

		exports.isAbsolute = function (aPath) {
		  return aPath.charAt(0) === '/' || urlRegexp.test(aPath);
		};

		/**
		 * Make a path relative to a URL or another path.
		 *
		 * @param aRoot The root path or URL.
		 * @param aPath The path or URL to be made relative to aRoot.
		 */
		function relative(aRoot, aPath) {
		  if (aRoot === "") {
		    aRoot = ".";
		  }

		  aRoot = aRoot.replace(/\/$/, '');

		  // It is possible for the path to be above the root. In this case, simply
		  // checking whether the root is a prefix of the path won't work. Instead, we
		  // need to remove components from the root one by one, until either we find
		  // a prefix that fits, or we run out of components to remove.
		  var level = 0;
		  while (aPath.indexOf(aRoot + '/') !== 0) {
		    var index = aRoot.lastIndexOf("/");
		    if (index < 0) {
		      return aPath;
		    }

		    // If the only part of the root that is left is the scheme (i.e. http://,
		    // file:///, etc.), one or more slashes (/), or simply nothing at all, we
		    // have exhausted all components, so the path is not relative to the root.
		    aRoot = aRoot.slice(0, index);
		    if (aRoot.match(/^([^\/]+:\/)?\/*$/)) {
		      return aPath;
		    }

		    ++level;
		  }

		  // Make sure we add a "../" for each component we removed from the root.
		  return Array(level + 1).join("../") + aPath.substr(aRoot.length + 1);
		}
		exports.relative = relative;

		var supportsNullProto = (function () {
		  var obj = Object.create(null);
		  return !('__proto__' in obj);
		}());

		function identity (s) {
		  return s;
		}

		/**
		 * Because behavior goes wacky when you set `__proto__` on objects, we
		 * have to prefix all the strings in our set with an arbitrary character.
		 *
		 * See https://github.com/mozilla/source-map/pull/31 and
		 * https://github.com/mozilla/source-map/issues/30
		 *
		 * @param String aStr
		 */
		function toSetString(aStr) {
		  if (isProtoString(aStr)) {
		    return '$' + aStr;
		  }

		  return aStr;
		}
		exports.toSetString = supportsNullProto ? identity : toSetString;

		function fromSetString(aStr) {
		  if (isProtoString(aStr)) {
		    return aStr.slice(1);
		  }

		  return aStr;
		}
		exports.fromSetString = supportsNullProto ? identity : fromSetString;

		function isProtoString(s) {
		  if (!s) {
		    return false;
		  }

		  var length = s.length;

		  if (length < 9 /* "__proto__".length */) {
		    return false;
		  }

		  if (s.charCodeAt(length - 1) !== 95  /* '_' */ ||
		      s.charCodeAt(length - 2) !== 95  /* '_' */ ||
		      s.charCodeAt(length - 3) !== 111 /* 'o' */ ||
		      s.charCodeAt(length - 4) !== 116 /* 't' */ ||
		      s.charCodeAt(length - 5) !== 111 /* 'o' */ ||
		      s.charCodeAt(length - 6) !== 114 /* 'r' */ ||
		      s.charCodeAt(length - 7) !== 112 /* 'p' */ ||
		      s.charCodeAt(length - 8) !== 95  /* '_' */ ||
		      s.charCodeAt(length - 9) !== 95  /* '_' */) {
		    return false;
		  }

		  for (var i = length - 10; i >= 0; i--) {
		    if (s.charCodeAt(i) !== 36 /* '$' */) {
		      return false;
		    }
		  }

		  return true;
		}

		/**
		 * Comparator between two mappings where the original positions are compared.
		 *
		 * Optionally pass in `true` as `onlyCompareGenerated` to consider two
		 * mappings with the same original source/line/column, but different generated
		 * line and column the same. Useful when searching for a mapping with a
		 * stubbed out mapping.
		 */
		function compareByOriginalPositions(mappingA, mappingB, onlyCompareOriginal) {
		  var cmp = strcmp(mappingA.source, mappingB.source);
		  if (cmp !== 0) {
		    return cmp;
		  }

		  cmp = mappingA.originalLine - mappingB.originalLine;
		  if (cmp !== 0) {
		    return cmp;
		  }

		  cmp = mappingA.originalColumn - mappingB.originalColumn;
		  if (cmp !== 0 || onlyCompareOriginal) {
		    return cmp;
		  }

		  cmp = mappingA.generatedColumn - mappingB.generatedColumn;
		  if (cmp !== 0) {
		    return cmp;
		  }

		  cmp = mappingA.generatedLine - mappingB.generatedLine;
		  if (cmp !== 0) {
		    return cmp;
		  }

		  return strcmp(mappingA.name, mappingB.name);
		}
		exports.compareByOriginalPositions = compareByOriginalPositions;

		function compareByOriginalPositionsNoSource(mappingA, mappingB, onlyCompareOriginal) {
		  var cmp;

		  cmp = mappingA.originalLine - mappingB.originalLine;
		  if (cmp !== 0) {
		    return cmp;
		  }

		  cmp = mappingA.originalColumn - mappingB.originalColumn;
		  if (cmp !== 0 || onlyCompareOriginal) {
		    return cmp;
		  }

		  cmp = mappingA.generatedColumn - mappingB.generatedColumn;
		  if (cmp !== 0) {
		    return cmp;
		  }

		  cmp = mappingA.generatedLine - mappingB.generatedLine;
		  if (cmp !== 0) {
		    return cmp;
		  }

		  return strcmp(mappingA.name, mappingB.name);
		}
		exports.compareByOriginalPositionsNoSource = compareByOriginalPositionsNoSource;

		/**
		 * Comparator between two mappings with deflated source and name indices where
		 * the generated positions are compared.
		 *
		 * Optionally pass in `true` as `onlyCompareGenerated` to consider two
		 * mappings with the same generated line and column, but different
		 * source/name/original line and column the same. Useful when searching for a
		 * mapping with a stubbed out mapping.
		 */
		function compareByGeneratedPositionsDeflated(mappingA, mappingB, onlyCompareGenerated) {
		  var cmp = mappingA.generatedLine - mappingB.generatedLine;
		  if (cmp !== 0) {
		    return cmp;
		  }

		  cmp = mappingA.generatedColumn - mappingB.generatedColumn;
		  if (cmp !== 0 || onlyCompareGenerated) {
		    return cmp;
		  }

		  cmp = strcmp(mappingA.source, mappingB.source);
		  if (cmp !== 0) {
		    return cmp;
		  }

		  cmp = mappingA.originalLine - mappingB.originalLine;
		  if (cmp !== 0) {
		    return cmp;
		  }

		  cmp = mappingA.originalColumn - mappingB.originalColumn;
		  if (cmp !== 0) {
		    return cmp;
		  }

		  return strcmp(mappingA.name, mappingB.name);
		}
		exports.compareByGeneratedPositionsDeflated = compareByGeneratedPositionsDeflated;

		function compareByGeneratedPositionsDeflatedNoLine(mappingA, mappingB, onlyCompareGenerated) {
		  var cmp = mappingA.generatedColumn - mappingB.generatedColumn;
		  if (cmp !== 0 || onlyCompareGenerated) {
		    return cmp;
		  }

		  cmp = strcmp(mappingA.source, mappingB.source);
		  if (cmp !== 0) {
		    return cmp;
		  }

		  cmp = mappingA.originalLine - mappingB.originalLine;
		  if (cmp !== 0) {
		    return cmp;
		  }

		  cmp = mappingA.originalColumn - mappingB.originalColumn;
		  if (cmp !== 0) {
		    return cmp;
		  }

		  return strcmp(mappingA.name, mappingB.name);
		}
		exports.compareByGeneratedPositionsDeflatedNoLine = compareByGeneratedPositionsDeflatedNoLine;

		function strcmp(aStr1, aStr2) {
		  if (aStr1 === aStr2) {
		    return 0;
		  }

		  if (aStr1 === null) {
		    return 1; // aStr2 !== null
		  }

		  if (aStr2 === null) {
		    return -1; // aStr1 !== null
		  }

		  if (aStr1 > aStr2) {
		    return 1;
		  }

		  return -1;
		}

		/**
		 * Comparator between two mappings with inflated source and name strings where
		 * the generated positions are compared.
		 */
		function compareByGeneratedPositionsInflated(mappingA, mappingB) {
		  var cmp = mappingA.generatedLine - mappingB.generatedLine;
		  if (cmp !== 0) {
		    return cmp;
		  }

		  cmp = mappingA.generatedColumn - mappingB.generatedColumn;
		  if (cmp !== 0) {
		    return cmp;
		  }

		  cmp = strcmp(mappingA.source, mappingB.source);
		  if (cmp !== 0) {
		    return cmp;
		  }

		  cmp = mappingA.originalLine - mappingB.originalLine;
		  if (cmp !== 0) {
		    return cmp;
		  }

		  cmp = mappingA.originalColumn - mappingB.originalColumn;
		  if (cmp !== 0) {
		    return cmp;
		  }

		  return strcmp(mappingA.name, mappingB.name);
		}
		exports.compareByGeneratedPositionsInflated = compareByGeneratedPositionsInflated;

		/**
		 * Strip any JSON XSSI avoidance prefix from the string (as documented
		 * in the source maps specification), and then parse the string as
		 * JSON.
		 */
		function parseSourceMapInput(str) {
		  return JSON.parse(str.replace(/^\)]}'[^\n]*\n/, ''));
		}
		exports.parseSourceMapInput = parseSourceMapInput;

		/**
		 * Compute the URL of a source given the the source root, the source's
		 * URL, and the source map's URL.
		 */
		function computeSourceURL(sourceRoot, sourceURL, sourceMapURL) {
		  sourceURL = sourceURL || '';

		  if (sourceRoot) {
		    // This follows what Chrome does.
		    if (sourceRoot[sourceRoot.length - 1] !== '/' && sourceURL[0] !== '/') {
		      sourceRoot += '/';
		    }
		    // The spec says:
		    //   Line 4: An optional source root, useful for relocating source
		    //   files on a server or removing repeated values in the
		    //   “sources” entry.  This value is prepended to the individual
		    //   entries in the “source” field.
		    sourceURL = sourceRoot + sourceURL;
		  }

		  // Historically, SourceMapConsumer did not take the sourceMapURL as
		  // a parameter.  This mode is still somewhat supported, which is why
		  // this code block is conditional.  However, it's preferable to pass
		  // the source map URL to SourceMapConsumer, so that this function
		  // can implement the source URL resolution algorithm as outlined in
		  // the spec.  This block is basically the equivalent of:
		  //    new URL(sourceURL, sourceMapURL).toString()
		  // ... except it avoids using URL, which wasn't available in the
		  // older releases of node still supported by this library.
		  //
		  // The spec says:
		  //   If the sources are not absolute URLs after prepending of the
		  //   “sourceRoot”, the sources are resolved relative to the
		  //   SourceMap (like resolving script src in a html document).
		  if (sourceMapURL) {
		    var parsed = urlParse(sourceMapURL);
		    if (!parsed) {
		      throw new Error("sourceMapURL could not be parsed");
		    }
		    if (parsed.path) {
		      // Strip the last path component, but keep the "/".
		      var index = parsed.path.lastIndexOf('/');
		      if (index >= 0) {
		        parsed.path = parsed.path.substring(0, index + 1);
		      }
		    }
		    sourceURL = join(urlGenerate(parsed), sourceURL);
		  }

		  return normalize(sourceURL);
		}
		exports.computeSourceURL = computeSourceURL; 
	} (util));
	return util;
}

var arraySet = {};

/* -*- Mode: js; js-indent-level: 2; -*- */

var hasRequiredArraySet;

function requireArraySet () {
	if (hasRequiredArraySet) return arraySet;
	hasRequiredArraySet = 1;
	/*
	 * Copyright 2011 Mozilla Foundation and contributors
	 * Licensed under the New BSD license. See LICENSE or:
	 * http://opensource.org/licenses/BSD-3-Clause
	 */

	var util = requireUtil();
	var has = Object.prototype.hasOwnProperty;
	var hasNativeMap = typeof Map !== "undefined";

	/**
	 * A data structure which is a combination of an array and a set. Adding a new
	 * member is O(1), testing for membership is O(1), and finding the index of an
	 * element is O(1). Removing elements from the set is not supported. Only
	 * strings are supported for membership.
	 */
	function ArraySet() {
	  this._array = [];
	  this._set = hasNativeMap ? new Map() : Object.create(null);
	}

	/**
	 * Static method for creating ArraySet instances from an existing array.
	 */
	ArraySet.fromArray = function ArraySet_fromArray(aArray, aAllowDuplicates) {
	  var set = new ArraySet();
	  for (var i = 0, len = aArray.length; i < len; i++) {
	    set.add(aArray[i], aAllowDuplicates);
	  }
	  return set;
	};

	/**
	 * Return how many unique items are in this ArraySet. If duplicates have been
	 * added, than those do not count towards the size.
	 *
	 * @returns Number
	 */
	ArraySet.prototype.size = function ArraySet_size() {
	  return hasNativeMap ? this._set.size : Object.getOwnPropertyNames(this._set).length;
	};

	/**
	 * Add the given string to this set.
	 *
	 * @param String aStr
	 */
	ArraySet.prototype.add = function ArraySet_add(aStr, aAllowDuplicates) {
	  var sStr = hasNativeMap ? aStr : util.toSetString(aStr);
	  var isDuplicate = hasNativeMap ? this.has(aStr) : has.call(this._set, sStr);
	  var idx = this._array.length;
	  if (!isDuplicate || aAllowDuplicates) {
	    this._array.push(aStr);
	  }
	  if (!isDuplicate) {
	    if (hasNativeMap) {
	      this._set.set(aStr, idx);
	    } else {
	      this._set[sStr] = idx;
	    }
	  }
	};

	/**
	 * Is the given string a member of this set?
	 *
	 * @param String aStr
	 */
	ArraySet.prototype.has = function ArraySet_has(aStr) {
	  if (hasNativeMap) {
	    return this._set.has(aStr);
	  } else {
	    var sStr = util.toSetString(aStr);
	    return has.call(this._set, sStr);
	  }
	};

	/**
	 * What is the index of the given string in the array?
	 *
	 * @param String aStr
	 */
	ArraySet.prototype.indexOf = function ArraySet_indexOf(aStr) {
	  if (hasNativeMap) {
	    var idx = this._set.get(aStr);
	    if (idx >= 0) {
	        return idx;
	    }
	  } else {
	    var sStr = util.toSetString(aStr);
	    if (has.call(this._set, sStr)) {
	      return this._set[sStr];
	    }
	  }

	  throw new Error('"' + aStr + '" is not in the set.');
	};

	/**
	 * What is the element at the given index?
	 *
	 * @param Number aIdx
	 */
	ArraySet.prototype.at = function ArraySet_at(aIdx) {
	  if (aIdx >= 0 && aIdx < this._array.length) {
	    return this._array[aIdx];
	  }
	  throw new Error('No element indexed by ' + aIdx);
	};

	/**
	 * Returns the array representation of this set (which has the proper indices
	 * indicated by indexOf). Note that this is a copy of the internal array used
	 * for storing the members so that no one can mess with internal state.
	 */
	ArraySet.prototype.toArray = function ArraySet_toArray() {
	  return this._array.slice();
	};

	arraySet.ArraySet = ArraySet;
	return arraySet;
}

var mappingList = {};

/* -*- Mode: js; js-indent-level: 2; -*- */

var hasRequiredMappingList;

function requireMappingList () {
	if (hasRequiredMappingList) return mappingList;
	hasRequiredMappingList = 1;
	/*
	 * Copyright 2014 Mozilla Foundation and contributors
	 * Licensed under the New BSD license. See LICENSE or:
	 * http://opensource.org/licenses/BSD-3-Clause
	 */

	var util = requireUtil();

	/**
	 * Determine whether mappingB is after mappingA with respect to generated
	 * position.
	 */
	function generatedPositionAfter(mappingA, mappingB) {
	  // Optimized for most common case
	  var lineA = mappingA.generatedLine;
	  var lineB = mappingB.generatedLine;
	  var columnA = mappingA.generatedColumn;
	  var columnB = mappingB.generatedColumn;
	  return lineB > lineA || lineB == lineA && columnB >= columnA ||
	         util.compareByGeneratedPositionsInflated(mappingA, mappingB) <= 0;
	}

	/**
	 * A data structure to provide a sorted view of accumulated mappings in a
	 * performance conscious manner. It trades a neglibable overhead in general
	 * case for a large speedup in case of mappings being added in order.
	 */
	function MappingList() {
	  this._array = [];
	  this._sorted = true;
	  // Serves as infimum
	  this._last = {generatedLine: -1, generatedColumn: 0};
	}

	/**
	 * Iterate through internal items. This method takes the same arguments that
	 * `Array.prototype.forEach` takes.
	 *
	 * NOTE: The order of the mappings is NOT guaranteed.
	 */
	MappingList.prototype.unsortedForEach =
	  function MappingList_forEach(aCallback, aThisArg) {
	    this._array.forEach(aCallback, aThisArg);
	  };

	/**
	 * Add the given source mapping.
	 *
	 * @param Object aMapping
	 */
	MappingList.prototype.add = function MappingList_add(aMapping) {
	  if (generatedPositionAfter(this._last, aMapping)) {
	    this._last = aMapping;
	    this._array.push(aMapping);
	  } else {
	    this._sorted = false;
	    this._array.push(aMapping);
	  }
	};

	/**
	 * Returns the flat, sorted array of mappings. The mappings are sorted by
	 * generated position.
	 *
	 * WARNING: This method returns internal data without copying, for
	 * performance. The return value must NOT be mutated, and should be treated as
	 * an immutable borrow. If you want to take ownership, you must make your own
	 * copy.
	 */
	MappingList.prototype.toArray = function MappingList_toArray() {
	  if (!this._sorted) {
	    this._array.sort(util.compareByGeneratedPositionsInflated);
	    this._sorted = true;
	  }
	  return this._array;
	};

	mappingList.MappingList = MappingList;
	return mappingList;
}

/* -*- Mode: js; js-indent-level: 2; -*- */

var hasRequiredSourceMapGenerator;

function requireSourceMapGenerator () {
	if (hasRequiredSourceMapGenerator) return sourceMapGenerator;
	hasRequiredSourceMapGenerator = 1;
	/*
	 * Copyright 2011 Mozilla Foundation and contributors
	 * Licensed under the New BSD license. See LICENSE or:
	 * http://opensource.org/licenses/BSD-3-Clause
	 */

	var base64VLQ = requireBase64Vlq();
	var util = requireUtil();
	var ArraySet = requireArraySet().ArraySet;
	var MappingList = requireMappingList().MappingList;

	/**
	 * An instance of the SourceMapGenerator represents a source map which is
	 * being built incrementally. You may pass an object with the following
	 * properties:
	 *
	 *   - file: The filename of the generated source.
	 *   - sourceRoot: A root for all relative URLs in this source map.
	 */
	function SourceMapGenerator(aArgs) {
	  if (!aArgs) {
	    aArgs = {};
	  }
	  this._file = util.getArg(aArgs, 'file', null);
	  this._sourceRoot = util.getArg(aArgs, 'sourceRoot', null);
	  this._skipValidation = util.getArg(aArgs, 'skipValidation', false);
	  this._sources = new ArraySet();
	  this._names = new ArraySet();
	  this._mappings = new MappingList();
	  this._sourcesContents = null;
	}

	SourceMapGenerator.prototype._version = 3;

	/**
	 * Creates a new SourceMapGenerator based on a SourceMapConsumer
	 *
	 * @param aSourceMapConsumer The SourceMap.
	 */
	SourceMapGenerator.fromSourceMap =
	  function SourceMapGenerator_fromSourceMap(aSourceMapConsumer) {
	    var sourceRoot = aSourceMapConsumer.sourceRoot;
	    var generator = new SourceMapGenerator({
	      file: aSourceMapConsumer.file,
	      sourceRoot: sourceRoot
	    });
	    aSourceMapConsumer.eachMapping(function (mapping) {
	      var newMapping = {
	        generated: {
	          line: mapping.generatedLine,
	          column: mapping.generatedColumn
	        }
	      };

	      if (mapping.source != null) {
	        newMapping.source = mapping.source;
	        if (sourceRoot != null) {
	          newMapping.source = util.relative(sourceRoot, newMapping.source);
	        }

	        newMapping.original = {
	          line: mapping.originalLine,
	          column: mapping.originalColumn
	        };

	        if (mapping.name != null) {
	          newMapping.name = mapping.name;
	        }
	      }

	      generator.addMapping(newMapping);
	    });
	    aSourceMapConsumer.sources.forEach(function (sourceFile) {
	      var sourceRelative = sourceFile;
	      if (sourceRoot !== null) {
	        sourceRelative = util.relative(sourceRoot, sourceFile);
	      }

	      if (!generator._sources.has(sourceRelative)) {
	        generator._sources.add(sourceRelative);
	      }

	      var content = aSourceMapConsumer.sourceContentFor(sourceFile);
	      if (content != null) {
	        generator.setSourceContent(sourceFile, content);
	      }
	    });
	    return generator;
	  };

	/**
	 * Add a single mapping from original source line and column to the generated
	 * source's line and column for this source map being created. The mapping
	 * object should have the following properties:
	 *
	 *   - generated: An object with the generated line and column positions.
	 *   - original: An object with the original line and column positions.
	 *   - source: The original source file (relative to the sourceRoot).
	 *   - name: An optional original token name for this mapping.
	 */
	SourceMapGenerator.prototype.addMapping =
	  function SourceMapGenerator_addMapping(aArgs) {
	    var generated = util.getArg(aArgs, 'generated');
	    var original = util.getArg(aArgs, 'original', null);
	    var source = util.getArg(aArgs, 'source', null);
	    var name = util.getArg(aArgs, 'name', null);

	    if (!this._skipValidation) {
	      this._validateMapping(generated, original, source, name);
	    }

	    if (source != null) {
	      source = String(source);
	      if (!this._sources.has(source)) {
	        this._sources.add(source);
	      }
	    }

	    if (name != null) {
	      name = String(name);
	      if (!this._names.has(name)) {
	        this._names.add(name);
	      }
	    }

	    this._mappings.add({
	      generatedLine: generated.line,
	      generatedColumn: generated.column,
	      originalLine: original != null && original.line,
	      originalColumn: original != null && original.column,
	      source: source,
	      name: name
	    });
	  };

	/**
	 * Set the source content for a source file.
	 */
	SourceMapGenerator.prototype.setSourceContent =
	  function SourceMapGenerator_setSourceContent(aSourceFile, aSourceContent) {
	    var source = aSourceFile;
	    if (this._sourceRoot != null) {
	      source = util.relative(this._sourceRoot, source);
	    }

	    if (aSourceContent != null) {
	      // Add the source content to the _sourcesContents map.
	      // Create a new _sourcesContents map if the property is null.
	      if (!this._sourcesContents) {
	        this._sourcesContents = Object.create(null);
	      }
	      this._sourcesContents[util.toSetString(source)] = aSourceContent;
	    } else if (this._sourcesContents) {
	      // Remove the source file from the _sourcesContents map.
	      // If the _sourcesContents map is empty, set the property to null.
	      delete this._sourcesContents[util.toSetString(source)];
	      if (Object.keys(this._sourcesContents).length === 0) {
	        this._sourcesContents = null;
	      }
	    }
	  };

	/**
	 * Applies the mappings of a sub-source-map for a specific source file to the
	 * source map being generated. Each mapping to the supplied source file is
	 * rewritten using the supplied source map. Note: The resolution for the
	 * resulting mappings is the minimium of this map and the supplied map.
	 *
	 * @param aSourceMapConsumer The source map to be applied.
	 * @param aSourceFile Optional. The filename of the source file.
	 *        If omitted, SourceMapConsumer's file property will be used.
	 * @param aSourceMapPath Optional. The dirname of the path to the source map
	 *        to be applied. If relative, it is relative to the SourceMapConsumer.
	 *        This parameter is needed when the two source maps aren't in the same
	 *        directory, and the source map to be applied contains relative source
	 *        paths. If so, those relative source paths need to be rewritten
	 *        relative to the SourceMapGenerator.
	 */
	SourceMapGenerator.prototype.applySourceMap =
	  function SourceMapGenerator_applySourceMap(aSourceMapConsumer, aSourceFile, aSourceMapPath) {
	    var sourceFile = aSourceFile;
	    // If aSourceFile is omitted, we will use the file property of the SourceMap
	    if (aSourceFile == null) {
	      if (aSourceMapConsumer.file == null) {
	        throw new Error(
	          'SourceMapGenerator.prototype.applySourceMap requires either an explicit source file, ' +
	          'or the source map\'s "file" property. Both were omitted.'
	        );
	      }
	      sourceFile = aSourceMapConsumer.file;
	    }
	    var sourceRoot = this._sourceRoot;
	    // Make "sourceFile" relative if an absolute Url is passed.
	    if (sourceRoot != null) {
	      sourceFile = util.relative(sourceRoot, sourceFile);
	    }
	    // Applying the SourceMap can add and remove items from the sources and
	    // the names array.
	    var newSources = new ArraySet();
	    var newNames = new ArraySet();

	    // Find mappings for the "sourceFile"
	    this._mappings.unsortedForEach(function (mapping) {
	      if (mapping.source === sourceFile && mapping.originalLine != null) {
	        // Check if it can be mapped by the source map, then update the mapping.
	        var original = aSourceMapConsumer.originalPositionFor({
	          line: mapping.originalLine,
	          column: mapping.originalColumn
	        });
	        if (original.source != null) {
	          // Copy mapping
	          mapping.source = original.source;
	          if (aSourceMapPath != null) {
	            mapping.source = util.join(aSourceMapPath, mapping.source);
	          }
	          if (sourceRoot != null) {
	            mapping.source = util.relative(sourceRoot, mapping.source);
	          }
	          mapping.originalLine = original.line;
	          mapping.originalColumn = original.column;
	          if (original.name != null) {
	            mapping.name = original.name;
	          }
	        }
	      }

	      var source = mapping.source;
	      if (source != null && !newSources.has(source)) {
	        newSources.add(source);
	      }

	      var name = mapping.name;
	      if (name != null && !newNames.has(name)) {
	        newNames.add(name);
	      }

	    }, this);
	    this._sources = newSources;
	    this._names = newNames;

	    // Copy sourcesContents of applied map.
	    aSourceMapConsumer.sources.forEach(function (sourceFile) {
	      var content = aSourceMapConsumer.sourceContentFor(sourceFile);
	      if (content != null) {
	        if (aSourceMapPath != null) {
	          sourceFile = util.join(aSourceMapPath, sourceFile);
	        }
	        if (sourceRoot != null) {
	          sourceFile = util.relative(sourceRoot, sourceFile);
	        }
	        this.setSourceContent(sourceFile, content);
	      }
	    }, this);
	  };

	/**
	 * A mapping can have one of the three levels of data:
	 *
	 *   1. Just the generated position.
	 *   2. The Generated position, original position, and original source.
	 *   3. Generated and original position, original source, as well as a name
	 *      token.
	 *
	 * To maintain consistency, we validate that any new mapping being added falls
	 * in to one of these categories.
	 */
	SourceMapGenerator.prototype._validateMapping =
	  function SourceMapGenerator_validateMapping(aGenerated, aOriginal, aSource,
	                                              aName) {
	    // When aOriginal is truthy but has empty values for .line and .column,
	    // it is most likely a programmer error. In this case we throw a very
	    // specific error message to try to guide them the right way.
	    // For example: https://github.com/Polymer/polymer-bundler/pull/519
	    if (aOriginal && typeof aOriginal.line !== 'number' && typeof aOriginal.column !== 'number') {
	        throw new Error(
	            'original.line and original.column are not numbers -- you probably meant to omit ' +
	            'the original mapping entirely and only map the generated position. If so, pass ' +
	            'null for the original mapping instead of an object with empty or null values.'
	        );
	    }

	    if (aGenerated && 'line' in aGenerated && 'column' in aGenerated
	        && aGenerated.line > 0 && aGenerated.column >= 0
	        && !aOriginal && !aSource && !aName) {
	      // Case 1.
	      return;
	    }
	    else if (aGenerated && 'line' in aGenerated && 'column' in aGenerated
	             && aOriginal && 'line' in aOriginal && 'column' in aOriginal
	             && aGenerated.line > 0 && aGenerated.column >= 0
	             && aOriginal.line > 0 && aOriginal.column >= 0
	             && aSource) {
	      // Cases 2 and 3.
	      return;
	    }
	    else {
	      throw new Error('Invalid mapping: ' + JSON.stringify({
	        generated: aGenerated,
	        source: aSource,
	        original: aOriginal,
	        name: aName
	      }));
	    }
	  };

	/**
	 * Serialize the accumulated mappings in to the stream of base 64 VLQs
	 * specified by the source map format.
	 */
	SourceMapGenerator.prototype._serializeMappings =
	  function SourceMapGenerator_serializeMappings() {
	    var previousGeneratedColumn = 0;
	    var previousGeneratedLine = 1;
	    var previousOriginalColumn = 0;
	    var previousOriginalLine = 0;
	    var previousName = 0;
	    var previousSource = 0;
	    var result = '';
	    var next;
	    var mapping;
	    var nameIdx;
	    var sourceIdx;

	    var mappings = this._mappings.toArray();
	    for (var i = 0, len = mappings.length; i < len; i++) {
	      mapping = mappings[i];
	      next = '';

	      if (mapping.generatedLine !== previousGeneratedLine) {
	        previousGeneratedColumn = 0;
	        while (mapping.generatedLine !== previousGeneratedLine) {
	          next += ';';
	          previousGeneratedLine++;
	        }
	      }
	      else {
	        if (i > 0) {
	          if (!util.compareByGeneratedPositionsInflated(mapping, mappings[i - 1])) {
	            continue;
	          }
	          next += ',';
	        }
	      }

	      next += base64VLQ.encode(mapping.generatedColumn
	                                 - previousGeneratedColumn);
	      previousGeneratedColumn = mapping.generatedColumn;

	      if (mapping.source != null) {
	        sourceIdx = this._sources.indexOf(mapping.source);
	        next += base64VLQ.encode(sourceIdx - previousSource);
	        previousSource = sourceIdx;

	        // lines are stored 0-based in SourceMap spec version 3
	        next += base64VLQ.encode(mapping.originalLine - 1
	                                   - previousOriginalLine);
	        previousOriginalLine = mapping.originalLine - 1;

	        next += base64VLQ.encode(mapping.originalColumn
	                                   - previousOriginalColumn);
	        previousOriginalColumn = mapping.originalColumn;

	        if (mapping.name != null) {
	          nameIdx = this._names.indexOf(mapping.name);
	          next += base64VLQ.encode(nameIdx - previousName);
	          previousName = nameIdx;
	        }
	      }

	      result += next;
	    }

	    return result;
	  };

	SourceMapGenerator.prototype._generateSourcesContent =
	  function SourceMapGenerator_generateSourcesContent(aSources, aSourceRoot) {
	    return aSources.map(function (source) {
	      if (!this._sourcesContents) {
	        return null;
	      }
	      if (aSourceRoot != null) {
	        source = util.relative(aSourceRoot, source);
	      }
	      var key = util.toSetString(source);
	      return Object.prototype.hasOwnProperty.call(this._sourcesContents, key)
	        ? this._sourcesContents[key]
	        : null;
	    }, this);
	  };

	/**
	 * Externalize the source map.
	 */
	SourceMapGenerator.prototype.toJSON =
	  function SourceMapGenerator_toJSON() {
	    var map = {
	      version: this._version,
	      sources: this._sources.toArray(),
	      names: this._names.toArray(),
	      mappings: this._serializeMappings()
	    };
	    if (this._file != null) {
	      map.file = this._file;
	    }
	    if (this._sourceRoot != null) {
	      map.sourceRoot = this._sourceRoot;
	    }
	    if (this._sourcesContents) {
	      map.sourcesContent = this._generateSourcesContent(map.sources, map.sourceRoot);
	    }

	    return map;
	  };

	/**
	 * Render the source map being generated to a string.
	 */
	SourceMapGenerator.prototype.toString =
	  function SourceMapGenerator_toString() {
	    return JSON.stringify(this.toJSON());
	  };

	sourceMapGenerator.SourceMapGenerator = SourceMapGenerator;
	return sourceMapGenerator;
}

var sourceMapGeneratorExports = requireSourceMapGenerator();

const trackNodes = new Set(['Atrule', 'Selector', 'Declaration']);

function generateSourceMap(handlers) {
    const map = new sourceMapGeneratorExports.SourceMapGenerator();
    const generated = {
        line: 1,
        column: 0
    };
    const original = {
        line: 0, // should be zero to add first mapping
        column: 0
    };
    const activatedGenerated = {
        line: 1,
        column: 0
    };
    const activatedMapping = {
        generated: activatedGenerated
    };
    let line = 1;
    let column = 0;
    let sourceMappingActive = false;

    const origHandlersNode = handlers.node;
    handlers.node = function(node) {
        if (node.loc && node.loc.start && trackNodes.has(node.type)) {
            const nodeLine = node.loc.start.line;
            const nodeColumn = node.loc.start.column - 1;

            if (original.line !== nodeLine ||
                original.column !== nodeColumn) {
                original.line = nodeLine;
                original.column = nodeColumn;

                generated.line = line;
                generated.column = column;

                if (sourceMappingActive) {
                    sourceMappingActive = false;
                    if (generated.line !== activatedGenerated.line ||
                        generated.column !== activatedGenerated.column) {
                        map.addMapping(activatedMapping);
                    }
                }

                sourceMappingActive = true;
                map.addMapping({
                    source: node.loc.source,
                    original,
                    generated
                });
            }
        }

        origHandlersNode.call(this, node);

        if (sourceMappingActive && trackNodes.has(node.type)) {
            activatedGenerated.line = line;
            activatedGenerated.column = column;
        }
    };

    const origHandlersEmit = handlers.emit;
    handlers.emit = function(value, type, auto) {
        for (let i = 0; i < value.length; i++) {
            if (value.charCodeAt(i) === 10) { // \n
                line++;
                column = 0;
            } else {
                column++;
            }
        }

        origHandlersEmit(value, type, auto);
    };

    const origHandlersResult = handlers.result;
    handlers.result = function() {
        if (sourceMappingActive) {
            map.addMapping(activatedMapping);
        }

        return {
            css: origHandlersResult(),
            map
        };
    };

    return handlers;
}

const PLUSSIGN$9 = 0x002B;    // U+002B PLUS SIGN (+)
const HYPHENMINUS$6 = 0x002D; // U+002D HYPHEN-MINUS (-)

const code = (type, value) => {
    if (type === Delim) {
        type = value;
    }

    if (typeof type === 'string') {
        const charCode = type.charCodeAt(0);
        return charCode > 0x7F ? 0x8000 : charCode << 8;
    }

    return type;
};

// https://www.w3.org/TR/css-syntax-3/#serialization
// The only requirement for serialization is that it must "round-trip" with parsing,
// that is, parsing the stylesheet must produce the same data structures as parsing,
// serializing, and parsing again, except for consecutive <whitespace-token>s,
// which may be collapsed into a single token.

const specPairs = [
    [Ident, Ident],
    [Ident, Function$1],
    [Ident, Url$1],
    [Ident, BadUrl],
    [Ident, '-'],
    [Ident, Number$2],
    [Ident, Percentage$1],
    [Ident, Dimension$1],
    [Ident, CDC$1],
    [Ident, LeftParenthesis],

    [AtKeyword, Ident],
    [AtKeyword, Function$1],
    [AtKeyword, Url$1],
    [AtKeyword, BadUrl],
    [AtKeyword, '-'],
    [AtKeyword, Number$2],
    [AtKeyword, Percentage$1],
    [AtKeyword, Dimension$1],
    [AtKeyword, CDC$1],

    [Hash$1, Ident],
    [Hash$1, Function$1],
    [Hash$1, Url$1],
    [Hash$1, BadUrl],
    [Hash$1, '-'],
    [Hash$1, Number$2],
    [Hash$1, Percentage$1],
    [Hash$1, Dimension$1],
    [Hash$1, CDC$1],

    [Dimension$1, Ident],
    [Dimension$1, Function$1],
    [Dimension$1, Url$1],
    [Dimension$1, BadUrl],
    [Dimension$1, '-'],
    [Dimension$1, Number$2],
    [Dimension$1, Percentage$1],
    [Dimension$1, Dimension$1],
    [Dimension$1, CDC$1],

    ['#', Ident],
    ['#', Function$1],
    ['#', Url$1],
    ['#', BadUrl],
    ['#', '-'],
    ['#', Number$2],
    ['#', Percentage$1],
    ['#', Dimension$1],
    ['#', CDC$1], // https://github.com/w3c/csswg-drafts/pull/6874

    ['-', Ident],
    ['-', Function$1],
    ['-', Url$1],
    ['-', BadUrl],
    ['-', '-'],
    ['-', Number$2],
    ['-', Percentage$1],
    ['-', Dimension$1],
    ['-', CDC$1], // https://github.com/w3c/csswg-drafts/pull/6874

    [Number$2, Ident],
    [Number$2, Function$1],
    [Number$2, Url$1],
    [Number$2, BadUrl],
    [Number$2, Number$2],
    [Number$2, Percentage$1],
    [Number$2, Dimension$1],
    [Number$2, '%'],
    [Number$2, CDC$1], // https://github.com/w3c/csswg-drafts/pull/6874

    ['@', Ident],
    ['@', Function$1],
    ['@', Url$1],
    ['@', BadUrl],
    ['@', '-'],
    ['@', CDC$1], // https://github.com/w3c/csswg-drafts/pull/6874

    ['.', Number$2],
    ['.', Percentage$1],
    ['.', Dimension$1],

    ['+', Number$2],
    ['+', Percentage$1],
    ['+', Dimension$1],

    ['/', '*']
];
// validate with scripts/generate-safe
const safePairs = specPairs.concat([
    [Ident, Hash$1],

    [Dimension$1, Hash$1],

    [Hash$1, Hash$1],

    [AtKeyword, LeftParenthesis],
    [AtKeyword, String$2],
    [AtKeyword, Colon],

    [Percentage$1, Percentage$1],
    [Percentage$1, Dimension$1],
    [Percentage$1, Function$1],
    [Percentage$1, '-'],

    [RightParenthesis, Ident],
    [RightParenthesis, Function$1],
    [RightParenthesis, Percentage$1],
    [RightParenthesis, Dimension$1],
    [RightParenthesis, Hash$1],
    [RightParenthesis, '-']
]);

function createMap(pairs) {
    const isWhiteSpaceRequired = new Set(
        pairs.map(([prev, next]) => (code(prev) << 16 | code(next)))
    );

    return function(prevCode, type, value) {
        const nextCode = code(type, value);
        const nextCharCode = value.charCodeAt(0);
        const emitWs =
            (nextCharCode === HYPHENMINUS$6 &&
                type !== Ident &&
                type !== Function$1 &&
                type !== CDC$1) ||
            (nextCharCode === PLUSSIGN$9)
                ? isWhiteSpaceRequired.has(prevCode << 16 | nextCharCode << 8)
                : isWhiteSpaceRequired.has(prevCode << 16 | nextCode);

        if (emitWs) {
            this.emit(' ', WhiteSpace$1, true);
        }

        return nextCode;
    };
}

const spec = createMap(specPairs);
const safe = createMap(safePairs);

var tokenBefore = /*#__PURE__*/Object.freeze({
    __proto__: null,
    spec: spec,
    safe: safe
});

const REVERSESOLIDUS = 0x005c; // U+005C REVERSE SOLIDUS (\)

function processChildren(node, delimeter) {
    if (typeof delimeter === 'function') {
        let prev = null;

        node.children.forEach(node => {
            if (prev !== null) {
                delimeter.call(this, prev);
            }

            this.node(node);
            prev = node;
        });

        return;
    }

    node.children.forEach(this.node, this);
}

function processChunk(chunk) {
    tokenize$1(chunk, (type, start, end) => {
        this.token(type, chunk.slice(start, end));
    });
}

function createGenerator(config) {
    const types = new Map();

    for (let [name, item] of Object.entries(config.node)) {
        const fn = item.generate || item;

        if (typeof fn === 'function') {
            types.set(name, item.generate || item);
        }
    }

    return function(node, options) {
        let buffer = '';
        let prevCode = 0;
        let handlers = {
            node(node) {
                if (types.has(node.type)) {
                    types.get(node.type).call(publicApi, node);
                } else {
                    throw new Error('Unknown node type: ' + node.type);
                }
            },
            tokenBefore: safe,
            token(type, value) {
                prevCode = this.tokenBefore(prevCode, type, value);

                this.emit(value, type, false);

                if (type === Delim && value.charCodeAt(0) === REVERSESOLIDUS) {
                    this.emit('\n', WhiteSpace$1, true);
                }
            },
            emit(value) {
                buffer += value;
            },
            result() {
                return buffer;
            }
        };

        if (options) {
            if (typeof options.decorator === 'function') {
                handlers = options.decorator(handlers);
            }

            if (options.sourceMap) {
                handlers = generateSourceMap(handlers);
            }

            if (options.mode in tokenBefore) {
                handlers.tokenBefore = tokenBefore[options.mode];
            }
        }

        const publicApi = {
            node: (node) => handlers.node(node),
            children: processChildren,
            token: (type, value) => handlers.token(type, value),
            tokenize: processChunk
        };

        handlers.node(node);

        return handlers.result();
    };
}

function createConvertor(walk) {
    return {
        fromPlainObject(ast) {
            walk(ast, {
                enter(node) {
                    if (node.children && node.children instanceof List === false) {
                        node.children = new List().fromArray(node.children);
                    }
                }
            });

            return ast;
        },
        toPlainObject(ast) {
            walk(ast, {
                leave(node) {
                    if (node.children && node.children instanceof List) {
                        node.children = node.children.toArray();
                    }
                }
            });

            return ast;
        }
    };
}

const { hasOwnProperty: hasOwnProperty$3 } = Object.prototype;
const noop$2 = function() {};

function ensureFunction$1(value) {
    return typeof value === 'function' ? value : noop$2;
}

function invokeForType(fn, type) {
    return function(node, item, list) {
        if (node.type === type) {
            fn.call(this, node, item, list);
        }
    };
}

function getWalkersFromStructure(name, nodeType) {
    const structure = nodeType.structure;
    const walkers = [];

    for (const key in structure) {
        if (hasOwnProperty$3.call(structure, key) === false) {
            continue;
        }

        let fieldTypes = structure[key];
        const walker = {
            name: key,
            type: false,
            nullable: false
        };

        if (!Array.isArray(fieldTypes)) {
            fieldTypes = [fieldTypes];
        }

        for (const fieldType of fieldTypes) {
            if (fieldType === null) {
                walker.nullable = true;
            } else if (typeof fieldType === 'string') {
                walker.type = 'node';
            } else if (Array.isArray(fieldType)) {
                walker.type = 'list';
            }
        }

        if (walker.type) {
            walkers.push(walker);
        }
    }

    if (walkers.length) {
        return {
            context: nodeType.walkContext,
            fields: walkers
        };
    }

    return null;
}

function getTypesFromConfig(config) {
    const types = {};

    for (const name in config.node) {
        if (hasOwnProperty$3.call(config.node, name)) {
            const nodeType = config.node[name];

            if (!nodeType.structure) {
                throw new Error('Missed `structure` field in `' + name + '` node type definition');
            }

            types[name] = getWalkersFromStructure(name, nodeType);
        }
    }

    return types;
}

function createTypeIterator(config, reverse) {
    const fields = config.fields.slice();
    const contextName = config.context;
    const useContext = typeof contextName === 'string';

    if (reverse) {
        fields.reverse();
    }

    return function(node, context, walk, walkReducer) {
        let prevContextValue;

        if (useContext) {
            prevContextValue = context[contextName];
            context[contextName] = node;
        }

        for (const field of fields) {
            const ref = node[field.name];

            if (!field.nullable || ref) {
                if (field.type === 'list') {
                    const breakWalk = reverse
                        ? ref.reduceRight(walkReducer, false)
                        : ref.reduce(walkReducer, false);

                    if (breakWalk) {
                        return true;
                    }
                } else if (walk(ref)) {
                    return true;
                }
            }
        }

        if (useContext) {
            context[contextName] = prevContextValue;
        }
    };
}

function createFastTraveralMap({
    StyleSheet,
    Atrule,
    Rule,
    Block,
    DeclarationList
}) {
    return {
        Atrule: {
            StyleSheet,
            Atrule,
            Rule,
            Block
        },
        Rule: {
            StyleSheet,
            Atrule,
            Rule,
            Block
        },
        Declaration: {
            StyleSheet,
            Atrule,
            Rule,
            Block,
            DeclarationList
        }
    };
}

function createWalker(config) {
    const types = getTypesFromConfig(config);
    const iteratorsNatural = {};
    const iteratorsReverse = {};
    const breakWalk = Symbol('break-walk');
    const skipNode = Symbol('skip-node');

    for (const name in types) {
        if (hasOwnProperty$3.call(types, name) && types[name] !== null) {
            iteratorsNatural[name] = createTypeIterator(types[name], false);
            iteratorsReverse[name] = createTypeIterator(types[name], true);
        }
    }

    const fastTraversalIteratorsNatural = createFastTraveralMap(iteratorsNatural);
    const fastTraversalIteratorsReverse = createFastTraveralMap(iteratorsReverse);

    const walk = function(root, options) {
        function walkNode(node, item, list) {
            const enterRet = enter.call(context, node, item, list);

            if (enterRet === breakWalk) {
                return true;
            }

            if (enterRet === skipNode) {
                return false;
            }

            if (iterators.hasOwnProperty(node.type)) {
                if (iterators[node.type](node, context, walkNode, walkReducer)) {
                    return true;
                }
            }

            if (leave.call(context, node, item, list) === breakWalk) {
                return true;
            }

            return false;
        }

        let enter = noop$2;
        let leave = noop$2;
        let iterators = iteratorsNatural;
        let walkReducer = (ret, data, item, list) => ret || walkNode(data, item, list);
        const context = {
            break: breakWalk,
            skip: skipNode,

            root,
            stylesheet: null,
            atrule: null,
            atrulePrelude: null,
            rule: null,
            selector: null,
            block: null,
            declaration: null,
            function: null
        };

        if (typeof options === 'function') {
            enter = options;
        } else if (options) {
            enter = ensureFunction$1(options.enter);
            leave = ensureFunction$1(options.leave);

            if (options.reverse) {
                iterators = iteratorsReverse;
            }

            if (options.visit) {
                if (fastTraversalIteratorsNatural.hasOwnProperty(options.visit)) {
                    iterators = options.reverse
                        ? fastTraversalIteratorsReverse[options.visit]
                        : fastTraversalIteratorsNatural[options.visit];
                } else if (!types.hasOwnProperty(options.visit)) {
                    throw new Error('Bad value `' + options.visit + '` for `visit` option (should be: ' + Object.keys(types).sort().join(', ') + ')');
                }

                enter = invokeForType(enter, options.visit);
                leave = invokeForType(leave, options.visit);
            }
        }

        if (enter === noop$2 && leave === noop$2) {
            throw new Error('Neither `enter` nor `leave` walker handler is set or both aren\'t a function');
        }

        walkNode(root);
    };

    walk.break = breakWalk;
    walk.skip = skipNode;

    walk.find = function(ast, fn) {
        let found = null;

        walk(ast, function(node, item, list) {
            if (fn.call(this, node, item, list)) {
                found = node;
                return breakWalk;
            }
        });

        return found;
    };

    walk.findLast = function(ast, fn) {
        let found = null;

        walk(ast, {
            reverse: true,
            enter(node, item, list) {
                if (fn.call(this, node, item, list)) {
                    found = node;
                    return breakWalk;
                }
            }
        });

        return found;
    };

    walk.findAll = function(ast, fn) {
        const found = [];

        walk(ast, function(node, item, list) {
            if (fn.call(this, node, item, list)) {
                found.push(node);
            }
        });

        return found;
    };

    return walk;
}

function noop$1(value) {
    return value;
}

function generateMultiplier(multiplier) {
    const { min, max, comma } = multiplier;

    if (min === 0 && max === 0) {
        return comma ? '#?' : '*';
    }

    if (min === 0 && max === 1) {
        return '?';
    }

    if (min === 1 && max === 0) {
        return comma ? '#' : '+';
    }

    if (min === 1 && max === 1) {
        return '';
    }

    return (
        (comma ? '#' : '') +
        (min === max
            ? '{' + min + '}'
            : '{' + min + ',' + (max !== 0 ? max : '') + '}'
        )
    );
}

function generateTypeOpts(node) {
    switch (node.type) {
        case 'Range':
            return (
                ' [' +
                (node.min === null ? '-∞' : node.min) +
                ',' +
                (node.max === null ? '∞' : node.max) +
                ']'
            );

        default:
            throw new Error('Unknown node type `' + node.type + '`');
    }
}

function generateSequence(node, decorate, forceBraces, compact) {
    const combinator = node.combinator === ' ' || compact ? node.combinator : ' ' + node.combinator + ' ';
    const result = node.terms
        .map(term => internalGenerate(term, decorate, forceBraces, compact))
        .join(combinator);

    if (node.explicit || forceBraces) {
        return (compact || result[0] === ',' ? '[' : '[ ') + result + (compact ? ']' : ' ]');
    }

    return result;
}

function internalGenerate(node, decorate, forceBraces, compact) {
    let result;

    switch (node.type) {
        case 'Group':
            result =
                generateSequence(node, decorate, forceBraces, compact) +
                (node.disallowEmpty ? '!' : '');
            break;

        case 'Multiplier':
            // return since node is a composition
            return (
                internalGenerate(node.term, decorate, forceBraces, compact) +
                decorate(generateMultiplier(node), node)
            );

        case 'Boolean':
            result = '<boolean-expr[' + internalGenerate(node.term, decorate, forceBraces, compact) + ']>';
            break;

        case 'Type':
            result = '<' + node.name + (node.opts ? decorate(generateTypeOpts(node.opts), node.opts) : '') + '>';
            break;

        case 'Property':
            result = '<\'' + node.name + '\'>';
            break;

        case 'Keyword':
            result = node.name;
            break;

        case 'AtKeyword':
            result = '@' + node.name;
            break;

        case 'Function':
            result = node.name + '(';
            break;

        case 'String':
        case 'Token':
            result = node.value;
            break;

        case 'Comma':
            result = ',';
            break;

        default:
            throw new Error('Unknown node type `' + node.type + '`');
    }

    return decorate(result, node);
}

function generate$O(node, options) {
    let decorate = noop$1;
    let forceBraces = false;
    let compact = false;

    if (typeof options === 'function') {
        decorate = options;
    } else if (options) {
        forceBraces = Boolean(options.forceBraces);
        compact = Boolean(options.compact);
        if (typeof options.decorate === 'function') {
            decorate = options.decorate;
        }
    }

    return internalGenerate(node, decorate, forceBraces, compact);
}

const defaultLoc = { offset: 0, line: 1, column: 1 };

function locateMismatch(matchResult, node) {
    const tokens = matchResult.tokens;
    const longestMatch = matchResult.longestMatch;
    const mismatchNode = longestMatch < tokens.length ? tokens[longestMatch].node || null : null;
    const badNode = mismatchNode !== node ? mismatchNode : null;
    let mismatchOffset = 0;
    let mismatchLength = 0;
    let entries = 0;
    let css = '';
    let start;
    let end;

    for (let i = 0; i < tokens.length; i++) {
        const token = tokens[i].value;

        if (i === longestMatch) {
            mismatchLength = token.length;
            mismatchOffset = css.length;
        }

        if (badNode !== null && tokens[i].node === badNode) {
            if (i <= longestMatch) {
                entries++;
            } else {
                entries = 0;
            }
        }

        css += token;
    }

    if (longestMatch === tokens.length || entries > 1) { // last
        start = fromLoc(badNode || node, 'end') || buildLoc(defaultLoc, css);
        end = buildLoc(start);
    } else {
        start = fromLoc(badNode, 'start') ||
            buildLoc(fromLoc(node, 'start') || defaultLoc, css.slice(0, mismatchOffset));
        end = fromLoc(badNode, 'end') ||
            buildLoc(start, css.substr(mismatchOffset, mismatchLength));
    }

    return {
        css,
        mismatchOffset,
        mismatchLength,
        start,
        end
    };
}

function fromLoc(node, point) {
    const value = node && node.loc && node.loc[point];

    if (value) {
        return 'line' in value ? buildLoc(value) : value;
    }

    return null;
}

function buildLoc({ offset, line, column }, extra) {
    const loc = {
        offset,
        line,
        column
    };

    if (extra) {
        const lines = extra.split(/\n|\r\n?|\f/);

        loc.offset += extra.length;
        loc.line += lines.length - 1;
        loc.column = lines.length === 1 ? loc.column + extra.length : lines.pop().length + 1;
    }

    return loc;
}

const SyntaxReferenceError = function(type, referenceName) {
    const error = createCustomError(
        'SyntaxReferenceError',
        type + (referenceName ? ' `' + referenceName + '`' : '')
    );

    error.reference = referenceName;

    return error;
};

const SyntaxMatchError = function(message, syntax, node, matchResult) {
    const error = createCustomError('SyntaxMatchError', message);
    const {
        css,
        mismatchOffset,
        mismatchLength,
        start,
        end
    } = locateMismatch(matchResult, node);

    error.rawMessage = message;
    error.syntax = syntax ? generate$O(syntax) : '<generic>';
    error.css = css;
    error.mismatchOffset = mismatchOffset;
    error.mismatchLength = mismatchLength;
    error.message = message + '\n' +
        '  syntax: ' + error.syntax + '\n' +
        '   value: ' + (css || '<empty string>') + '\n' +
        '  --------' + new Array(error.mismatchOffset + 1).join('-') + '^';

    Object.assign(error, start);
    error.loc = {
        source: (node && node.loc && node.loc.source) || '<unknown>',
        start,
        end
    };

    return error;
};

const keywords = new Map();
const properties = new Map();
const HYPHENMINUS$5 = 45; // '-'.charCodeAt()

const keyword = getKeywordDescriptor;
const property = getPropertyDescriptor;
const vendorPrefix = getVendorPrefix;
function isCustomProperty(str, offset) {
    offset = offset || 0;

    return str.length - offset >= 2 &&
           str.charCodeAt(offset) === HYPHENMINUS$5 &&
           str.charCodeAt(offset + 1) === HYPHENMINUS$5;
}

function getVendorPrefix(str, offset) {
    offset = offset || 0;

    // verdor prefix should be at least 3 chars length
    if (str.length - offset >= 3) {
        // vendor prefix starts with hyper minus following non-hyper minus
        if (str.charCodeAt(offset) === HYPHENMINUS$5 &&
            str.charCodeAt(offset + 1) !== HYPHENMINUS$5) {
            // vendor prefix should contain a hyper minus at the ending
            const secondDashIndex = str.indexOf('-', offset + 2);

            if (secondDashIndex !== -1) {
                return str.substring(offset, secondDashIndex + 1);
            }
        }
    }

    return '';
}

function getKeywordDescriptor(keyword) {
    if (keywords.has(keyword)) {
        return keywords.get(keyword);
    }

    const name = keyword.toLowerCase();
    let descriptor = keywords.get(name);

    if (descriptor === undefined) {
        const custom = isCustomProperty(name, 0);
        const vendor = !custom ? getVendorPrefix(name, 0) : '';
        descriptor = Object.freeze({
            basename: name.substr(vendor.length),
            name,
            prefix: vendor,
            vendor,
            custom
        });
    }

    keywords.set(keyword, descriptor);

    return descriptor;
}

function getPropertyDescriptor(property) {
    if (properties.has(property)) {
        return properties.get(property);
    }

    let name = property;
    let hack = property[0];

    if (hack === '/') {
        hack = property[1] === '/' ? '//' : '/';
    } else if (hack !== '_' &&
               hack !== '*' &&
               hack !== '$' &&
               hack !== '#' &&
               hack !== '+' &&
               hack !== '&') {
        hack = '';
    }

    const custom = isCustomProperty(name, hack.length);

    // re-use result when possible (the same as for lower case)
    if (!custom) {
        name = name.toLowerCase();
        if (properties.has(name)) {
            const descriptor = properties.get(name);
            properties.set(property, descriptor);
            return descriptor;
        }
    }

    const vendor = !custom ? getVendorPrefix(name, hack.length) : '';
    const prefix = name.substr(0, hack.length + vendor.length);
    const descriptor = Object.freeze({
        basename: name.substr(prefix.length),
        name: name.substr(hack.length),
        hack,
        vendor,
        prefix,
        custom
    });

    properties.set(property, descriptor);

    return descriptor;
}

// https://drafts.csswg.org/css-cascade-5/
const cssWideKeywords = [
    'initial',
    'inherit',
    'unset',
    'revert',
    'revert-layer'
];

const PLUSSIGN$8 = 0x002B;    // U+002B PLUS SIGN (+)
const HYPHENMINUS$4 = 0x002D; // U+002D HYPHEN-MINUS (-)
const N$3 = 0x006E;           // U+006E LATIN SMALL LETTER N (n)
const DISALLOW_SIGN$1 = true;
const ALLOW_SIGN$1 = false;

function isDelim$1(token, code) {
    return token !== null && token.type === Delim && token.value.charCodeAt(0) === code;
}

function skipSC(token, offset, getNextToken) {
    while (token !== null && (token.type === WhiteSpace$1 || token.type === Comment$1)) {
        token = getNextToken(++offset);
    }

    return offset;
}

function checkInteger$1(token, valueOffset, disallowSign, offset) {
    if (!token) {
        return 0;
    }

    const code = token.value.charCodeAt(valueOffset);

    if (code === PLUSSIGN$8 || code === HYPHENMINUS$4) {
        if (disallowSign) {
            // Number sign is not allowed
            return 0;
        }
        valueOffset++;
    }

    for (; valueOffset < token.value.length; valueOffset++) {
        if (!isDigit(token.value.charCodeAt(valueOffset))) {
            // Integer is expected
            return 0;
        }
    }

    return offset + 1;
}

// ... <signed-integer>
// ... ['+' | '-'] <signless-integer>
function consumeB$1(token, offset_, getNextToken) {
    let sign = false;
    let offset = skipSC(token, offset_, getNextToken);

    token = getNextToken(offset);

    if (token === null) {
        return offset_;
    }

    if (token.type !== Number$2) {
        if (isDelim$1(token, PLUSSIGN$8) || isDelim$1(token, HYPHENMINUS$4)) {
            sign = true;
            offset = skipSC(getNextToken(++offset), offset, getNextToken);
            token = getNextToken(offset);

            if (token === null || token.type !== Number$2) {
                return 0;
            }
        } else {
            return offset_;
        }
    }

    if (!sign) {
        const code = token.value.charCodeAt(0);
        if (code !== PLUSSIGN$8 && code !== HYPHENMINUS$4) {
            // Number sign is expected
            return 0;
        }
    }

    return checkInteger$1(token, sign ? 0 : 1, sign, offset);
}

// An+B microsyntax https://www.w3.org/TR/css-syntax-3/#anb
function anPlusB(token, getNextToken) {
    /* eslint-disable brace-style*/
    let offset = 0;

    if (!token) {
        return 0;
    }

    // <integer>
    if (token.type === Number$2) {
        return checkInteger$1(token, 0, ALLOW_SIGN$1, offset); // b
    }

    // -n
    // -n <signed-integer>
    // -n ['+' | '-'] <signless-integer>
    // -n- <signless-integer>
    // <dashndashdigit-ident>
    else if (token.type === Ident && token.value.charCodeAt(0) === HYPHENMINUS$4) {
        // expect 1st char is N
        if (!cmpChar(token.value, 1, N$3)) {
            return 0;
        }

        switch (token.value.length) {
            // -n
            // -n <signed-integer>
            // -n ['+' | '-'] <signless-integer>
            case 2:
                return consumeB$1(getNextToken(++offset), offset, getNextToken);

            // -n- <signless-integer>
            case 3:
                if (token.value.charCodeAt(2) !== HYPHENMINUS$4) {
                    return 0;
                }

                offset = skipSC(getNextToken(++offset), offset, getNextToken);
                token = getNextToken(offset);

                return checkInteger$1(token, 0, DISALLOW_SIGN$1, offset);

            // <dashndashdigit-ident>
            default:
                if (token.value.charCodeAt(2) !== HYPHENMINUS$4) {
                    return 0;
                }

                return checkInteger$1(token, 3, DISALLOW_SIGN$1, offset);
        }
    }

    // '+'? n
    // '+'? n <signed-integer>
    // '+'? n ['+' | '-'] <signless-integer>
    // '+'? n- <signless-integer>
    // '+'? <ndashdigit-ident>
    else if (token.type === Ident || (isDelim$1(token, PLUSSIGN$8) && getNextToken(offset + 1).type === Ident)) {
        // just ignore a plus
        if (token.type !== Ident) {
            token = getNextToken(++offset);
        }

        if (token === null || !cmpChar(token.value, 0, N$3)) {
            return 0;
        }

        switch (token.value.length) {
            // '+'? n
            // '+'? n <signed-integer>
            // '+'? n ['+' | '-'] <signless-integer>
            case 1:
                return consumeB$1(getNextToken(++offset), offset, getNextToken);

            // '+'? n- <signless-integer>
            case 2:
                if (token.value.charCodeAt(1) !== HYPHENMINUS$4) {
                    return 0;
                }

                offset = skipSC(getNextToken(++offset), offset, getNextToken);
                token = getNextToken(offset);

                return checkInteger$1(token, 0, DISALLOW_SIGN$1, offset);

            // '+'? <ndashdigit-ident>
            default:
                if (token.value.charCodeAt(1) !== HYPHENMINUS$4) {
                    return 0;
                }

                return checkInteger$1(token, 2, DISALLOW_SIGN$1, offset);
        }
    }

    // <ndashdigit-dimension>
    // <ndash-dimension> <signless-integer>
    // <n-dimension>
    // <n-dimension> <signed-integer>
    // <n-dimension> ['+' | '-'] <signless-integer>
    else if (token.type === Dimension$1) {
        let code = token.value.charCodeAt(0);
        let sign = code === PLUSSIGN$8 || code === HYPHENMINUS$4 ? 1 : 0;
        let i = sign;

        for (; i < token.value.length; i++) {
            if (!isDigit(token.value.charCodeAt(i))) {
                break;
            }
        }

        if (i === sign) {
            // Integer is expected
            return 0;
        }

        if (!cmpChar(token.value, i, N$3)) {
            return 0;
        }

        // <n-dimension>
        // <n-dimension> <signed-integer>
        // <n-dimension> ['+' | '-'] <signless-integer>
        if (i + 1 === token.value.length) {
            return consumeB$1(getNextToken(++offset), offset, getNextToken);
        } else {
            if (token.value.charCodeAt(i + 1) !== HYPHENMINUS$4) {
                return 0;
            }

            // <ndash-dimension> <signless-integer>
            if (i + 2 === token.value.length) {
                offset = skipSC(getNextToken(++offset), offset, getNextToken);
                token = getNextToken(offset);

                return checkInteger$1(token, 0, DISALLOW_SIGN$1, offset);
            }
            // <ndashdigit-dimension>
            else {
                return checkInteger$1(token, i + 2, DISALLOW_SIGN$1, offset);
            }
        }
    }

    return 0;
}

const PLUSSIGN$7 = 0x002B;     // U+002B PLUS SIGN (+)
const HYPHENMINUS$3 = 0x002D;  // U+002D HYPHEN-MINUS (-)
const QUESTIONMARK$2 = 0x003F; // U+003F QUESTION MARK (?)
const U$1 = 0x0075;            // U+0075 LATIN SMALL LETTER U (u)

function isDelim(token, code) {
    return token !== null && token.type === Delim && token.value.charCodeAt(0) === code;
}

function startsWith$1(token, code) {
    return token.value.charCodeAt(0) === code;
}

function hexSequence(token, offset, allowDash) {
    let hexlen = 0;

    for (let pos = offset; pos < token.value.length; pos++) {
        const code = token.value.charCodeAt(pos);

        if (code === HYPHENMINUS$3 && allowDash && hexlen !== 0) {
            hexSequence(token, offset + hexlen + 1, false);
            return 6; // dissallow following question marks
        }

        if (!isHexDigit(code)) {
            return 0; // not a hex digit
        }

        if (++hexlen > 6) {
            return 0; // too many hex digits
        }    }

    return hexlen;
}

function withQuestionMarkSequence(consumed, length, getNextToken) {
    if (!consumed) {
        return 0; // nothing consumed
    }

    while (isDelim(getNextToken(length), QUESTIONMARK$2)) {
        if (++consumed > 6) {
            return 0; // too many question marks
        }

        length++;
    }

    return length;
}

// https://drafts.csswg.org/css-syntax/#urange
// Informally, the <urange> production has three forms:
// U+0001
//      Defines a range consisting of a single code point, in this case the code point "1".
// U+0001-00ff
//      Defines a range of codepoints between the first and the second value, in this case
//      the range between "1" and "ff" (255 in decimal) inclusive.
// U+00??
//      Defines a range of codepoints where the "?" characters range over all hex digits,
//      in this case defining the same as the value U+0000-00ff.
// In each form, a maximum of 6 digits is allowed for each hexadecimal number (if you treat "?" as a hexadecimal digit).
//
// <urange> =
//   u '+' <ident-token> '?'* |
//   u <dimension-token> '?'* |
//   u <number-token> '?'* |
//   u <number-token> <dimension-token> |
//   u <number-token> <number-token> |
//   u '+' '?'+
function urange(token, getNextToken) {
    let length = 0;

    // should start with `u` or `U`
    if (token === null || token.type !== Ident || !cmpChar(token.value, 0, U$1)) {
        return 0;
    }

    token = getNextToken(++length);
    if (token === null) {
        return 0;
    }

    // u '+' <ident-token> '?'*
    // u '+' '?'+
    if (isDelim(token, PLUSSIGN$7)) {
        token = getNextToken(++length);
        if (token === null) {
            return 0;
        }

        if (token.type === Ident) {
            // u '+' <ident-token> '?'*
            return withQuestionMarkSequence(hexSequence(token, 0, true), ++length, getNextToken);
        }

        if (isDelim(token, QUESTIONMARK$2)) {
            // u '+' '?'+
            return withQuestionMarkSequence(1, ++length, getNextToken);
        }

        // Hex digit or question mark is expected
        return 0;
    }

    // u <number-token> '?'*
    // u <number-token> <dimension-token>
    // u <number-token> <number-token>
    if (token.type === Number$2) {
        const consumedHexLength = hexSequence(token, 1, true);
        if (consumedHexLength === 0) {
            return 0;
        }

        token = getNextToken(++length);
        if (token === null) {
            // u <number-token> <eof>
            return length;
        }

        if (token.type === Dimension$1 || token.type === Number$2) {
            // u <number-token> <dimension-token>
            // u <number-token> <number-token>
            if (!startsWith$1(token, HYPHENMINUS$3) || !hexSequence(token, 1, false)) {
                return 0;
            }

            return length + 1;
        }

        // u <number-token> '?'*
        return withQuestionMarkSequence(consumedHexLength, length, getNextToken);
    }

    // u <dimension-token> '?'*
    if (token.type === Dimension$1) {
        return withQuestionMarkSequence(hexSequence(token, 1, true), ++length, getNextToken);
    }

    return 0;
}

const calcFunctionNames = ['calc(', '-moz-calc(', '-webkit-calc('];
const balancePair = new Map([
    [Function$1, RightParenthesis],
    [LeftParenthesis, RightParenthesis],
    [LeftSquareBracket, RightSquareBracket],
    [LeftCurlyBracket, RightCurlyBracket]
]);

// safe char code getter
function charCodeAt(str, index) {
    return index < str.length ? str.charCodeAt(index) : 0;
}

function eqStr(actual, expected) {
    return cmpStr(actual, 0, actual.length, expected);
}

function eqStrAny(actual, expected) {
    for (let i = 0; i < expected.length; i++) {
        if (eqStr(actual, expected[i])) {
            return true;
        }
    }

    return false;
}

// IE postfix hack, i.e. 123\0 or 123px\9
function isPostfixIeHack(str, offset) {
    if (offset !== str.length - 2) {
        return false;
    }

    return (
        charCodeAt(str, offset) === 0x005C &&  // U+005C REVERSE SOLIDUS (\)
        isDigit(charCodeAt(str, offset + 1))
    );
}

function outOfRange(opts, value, numEnd) {
    if (opts && opts.type === 'Range') {
        const num = Number(
            numEnd !== undefined && numEnd !== value.length
                ? value.substr(0, numEnd)
                : value
        );

        if (isNaN(num)) {
            return true;
        }

        // FIXME: when opts.min is a string it's a dimension, skip a range validation
        // for now since it requires a type covertation which is not implmented yet
        if (opts.min !== null && num < opts.min && typeof opts.min !== 'string') {
            return true;
        }

        // FIXME: when opts.max is a string it's a dimension, skip a range validation
        // for now since it requires a type covertation which is not implmented yet
        if (opts.max !== null && num > opts.max && typeof opts.max !== 'string') {
            return true;
        }
    }

    return false;
}

function consumeFunction(token, getNextToken) {
    let balanceCloseType = 0;
    let balanceStash = [];
    let length = 0;

    // balanced token consuming
    scan:
    do {
        switch (token.type) {
            case RightCurlyBracket:
            case RightParenthesis:
            case RightSquareBracket:
                if (token.type !== balanceCloseType) {
                    break scan;
                }

                balanceCloseType = balanceStash.pop();

                if (balanceStash.length === 0) {
                    length++;
                    break scan;
                }

                break;

            case Function$1:
            case LeftParenthesis:
            case LeftSquareBracket:
            case LeftCurlyBracket:
                balanceStash.push(balanceCloseType);
                balanceCloseType = balancePair.get(token.type);
                break;
        }

        length++;
    } while (token = getNextToken(length));

    return length;
}

// TODO: implement
// can be used wherever <length>, <frequency>, <angle>, <time>, <percentage>, <number>, or <integer> values are allowed
// https://drafts.csswg.org/css-values/#calc-notation
function calc(next) {
    return function(token, getNextToken, opts) {
        if (token === null) {
            return 0;
        }

        if (token.type === Function$1 && eqStrAny(token.value, calcFunctionNames)) {
            return consumeFunction(token, getNextToken);
        }

        return next(token, getNextToken, opts);
    };
}

function tokenType(expectedTokenType) {
    return function(token) {
        if (token === null || token.type !== expectedTokenType) {
            return 0;
        }

        return 1;
    };
}

// =========================
// Complex types
//

// https://drafts.csswg.org/css-values-4/#custom-idents
// 4.2. Author-defined Identifiers: the <custom-ident> type
// Some properties accept arbitrary author-defined identifiers as a component value.
// This generic data type is denoted by <custom-ident>, and represents any valid CSS identifier
// that would not be misinterpreted as a pre-defined keyword in that property’s value definition.
//
// See also: https://developer.mozilla.org/en-US/docs/Web/CSS/custom-ident
function customIdent(token) {
    if (token === null || token.type !== Ident) {
        return 0;
    }

    const name = token.value.toLowerCase();

    // The CSS-wide keywords are not valid <custom-ident>s
    if (eqStrAny(name, cssWideKeywords)) {
        return 0;
    }

    // The default keyword is reserved and is also not a valid <custom-ident>
    if (eqStr(name, 'default')) {
        return 0;
    }

    // TODO: ignore property specific keywords (as described https://developer.mozilla.org/en-US/docs/Web/CSS/custom-ident)
    // Specifications using <custom-ident> must specify clearly what other keywords
    // are excluded from <custom-ident>, if any—for example by saying that any pre-defined keywords
    // in that property’s value definition are excluded. Excluded keywords are excluded
    // in all ASCII case permutations.

    return 1;
}

// https://drafts.csswg.org/css-values-4/#dashed-idents
// The <dashed-ident> production is a <custom-ident>, with all the case-sensitivity that implies,
// with the additional restriction that it must start with two dashes (U+002D HYPHEN-MINUS).
function dashedIdent(token) {
    if (token === null || token.type !== Ident) {
        return 0;
    }

    // ... must start with two dashes (U+002D HYPHEN-MINUS)
    if (charCodeAt(token.value, 0) !== 0x002D || charCodeAt(token.value, 1) !== 0x002D) {
        return 0;
    }

    return 1;
}

// https://drafts.csswg.org/css-variables/#typedef-custom-property-name
// A custom property is any property whose name starts with two dashes (U+002D HYPHEN-MINUS), like --foo.
// The <custom-property-name> production corresponds to this: it’s defined as any <dashed-ident>
// (a valid identifier that starts with two dashes), except -- itself, which is reserved for future use by CSS.
function customPropertyName(token) {
    // ... it’s defined as any <dashed-ident>
    if (!dashedIdent(token)) {
        return 0;
    }

    // ... except -- itself, which is reserved for future use by CSS
    if (token.value === '--') {
        return 0;
    }

    return 1;
}

// https://drafts.csswg.org/css-color-4/#hex-notation
// The syntax of a <hex-color> is a <hash-token> token whose value consists of 3, 4, 6, or 8 hexadecimal digits.
// In other words, a hex color is written as a hash character, "#", followed by some number of digits 0-9 or
// letters a-f (the case of the letters doesn’t matter - #00ff00 is identical to #00FF00).
function hexColor(token) {
    if (token === null || token.type !== Hash$1) {
        return 0;
    }

    const length = token.value.length;

    // valid values (length): #rgb (4), #rgba (5), #rrggbb (7), #rrggbbaa (9)
    if (length !== 4 && length !== 5 && length !== 7 && length !== 9) {
        return 0;
    }

    for (let i = 1; i < length; i++) {
        if (!isHexDigit(charCodeAt(token.value, i))) {
            return 0;
        }
    }

    return 1;
}

function idSelector(token) {
    if (token === null || token.type !== Hash$1) {
        return 0;
    }

    if (!isIdentifierStart(charCodeAt(token.value, 1), charCodeAt(token.value, 2), charCodeAt(token.value, 3))) {
        return 0;
    }

    return 1;
}

// https://drafts.csswg.org/css-syntax/#any-value
// It represents the entirety of what a valid declaration can have as its value.
function declarationValue(token, getNextToken) {
    if (!token) {
        return 0;
    }

    let balanceCloseType = 0;
    let balanceStash = [];
    let length = 0;

    // The <declaration-value> production matches any sequence of one or more tokens,
    // so long as the sequence does not contain ...
    scan:
    do {
        switch (token.type) {
            // ... <bad-string-token>, <bad-url-token>,
            case BadString:
            case BadUrl:
                break scan;

            // ... unmatched <)-token>, <]-token>, or <}-token>,
            case RightCurlyBracket:
            case RightParenthesis:
            case RightSquareBracket:
                if (token.type !== balanceCloseType) {
                    break scan;
                }

                balanceCloseType = balanceStash.pop();
                break;

            // ... or top-level <semicolon-token> tokens
            case Semicolon:
                if (balanceCloseType === 0) {
                    break scan;
                }

                break;

            // ... or <delim-token> tokens with a value of "!"
            case Delim:
                if (balanceCloseType === 0 && token.value === '!') {
                    break scan;
                }

                break;

            case Function$1:
            case LeftParenthesis:
            case LeftSquareBracket:
            case LeftCurlyBracket:
                balanceStash.push(balanceCloseType);
                balanceCloseType = balancePair.get(token.type);
                break;
        }

        length++;
    } while (token = getNextToken(length));

    return length;
}

// https://drafts.csswg.org/css-syntax/#any-value
// The <any-value> production is identical to <declaration-value>, but also
// allows top-level <semicolon-token> tokens and <delim-token> tokens
// with a value of "!". It represents the entirety of what valid CSS can be in any context.
function anyValue(token, getNextToken) {
    if (!token) {
        return 0;
    }

    let balanceCloseType = 0;
    let balanceStash = [];
    let length = 0;

    // The <any-value> production matches any sequence of one or more tokens,
    // so long as the sequence ...
    scan:
    do {
        switch (token.type) {
            // ... does not contain <bad-string-token>, <bad-url-token>,
            case BadString:
            case BadUrl:
                break scan;

            // ... unmatched <)-token>, <]-token>, or <}-token>,
            case RightCurlyBracket:
            case RightParenthesis:
            case RightSquareBracket:
                if (token.type !== balanceCloseType) {
                    break scan;
                }

                balanceCloseType = balanceStash.pop();
                break;

            case Function$1:
            case LeftParenthesis:
            case LeftSquareBracket:
            case LeftCurlyBracket:
                balanceStash.push(balanceCloseType);
                balanceCloseType = balancePair.get(token.type);
                break;
        }

        length++;
    } while (token = getNextToken(length));

    return length;
}

// =========================
// Dimensions
//

function dimension(type) {
    if (type) {
        type = new Set(type);
    }

    return function(token, getNextToken, opts) {
        if (token === null || token.type !== Dimension$1) {
            return 0;
        }

        const numberEnd = consumeNumber(token.value, 0);

        // check unit
        if (type !== null) {
            // check for IE postfix hack, i.e. 123px\0 or 123px\9
            const reverseSolidusOffset = token.value.indexOf('\\', numberEnd);
            const unit = reverseSolidusOffset === -1 || !isPostfixIeHack(token.value, reverseSolidusOffset)
                ? token.value.substr(numberEnd)
                : token.value.substring(numberEnd, reverseSolidusOffset);

            if (type.has(unit.toLowerCase()) === false) {
                return 0;
            }
        }

        // check range if specified
        if (outOfRange(opts, token.value, numberEnd)) {
            return 0;
        }

        return 1;
    };
}

// =========================
// Percentage
//

// §5.5. Percentages: the <percentage> type
// https://drafts.csswg.org/css-values-4/#percentages
function percentage(token, getNextToken, opts) {
    // ... corresponds to the <percentage-token> production
    if (token === null || token.type !== Percentage$1) {
        return 0;
    }

    // check range if specified
    if (outOfRange(opts, token.value, token.value.length - 1)) {
        return 0;
    }

    return 1;
}

// =========================
// Numeric
//

// https://drafts.csswg.org/css-values-4/#numbers
// The value <zero> represents a literal number with the value 0. Expressions that merely
// evaluate to a <number> with the value 0 (for example, calc(0)) do not match <zero>;
// only literal <number-token>s do.
function zero(next) {
    if (typeof next !== 'function') {
        next = function() {
            return 0;
        };
    }

    return function(token, getNextToken, opts) {
        if (token !== null && token.type === Number$2) {
            if (Number(token.value) === 0) {
                return 1;
            }
        }

        return next(token, getNextToken, opts);
    };
}

// § 5.3. Real Numbers: the <number> type
// https://drafts.csswg.org/css-values-4/#numbers
// Number values are denoted by <number>, and represent real numbers, possibly with a fractional component.
// ... It corresponds to the <number-token> production
function number(token, getNextToken, opts) {
    if (token === null) {
        return 0;
    }

    const numberEnd = consumeNumber(token.value, 0);
    const isNumber = numberEnd === token.value.length;
    if (!isNumber && !isPostfixIeHack(token.value, numberEnd)) {
        return 0;
    }

    // check range if specified
    if (outOfRange(opts, token.value, numberEnd)) {
        return 0;
    }

    return 1;
}

// §5.2. Integers: the <integer> type
// https://drafts.csswg.org/css-values-4/#integers
function integer(token, getNextToken, opts) {
    // ... corresponds to a subset of the <number-token> production
    if (token === null || token.type !== Number$2) {
        return 0;
    }

    // The first digit of an integer may be immediately preceded by `-` or `+` to indicate the integer’s sign.
    let i = charCodeAt(token.value, 0) === 0x002B ||       // U+002B PLUS SIGN (+)
            charCodeAt(token.value, 0) === 0x002D ? 1 : 0; // U+002D HYPHEN-MINUS (-)

    // When written literally, an integer is one or more decimal digits 0 through 9 ...
    for (; i < token.value.length; i++) {
        if (!isDigit(charCodeAt(token.value, i))) {
            return 0;
        }
    }

    // check range if specified
    if (outOfRange(opts, token.value, i)) {
        return 0;
    }

    return 1;
}

// token types
const tokenTypes = {
    'ident-token': tokenType(Ident),
    'function-token': tokenType(Function$1),
    'at-keyword-token': tokenType(AtKeyword),
    'hash-token': tokenType(Hash$1),
    'string-token': tokenType(String$2),
    'bad-string-token': tokenType(BadString),
    'url-token': tokenType(Url$1),
    'bad-url-token': tokenType(BadUrl),
    'delim-token': tokenType(Delim),
    'number-token': tokenType(Number$2),
    'percentage-token': tokenType(Percentage$1),
    'dimension-token': tokenType(Dimension$1),
    'whitespace-token': tokenType(WhiteSpace$1),
    'CDO-token': tokenType(CDO$1),
    'CDC-token': tokenType(CDC$1),
    'colon-token': tokenType(Colon),
    'semicolon-token': tokenType(Semicolon),
    'comma-token': tokenType(Comma),
    '[-token': tokenType(LeftSquareBracket),
    ']-token': tokenType(RightSquareBracket),
    '(-token': tokenType(LeftParenthesis),
    ')-token': tokenType(RightParenthesis),
    '{-token': tokenType(LeftCurlyBracket),
    '}-token': tokenType(RightCurlyBracket)
};

// token production types
const productionTypes = {
    // token type aliases
    'string': tokenType(String$2),
    'ident': tokenType(Ident),

    // percentage
    'percentage': calc(percentage),

    // numeric
    'zero': zero(),
    'number': calc(number),
    'integer': calc(integer),

    // complex types
    'custom-ident': customIdent,
    'dashed-ident': dashedIdent,
    'custom-property-name': customPropertyName,
    'hex-color': hexColor,
    'id-selector': idSelector, // element( <id-selector> )
    'an-plus-b': anPlusB,
    'urange': urange,
    'declaration-value': declarationValue,
    'any-value': anyValue
};

// dimensions types depend on units set
function createDemensionTypes(units) {
    const {
        angle,
        decibel,
        frequency,
        flex,
        length,
        resolution,
        semitones,
        time
    } = units || {};

    return {
        'dimension': calc(dimension(null)),
        'angle': calc(dimension(angle)),
        'decibel': calc(dimension(decibel)),
        'frequency': calc(dimension(frequency)),
        'flex': calc(dimension(flex)),
        'length': calc(zero(dimension(length))),
        'resolution': calc(dimension(resolution)),
        'semitones': calc(dimension(semitones)),
        'time': calc(dimension(time))
    };
}

function createGenericTypes(units) {
    return {
        ...tokenTypes,
        ...productionTypes,
        ...createDemensionTypes(units)
    };
}

const length = [
    // absolute length units https://www.w3.org/TR/css-values-3/#lengths
    'cm', 'mm', 'q', 'in', 'pt', 'pc', 'px',
    // font-relative length units https://drafts.csswg.org/css-values-4/#font-relative-lengths
    'em', 'rem',
    'ex', 'rex',
    'cap', 'rcap',
    'ch', 'rch',
    'ic', 'ric',
    'lh', 'rlh',
    // viewport-percentage lengths https://drafts.csswg.org/css-values-4/#viewport-relative-lengths
    'vw', 'svw', 'lvw', 'dvw',
    'vh', 'svh', 'lvh', 'dvh',
    'vi', 'svi', 'lvi', 'dvi',
    'vb', 'svb', 'lvb', 'dvb',
    'vmin', 'svmin', 'lvmin', 'dvmin',
    'vmax', 'svmax', 'lvmax', 'dvmax',
    // container relative lengths https://drafts.csswg.org/css-contain-3/#container-lengths
    'cqw', 'cqh', 'cqi', 'cqb', 'cqmin', 'cqmax'
];
const angle = ['deg', 'grad', 'rad', 'turn'];    // https://www.w3.org/TR/css-values-3/#angles
const time = ['s', 'ms'];                        // https://www.w3.org/TR/css-values-3/#time
const frequency = ['hz', 'khz'];                 // https://www.w3.org/TR/css-values-3/#frequency
const resolution = ['dpi', 'dpcm', 'dppx', 'x']; // https://www.w3.org/TR/css-values-3/#resolution
const flex = ['fr'];                             // https://drafts.csswg.org/css-grid/#fr-unit
const decibel = ['db'];                          // https://www.w3.org/TR/css3-speech/#mixing-props-voice-volume
const semitones = ['st'];                        // https://www.w3.org/TR/css3-speech/#voice-props-voice-pitch

var units = /*#__PURE__*/Object.freeze({
    __proto__: null,
    length: length,
    angle: angle,
    time: time,
    frequency: frequency,
    resolution: resolution,
    flex: flex,
    decibel: decibel,
    semitones: semitones
});

function SyntaxError$1(message, input, offset) {
    return Object.assign(createCustomError('SyntaxError', message), {
        input,
        offset,
        rawMessage: message,
        message: message + '\n' +
            '  ' + input + '\n' +
            '--' + new Array((offset || input.length) + 1).join('-') + '^'
    });
}

const TAB$1 = 9;
const N$2 = 10;
const F$1 = 12;
const R$1 = 13;
const SPACE$3 = 32;
const NAME_CHAR = new Uint8Array(128).map((_, idx) =>
    /[a-zA-Z0-9\-]/.test(String.fromCharCode(idx)) ? 1 : 0
);

class Scanner {
    constructor(str) {
        this.str = str;
        this.pos = 0;
    }

    charCodeAt(pos) {
        return pos < this.str.length ? this.str.charCodeAt(pos) : 0;
    }
    charCode() {
        return this.charCodeAt(this.pos);
    }
    isNameCharCode(code = this.charCode()) {
        return code < 128 && NAME_CHAR[code] === 1;
    }
    nextCharCode() {
        return this.charCodeAt(this.pos + 1);
    }
    nextNonWsCode(pos) {
        return this.charCodeAt(this.findWsEnd(pos));
    }
    skipWs() {
        this.pos = this.findWsEnd(this.pos);
    }
    findWsEnd(pos) {
        for (; pos < this.str.length; pos++) {
            const code = this.str.charCodeAt(pos);
            if (code !== R$1 && code !== N$2 && code !== F$1 && code !== SPACE$3 && code !== TAB$1) {
                break;
            }
        }

        return pos;
    }
    substringToPos(end) {
        return this.str.substring(this.pos, this.pos = end);
    }
    eat(code) {
        if (this.charCode() !== code) {
            this.error('Expect `' + String.fromCharCode(code) + '`');
        }

        this.pos++;
    }
    peek() {
        return this.pos < this.str.length ? this.str.charAt(this.pos++) : '';
    }
    error(message) {
        throw new SyntaxError$1(message, this.str, this.pos);
    }

    scanSpaces() {
        return this.substringToPos(this.findWsEnd(this.pos));
    }
    scanWord() {
        let end = this.pos;

        for (; end < this.str.length; end++) {
            const code = this.str.charCodeAt(end);
            if (code >= 128 || NAME_CHAR[code] === 0) {
                break;
            }
        }

        if (this.pos === end) {
            this.error('Expect a keyword');
        }

        return this.substringToPos(end);
    }
    scanNumber() {
        let end = this.pos;

        for (; end < this.str.length; end++) {
            const code = this.str.charCodeAt(end);

            if (code < 48 || code > 57) {
                break;
            }
        }

        if (this.pos === end) {
            this.error('Expect a number');
        }

        return this.substringToPos(end);
    }
    scanString() {
        const end = this.str.indexOf('\'', this.pos + 1);

        if (end === -1) {
            this.pos = this.str.length;
            this.error('Expect an apostrophe');
        }

        return this.substringToPos(end + 1);
    }
}

const TAB = 9;
const N$1 = 10;
const F = 12;
const R = 13;
const SPACE$2 = 32;
const EXCLAMATIONMARK$2 = 33;    // !
const NUMBERSIGN$3 = 35;         // #
const AMPERSAND$5 = 38;          // &
const APOSTROPHE$2 = 39;         // '
const LEFTPARENTHESIS$2 = 40;    // (
const RIGHTPARENTHESIS$2 = 41;   // )
const ASTERISK$6 = 42;           // *
const PLUSSIGN$6 = 43;           // +
const COMMA = 44;              // ,
const HYPERMINUS = 45;         // -
const LESSTHANSIGN$1 = 60;       // <
const GREATERTHANSIGN$3 = 62;    // >
const QUESTIONMARK$1 = 63;       // ?
const COMMERCIALAT = 64;       // @
const LEFTSQUAREBRACKET = 91;  // [
const RIGHTSQUAREBRACKET = 93; // ]
const LEFTCURLYBRACKET = 123;  // {
const VERTICALLINE$3 = 124;      // |
const RIGHTCURLYBRACKET = 125; // }
const INFINITY = 8734;         // ∞
const COMBINATOR_PRECEDENCE = {
    ' ': 1,
    '&&': 2,
    '||': 3,
    '|': 4
};

function readMultiplierRange(scanner) {
    let min = null;
    let max = null;

    scanner.eat(LEFTCURLYBRACKET);
    scanner.skipWs();

    min = scanner.scanNumber(scanner);
    scanner.skipWs();

    if (scanner.charCode() === COMMA) {
        scanner.pos++;
        scanner.skipWs();

        if (scanner.charCode() !== RIGHTCURLYBRACKET) {
            max = scanner.scanNumber(scanner);
            scanner.skipWs();
        }
    } else {
        max = min;
    }

    scanner.eat(RIGHTCURLYBRACKET);

    return {
        min: Number(min),
        max: max ? Number(max) : 0
    };
}

function readMultiplier(scanner) {
    let range = null;
    let comma = false;

    switch (scanner.charCode()) {
        case ASTERISK$6:
            scanner.pos++;

            range = {
                min: 0,
                max: 0
            };

            break;

        case PLUSSIGN$6:
            scanner.pos++;

            range = {
                min: 1,
                max: 0
            };

            break;

        case QUESTIONMARK$1:
            scanner.pos++;

            range = {
                min: 0,
                max: 1
            };

            break;

        case NUMBERSIGN$3:
            scanner.pos++;

            comma = true;

            if (scanner.charCode() === LEFTCURLYBRACKET) {
                range = readMultiplierRange(scanner);
            } else if (scanner.charCode() === QUESTIONMARK$1) {
                // https://www.w3.org/TR/css-values-4/#component-multipliers
                // > the # and ? multipliers may be stacked as #?
                // In this case just treat "#?" as a single multiplier
                // { min: 0, max: 0, comma: true }
                scanner.pos++;
                range = {
                    min: 0,
                    max: 0
                };
            } else {
                range = {
                    min: 1,
                    max: 0
                };
            }

            break;

        case LEFTCURLYBRACKET:
            range = readMultiplierRange(scanner);
            break;

        default:
            return null;
    }

    return {
        type: 'Multiplier',
        comma,
        min: range.min,
        max: range.max,
        term: null
    };
}

function maybeMultiplied(scanner, node) {
    const multiplier = readMultiplier(scanner);

    if (multiplier !== null) {
        multiplier.term = node;

        // https://www.w3.org/TR/css-values-4/#component-multipliers
        // > The + and # multipliers may be stacked as +#;
        // Represent "+#" as nested multipliers:
        // { ...<multiplier #>,
        //   term: {
        //     ...<multipler +>,
        //     term: node
        //   }
        // }
        if (scanner.charCode() === NUMBERSIGN$3 &&
            scanner.charCodeAt(scanner.pos - 1) === PLUSSIGN$6) {
            return maybeMultiplied(scanner, multiplier);
        }

        return multiplier;
    }

    return node;
}

function maybeToken(scanner) {
    const ch = scanner.peek();

    if (ch === '') {
        return null;
    }

    return maybeMultiplied(scanner, {
        type: 'Token',
        value: ch
    });
}

function readProperty$1(scanner) {
    let name;

    scanner.eat(LESSTHANSIGN$1);
    scanner.eat(APOSTROPHE$2);

    name = scanner.scanWord();

    scanner.eat(APOSTROPHE$2);
    scanner.eat(GREATERTHANSIGN$3);

    return maybeMultiplied(scanner, {
        type: 'Property',
        name
    });
}

// https://drafts.csswg.org/css-values-3/#numeric-ranges
// 4.1. Range Restrictions and Range Definition Notation
//
// Range restrictions can be annotated in the numeric type notation using CSS bracketed
// range notation—[min,max]—within the angle brackets, after the identifying keyword,
// indicating a closed range between (and including) min and max.
// For example, <integer [0, 10]> indicates an integer between 0 and 10, inclusive.
function readTypeRange(scanner) {
    // use null for Infinity to make AST format JSON serializable/deserializable
    let min = null; // -Infinity
    let max = null; // Infinity
    let sign = 1;

    scanner.eat(LEFTSQUAREBRACKET);

    if (scanner.charCode() === HYPERMINUS) {
        scanner.peek();
        sign = -1;
    }

    if (sign == -1 && scanner.charCode() === INFINITY) {
        scanner.peek();
    } else {
        min = sign * Number(scanner.scanNumber(scanner));

        if (scanner.isNameCharCode()) {
            min += scanner.scanWord();
        }
    }

    scanner.skipWs();
    scanner.eat(COMMA);
    scanner.skipWs();

    if (scanner.charCode() === INFINITY) {
        scanner.peek();
    } else {
        sign = 1;

        if (scanner.charCode() === HYPERMINUS) {
            scanner.peek();
            sign = -1;
        }

        max = sign * Number(scanner.scanNumber(scanner));

        if (scanner.isNameCharCode()) {
            max += scanner.scanWord();
        }
    }

    scanner.eat(RIGHTSQUAREBRACKET);

    return {
        type: 'Range',
        min,
        max
    };
}

function readType(scanner) {
    let name;
    let opts = null;

    scanner.eat(LESSTHANSIGN$1);
    name = scanner.scanWord();

    // https://drafts.csswg.org/css-values-5/#boolean
    if (name === 'boolean-expr') {
        scanner.eat(LEFTSQUAREBRACKET);

        const implicitGroup = readImplicitGroup(scanner, RIGHTSQUAREBRACKET);

        scanner.eat(RIGHTSQUAREBRACKET);
        scanner.eat(GREATERTHANSIGN$3);

        return maybeMultiplied(scanner, {
            type: 'Boolean',
            term: implicitGroup.terms.length === 1
                ? implicitGroup.terms[0]
                : implicitGroup
        });
    }

    if (scanner.charCode() === LEFTPARENTHESIS$2 &&
        scanner.nextCharCode() === RIGHTPARENTHESIS$2) {
        scanner.pos += 2;
        name += '()';
    }

    if (scanner.charCodeAt(scanner.findWsEnd(scanner.pos)) === LEFTSQUAREBRACKET) {
        scanner.skipWs();
        opts = readTypeRange(scanner);
    }

    scanner.eat(GREATERTHANSIGN$3);

    return maybeMultiplied(scanner, {
        type: 'Type',
        name,
        opts
    });
}

function readKeywordOrFunction(scanner) {
    const name = scanner.scanWord();

    if (scanner.charCode() === LEFTPARENTHESIS$2) {
        scanner.pos++;

        return {
            type: 'Function',
            name
        };
    }

    return maybeMultiplied(scanner, {
        type: 'Keyword',
        name
    });
}

function regroupTerms(terms, combinators) {
    function createGroup(terms, combinator) {
        return {
            type: 'Group',
            terms,
            combinator,
            disallowEmpty: false,
            explicit: false
        };
    }

    let combinator;

    combinators = Object.keys(combinators)
        .sort((a, b) => COMBINATOR_PRECEDENCE[a] - COMBINATOR_PRECEDENCE[b]);

    while (combinators.length > 0) {
        combinator = combinators.shift();

        let i = 0;
        let subgroupStart = 0;

        for (; i < terms.length; i++) {
            const term = terms[i];

            if (term.type === 'Combinator') {
                if (term.value === combinator) {
                    if (subgroupStart === -1) {
                        subgroupStart = i - 1;
                    }
                    terms.splice(i, 1);
                    i--;
                } else {
                    if (subgroupStart !== -1 && i - subgroupStart > 1) {
                        terms.splice(
                            subgroupStart,
                            i - subgroupStart,
                            createGroup(terms.slice(subgroupStart, i), combinator)
                        );
                        i = subgroupStart + 1;
                    }
                    subgroupStart = -1;
                }
            }
        }

        if (subgroupStart !== -1 && combinators.length) {
            terms.splice(
                subgroupStart,
                i - subgroupStart,
                createGroup(terms.slice(subgroupStart, i), combinator)
            );
        }
    }

    return combinator;
}

function readImplicitGroup(scanner, stopCharCode) {
    const combinators = Object.create(null);
    const terms = [];
    let token;
    let prevToken = null;
    let prevTokenPos = scanner.pos;

    while (scanner.charCode() !== stopCharCode && (token = peek(scanner, stopCharCode))) {
        if (token.type !== 'Spaces') {
            if (token.type === 'Combinator') {
                // check for combinator in group beginning and double combinator sequence
                if (prevToken === null || prevToken.type === 'Combinator') {
                    scanner.pos = prevTokenPos;
                    scanner.error('Unexpected combinator');
                }

                combinators[token.value] = true;
            } else if (prevToken !== null && prevToken.type !== 'Combinator') {
                combinators[' '] = true;  // a b
                terms.push({
                    type: 'Combinator',
                    value: ' '
                });
            }

            terms.push(token);
            prevToken = token;
            prevTokenPos = scanner.pos;
        }
    }

    // check for combinator in group ending
    if (prevToken !== null && prevToken.type === 'Combinator') {
        scanner.pos -= prevTokenPos;
        scanner.error('Unexpected combinator');
    }

    return {
        type: 'Group',
        terms,
        combinator: regroupTerms(terms, combinators) || ' ',
        disallowEmpty: false,
        explicit: false
    };
}

function readGroup(scanner, stopCharCode) {
    let result;

    scanner.eat(LEFTSQUAREBRACKET);
    result = readImplicitGroup(scanner, stopCharCode);
    scanner.eat(RIGHTSQUAREBRACKET);

    result.explicit = true;

    if (scanner.charCode() === EXCLAMATIONMARK$2) {
        scanner.pos++;
        result.disallowEmpty = true;
    }

    return result;
}

function peek(scanner, stopCharCode) {
    let code = scanner.charCode();

    switch (code) {
        case RIGHTSQUAREBRACKET:
            // don't eat, stop scan a group
            break;

        case LEFTSQUAREBRACKET:
            return maybeMultiplied(scanner, readGroup(scanner, stopCharCode));

        case LESSTHANSIGN$1:
            return scanner.nextCharCode() === APOSTROPHE$2
                ? readProperty$1(scanner)
                : readType(scanner);

        case VERTICALLINE$3:
            return {
                type: 'Combinator',
                value: scanner.substringToPos(
                    scanner.pos + (scanner.nextCharCode() === VERTICALLINE$3 ? 2 : 1)
                )
            };

        case AMPERSAND$5:
            scanner.pos++;
            scanner.eat(AMPERSAND$5);

            return {
                type: 'Combinator',
                value: '&&'
            };

        case COMMA:
            scanner.pos++;
            return {
                type: 'Comma'
            };

        case APOSTROPHE$2:
            return maybeMultiplied(scanner, {
                type: 'String',
                value: scanner.scanString()
            });

        case SPACE$2:
        case TAB:
        case N$1:
        case R:
        case F:
            return {
                type: 'Spaces',
                value: scanner.scanSpaces()
            };

        case COMMERCIALAT:
            code = scanner.nextCharCode();

            if (scanner.isNameCharCode(code)) {
                scanner.pos++;
                return {
                    type: 'AtKeyword',
                    name: scanner.scanWord()
                };
            }

            return maybeToken(scanner);

        case ASTERISK$6:
        case PLUSSIGN$6:
        case QUESTIONMARK$1:
        case NUMBERSIGN$3:
        case EXCLAMATIONMARK$2:
            // prohibited tokens (used as a multiplier start)
            break;

        case LEFTCURLYBRACKET:
            // LEFTCURLYBRACKET is allowed since mdn/data uses it w/o quoting
            // check next char isn't a number, because it's likely a disjoined multiplier
            code = scanner.nextCharCode();

            if (code < 48 || code > 57) {
                return maybeToken(scanner);
            }

            break;

        default:
            if (scanner.isNameCharCode(code)) {
                return readKeywordOrFunction(scanner);
            }

            return maybeToken(scanner);
    }
}

function parse$O(source) {
    const scanner = new Scanner(source);
    const result = readImplicitGroup(scanner);

    if (scanner.pos !== source.length) {
        scanner.error('Unexpected input');
    }

    // reduce redundant groups with single group term
    if (result.terms.length === 1 && result.terms[0].type === 'Group') {
        return result.terms[0];
    }

    return result;
}

const noop = function() {};

function ensureFunction(value) {
    return typeof value === 'function' ? value : noop;
}

function walk$1(node, options, context) {
    function walk(node) {
        enter.call(context, node);

        switch (node.type) {
            case 'Group':
                node.terms.forEach(walk);
                break;

            case 'Multiplier':
            case 'Boolean':
                walk(node.term);
                break;

            case 'Type':
            case 'Property':
            case 'Keyword':
            case 'AtKeyword':
            case 'Function':
            case 'String':
            case 'Token':
            case 'Comma':
                break;

            default:
                throw new Error('Unknown type: ' + node.type);
        }

        leave.call(context, node);
    }

    let enter = noop;
    let leave = noop;

    if (typeof options === 'function') {
        enter = options;
    } else if (options) {
        enter = ensureFunction(options.enter);
        leave = ensureFunction(options.leave);
    }

    if (enter === noop && leave === noop) {
        throw new Error('Neither `enter` nor `leave` walker handler is set or both aren\'t a function');
    }

    walk(node);
}

var index = /*#__PURE__*/Object.freeze({
    __proto__: null,
    SyntaxError: SyntaxError$1,
    generate: generate$O,
    parse: parse$O,
    walk: walk$1
});

const astToTokens = {
    decorator(handlers) {
        const tokens = [];
        let curNode = null;

        return {
            ...handlers,
            node(node) {
                const tmp = curNode;
                curNode = node;
                handlers.node.call(this, node);
                curNode = tmp;
            },
            emit(value, type, auto) {
                tokens.push({
                    type,
                    value,
                    node: auto ? null : curNode
                });
            },
            result() {
                return tokens;
            }
        };
    }
};

function stringToTokens(str) {
    const tokens = [];

    tokenize$1(str, (type, start, end) =>
        tokens.push({
            type,
            value: str.slice(start, end),
            node: null
        })
    );

    return tokens;
}

function prepareTokens(value, syntax) {
    if (typeof value === 'string') {
        return stringToTokens(value);
    }

    return syntax.generate(value, astToTokens);
}

const MATCH = { type: 'Match' };
const MISMATCH = { type: 'Mismatch' };
const DISALLOW_EMPTY = { type: 'DisallowEmpty' };

const LEFTPARENTHESIS$1 = 40;  // (
const RIGHTPARENTHESIS$1 = 41; // )

function createCondition(match, thenBranch, elseBranch) {
    // reduce node count
    if (thenBranch === MATCH && elseBranch === MISMATCH) {
        return match;
    }

    if (match === MATCH && thenBranch === MATCH && elseBranch === MATCH) {
        return match;
    }

    if (match.type === 'If' && match.else === MISMATCH && thenBranch === MATCH) {
        thenBranch = match.then;
        match = match.match;
    }

    return {
        type: 'If',
        match,
        then: thenBranch,
        else: elseBranch
    };
}

function isFunctionType(name) {
    return (
        name.length > 2 &&
        name.charCodeAt(name.length - 2) === LEFTPARENTHESIS$1 &&
        name.charCodeAt(name.length - 1) === RIGHTPARENTHESIS$1
    );
}

function isEnumCapatible(term) {
    return (
        term.type === 'Keyword' ||
        term.type === 'AtKeyword' ||
        term.type === 'Function' ||
        term.type === 'Type' && isFunctionType(term.name)
    );
}

function groupNode(terms, combinator = ' ', explicit = false) {
    return {
        type: 'Group',
        terms,
        combinator,
        disallowEmpty: false,
        explicit
    };
}

function replaceTypeInGraph(node, replacements, visited = new Set()) {
    if (!visited.has(node)) {
        visited.add(node);

        switch (node.type) {
            case 'If':
                node.match = replaceTypeInGraph(node.match, replacements, visited);
                node.then = replaceTypeInGraph(node.then, replacements, visited);
                node.else = replaceTypeInGraph(node.else, replacements, visited);
                break;

            case 'Type':
                return replacements[node.name] || node;
        }
    }

    return node;
}

function buildGroupMatchGraph(combinator, terms, atLeastOneTermMatched) {
    switch (combinator) {
        case ' ': {
            // Juxtaposing components means that all of them must occur, in the given order.
            //
            // a b c
            // =
            // match a
            //   then match b
            //     then match c
            //       then MATCH
            //       else MISMATCH
            //     else MISMATCH
            //   else MISMATCH
            let result = MATCH;

            for (let i = terms.length - 1; i >= 0; i--) {
                const term = terms[i];

                result = createCondition(
                    term,
                    result,
                    MISMATCH
                );
            }
            return result;
        }

        case '|': {
            // A bar (|) separates two or more alternatives: exactly one of them must occur.
            //
            // a | b | c
            // =
            // match a
            //   then MATCH
            //   else match b
            //     then MATCH
            //     else match c
            //       then MATCH
            //       else MISMATCH

            let result = MISMATCH;
            let map = null;

            for (let i = terms.length - 1; i >= 0; i--) {
                let term = terms[i];

                // reduce sequence of keywords into a Enum
                if (isEnumCapatible(term)) {
                    if (map === null && i > 0 && isEnumCapatible(terms[i - 1])) {
                        map = Object.create(null);
                        result = createCondition(
                            {
                                type: 'Enum',
                                map
                            },
                            MATCH,
                            result
                        );
                    }

                    if (map !== null) {
                        const key = (isFunctionType(term.name) ? term.name.slice(0, -1) : term.name).toLowerCase();
                        if (key in map === false) {
                            map[key] = term;
                            continue;
                        }
                    }
                }

                map = null;

                // create a new conditonal node
                result = createCondition(
                    term,
                    MATCH,
                    result
                );
            }
            return result;
        }

        case '&&': {
            // A double ampersand (&&) separates two or more components,
            // all of which must occur, in any order.

            // Use MatchOnce for groups with a large number of terms,
            // since &&-groups produces at least N!-node trees
            if (terms.length > 5) {
                return {
                    type: 'MatchOnce',
                    terms,
                    all: true
                };
            }

            // Use a combination tree for groups with small number of terms
            //
            // a && b && c
            // =
            // match a
            //   then [b && c]
            //   else match b
            //     then [a && c]
            //     else match c
            //       then [a && b]
            //       else MISMATCH
            //
            // a && b
            // =
            // match a
            //   then match b
            //     then MATCH
            //     else MISMATCH
            //   else match b
            //     then match a
            //       then MATCH
            //       else MISMATCH
            //     else MISMATCH
            let result = MISMATCH;

            for (let i = terms.length - 1; i >= 0; i--) {
                const term = terms[i];
                let thenClause;

                if (terms.length > 1) {
                    thenClause = buildGroupMatchGraph(
                        combinator,
                        terms.filter(function(newGroupTerm) {
                            return newGroupTerm !== term;
                        }),
                        false
                    );
                } else {
                    thenClause = MATCH;
                }

                result = createCondition(
                    term,
                    thenClause,
                    result
                );
            }
            return result;
        }

        case '||': {
            // A double bar (||) separates two or more options:
            // one or more of them must occur, in any order.

            // Use MatchOnce for groups with a large number of terms,
            // since ||-groups produces at least N!-node trees
            if (terms.length > 5) {
                return {
                    type: 'MatchOnce',
                    terms,
                    all: false
                };
            }

            // Use a combination tree for groups with small number of terms
            //
            // a || b || c
            // =
            // match a
            //   then [b || c]
            //   else match b
            //     then [a || c]
            //     else match c
            //       then [a || b]
            //       else MISMATCH
            //
            // a || b
            // =
            // match a
            //   then match b
            //     then MATCH
            //     else MATCH
            //   else match b
            //     then match a
            //       then MATCH
            //       else MATCH
            //     else MISMATCH
            let result = atLeastOneTermMatched ? MATCH : MISMATCH;

            for (let i = terms.length - 1; i >= 0; i--) {
                const term = terms[i];
                let thenClause;

                if (terms.length > 1) {
                    thenClause = buildGroupMatchGraph(
                        combinator,
                        terms.filter(function(newGroupTerm) {
                            return newGroupTerm !== term;
                        }),
                        true
                    );
                } else {
                    thenClause = MATCH;
                }

                result = createCondition(
                    term,
                    thenClause,
                    result
                );
            }
            return result;
        }
    }
}

function buildMultiplierMatchGraph(node) {
    let result = MATCH;
    let matchTerm = buildMatchGraphInternal(node.term);

    if (node.max === 0) {
        // disable repeating of empty match to prevent infinite loop
        matchTerm = createCondition(
            matchTerm,
            DISALLOW_EMPTY,
            MISMATCH
        );

        // an occurrence count is not limited, make a cycle;
        // to collect more terms on each following matching mismatch
        result = createCondition(
            matchTerm,
            null, // will be a loop
            MISMATCH
        );

        result.then = createCondition(
            MATCH,
            MATCH,
            result // make a loop
        );

        if (node.comma) {
            result.then.else = createCondition(
                { type: 'Comma', syntax: node },
                result,
                MISMATCH
            );
        }
    } else {
        // create a match node chain for [min .. max] interval with optional matches
        for (let i = node.min || 1; i <= node.max; i++) {
            if (node.comma && result !== MATCH) {
                result = createCondition(
                    { type: 'Comma', syntax: node },
                    result,
                    MISMATCH
                );
            }

            result = createCondition(
                matchTerm,
                createCondition(
                    MATCH,
                    MATCH,
                    result
                ),
                MISMATCH
            );
        }
    }

    if (node.min === 0) {
        // allow zero match
        result = createCondition(
            MATCH,
            MATCH,
            result
        );
    } else {
        // create a match node chain to collect [0 ... min - 1] required matches
        for (let i = 0; i < node.min - 1; i++) {
            if (node.comma && result !== MATCH) {
                result = createCondition(
                    { type: 'Comma', syntax: node },
                    result,
                    MISMATCH
                );
            }

            result = createCondition(
                matchTerm,
                result,
                MISMATCH
            );
        }
    }

    return result;
}

function buildMatchGraphInternal(node) {
    if (typeof node === 'function') {
        return {
            type: 'Generic',
            fn: node
        };
    }

    switch (node.type) {
        case 'Group': {
            let result = buildGroupMatchGraph(
                node.combinator,
                node.terms.map(buildMatchGraphInternal),
                false
            );

            if (node.disallowEmpty) {
                result = createCondition(
                    result,
                    DISALLOW_EMPTY,
                    MISMATCH
                );
            }

            return result;
        }

        case 'Multiplier':
            return buildMultiplierMatchGraph(node);

        // https://drafts.csswg.org/css-values-5/#boolean
        case 'Boolean': {
            const term = buildMatchGraphInternal(node.term);
            // <boolean-expr[ <test> ]> = not <boolean-expr-group> | <boolean-expr-group> [ [ and <boolean-expr-group> ]* | [ or <boolean-expr-group> ]* ]
            const matchNode = buildMatchGraphInternal(groupNode([
                groupNode([
                    { type: 'Keyword', name: 'not' },
                    { type: 'Type', name: '!boolean-group' }
                ]),
                groupNode([
                    { type: 'Type', name: '!boolean-group' },
                    groupNode([
                        { type: 'Multiplier', comma: false, min: 0, max: 0, term: groupNode([
                            { type: 'Keyword', name: 'and' },
                            { type: 'Type', name: '!boolean-group' }
                        ]) },
                        { type: 'Multiplier', comma: false, min: 0, max: 0, term: groupNode([
                            { type: 'Keyword', name: 'or' },
                            { type: 'Type', name: '!boolean-group' }
                        ]) }
                    ], '|')
                ])
            ], '|'));
            // <boolean-expr-group> = <test> | ( <boolean-expr[ <test> ]> ) | <general-enclosed>
            const booleanGroup = buildMatchGraphInternal(
                groupNode([
                    { type: 'Type', name: '!term' },
                    groupNode([
                        { type: 'Token', value: '(' },
                        { type: 'Type', name: '!self' },
                        { type: 'Token', value: ')' }
                    ]),
                    { type: 'Type', name: 'general-enclosed' }
                ], '|')
            );

            replaceTypeInGraph(booleanGroup, { '!term': term, '!self': matchNode });
            replaceTypeInGraph(matchNode, { '!boolean-group': booleanGroup });

            return matchNode;
        }

        case 'Type':
        case 'Property':
            return {
                type: node.type,
                name: node.name,
                syntax: node
            };

        case 'Keyword':
            return {
                type: node.type,
                name: node.name.toLowerCase(),
                syntax: node
            };

        case 'AtKeyword':
            return {
                type: node.type,
                name: '@' + node.name.toLowerCase(),
                syntax: node
            };

        case 'Function':
            return {
                type: node.type,
                name: node.name.toLowerCase() + '(',
                syntax: node
            };

        case 'String':
            // convert a one char length String to a Token
            if (node.value.length === 3) {
                return {
                    type: 'Token',
                    value: node.value.charAt(1),
                    syntax: node
                };
            }

            // otherwise use it as is
            return {
                type: node.type,
                value: node.value.substr(1, node.value.length - 2).replace(/\\'/g, '\''),
                syntax: node
            };

        case 'Token':
            return {
                type: node.type,
                value: node.value,
                syntax: node
            };

        case 'Comma':
            return {
                type: node.type,
                syntax: node
            };

        default:
            throw new Error('Unknown node type:', node.type);
    }
}

function buildMatchGraph(syntaxTree, ref) {
    if (typeof syntaxTree === 'string') {
        syntaxTree = parse$O(syntaxTree);
    }

    return {
        type: 'MatchGraph',
        match: buildMatchGraphInternal(syntaxTree),
        syntax: ref || null,
        source: syntaxTree
    };
}

const { hasOwnProperty: hasOwnProperty$2 } = Object.prototype;
const STUB = 0;
const TOKEN = 1;
const OPEN_SYNTAX = 2;
const CLOSE_SYNTAX = 3;

const EXIT_REASON_MATCH = 'Match';
const EXIT_REASON_MISMATCH = 'Mismatch';
const EXIT_REASON_ITERATION_LIMIT = 'Maximum iteration number exceeded (please fill an issue on https://github.com/csstree/csstree/issues)';

const ITERATION_LIMIT = 15000;

function reverseList(list) {
    let prev = null;
    let next = null;
    let item = list;

    while (item !== null) {
        next = item.prev;
        item.prev = prev;
        prev = item;
        item = next;
    }

    return prev;
}

function areStringsEqualCaseInsensitive(testStr, referenceStr) {
    if (testStr.length !== referenceStr.length) {
        return false;
    }

    for (let i = 0; i < testStr.length; i++) {
        const referenceCode = referenceStr.charCodeAt(i);
        let testCode = testStr.charCodeAt(i);

        // testCode.toLowerCase() for U+0041 LATIN CAPITAL LETTER A (A) .. U+005A LATIN CAPITAL LETTER Z (Z).
        if (testCode >= 0x0041 && testCode <= 0x005A) {
            testCode = testCode | 32;
        }

        if (testCode !== referenceCode) {
            return false;
        }
    }

    return true;
}

function isContextEdgeDelim(token) {
    if (token.type !== Delim) {
        return false;
    }

    // Fix matching for unicode-range: U+30??, U+FF00-FF9F
    // Probably we need to check out previous match instead
    return token.value !== '?';
}

function isCommaContextStart(token) {
    if (token === null) {
        return true;
    }

    return (
        token.type === Comma ||
        token.type === Function$1 ||
        token.type === LeftParenthesis ||
        token.type === LeftSquareBracket ||
        token.type === LeftCurlyBracket ||
        isContextEdgeDelim(token)
    );
}

function isCommaContextEnd(token) {
    if (token === null) {
        return true;
    }

    return (
        token.type === RightParenthesis ||
        token.type === RightSquareBracket ||
        token.type === RightCurlyBracket ||
        (token.type === Delim && token.value === '/')
    );
}

function internalMatch(tokens, state, syntaxes) {
    function moveToNextToken() {
        do {
            tokenIndex++;
            token = tokenIndex < tokens.length ? tokens[tokenIndex] : null;
        } while (token !== null && (token.type === WhiteSpace$1 || token.type === Comment$1));
    }

    function getNextToken(offset) {
        const nextIndex = tokenIndex + offset;

        return nextIndex < tokens.length ? tokens[nextIndex] : null;
    }

    function stateSnapshotFromSyntax(nextState, prev) {
        return {
            nextState,
            matchStack,
            syntaxStack,
            thenStack,
            tokenIndex,
            prev
        };
    }

    function pushThenStack(nextState) {
        thenStack = {
            nextState,
            matchStack,
            syntaxStack,
            prev: thenStack
        };
    }

    function pushElseStack(nextState) {
        elseStack = stateSnapshotFromSyntax(nextState, elseStack);
    }

    function addTokenToMatch() {
        matchStack = {
            type: TOKEN,
            syntax: state.syntax,
            token,
            prev: matchStack
        };

        moveToNextToken();
        syntaxStash = null;

        if (tokenIndex > longestMatch) {
            longestMatch = tokenIndex;
        }
    }

    function openSyntax() {
        syntaxStack = {
            syntax: state.syntax,
            opts: state.syntax.opts || (syntaxStack !== null && syntaxStack.opts) || null,
            prev: syntaxStack
        };

        matchStack = {
            type: OPEN_SYNTAX,
            syntax: state.syntax,
            token: matchStack.token,
            prev: matchStack
        };
    }

    function closeSyntax() {
        if (matchStack.type === OPEN_SYNTAX) {
            matchStack = matchStack.prev;
        } else {
            matchStack = {
                type: CLOSE_SYNTAX,
                syntax: syntaxStack.syntax,
                token: matchStack.token,
                prev: matchStack
            };
        }

        syntaxStack = syntaxStack.prev;
    }

    let syntaxStack = null;
    let thenStack = null;
    let elseStack = null;

    // null – stashing allowed, nothing stashed
    // false – stashing disabled, nothing stashed
    // anithing else – fail stashable syntaxes, some syntax stashed
    let syntaxStash = null;

    let iterationCount = 0; // count iterations and prevent infinite loop
    let exitReason = null;

    let token = null;
    let tokenIndex = -1;
    let longestMatch = 0;
    let matchStack = {
        type: STUB,
        syntax: null,
        token: null,
        prev: null
    };

    moveToNextToken();

    while (exitReason === null && ++iterationCount < ITERATION_LIMIT) {
        // function mapList(list, fn) {
        //     const result = [];
        //     while (list) {
        //         result.unshift(fn(list));
        //         list = list.prev;
        //     }
        //     return result;
        // }
        // console.log('--\n',
        //     '#' + iterationCount,
        //     require('util').inspect({
        //         match: mapList(matchStack, x => x.type === TOKEN ? x.token && x.token.value : x.syntax ? ({ [OPEN_SYNTAX]: '<', [CLOSE_SYNTAX]: '</' }[x.type] || x.type) + '!' + x.syntax.name : null),
        //         token: token && token.value,
        //         tokenIndex,
        //         syntax: syntax.type + (syntax.id ? ' #' + syntax.id : '')
        //     }, { depth: null })
        // );
        switch (state.type) {
            case 'Match':
                if (thenStack === null) {
                    // turn to MISMATCH when some tokens left unmatched
                    if (token !== null) {
                        // doesn't mismatch if just one token left and it's an IE hack
                        if (tokenIndex !== tokens.length - 1 || (token.value !== '\\0' && token.value !== '\\9')) {
                            state = MISMATCH;
                            break;
                        }
                    }

                    // break the main loop, return a result - MATCH
                    exitReason = EXIT_REASON_MATCH;
                    break;
                }

                // go to next syntax (`then` branch)
                state = thenStack.nextState;

                // check match is not empty
                if (state === DISALLOW_EMPTY) {
                    if (thenStack.matchStack === matchStack) {
                        state = MISMATCH;
                        break;
                    } else {
                        state = MATCH;
                    }
                }

                // close syntax if needed
                while (thenStack.syntaxStack !== syntaxStack) {
                    closeSyntax();
                }

                // pop stack
                thenStack = thenStack.prev;
                break;

            case 'Mismatch':
                // when some syntax is stashed
                if (syntaxStash !== null && syntaxStash !== false) {
                    // there is no else branches or a branch reduce match stack
                    if (elseStack === null || tokenIndex > elseStack.tokenIndex) {
                        // restore state from the stash
                        elseStack = syntaxStash;
                        syntaxStash = false; // disable stashing
                    }
                } else if (elseStack === null) {
                    // no else branches -> break the main loop
                    // return a result - MISMATCH
                    exitReason = EXIT_REASON_MISMATCH;
                    break;
                }

                // go to next syntax (`else` branch)
                state = elseStack.nextState;

                // restore all the rest stack states
                thenStack = elseStack.thenStack;
                syntaxStack = elseStack.syntaxStack;
                matchStack = elseStack.matchStack;
                tokenIndex = elseStack.tokenIndex;
                token = tokenIndex < tokens.length ? tokens[tokenIndex] : null;

                // pop stack
                elseStack = elseStack.prev;
                break;

            case 'MatchGraph':
                state = state.match;
                break;

            case 'If':
                // IMPORTANT: else stack push must go first,
                // since it stores the state of thenStack before changes
                if (state.else !== MISMATCH) {
                    pushElseStack(state.else);
                }

                if (state.then !== MATCH) {
                    pushThenStack(state.then);
                }

                state = state.match;
                break;

            case 'MatchOnce':
                state = {
                    type: 'MatchOnceBuffer',
                    syntax: state,
                    index: 0,
                    mask: 0
                };
                break;

            case 'MatchOnceBuffer': {
                const terms = state.syntax.terms;

                if (state.index === terms.length) {
                    // no matches at all or it's required all terms to be matched
                    if (state.mask === 0 || state.syntax.all) {
                        state = MISMATCH;
                        break;
                    }

                    // a partial match is ok
                    state = MATCH;
                    break;
                }

                // all terms are matched
                if (state.mask === (1 << terms.length) - 1) {
                    state = MATCH;
                    break;
                }

                for (; state.index < terms.length; state.index++) {
                    const matchFlag = 1 << state.index;

                    if ((state.mask & matchFlag) === 0) {
                        // IMPORTANT: else stack push must go first,
                        // since it stores the state of thenStack before changes
                        pushElseStack(state);
                        pushThenStack({
                            type: 'AddMatchOnce',
                            syntax: state.syntax,
                            mask: state.mask | matchFlag
                        });

                        // match
                        state = terms[state.index++];
                        break;
                    }
                }
                break;
            }

            case 'AddMatchOnce':
                state = {
                    type: 'MatchOnceBuffer',
                    syntax: state.syntax,
                    index: 0,
                    mask: state.mask
                };
                break;

            case 'Enum':
                if (token !== null) {
                    let name = token.value.toLowerCase();

                    // drop \0 and \9 hack from keyword name
                    if (name.indexOf('\\') !== -1) {
                        name = name.replace(/\\[09].*$/, '');
                    }

                    if (hasOwnProperty$2.call(state.map, name)) {
                        state = state.map[name];
                        break;
                    }
                }

                state = MISMATCH;
                break;

            case 'Generic': {
                const opts = syntaxStack !== null ? syntaxStack.opts : null;
                const lastTokenIndex = tokenIndex + Math.floor(state.fn(token, getNextToken, opts));

                if (!isNaN(lastTokenIndex) && lastTokenIndex > tokenIndex) {
                    while (tokenIndex < lastTokenIndex) {
                        addTokenToMatch();
                    }

                    state = MATCH;
                } else {
                    state = MISMATCH;
                }

                break;
            }

            case 'Type':
            case 'Property': {
                const syntaxDict = state.type === 'Type' ? 'types' : 'properties';
                const dictSyntax = hasOwnProperty$2.call(syntaxes, syntaxDict) ? syntaxes[syntaxDict][state.name] : null;

                if (!dictSyntax || !dictSyntax.match) {
                    throw new Error(
                        'Bad syntax reference: ' +
                        (state.type === 'Type'
                            ? '<' + state.name + '>'
                            : '<\'' + state.name + '\'>')
                    );
                }

                // stash a syntax for types with low priority
                if (syntaxStash !== false && token !== null && state.type === 'Type') {
                    const lowPriorityMatching =
                        // https://drafts.csswg.org/css-values-4/#custom-idents
                        // When parsing positionally-ambiguous keywords in a property value, a <custom-ident> production
                        // can only claim the keyword if no other unfulfilled production can claim it.
                        (state.name === 'custom-ident' && token.type === Ident) ||

                        // https://drafts.csswg.org/css-values-4/#lengths
                        // ... if a `0` could be parsed as either a <number> or a <length> in a property (such as line-height),
                        // it must parse as a <number>
                        (state.name === 'length' && token.value === '0');

                    if (lowPriorityMatching) {
                        if (syntaxStash === null) {
                            syntaxStash = stateSnapshotFromSyntax(state, elseStack);
                        }

                        state = MISMATCH;
                        break;
                    }
                }

                openSyntax();
                state = dictSyntax.matchRef || dictSyntax.match;
                break;
            }

            case 'Keyword': {
                const name = state.name;

                if (token !== null) {
                    let keywordName = token.value;

                    // drop \0 and \9 hack from keyword name
                    if (keywordName.indexOf('\\') !== -1) {
                        keywordName = keywordName.replace(/\\[09].*$/, '');
                    }

                    if (areStringsEqualCaseInsensitive(keywordName, name)) {
                        addTokenToMatch();
                        state = MATCH;
                        break;
                    }
                }

                state = MISMATCH;
                break;
            }

            case 'AtKeyword':
            case 'Function':
                if (token !== null && areStringsEqualCaseInsensitive(token.value, state.name)) {
                    addTokenToMatch();
                    state = MATCH;
                    break;
                }

                state = MISMATCH;
                break;

            case 'Token':
                if (token !== null && token.value === state.value) {
                    addTokenToMatch();
                    state = MATCH;
                    break;
                }

                state = MISMATCH;
                break;

            case 'Comma':
                if (token !== null && token.type === Comma) {
                    if (isCommaContextStart(matchStack.token)) {
                        state = MISMATCH;
                    } else {
                        addTokenToMatch();
                        state = isCommaContextEnd(token) ? MISMATCH : MATCH;
                    }
                } else {
                    state = isCommaContextStart(matchStack.token) || isCommaContextEnd(token) ? MATCH : MISMATCH;
                }

                break;

            case 'String':
                let string = '';
                let lastTokenIndex = tokenIndex;

                for (; lastTokenIndex < tokens.length && string.length < state.value.length; lastTokenIndex++) {
                    string += tokens[lastTokenIndex].value;
                }

                if (areStringsEqualCaseInsensitive(string, state.value)) {
                    while (tokenIndex < lastTokenIndex) {
                        addTokenToMatch();
                    }

                    state = MATCH;
                } else {
                    state = MISMATCH;
                }

                break;

            default:
                throw new Error('Unknown node type: ' + state.type);
        }
    }

    switch (exitReason) {
        case null:
            console.warn('[csstree-match] BREAK after ' + ITERATION_LIMIT + ' iterations');
            exitReason = EXIT_REASON_ITERATION_LIMIT;
            matchStack = null;
            break;

        case EXIT_REASON_MATCH:
            while (syntaxStack !== null) {
                closeSyntax();
            }
            break;

        default:
            matchStack = null;
    }

    return {
        tokens,
        reason: exitReason,
        iterations: iterationCount,
        match: matchStack,
        longestMatch
    };
}

function matchAsTree(tokens, matchGraph, syntaxes) {
    const matchResult = internalMatch(tokens, matchGraph, syntaxes || {});

    if (matchResult.match === null) {
        return matchResult;
    }

    let item = matchResult.match;
    let host = matchResult.match = {
        syntax: matchGraph.syntax || null,
        match: []
    };
    const hostStack = [host];

    // revert a list and start with 2nd item since 1st is a stub item
    item = reverseList(item).prev;

    // build a tree
    while (item !== null) {
        switch (item.type) {
            case OPEN_SYNTAX:
                host.match.push(host = {
                    syntax: item.syntax,
                    match: []
                });
                hostStack.push(host);
                break;

            case CLOSE_SYNTAX:
                hostStack.pop();
                host = hostStack[hostStack.length - 1];
                break;

            default:
                host.match.push({
                    syntax: item.syntax || null,
                    token: item.token.value,
                    node: item.token.node
                });
        }

        item = item.prev;
    }

    return matchResult;
}

function getTrace(node) {
    function shouldPutToTrace(syntax) {
        if (syntax === null) {
            return false;
        }

        return (
            syntax.type === 'Type' ||
            syntax.type === 'Property' ||
            syntax.type === 'Keyword'
        );
    }

    function hasMatch(matchNode) {
        if (Array.isArray(matchNode.match)) {
            // use for-loop for better perfomance
            for (let i = 0; i < matchNode.match.length; i++) {
                if (hasMatch(matchNode.match[i])) {
                    if (shouldPutToTrace(matchNode.syntax)) {
                        result.unshift(matchNode.syntax);
                    }

                    return true;
                }
            }
        } else if (matchNode.node === node) {
            result = shouldPutToTrace(matchNode.syntax)
                ? [matchNode.syntax]
                : [];

            return true;
        }

        return false;
    }

    let result = null;

    if (this.matched !== null) {
        hasMatch(this.matched);
    }

    return result;
}

function isType(node, type) {
    return testNode(this, node, match => match.type === 'Type' && match.name === type);
}

function isProperty(node, property) {
    return testNode(this, node, match => match.type === 'Property' && match.name === property);
}

function isKeyword(node) {
    return testNode(this, node, match => match.type === 'Keyword');
}

function testNode(match, node, fn) {
    const trace = getTrace.call(match, node);

    if (trace === null) {
        return false;
    }

    return trace.some(fn);
}

var trace = /*#__PURE__*/Object.freeze({
    __proto__: null,
    getTrace: getTrace,
    isType: isType,
    isProperty: isProperty,
    isKeyword: isKeyword
});

function getFirstMatchNode(matchNode) {
    if ('node' in matchNode) {
        return matchNode.node;
    }

    return getFirstMatchNode(matchNode.match[0]);
}

function getLastMatchNode(matchNode) {
    if ('node' in matchNode) {
        return matchNode.node;
    }

    return getLastMatchNode(matchNode.match[matchNode.match.length - 1]);
}

function matchFragments(lexer, ast, match, type, name) {
    function findFragments(matchNode) {
        if (matchNode.syntax !== null &&
            matchNode.syntax.type === type &&
            matchNode.syntax.name === name) {
            const start = getFirstMatchNode(matchNode);
            const end = getLastMatchNode(matchNode);

            lexer.syntax.walk(ast, function(node, item, list) {
                if (node === start) {
                    const nodes = new List();

                    do {
                        nodes.appendData(item.data);

                        if (item.data === end) {
                            break;
                        }

                        item = item.next;
                    } while (item !== null);

                    fragments.push({
                        parent: list,
                        nodes
                    });
                }
            });
        }

        if (Array.isArray(matchNode.match)) {
            matchNode.match.forEach(findFragments);
        }
    }

    const fragments = [];

    if (match.matched !== null) {
        findFragments(match.matched);
    }

    return fragments;
}

const { hasOwnProperty: hasOwnProperty$1 } = Object.prototype;

function isValidNumber(value) {
    // Number.isInteger(value) && value >= 0
    return (
        typeof value === 'number' &&
        isFinite(value) &&
        Math.floor(value) === value &&
        value >= 0
    );
}

function isValidLocation(loc) {
    return (
        Boolean(loc) &&
        isValidNumber(loc.offset) &&
        isValidNumber(loc.line) &&
        isValidNumber(loc.column)
    );
}

function createNodeStructureChecker(type, fields) {
    return function checkNode(node, warn) {
        if (!node || node.constructor !== Object) {
            return warn(node, 'Type of node should be an Object');
        }

        for (let key in node) {
            let valid = true;

            if (hasOwnProperty$1.call(node, key) === false) {
                continue;
            }

            if (key === 'type') {
                if (node.type !== type) {
                    warn(node, 'Wrong node type `' + node.type + '`, expected `' + type + '`');
                }
            } else if (key === 'loc') {
                if (node.loc === null) {
                    continue;
                } else if (node.loc && node.loc.constructor === Object) {
                    if (typeof node.loc.source !== 'string') {
                        key += '.source';
                    } else if (!isValidLocation(node.loc.start)) {
                        key += '.start';
                    } else if (!isValidLocation(node.loc.end)) {
                        key += '.end';
                    } else {
                        continue;
                    }
                }

                valid = false;
            } else if (fields.hasOwnProperty(key)) {
                valid = false;

                for (let i = 0; !valid && i < fields[key].length; i++) {
                    const fieldType = fields[key][i];

                    switch (fieldType) {
                        case String:
                            valid = typeof node[key] === 'string';
                            break;

                        case Boolean:
                            valid = typeof node[key] === 'boolean';
                            break;

                        case null:
                            valid = node[key] === null;
                            break;

                        default:
                            if (typeof fieldType === 'string') {
                                valid = node[key] && node[key].type === fieldType;
                            } else if (Array.isArray(fieldType)) {
                                valid = node[key] instanceof List;
                            }
                    }
                }
            } else {
                warn(node, 'Unknown field `' + key + '` for ' + type + ' node type');
            }

            if (!valid) {
                warn(node, 'Bad value for `' + type + '.' + key + '`');
            }
        }

        for (const key in fields) {
            if (hasOwnProperty$1.call(fields, key) &&
                hasOwnProperty$1.call(node, key) === false) {
                warn(node, 'Field `' + type + '.' + key + '` is missed');
            }
        }
    };
}

function genTypesList(fieldTypes, path) {
    const docsTypes = [];

    for (let i = 0; i < fieldTypes.length; i++) {
        const fieldType = fieldTypes[i];
        if (fieldType === String || fieldType === Boolean) {
            docsTypes.push(fieldType.name.toLowerCase());
        } else if (fieldType === null) {
            docsTypes.push('null');
        } else if (typeof fieldType === 'string') {
            docsTypes.push(fieldType);
        } else if (Array.isArray(fieldType)) {
            docsTypes.push('List<' + (genTypesList(fieldType, path) || 'any') + '>'); // TODO: use type enum
        } else {
            throw new Error('Wrong value `' + fieldType + '` in `' + path + '` structure definition');
        }
    }

    return docsTypes.join(' | ');
}

function processStructure(name, nodeType) {
    const structure = nodeType.structure;
    const fields = {
        type: String,
        loc: true
    };
    const docs = {
        type: '"' + name + '"'
    };

    for (const key in structure) {
        if (hasOwnProperty$1.call(structure, key) === false) {
            continue;
        }

        const fieldTypes = fields[key] = Array.isArray(structure[key])
            ? structure[key].slice()
            : [structure[key]];

        docs[key] = genTypesList(fieldTypes, name + '.' + key);
    }

    return {
        docs,
        check: createNodeStructureChecker(name, fields)
    };
}

function getStructureFromConfig(config) {
    const structure = {};

    if (config.node) {
        for (const name in config.node) {
            if (hasOwnProperty$1.call(config.node, name)) {
                const nodeType = config.node[name];

                if (nodeType.structure) {
                    structure[name] = processStructure(name, nodeType);
                } else {
                    throw new Error('Missed `structure` field in `' + name + '` node type definition');
                }
            }
        }
    }

    return structure;
}

function dumpMapSyntax(map, compact, syntaxAsAst) {
    const result = {};

    for (const name in map) {
        if (map[name].syntax) {
            result[name] = syntaxAsAst
                ? map[name].syntax
                : generate$O(map[name].syntax, { compact });
        }
    }

    return result;
}

function dumpAtruleMapSyntax(map, compact, syntaxAsAst) {
    const result = {};

    for (const [name, atrule] of Object.entries(map)) {
        result[name] = {
            prelude: atrule.prelude && (
                syntaxAsAst
                    ? atrule.prelude.syntax
                    : generate$O(atrule.prelude.syntax, { compact })
            ),
            descriptors: atrule.descriptors && dumpMapSyntax(atrule.descriptors, compact, syntaxAsAst)
        };
    }

    return result;
}

function valueHasVar(tokens) {
    for (let i = 0; i < tokens.length; i++) {
        if (tokens[i].value.toLowerCase() === 'var(') {
            return true;
        }
    }

    return false;
}

function syntaxHasTopLevelCommaMultiplier(syntax) {
    const singleTerm = syntax.terms[0];

    return (
        syntax.explicit === false &&
        syntax.terms.length === 1 &&
        singleTerm.type === 'Multiplier' &&
        singleTerm.comma === true
    );
}

function buildMatchResult(matched, error, iterations) {
    return {
        matched,
        iterations,
        error,
        ...trace
    };
}

function matchSyntax(lexer, syntax, value, useCssWideKeywords) {
    const tokens = prepareTokens(value, lexer.syntax);
    let result;

    if (valueHasVar(tokens)) {
        return buildMatchResult(null, new Error('Matching for a tree with var() is not supported'));
    }

    if (useCssWideKeywords) {
        result = matchAsTree(tokens, lexer.cssWideKeywordsSyntax, lexer);
    }

    if (!useCssWideKeywords || !result.match) {
        result = matchAsTree(tokens, syntax.match, lexer);
        if (!result.match) {
            return buildMatchResult(
                null,
                new SyntaxMatchError(result.reason, syntax.syntax, value, result),
                result.iterations
            );
        }
    }

    return buildMatchResult(result.match, null, result.iterations);
}

class Lexer {
    constructor(config, syntax, structure) {
        this.cssWideKeywords = cssWideKeywords;
        this.syntax = syntax;
        this.generic = false;
        this.units = { ...units };
        this.atrules = Object.create(null);
        this.properties = Object.create(null);
        this.types = Object.create(null);
        this.structure = structure || getStructureFromConfig(config);

        if (config) {
            if (config.cssWideKeywords) {
                this.cssWideKeywords = config.cssWideKeywords;
            }

            if (config.units) {
                for (const group of Object.keys(units)) {
                    if (Array.isArray(config.units[group])) {
                        this.units[group] = config.units[group];
                    }
                }
            }

            if (config.types) {
                for (const [name, type] of Object.entries(config.types)) {
                    this.addType_(name, type);
                }
            }

            if (config.generic) {
                this.generic = true;
                for (const [name, value] of Object.entries(createGenericTypes(this.units))) {
                    this.addType_(name, value);
                }
            }

            if (config.atrules) {
                for (const [name, atrule] of Object.entries(config.atrules)) {
                    this.addAtrule_(name, atrule);
                }
            }

            if (config.properties) {
                for (const [name, property] of Object.entries(config.properties)) {
                    this.addProperty_(name, property);
                }
            }
        }

        this.cssWideKeywordsSyntax = buildMatchGraph(this.cssWideKeywords.join(' |  '));
    }

    checkStructure(ast) {
        function collectWarning(node, message) {
            warns.push({ node, message });
        }

        const structure = this.structure;
        const warns = [];

        this.syntax.walk(ast, function(node) {
            if (structure.hasOwnProperty(node.type)) {
                structure[node.type].check(node, collectWarning);
            } else {
                collectWarning(node, 'Unknown node type `' + node.type + '`');
            }
        });

        return warns.length ? warns : false;
    }

    createDescriptor(syntax, type, name, parent = null) {
        const ref = {
            type,
            name
        };
        const descriptor = {
            type,
            name,
            parent,
            serializable: typeof syntax === 'string' || (syntax && typeof syntax.type === 'string'),
            syntax: null,
            match: null,
            matchRef: null // used for properties when a syntax referenced as <'property'> in other syntax definitions
        };

        if (typeof syntax === 'function') {
            descriptor.match = buildMatchGraph(syntax, ref);
        } else {
            if (typeof syntax === 'string') {
                // lazy parsing on first access
                Object.defineProperty(descriptor, 'syntax', {
                    get() {
                        Object.defineProperty(descriptor, 'syntax', {
                            value: parse$O(syntax)
                        });

                        return descriptor.syntax;
                    }
                });
            } else {
                descriptor.syntax = syntax;
            }

            // lazy graph build on first access
            Object.defineProperty(descriptor, 'match', {
                get() {
                    Object.defineProperty(descriptor, 'match', {
                        value: buildMatchGraph(descriptor.syntax, ref)
                    });

                    return descriptor.match;
                }
            });

            if (type === 'Property') {
                Object.defineProperty(descriptor, 'matchRef', {
                    get() {
                        const syntax = descriptor.syntax;
                        const value = syntaxHasTopLevelCommaMultiplier(syntax)
                            ? buildMatchGraph({
                                ...syntax,
                                terms: [syntax.terms[0].term]
                            }, ref)
                            : null;

                        Object.defineProperty(descriptor, 'matchRef', {
                            value
                        });

                        return value;
                    }
                });
            }
        }

        return descriptor;
    }
    addAtrule_(name, syntax) {
        if (!syntax) {
            return;
        }

        this.atrules[name] = {
            type: 'Atrule',
            name: name,
            prelude: syntax.prelude ? this.createDescriptor(syntax.prelude, 'AtrulePrelude', name) : null,
            descriptors: syntax.descriptors
                ? Object.keys(syntax.descriptors).reduce(
                    (map, descName) => {
                        map[descName] = this.createDescriptor(syntax.descriptors[descName], 'AtruleDescriptor', descName, name);
                        return map;
                    },
                    Object.create(null)
                )
                : null
        };
    }
    addProperty_(name, syntax) {
        if (!syntax) {
            return;
        }

        this.properties[name] = this.createDescriptor(syntax, 'Property', name);
    }
    addType_(name, syntax) {
        if (!syntax) {
            return;
        }

        this.types[name] = this.createDescriptor(syntax, 'Type', name);
    }

    checkAtruleName(atruleName) {
        if (!this.getAtrule(atruleName)) {
            return new SyntaxReferenceError('Unknown at-rule', '@' + atruleName);
        }
    }
    checkAtrulePrelude(atruleName, prelude) {
        const error = this.checkAtruleName(atruleName);

        if (error) {
            return error;
        }

        const atrule = this.getAtrule(atruleName);

        if (!atrule.prelude && prelude) {
            return new SyntaxError('At-rule `@' + atruleName + '` should not contain a prelude');
        }

        if (atrule.prelude && !prelude) {
            if (!matchSyntax(this, atrule.prelude, '', false).matched) {
                return new SyntaxError('At-rule `@' + atruleName + '` should contain a prelude');
            }
        }
    }
    checkAtruleDescriptorName(atruleName, descriptorName) {
        const error = this.checkAtruleName(atruleName);

        if (error) {
            return error;
        }

        const atrule = this.getAtrule(atruleName);
        const descriptor = keyword(descriptorName);

        if (!atrule.descriptors) {
            return new SyntaxError('At-rule `@' + atruleName + '` has no known descriptors');
        }

        if (!atrule.descriptors[descriptor.name] &&
            !atrule.descriptors[descriptor.basename]) {
            return new SyntaxReferenceError('Unknown at-rule descriptor', descriptorName);
        }
    }
    checkPropertyName(propertyName) {
        if (!this.getProperty(propertyName)) {
            return new SyntaxReferenceError('Unknown property', propertyName);
        }
    }

    matchAtrulePrelude(atruleName, prelude) {
        const error = this.checkAtrulePrelude(atruleName, prelude);

        if (error) {
            return buildMatchResult(null, error);
        }

        const atrule = this.getAtrule(atruleName);

        if (!atrule.prelude) {
            return buildMatchResult(null, null);
        }

        return matchSyntax(this, atrule.prelude, prelude || '', false);
    }
    matchAtruleDescriptor(atruleName, descriptorName, value) {
        const error = this.checkAtruleDescriptorName(atruleName, descriptorName);

        if (error) {
            return buildMatchResult(null, error);
        }

        const atrule = this.getAtrule(atruleName);
        const descriptor = keyword(descriptorName);

        return matchSyntax(this, atrule.descriptors[descriptor.name] || atrule.descriptors[descriptor.basename], value, false);
    }
    matchDeclaration(node) {
        if (node.type !== 'Declaration') {
            return buildMatchResult(null, new Error('Not a Declaration node'));
        }

        return this.matchProperty(node.property, node.value);
    }
    matchProperty(propertyName, value) {
        // don't match syntax for a custom property at the moment
        if (property(propertyName).custom) {
            return buildMatchResult(null, new Error('Lexer matching doesn\'t applicable for custom properties'));
        }

        const error = this.checkPropertyName(propertyName);

        if (error) {
            return buildMatchResult(null, error);
        }

        return matchSyntax(this, this.getProperty(propertyName), value, true);
    }
    matchType(typeName, value) {
        const typeSyntax = this.getType(typeName);

        if (!typeSyntax) {
            return buildMatchResult(null, new SyntaxReferenceError('Unknown type', typeName));
        }

        return matchSyntax(this, typeSyntax, value, false);
    }
    match(syntax, value) {
        if (typeof syntax !== 'string' && (!syntax || !syntax.type)) {
            return buildMatchResult(null, new SyntaxReferenceError('Bad syntax'));
        }

        if (typeof syntax === 'string' || !syntax.match) {
            syntax = this.createDescriptor(syntax, 'Type', 'anonymous');
        }

        return matchSyntax(this, syntax, value, false);
    }

    findValueFragments(propertyName, value, type, name) {
        return matchFragments(this, value, this.matchProperty(propertyName, value), type, name);
    }
    findDeclarationValueFragments(declaration, type, name) {
        return matchFragments(this, declaration.value, this.matchDeclaration(declaration), type, name);
    }
    findAllFragments(ast, type, name) {
        const result = [];

        this.syntax.walk(ast, {
            visit: 'Declaration',
            enter: (declaration) => {
                result.push.apply(result, this.findDeclarationValueFragments(declaration, type, name));
            }
        });

        return result;
    }

    getAtrule(atruleName, fallbackBasename = true) {
        const atrule = keyword(atruleName);
        const atruleEntry = atrule.vendor && fallbackBasename
            ? this.atrules[atrule.name] || this.atrules[atrule.basename]
            : this.atrules[atrule.name];

        return atruleEntry || null;
    }
    getAtrulePrelude(atruleName, fallbackBasename = true) {
        const atrule = this.getAtrule(atruleName, fallbackBasename);

        return atrule && atrule.prelude || null;
    }
    getAtruleDescriptor(atruleName, name) {
        return this.atrules.hasOwnProperty(atruleName) && this.atrules.declarators
            ? this.atrules[atruleName].declarators[name] || null
            : null;
    }
    getProperty(propertyName, fallbackBasename = true) {
        const property$1 = property(propertyName);
        const propertyEntry = property$1.vendor && fallbackBasename
            ? this.properties[property$1.name] || this.properties[property$1.basename]
            : this.properties[property$1.name];

        return propertyEntry || null;
    }
    getType(name) {
        return hasOwnProperty.call(this.types, name) ? this.types[name] : null;
    }

    validate() {
        function syntaxRef(name, isType) {
            return isType ? `<${name}>` : `<'${name}'>`;
        }

        function validate(syntax, name, broken, descriptor) {
            if (broken.has(name)) {
                return broken.get(name);
            }

            broken.set(name, false);
            if (descriptor.syntax !== null) {
                walk$1(descriptor.syntax, function(node) {
                    if (node.type !== 'Type' && node.type !== 'Property') {
                        return;
                    }

                    const map = node.type === 'Type' ? syntax.types : syntax.properties;
                    const brokenMap = node.type === 'Type' ? brokenTypes : brokenProperties;

                    if (!hasOwnProperty.call(map, node.name)) {
                        errors.push(`${syntaxRef(name, broken === brokenTypes)} used missed syntax definition ${syntaxRef(node.name, node.type === 'Type')}`);
                        broken.set(name, true);
                    } else if (validate(syntax, node.name, brokenMap, map[node.name])) {
                        errors.push(`${syntaxRef(name, broken === brokenTypes)} used broken syntax definition ${syntaxRef(node.name, node.type === 'Type')}`);
                        broken.set(name, true);
                    }
                }, this);
            }
        }

        const errors = [];
        let brokenTypes = new Map();
        let brokenProperties = new Map();

        for (const key in this.types) {
            validate(this, key, brokenTypes, this.types[key]);
        }

        for (const key in this.properties) {
            validate(this, key, brokenProperties, this.properties[key]);
        }

        const brokenTypesArray = [...brokenTypes.keys()].filter(name => brokenTypes.get(name));
        const brokenPropertiesArray = [...brokenProperties.keys()].filter(name => brokenProperties.get(name));

        if (brokenTypesArray.length || brokenPropertiesArray.length) {
            return {
                errors,
                types: brokenTypesArray,
                properties: brokenPropertiesArray
            };
        }

        return null;
    }
    dump(syntaxAsAst, pretty) {
        return {
            generic: this.generic,
            cssWideKeywords: this.cssWideKeywords,
            units: this.units,
            types: dumpMapSyntax(this.types, !pretty, syntaxAsAst),
            properties: dumpMapSyntax(this.properties, !pretty, syntaxAsAst),
            atrules: dumpAtruleMapSyntax(this.atrules, !pretty, syntaxAsAst)
        };
    }
    toString() {
        return JSON.stringify(this.dump());
    }
}

function appendOrSet(a, b) {
    if (typeof b === 'string' && /^\s*\|/.test(b)) {
        return typeof a === 'string'
            ? a + b
            : b.replace(/^\s*\|\s*/, '');
    }

    return b || null;
}

function extractProps(obj, props) {
    const result = Object.create(null);

    for (const prop of Object.keys(obj)) {
        if (props.includes(prop)) {
            result[prop] = obj[prop];
        }
    }

    return result;
}

function mergeDicts(base, ext, fields) {
    const result = { ...base };

    for (const [key, props] of Object.entries(ext)) {
        result[key] = {
            ...result[key],
            ...fields ? extractProps(props, fields) : props
        };
    }

    return result;
}

function mix(dest, src) {
    const result = { ...dest };

    for (const [prop, value] of Object.entries(src)) {
        switch (prop) {
            case 'generic':
                result[prop] = Boolean(value);
                break;

            case 'cssWideKeywords':
                result[prop] = dest[prop]
                    ? [...dest[prop], ...value]
                    : value || [];
                break;

            case 'units':
                result[prop] = { ...dest[prop] };
                for (const [name, patch] of Object.entries(value)) {
                    result[prop][name] = Array.isArray(patch) ? patch : [];
                }
                break;

            case 'atrules':
                result[prop] = { ...dest[prop] };

                for (const [name, atrule] of Object.entries(value)) {
                    const exists = result[prop][name] || {};
                    const current = result[prop][name] = {
                        prelude: exists.prelude || null,
                        descriptors: {
                            ...exists.descriptors
                        }
                    };

                    if (!atrule) {
                        continue;
                    }

                    current.prelude = atrule.prelude
                        ? appendOrSet(current.prelude, atrule.prelude)
                        : current.prelude || null;

                    for (const [descriptorName, descriptorValue] of Object.entries(atrule.descriptors || {})) {
                        current.descriptors[descriptorName] = descriptorValue
                            ? appendOrSet(current.descriptors[descriptorName], descriptorValue)
                            : null;
                    }

                    if (!Object.keys(current.descriptors).length) {
                        current.descriptors = null;
                    }
                }
                break;

            case 'types':
            case 'properties':
                result[prop] = { ...dest[prop] };
                for (const [name, syntax] of Object.entries(value)) {
                    result[prop][name] = appendOrSet(result[prop][name], syntax);
                }
                break;

            case 'parseContext':
                result[prop] = {
                    ...dest[prop],
                    ...value
                };
                break;

            case 'scope':
            case 'features':
                result[prop] = mergeDicts(dest[prop], value);
                break;

            case 'atrule':
            case 'pseudo':
                result[prop] = mergeDicts(dest[prop], value, ['parse']);
                break;

            case 'node':
                result[prop] = mergeDicts(dest[prop], value, ['name', 'structure', 'parse', 'generate', 'walkContext']);
                break;
        }
    }

    return result;
}

function createSyntax(config) {
    const parse = createParser(config);
    const walk = createWalker(config);
    const generate = createGenerator(config);
    const { fromPlainObject, toPlainObject } = createConvertor(walk);

    const syntax = {
        lexer: null,
        createLexer: config => new Lexer(config, syntax, syntax.lexer.structure),

        tokenize: tokenize$1,
        parse,
        generate,

        walk,
        find: walk.find,
        findLast: walk.findLast,
        findAll: walk.findAll,

        fromPlainObject,
        toPlainObject,

        fork(extension) {
            const base = mix({}, config); // copy of config

            return createSyntax(
                typeof extension === 'function'
                    ? extension(base) // TODO: remove Object.assign as second parameter
                    : mix(base, extension)
            );
        }
    };

    syntax.lexer = new Lexer({
        generic: config.generic,
        cssWideKeywords: config.cssWideKeywords,
        units: config.units,
        types: config.types,
        atrules: config.atrules,
        properties: config.properties,
        node: config.node
    }, syntax);

    return syntax;
}
var createSyntax$1 = config => createSyntax(mix({}, config));

var definitions = {
    "generic": true,
    "cssWideKeywords": [
        "initial",
        "inherit",
        "unset",
        "revert",
        "revert-layer"
    ],
    "units": {
        "angle": [
            "deg",
            "grad",
            "rad",
            "turn"
        ],
        "decibel": [
            "db"
        ],
        "flex": [
            "fr"
        ],
        "frequency": [
            "hz",
            "khz"
        ],
        "length": [
            "cm",
            "mm",
            "q",
            "in",
            "pt",
            "pc",
            "px",
            "em",
            "rem",
            "ex",
            "rex",
            "cap",
            "rcap",
            "ch",
            "rch",
            "ic",
            "ric",
            "lh",
            "rlh",
            "vw",
            "svw",
            "lvw",
            "dvw",
            "vh",
            "svh",
            "lvh",
            "dvh",
            "vi",
            "svi",
            "lvi",
            "dvi",
            "vb",
            "svb",
            "lvb",
            "dvb",
            "vmin",
            "svmin",
            "lvmin",
            "dvmin",
            "vmax",
            "svmax",
            "lvmax",
            "dvmax",
            "cqw",
            "cqh",
            "cqi",
            "cqb",
            "cqmin",
            "cqmax"
        ],
        "resolution": [
            "dpi",
            "dpcm",
            "dppx",
            "x"
        ],
        "semitones": [
            "st"
        ],
        "time": [
            "s",
            "ms"
        ]
    },
    "types": {
        "abs()": "abs( <calc-sum> )",
        "absolute-size": "xx-small|x-small|small|medium|large|x-large|xx-large|xxx-large",
        "acos()": "acos( <calc-sum> )",
        "alpha-value": "<number>|<percentage>",
        "an+b": "odd|even|<integer>|<n-dimension>|'+'? † n|-n|<ndashdigit-dimension>|'+'? † <ndashdigit-ident>|<dashndashdigit-ident>|<n-dimension> <signed-integer>|'+'? † n <signed-integer>|-n <signed-integer>|<ndash-dimension> <signless-integer>|'+'? † n- <signless-integer>|-n- <signless-integer>|<n-dimension> ['+'|'-'] <signless-integer>|'+'? † n ['+'|'-'] <signless-integer>|-n ['+'|'-'] <signless-integer>",
        "anchor()": "anchor( <anchor-name>?&&<anchor-side> , <length-percentage>? )",
        "anchor-name": "<dashed-ident>",
        "anchor-side": "inside|outside|top|left|right|bottom|start|end|self-start|self-end|<percentage>|center",
        "anchor-size": "width|height|block|inline|self-block|self-inline",
        "anchor-size()": "anchor-size( [<anchor-name>||<anchor-size>]? , <length-percentage>? )",
        "angle-percentage": "<angle>|<percentage>",
        "angular-color-hint": "<angle-percentage>|<zero>",
        "angular-color-stop": "<color> <color-stop-angle>?",
        "angular-color-stop-list": "<angular-color-stop> , [<angular-color-hint>? , <angular-color-stop>]#?",
        "animateable-feature": "scroll-position|contents|<custom-ident>",
        "asin()": "asin( <calc-sum> )",
        "atan()": "atan( <calc-sum> )",
        "atan2()": "atan2( <calc-sum> , <calc-sum> )",
        "attachment": "scroll|fixed|local",
        "attr()": "attr( <attr-name> <type-or-unit>? [, <attr-fallback>]? )",
        "attr-matcher": "['~'|'|'|'^'|'$'|'*']? '='",
        "attr-modifier": "i|s",
        "attribute-selector": "'[' <wq-name> ']'|'[' <wq-name> <attr-matcher> [<string-token>|<ident-token>] <attr-modifier>? ']'",
        "auto-repeat": "repeat( [auto-fill|auto-fit] , [<line-names>? <fixed-size>]+ <line-names>? )",
        "auto-track-list": "[<line-names>? [<fixed-size>|<fixed-repeat>]]* <line-names>? <auto-repeat> [<line-names>? [<fixed-size>|<fixed-repeat>]]* <line-names>?",
        "axis": "block|inline|x|y",
        "baseline-position": "[first|last]? baseline",
        "basic-shape": "<inset()>|<xywh()>|<rect()>|<circle()>|<ellipse()>|<polygon()>|<path()>",
        "basic-shape-rect": "<inset()>|<rect()>|<xywh()>",
        "bg-clip": "<visual-box>|border-area|text",
        "bg-image": "none|<image>",
        "bg-layer": "<bg-image>||<bg-position> [/ <bg-size>]?||<repeat-style>||<attachment>||<visual-box>||<visual-box>",
        "bg-position": "[[left|center|right|top|bottom|<length-percentage>]|[left|center|right|<length-percentage>] [top|center|bottom|<length-percentage>]|[center|[left|right] <length-percentage>?]&&[center|[top|bottom] <length-percentage>?]]",
        "bg-size": "[<length-percentage>|auto]{1,2}|cover|contain",
        "blend-mode": "normal|multiply|screen|overlay|darken|lighten|color-dodge|color-burn|hard-light|soft-light|difference|exclusion|hue|saturation|color|luminosity",
        "blur()": "blur( <length>? )",
        "brightness()": "brightness( [<number>|<percentage>]? )",
        "calc()": "calc( <calc-sum> )",
        "calc-constant": "e|pi|infinity|-infinity|NaN",
        "calc-product": "<calc-value> ['*' <calc-value>|'/' <number>]*",
        "calc-size()": "calc-size( <calc-size-basis> , <calc-sum> )",
        "calc-size-basis": "<intrinsic-size-keyword>|<calc-size()>|any|<calc-sum>",
        "calc-sum": "<calc-product> [['+'|'-'] <calc-product>]*",
        "calc-value": "<number>|<dimension>|<percentage>|<calc-constant>|( <calc-sum> )",
        "cf-final-image": "<image>|<color>",
        "cf-mixing-image": "<percentage>?&&<image>",
        "circle()": "circle( <radial-size>? [at <position>]? )",
        "clamp()": "clamp( <calc-sum>#{3} )",
        "class-selector": "'.' <ident-token>",
        "clip-source": "<url>",
        "color": "<color-base>|currentColor|<system-color>|<device-cmyk()>|<light-dark()>|<-non-standard-color>",
        "color()": "color( <colorspace-params> [/ [<alpha-value>|none]]? )",
        "color-base": "<hex-color>|<color-function>|<named-color>|<color-mix()>|transparent",
        "color-function": "<rgb()>|<rgba()>|<hsl()>|<hsla()>|<hwb()>|<lab()>|<lch()>|<oklab()>|<oklch()>|<color()>",
        "color-interpolation-method": "in [<rectangular-color-space>|<polar-color-space> <hue-interpolation-method>?|<custom-color-space>]",
        "color-mix()": "color-mix( <color-interpolation-method> , [<color>&&<percentage [0,100]>?]#{2} )",
        "color-stop": "<color-stop-length>|<color-stop-angle>",
        "color-stop-angle": "[<angle-percentage>|<zero>]{1,2}",
        "color-stop-length": "<length-percentage>{1,2}",
        "color-stop-list": "<linear-color-stop> , [<linear-color-hint>? , <linear-color-stop>]#?",
        "colorspace-params": "[<predefined-rgb-params>|<xyz-params>]",
        "combinator": "'>'|'+'|'~'|['|' '|']",
        "common-lig-values": "[common-ligatures|no-common-ligatures]",
        "compat-auto": "searchfield|textarea|push-button|slider-horizontal|checkbox|radio|square-button|menulist|listbox|meter|progress-bar|button",
        "complex-selector": "<complex-selector-unit> [<combinator>? <complex-selector-unit>]*",
        "complex-selector-list": "<complex-selector>#",
        "composite-style": "clear|copy|source-over|source-in|source-out|source-atop|destination-over|destination-in|destination-out|destination-atop|xor",
        "compositing-operator": "add|subtract|intersect|exclude",
        "compound-selector": "[<type-selector>? <subclass-selector>*]!",
        "compound-selector-list": "<compound-selector>#",
        "conic-gradient()": "conic-gradient( [<conic-gradient-syntax>] )",
        "conic-gradient-syntax": "[[[from [<angle>|<zero>]]? [at <position>]?]||<color-interpolation-method>]? , <angular-color-stop-list>",
        "container-condition": "not <query-in-parens>|<query-in-parens> [[and <query-in-parens>]*|[or <query-in-parens>]*]",
        "container-name": "<custom-ident>",
        "container-query": "not <query-in-parens>|<query-in-parens> [[and <query-in-parens>]*|[or <query-in-parens>]*]",
        "content-distribution": "space-between|space-around|space-evenly|stretch",
        "content-list": "[<string>|contents|<image>|<counter>|<quote>|<target>|<leader()>|<attr()>]+",
        "content-position": "center|start|end|flex-start|flex-end",
        "content-replacement": "<image>",
        "contextual-alt-values": "[contextual|no-contextual]",
        "contrast()": "contrast( [<number>|<percentage>]? )",
        "coord-box": "content-box|padding-box|border-box|fill-box|stroke-box|view-box",
        "cos()": "cos( <calc-sum> )",
        "counter": "<counter()>|<counters()>",
        "counter()": "counter( <counter-name> , <counter-style>? )",
        "counter-name": "<custom-ident>",
        "counter-style": "<counter-style-name>|symbols( )",
        "counter-style-name": "<custom-ident>",
        "counters()": "counters( <counter-name> , <string> , <counter-style>? )",
        "cross-fade()": "cross-fade( <cf-mixing-image> , <cf-final-image>? )",
        "cubic-bezier()": "cubic-bezier( [<number [0,1]> , <number>]#{2} )",
        "cubic-bezier-timing-function": "ease|ease-in|ease-out|ease-in-out|<cubic-bezier()>",
        "custom-color-space": "<dashed-ident>",
        "custom-params": "<dashed-ident> [<number>|<percentage>|none]+",
        "dasharray": "[[<length-percentage>|<number>]+]#",
        "dashndashdigit-ident": "<ident-token>",
        "deprecated-system-color": "ActiveBorder|ActiveCaption|AppWorkspace|Background|ButtonHighlight|ButtonShadow|CaptionText|InactiveBorder|InactiveCaption|InactiveCaptionText|InfoBackground|InfoText|Menu|MenuText|Scrollbar|ThreeDDarkShadow|ThreeDFace|ThreeDHighlight|ThreeDLightShadow|ThreeDShadow|Window|WindowFrame|WindowText",
        "discretionary-lig-values": "[discretionary-ligatures|no-discretionary-ligatures]",
        "display-box": "contents|none",
        "display-inside": "flow|flow-root|table|flex|grid|ruby",
        "display-internal": "table-row-group|table-header-group|table-footer-group|table-row|table-cell|table-column-group|table-column|table-caption|ruby-base|ruby-text|ruby-base-container|ruby-text-container",
        "display-legacy": "inline-block|inline-list-item|inline-table|inline-flex|inline-grid",
        "display-listitem": "<display-outside>?&&[flow|flow-root]?&&list-item",
        "display-outside": "block|inline|run-in",
        "drop-shadow()": "drop-shadow( [<color>?&&<length>{2,3}] )",
        "easing-function": "<linear-easing-function>|<cubic-bezier-easing-function>|<step-easing-function>",
        "east-asian-variant-values": "[jis78|jis83|jis90|jis04|simplified|traditional]",
        "east-asian-width-values": "[full-width|proportional-width]",
        "element()": "element( <custom-ident> , [first|start|last|first-except]? )|element( <id-selector> )",
        "ellipse()": "ellipse( <radial-size>? [at <position>]? )",
        "env()": "env( <custom-ident> , <declaration-value>? )",
        "exp()": "exp( <calc-sum> )",
        "explicit-track-list": "[<line-names>? <track-size>]+ <line-names>?",
        "family-name": "<string>|<custom-ident>+",
        "feature-tag-value": "<string> [<integer>|on|off]?",
        "feature-type": "@stylistic|@historical-forms|@styleset|@character-variant|@swash|@ornaments|@annotation",
        "feature-value-block": "<feature-type> '{' <feature-value-declaration-list> '}'",
        "feature-value-block-list": "<feature-value-block>+",
        "feature-value-declaration": "<custom-ident> : <integer>+ ;",
        "feature-value-declaration-list": "<feature-value-declaration>",
        "feature-value-name": "<custom-ident>",
        "filter-function": "<blur()>|<brightness()>|<contrast()>|<drop-shadow()>|<grayscale()>|<hue-rotate()>|<invert()>|<opacity()>|<saturate()>|<sepia()>",
        "filter-value-list": "[<filter-function>|<url>]+",
        "final-bg-layer": "<'background-color'>||<bg-image>||<bg-position> [/ <bg-size>]?||<repeat-style>||<attachment>||<visual-box>||<visual-box>",
        "fit-content()": "fit-content( <length-percentage [0,∞]> )",
        "fixed-breadth": "<length-percentage>",
        "fixed-repeat": "repeat( [<integer [1,∞]>] , [<line-names>? <fixed-size>]+ <line-names>? )",
        "fixed-size": "<fixed-breadth>|minmax( <fixed-breadth> , <track-breadth> )|minmax( <inflexible-breadth> , <fixed-breadth> )",
        "font-stretch-absolute": "normal|ultra-condensed|extra-condensed|condensed|semi-condensed|semi-expanded|expanded|extra-expanded|ultra-expanded|<percentage>",
        "font-variant-css21": "[normal|small-caps]",
        "font-weight-absolute": "normal|bold|<number [1,1000]>",
        "form-control-identifier": "select",
        "frequency-percentage": "<frequency>|<percentage>",
        "generic-complete": "serif|sans-serif|system-ui|cursive|fantasy|math|monospace",
        "general-enclosed": "[<function-token> <any-value>? )]|[( <any-value>? )]",
        "generic-family": "<generic-script-specific>|<generic-complete>|<generic-incomplete>|<-non-standard-generic-family>",
        "generic-incomplete": "ui-serif|ui-sans-serif|ui-monospace|ui-rounded",
        "geometry-box": "<shape-box>|fill-box|stroke-box|view-box",
        "gradient": "<linear-gradient()>|<repeating-linear-gradient()>|<radial-gradient()>|<repeating-radial-gradient()>|<conic-gradient()>|<repeating-conic-gradient()>|<-legacy-gradient>",
        "grayscale()": "grayscale( [<number>|<percentage>]? )",
        "grid-line": "auto|<custom-ident>|[<integer>&&<custom-ident>?]|[span&&[<integer>||<custom-ident>]]",
        "historical-lig-values": "[historical-ligatures|no-historical-ligatures]",
        "hsl()": "hsl( <hue> , <percentage> , <percentage> , <alpha-value>? )|hsl( [<hue>|none] [<percentage>|<number>|none] [<percentage>|<number>|none] [/ [<alpha-value>|none]]? )",
        "hsla()": "hsla( <hue> , <percentage> , <percentage> , <alpha-value>? )|hsla( [<hue>|none] [<percentage>|<number>|none] [<percentage>|<number>|none] [/ [<alpha-value>|none]]? )",
        "hue": "<number>|<angle>",
        "hue-interpolation-method": "[shorter|longer|increasing|decreasing] hue",
        "hue-rotate()": "hue-rotate( [<angle>|<zero>]? )",
        "hwb()": "hwb( [<hue>|none] [<percentage>|<number>|none] [<percentage>|<number>|none] [/ [<alpha-value>|none]]? )",
        "hypot()": "hypot( <calc-sum># )",
        "image": "<url>|<image()>|<image-set()>|<element()>|<paint()>|<cross-fade()>|<gradient>",
        "image()": "image( <image-tags>? [<image-src>? , <color>?]! )",
        "image-set()": "image-set( <image-set-option># )",
        "image-set-option": "[<image>|<string>] [<resolution>||type( <string> )]",
        "image-src": "<url>|<string>",
        "image-tags": "ltr|rtl",
        "inflexible-breadth": "<length-percentage>|min-content|max-content|auto",
        "inset()": "inset( <length-percentage>{1,4} [round <'border-radius'>]? )",
        "invert()": "invert( [<number>|<percentage>]? )",
        "keyframe-block": "<keyframe-selector># { <declaration-list> }",
        "keyframe-selector": "from|to|<percentage [0,100]>|<timeline-range-name> <percentage>",
        "keyframes-name": "<custom-ident>|<string>",
        "lab()": "lab( [<percentage>|<number>|none] [<percentage>|<number>|none] [<percentage>|<number>|none] [/ [<alpha-value>|none]]? )",
        "layer()": "layer( <layer-name> )",
        "layer-name": "<ident> ['.' <ident>]*",
        "lch()": "lch( [<percentage>|<number>|none] [<percentage>|<number>|none] [<hue>|none] [/ [<alpha-value>|none]]? )",
        "leader()": "leader( <leader-type> )",
        "leader-type": "dotted|solid|space|<string>",
        "length-percentage": "<length>|<percentage>",
        "light-dark()": "light-dark( <color> , <color> )",
        "line-name-list": "[<line-names>|<name-repeat>]+",
        "line-names": "'[' <custom-ident>* ']'",
        "line-style": "none|hidden|dotted|dashed|solid|double|groove|ridge|inset|outset",
        "line-width": "<length>|thin|medium|thick",
        "linear()": "linear( [<number>&&<percentage>{0,2}]# )",
        "linear-color-hint": "<length-percentage>",
        "linear-color-stop": "<color> <color-stop-length>?",
        "linear-easing-function": "linear|<linear()>",
        "linear-gradient()": "linear-gradient( [<linear-gradient-syntax>] )",
        "linear-gradient-syntax": "[[<angle>|<zero>|to <side-or-corner>]||<color-interpolation-method>]? , <color-stop-list>",
        "log()": "log( <calc-sum> , <calc-sum>? )",
        "mask-layer": "<mask-reference>||<position> [/ <bg-size>]?||<repeat-style>||<geometry-box>||[<geometry-box>|no-clip]||<compositing-operator>||<masking-mode>",
        "mask-position": "[<length-percentage>|left|center|right] [<length-percentage>|top|center|bottom]?",
        "mask-reference": "none|<image>|<mask-source>",
        "mask-source": "<url>",
        "masking-mode": "alpha|luminance|match-source",
        "matrix()": "matrix( <number>#{6} )",
        "matrix3d()": "matrix3d( <number>#{16} )",
        "max()": "max( <calc-sum># )",
        "media-and": "<media-in-parens> [and <media-in-parens>]+",
        "media-condition": "<media-not>|<media-and>|<media-or>|<media-in-parens>",
        "media-condition-without-or": "<media-not>|<media-and>|<media-in-parens>",
        "media-feature": "( [<mf-plain>|<mf-boolean>|<mf-range>] )",
        "media-in-parens": "( <media-condition> )|<media-feature>|<general-enclosed>",
        "media-not": "not <media-in-parens>",
        "media-or": "<media-in-parens> [or <media-in-parens>]+",
        "media-query": "<media-condition>|[not|only]? <media-type> [and <media-condition-without-or>]?",
        "media-query-list": "<media-query>#",
        "media-type": "<ident>",
        "mf-boolean": "<mf-name>",
        "mf-name": "<ident>",
        "mf-plain": "<mf-name> : <mf-value>",
        "mf-range": "<mf-name> ['<'|'>']? '='? <mf-value>|<mf-value> ['<'|'>']? '='? <mf-name>|<mf-value> '<' '='? <mf-name> '<' '='? <mf-value>|<mf-value> '>' '='? <mf-name> '>' '='? <mf-value>",
        "mf-value": "<number>|<dimension>|<ident>|<ratio>",
        "min()": "min( <calc-sum># )",
        "minmax()": "minmax( [<length-percentage>|min-content|max-content|auto] , [<length-percentage>|<flex>|min-content|max-content|auto] )",
        "mod()": "mod( <calc-sum> , <calc-sum> )",
        "n-dimension": "<dimension-token>",
        "name-repeat": "repeat( [<integer [1,∞]>|auto-fill] , <line-names>+ )",
        "named-color": "aliceblue|antiquewhite|aqua|aquamarine|azure|beige|bisque|black|blanchedalmond|blue|blueviolet|brown|burlywood|cadetblue|chartreuse|chocolate|coral|cornflowerblue|cornsilk|crimson|cyan|darkblue|darkcyan|darkgoldenrod|darkgray|darkgreen|darkgrey|darkkhaki|darkmagenta|darkolivegreen|darkorange|darkorchid|darkred|darksalmon|darkseagreen|darkslateblue|darkslategray|darkslategrey|darkturquoise|darkviolet|deeppink|deepskyblue|dimgray|dimgrey|dodgerblue|firebrick|floralwhite|forestgreen|fuchsia|gainsboro|ghostwhite|gold|goldenrod|gray|green|greenyellow|grey|honeydew|hotpink|indianred|indigo|ivory|khaki|lavender|lavenderblush|lawngreen|lemonchiffon|lightblue|lightcoral|lightcyan|lightgoldenrodyellow|lightgray|lightgreen|lightgrey|lightpink|lightsalmon|lightseagreen|lightskyblue|lightslategray|lightslategrey|lightsteelblue|lightyellow|lime|limegreen|linen|magenta|maroon|mediumaquamarine|mediumblue|mediumorchid|mediumpurple|mediumseagreen|mediumslateblue|mediumspringgreen|mediumturquoise|mediumvioletred|midnightblue|mintcream|mistyrose|moccasin|navajowhite|navy|oldlace|olive|olivedrab|orange|orangered|orchid|palegoldenrod|palegreen|paleturquoise|palevioletred|papayawhip|peachpuff|peru|pink|plum|powderblue|purple|rebeccapurple|red|rosybrown|royalblue|saddlebrown|salmon|sandybrown|seagreen|seashell|sienna|silver|skyblue|slateblue|slategray|slategrey|snow|springgreen|steelblue|tan|teal|thistle|tomato|turquoise|violet|wheat|white|whitesmoke|yellow|yellowgreen",
        "namespace-prefix": "<ident>",
        "ndash-dimension": "<dimension-token>",
        "ndashdigit-dimension": "<dimension-token>",
        "ndashdigit-ident": "<ident-token>",
        "ns-prefix": "[<ident-token>|'*']? '|'",
        "number-percentage": "<number>|<percentage>",
        "numeric-figure-values": "[lining-nums|oldstyle-nums]",
        "numeric-fraction-values": "[diagonal-fractions|stacked-fractions]",
        "numeric-spacing-values": "[proportional-nums|tabular-nums]",
        "offset-path": "<ray()>|<url>|<basic-shape>",
        "oklab()": "oklab( [<percentage>|<number>|none] [<percentage>|<number>|none] [<percentage>|<number>|none] [/ [<alpha-value>|none]]? )",
        "oklch()": "oklch( [<percentage>|<number>|none] [<percentage>|<number>|none] [<hue>|none] [/ [<alpha-value>|none]]? )",
        "opacity()": "opacity( [<number>|<percentage>]? )",
        "opacity-value": "<number>|<percentage>",
        "outline-line-style": "none|dotted|dashed|solid|double|groove|ridge|inset|outset",
        "outline-radius": "<length>|<percentage>",
        "overflow-position": "unsafe|safe",
        "page-body": "<declaration>? [; <page-body>]?|<page-margin-box> <page-body>",
        "page-margin-box": "<page-margin-box-type> '{' <declaration-list> '}'",
        "page-margin-box-type": "@top-left-corner|@top-left|@top-center|@top-right|@top-right-corner|@bottom-left-corner|@bottom-left|@bottom-center|@bottom-right|@bottom-right-corner|@left-top|@left-middle|@left-bottom|@right-top|@right-middle|@right-bottom",
        "page-selector": "<pseudo-page>+|<ident> <pseudo-page>*",
        "page-selector-list": "[<page-selector>#]?",
        "page-size": "A5|A4|A3|B5|B4|JIS-B5|JIS-B4|letter|legal|ledger",
        "paint": "none|<color>|<url> [none|<color>]?|context-fill|context-stroke",
        "paint()": "paint( <ident> , <declaration-value>? )",
        "paint-box": "<visual-box>|fill-box|stroke-box",
        "palette-identifier": "<dashed-ident>",
        "palette-mix()": "palette-mix( <color-interpolation-method> , [[normal|light|dark|<palette-identifier>|<palette-mix()>]&&<percentage [0,100]>?]#{2} )",
        "path()": "path( <'fill-rule'>? , <string> )",
        "perspective()": "perspective( [<length [0,∞]>|none] )",
        "polar-color-space": "hsl|hwb|lch|oklch",
        "polygon()": "polygon( <'fill-rule'>? , [<length-percentage> <length-percentage>]# )",
        "position": "[[left|center|right]||[top|center|bottom]|[left|center|right|<length-percentage>] [top|center|bottom|<length-percentage>]?|[[left|right] <length-percentage>]&&[[top|bottom] <length-percentage>]]",
        "position-area": "[[left|center|right|span-left|span-right|x-start|x-end|span-x-start|span-x-end|x-self-start|x-self-end|span-x-self-start|span-x-self-end|span-all]||[top|center|bottom|span-top|span-bottom|y-start|y-end|span-y-start|span-y-end|y-self-start|y-self-end|span-y-self-start|span-y-self-end|span-all]|[block-start|center|block-end|span-block-start|span-block-end|span-all]||[inline-start|center|inline-end|span-inline-start|span-inline-end|span-all]|[self-block-start|center|self-block-end|span-self-block-start|span-self-block-end|span-all]||[self-inline-start|center|self-inline-end|span-self-inline-start|span-self-inline-end|span-all]|[start|center|end|span-start|span-end|span-all]{1,2}|[self-start|center|self-end|span-self-start|span-self-end|span-all]{1,2}]",
        "pow()": "pow( <calc-sum> , <calc-sum> )",
        "predefined-rgb": "srgb|srgb-linear|display-p3|a98-rgb|prophoto-rgb|rec2020",
        "predefined-rgb-params": "<predefined-rgb> [<number>|<percentage>|none]{3}",
        "pseudo-class-selector": "':' <ident-token>|':' <function-token> <any-value> ')'",
        "pseudo-element-selector": "':' <pseudo-class-selector>|<legacy-pseudo-element-selector>",
        "pseudo-page": ": [left|right|first|blank]",
        "query-in-parens": "( <container-condition> )|( <size-feature> )|style( <style-query> )|<general-enclosed>",
        "quote": "open-quote|close-quote|no-open-quote|no-close-quote",
        "radial-extent": "closest-corner|closest-side|farthest-corner|farthest-side",
        "radial-gradient()": "radial-gradient( [<radial-gradient-syntax>] )",
        "radial-gradient-syntax": "[[[<radial-shape>||<radial-size>]? [at <position>]?]||<color-interpolation-method>]? , <color-stop-list>",
        "radial-shape": "circle|ellipse",
        "radial-size": "<radial-extent>|<length [0,∞]>|<length-percentage [0,∞]>{2}",
        "ratio": "<number [0,∞]> [/ <number [0,∞]>]?",
        "ray()": "ray( <angle>&&<ray-size>?&&contain?&&[at <position>]? )",
        "ray-size": "closest-side|closest-corner|farthest-side|farthest-corner|sides",
        "rect()": "rect( [<length-percentage>|auto]{4} [round <'border-radius'>]? )",
        "rectangular-color-space": "srgb|srgb-linear|display-p3|a98-rgb|prophoto-rgb|rec2020|lab|oklab|xyz|xyz-d50|xyz-d65",
        "relative-selector": "<combinator>? <complex-selector>",
        "relative-selector-list": "<relative-selector>#",
        "relative-size": "larger|smaller",
        "rem()": "rem( <calc-sum> , <calc-sum> )",
        "repeat-style": "repeat-x|repeat-y|[repeat|space|round|no-repeat]{1,2}",
        "repeating-conic-gradient()": "repeating-conic-gradient( [<conic-gradient-syntax>] )",
        "repeating-linear-gradient()": "repeating-linear-gradient( [<linear-gradient-syntax>] )",
        "repeating-radial-gradient()": "repeating-radial-gradient( [<radial-gradient-syntax>] )",
        "reversed-counter-name": "reversed( <counter-name> )",
        "rgb()": "rgb( <percentage>#{3} , <alpha-value>? )|rgb( <number>#{3} , <alpha-value>? )|rgb( [<number>|<percentage>|none]{3} [/ [<alpha-value>|none]]? )",
        "rgba()": "rgba( <percentage>#{3} , <alpha-value>? )|rgba( <number>#{3} , <alpha-value>? )|rgba( [<number>|<percentage>|none]{3} [/ [<alpha-value>|none]]? )",
        "rotate()": "rotate( [<angle>|<zero>] )",
        "rotate3d()": "rotate3d( <number> , <number> , <number> , [<angle>|<zero>] )",
        "rotateX()": "rotateX( [<angle>|<zero>] )",
        "rotateY()": "rotateY( [<angle>|<zero>] )",
        "rotateZ()": "rotateZ( [<angle>|<zero>] )",
        "round()": "round( <rounding-strategy>? , <calc-sum> , <calc-sum> )",
        "rounding-strategy": "nearest|up|down|to-zero",
        "saturate()": "saturate( [<number>|<percentage>]? )",
        "scale()": "scale( [<number>|<percentage>]#{1,2} )",
        "scale3d()": "scale3d( [<number>|<percentage>]#{3} )",
        "scaleX()": "scaleX( [<number>|<percentage>] )",
        "scaleY()": "scaleY( [<number>|<percentage>] )",
        "scaleZ()": "scaleZ( [<number>|<percentage>] )",
        "scope-end": "<forgiving-selector-list>",
        "scope-start": "<forgiving-selector-list>",
        "scroll()": "scroll( [<scroller>||<axis>]? )",
        "scroller": "root|nearest|self",
        "scroll-state-feature": "<media-query-list>",
        "scroll-state-in-parens": "( <scroll-state-query> )|( <scroll-state-feature> )|<general-enclosed>",
        "scroll-state-query": "not <scroll-state-in-parens>|<scroll-state-in-parens> [[and <scroll-state-in-parens>]*|[or <scroll-state-in-parens>]*]|<scroll-state-feature>",
        "selector-list": "<complex-selector-list>",
        "self-position": "center|start|end|self-start|self-end|flex-start|flex-end",
        "sepia()": "sepia( [<number>|<percentage>]? )",
        "shadow": "inset?&&<length>{2,4}&&<color>?",
        "shadow-t": "[<length>{2,3}&&<color>?]",
        "shape": "rect( <top> , <right> , <bottom> , <left> )|rect( <top> <right> <bottom> <left> )",
        "shape-box": "<visual-box>|margin-box",
        "side-or-corner": "[left|right]||[top|bottom]",
        "sign()": "sign( <calc-sum> )",
        "signed-integer": "<number-token>",
        "signless-integer": "<number-token>",
        "sin()": "sin( <calc-sum> )",
        "single-animation": "<'animation-duration'>||<easing-function>||<'animation-delay'>||<single-animation-iteration-count>||<single-animation-direction>||<single-animation-fill-mode>||<single-animation-play-state>||[none|<keyframes-name>]||<single-animation-timeline>",
        "single-animation-composition": "replace|add|accumulate",
        "single-animation-direction": "normal|reverse|alternate|alternate-reverse",
        "single-animation-fill-mode": "none|forwards|backwards|both",
        "single-animation-iteration-count": "infinite|<number>",
        "single-animation-play-state": "running|paused",
        "single-animation-timeline": "auto|none|<dashed-ident>|<scroll()>|<view()>",
        "single-transition": "[none|<single-transition-property>]||<time>||<easing-function>||<time>||<transition-behavior-value>",
        "single-transition-property": "all|<custom-ident>",
        "size": "closest-side|farthest-side|closest-corner|farthest-corner|<length>|<length-percentage>{2}",
        "size-feature": "<mf-plain>|<mf-boolean>|<mf-range>",
        "skew()": "skew( [<angle>|<zero>] , [<angle>|<zero>]? )",
        "skewX()": "skewX( [<angle>|<zero>] )",
        "skewY()": "skewY( [<angle>|<zero>] )",
        "sqrt()": "sqrt( <calc-sum> )",
        "step-position": "jump-start|jump-end|jump-none|jump-both|start|end",
        "step-easing-function": "step-start|step-end|<steps()>",
        "steps()": "steps( <integer> , <step-position>? )",
        "style-feature": "<declaration>",
        "style-in-parens": "( <style-condition> )|( <style-feature> )|<general-enclosed>",
        "style-query": "<style-condition>|<style-feature>",
        "subclass-selector": "<id-selector>|<class-selector>|<attribute-selector>|<pseudo-class-selector>",
        "supports-condition": "not <supports-in-parens>|<supports-in-parens> [and <supports-in-parens>]*|<supports-in-parens> [or <supports-in-parens>]*",
        "supports-decl": "( <declaration> )",
        "supports-feature": "<supports-decl>|<supports-selector-fn>",
        "supports-in-parens": "( <supports-condition> )|<supports-feature>|<general-enclosed>",
        "supports-selector-fn": "selector( <complex-selector> )",
        "symbol": "<string>|<image>|<custom-ident>",
        "symbols()": "symbols( <symbols-type>? [<string>|<image>]+ )",
        "symbols-type": "cyclic|numeric|alphabetic|symbolic|fixed",
        "system-color": "AccentColor|AccentColorText|ActiveText|ButtonBorder|ButtonFace|ButtonText|Canvas|CanvasText|Field|FieldText|GrayText|Highlight|HighlightText|LinkText|Mark|MarkText|SelectedItem|SelectedItemText|VisitedText",
        "tan()": "tan( <calc-sum> )",
        "target": "<target-counter()>|<target-counters()>|<target-text()>",
        "target-counter()": "target-counter( [<string>|<url>] , <custom-ident> , <counter-style>? )",
        "target-counters()": "target-counters( [<string>|<url>] , <custom-ident> , <string> , <counter-style>? )",
        "target-text()": "target-text( [<string>|<url>] , [content|before|after|first-letter]? )",
        "text-edge": "[text|cap|ex|ideographic|ideographic-ink] [text|alphabetic|ideographic|ideographic-ink]?",
        "time-percentage": "<time>|<percentage>",
        "timeline-range-name": "cover|contain|entry|exit|entry-crossing|exit-crossing",
        "track-breadth": "<length-percentage>|<flex>|min-content|max-content|auto",
        "track-list": "[<line-names>? [<track-size>|<track-repeat>]]+ <line-names>?",
        "track-repeat": "repeat( [<integer [1,∞]>] , [<line-names>? <track-size>]+ <line-names>? )",
        "track-size": "<track-breadth>|minmax( <inflexible-breadth> , <track-breadth> )|fit-content( <length-percentage> )",
        "transform-function": "<matrix()>|<translate()>|<translateX()>|<translateY()>|<scale()>|<scaleX()>|<scaleY()>|<rotate()>|<skew()>|<skewX()>|<skewY()>|<matrix3d()>|<translate3d()>|<translateZ()>|<scale3d()>|<scaleZ()>|<rotate3d()>|<rotateX()>|<rotateY()>|<rotateZ()>|<perspective()>",
        "transform-list": "<transform-function>+",
        "transition-behavior-value": "normal|allow-discrete",
        "translate()": "translate( <length-percentage> , <length-percentage>? )",
        "translate3d()": "translate3d( <length-percentage> , <length-percentage> , <length> )",
        "translateX()": "translateX( <length-percentage> )",
        "translateY()": "translateY( <length-percentage> )",
        "translateZ()": "translateZ( <length> )",
        "try-size": "most-width|most-height|most-block-size|most-inline-size",
        "try-tactic": "flip-block||flip-inline||flip-start",
        "type-or-unit": "string|color|url|integer|number|length|angle|time|frequency|cap|ch|em|ex|ic|lh|rlh|rem|vb|vi|vw|vh|vmin|vmax|mm|Q|cm|in|pt|pc|px|deg|grad|rad|turn|ms|s|Hz|kHz|%",
        "type-selector": "<wq-name>|<ns-prefix>? '*'",
        "var()": "var( <custom-property-name> , <declaration-value>? )",
        "view()": "view( [<axis>||<'view-timeline-inset'>]? )",
        "viewport-length": "auto|<length-percentage>",
        "visual-box": "content-box|padding-box|border-box",
        "wq-name": "<ns-prefix>? <ident-token>",
        "xywh()": "xywh( <length-percentage>{2} <length-percentage [0,∞]>{2} [round <'border-radius'>]? )",
        "xyz": "xyz|xyz-d50|xyz-d65",
        "xyz-params": "<xyz-space> [<number>|<percentage>|none]{3}",
        "-legacy-gradient": "<-webkit-gradient()>|<-legacy-linear-gradient>|<-legacy-repeating-linear-gradient>|<-legacy-radial-gradient>|<-legacy-repeating-radial-gradient>",
        "-legacy-linear-gradient": "-moz-linear-gradient( <-legacy-linear-gradient-arguments> )|-webkit-linear-gradient( <-legacy-linear-gradient-arguments> )|-o-linear-gradient( <-legacy-linear-gradient-arguments> )",
        "-legacy-repeating-linear-gradient": "-moz-repeating-linear-gradient( <-legacy-linear-gradient-arguments> )|-webkit-repeating-linear-gradient( <-legacy-linear-gradient-arguments> )|-o-repeating-linear-gradient( <-legacy-linear-gradient-arguments> )",
        "-legacy-linear-gradient-arguments": "[<angle>|<side-or-corner>]? , <color-stop-list>",
        "-legacy-radial-gradient": "-moz-radial-gradient( <-legacy-radial-gradient-arguments> )|-webkit-radial-gradient( <-legacy-radial-gradient-arguments> )|-o-radial-gradient( <-legacy-radial-gradient-arguments> )",
        "-legacy-repeating-radial-gradient": "-moz-repeating-radial-gradient( <-legacy-radial-gradient-arguments> )|-webkit-repeating-radial-gradient( <-legacy-radial-gradient-arguments> )|-o-repeating-radial-gradient( <-legacy-radial-gradient-arguments> )",
        "-legacy-radial-gradient-arguments": "[<position> ,]? [[[<-legacy-radial-gradient-shape>||<-legacy-radial-gradient-size>]|[<length>|<percentage>]{2}] ,]? <color-stop-list>",
        "-legacy-radial-gradient-size": "closest-side|closest-corner|farthest-side|farthest-corner|contain|cover",
        "-legacy-radial-gradient-shape": "circle|ellipse",
        "-non-standard-font": "-apple-system-body|-apple-system-headline|-apple-system-subheadline|-apple-system-caption1|-apple-system-caption2|-apple-system-footnote|-apple-system-short-body|-apple-system-short-headline|-apple-system-short-subheadline|-apple-system-short-caption1|-apple-system-short-footnote|-apple-system-tall-body",
        "-non-standard-color": "-moz-ButtonDefault|-moz-ButtonHoverFace|-moz-ButtonHoverText|-moz-CellHighlight|-moz-CellHighlightText|-moz-Combobox|-moz-ComboboxText|-moz-Dialog|-moz-DialogText|-moz-dragtargetzone|-moz-EvenTreeRow|-moz-Field|-moz-FieldText|-moz-html-CellHighlight|-moz-html-CellHighlightText|-moz-mac-accentdarkestshadow|-moz-mac-accentdarkshadow|-moz-mac-accentface|-moz-mac-accentlightesthighlight|-moz-mac-accentlightshadow|-moz-mac-accentregularhighlight|-moz-mac-accentregularshadow|-moz-mac-chrome-active|-moz-mac-chrome-inactive|-moz-mac-focusring|-moz-mac-menuselect|-moz-mac-menushadow|-moz-mac-menutextselect|-moz-MenuHover|-moz-MenuHoverText|-moz-MenuBarText|-moz-MenuBarHoverText|-moz-nativehyperlinktext|-moz-OddTreeRow|-moz-win-communicationstext|-moz-win-mediatext|-moz-activehyperlinktext|-moz-default-background-color|-moz-default-color|-moz-hyperlinktext|-moz-visitedhyperlinktext|-webkit-activelink|-webkit-focus-ring-color|-webkit-link|-webkit-text",
        "-non-standard-image-rendering": "optimize-contrast|-moz-crisp-edges|-o-crisp-edges|-webkit-optimize-contrast",
        "-non-standard-overflow": "overlay|-moz-scrollbars-none|-moz-scrollbars-horizontal|-moz-scrollbars-vertical|-moz-hidden-unscrollable",
        "-non-standard-size": "intrinsic|min-intrinsic|-webkit-fill-available|-webkit-fit-content|-webkit-min-content|-webkit-max-content|-moz-available|-moz-fit-content|-moz-min-content|-moz-max-content",
        "-webkit-gradient()": "-webkit-gradient( <-webkit-gradient-type> , <-webkit-gradient-point> [, <-webkit-gradient-point>|, <-webkit-gradient-radius> , <-webkit-gradient-point>] [, <-webkit-gradient-radius>]? [, <-webkit-gradient-color-stop>]* )",
        "-webkit-gradient-color-stop": "from( <color> )|color-stop( [<number-zero-one>|<percentage>] , <color> )|to( <color> )",
        "-webkit-gradient-point": "[left|center|right|<length-percentage>] [top|center|bottom|<length-percentage>]",
        "-webkit-gradient-radius": "<length>|<percentage>",
        "-webkit-gradient-type": "linear|radial",
        "-webkit-mask-box-repeat": "repeat|stretch|round",
        "-ms-filter-function-list": "<-ms-filter-function>+",
        "-ms-filter-function": "<-ms-filter-function-progid>|<-ms-filter-function-legacy>",
        "-ms-filter-function-progid": "'progid:' [<ident-token> '.']* [<ident-token>|<function-token> <any-value>? )]",
        "-ms-filter-function-legacy": "<ident-token>|<function-token> <any-value>? )",
        "age": "child|young|old",
        "attr-name": "<wq-name>",
        "attr-fallback": "<any-value>",
        "bottom": "<length>|auto",
        "cubic-bezier-easing-function": "ease|ease-in|ease-out|ease-in-out|cubic-bezier( <number [0,1]> , <number> , <number [0,1]> , <number> )",
        "generic-voice": "[<age>? <gender> <integer>?]",
        "gender": "male|female|neutral",
        "generic-script-specific": "generic( kai )|generic( fangsong )|generic( nastaliq )",
        "-non-standard-generic-family": "-apple-system|BlinkMacSystemFont",
        "intrinsic-size-keyword": "min-content|max-content|fit-content",
        "left": "<length>|auto",
        "device-cmyk()": "<legacy-device-cmyk-syntax>|<modern-device-cmyk-syntax>",
        "legacy-device-cmyk-syntax": "device-cmyk( <number>#{4} )",
        "modern-device-cmyk-syntax": "device-cmyk( <cmyk-component>{4} [/ [<alpha-value>|none]]? )",
        "cmyk-component": "<number>|<percentage>|none",
        "color-space": "<rectangular-color-space>|<polar-color-space>|<custom-color-space>",
        "right": "<length>|auto",
        "forgiving-selector-list": "<complex-real-selector-list>",
        "forgiving-relative-selector-list": "<relative-real-selector-list>",
        "complex-real-selector-list": "<complex-real-selector>#",
        "simple-selector-list": "<simple-selector>#",
        "relative-real-selector-list": "<relative-real-selector>#",
        "complex-selector-unit": "[<compound-selector>? <pseudo-compound-selector>*]!",
        "complex-real-selector": "<compound-selector> [<combinator>? <compound-selector>]*",
        "relative-real-selector": "<combinator>? <complex-real-selector>",
        "pseudo-compound-selector": "<pseudo-element-selector> <pseudo-class-selector>*",
        "simple-selector": "<type-selector>|<subclass-selector>",
        "legacy-pseudo-element-selector": "':' [before|after|first-line|first-letter]",
        "svg-length": "<percentage>|<length>|<number>",
        "svg-writing-mode": "lr-tb|rl-tb|tb-rl|lr|rl|tb",
        "top": "<length>|auto",
        "x": "<number>",
        "y": "<number>",
        "declaration": "<ident-token> : <declaration-value>? ['!' important]?",
        "declaration-list": "[<declaration>? ';']* <declaration>?",
        "url": "url( <string> <url-modifier>* )|<url-token>",
        "url-modifier": "<ident>|<function-token> <any-value> )",
        "number-zero-one": "<number [0,1]>",
        "number-one-or-greater": "<number [1,∞]>",
        "xyz-space": "xyz|xyz-d50|xyz-d65",
        "style-condition": "not <style-in-parens>|<style-in-parens> [[and <style-in-parens>]*|[or <style-in-parens>]*]",
        "-non-standard-display": "-ms-inline-flexbox|-ms-grid|-ms-inline-grid|-webkit-flex|-webkit-inline-flex|-webkit-box|-webkit-inline-box|-moz-inline-stack|-moz-box|-moz-inline-box",
        "inset-area": "[[left|center|right|span-left|span-right|x-start|x-end|span-x-start|span-x-end|x-self-start|x-self-end|span-x-self-start|span-x-self-end|span-all]||[top|center|bottom|span-top|span-bottom|y-start|y-end|span-y-start|span-y-end|y-self-start|y-self-end|span-y-self-start|span-y-self-end|span-all]|[block-start|center|block-end|span-block-start|span-block-end|span-all]||[inline-start|center|inline-end|span-inline-start|span-inline-end|span-all]|[self-block-start|self-block-end|span-self-block-start|span-self-block-end|span-all]||[self-inline-start|self-inline-end|span-self-inline-start|span-self-inline-end|span-all]|[start|center|end|span-start|span-end|span-all]{1,2}|[self-start|center|self-end|span-self-start|span-self-end|span-all]{1,2}]",
        "font-variant-css2": "normal|small-caps",
        "font-width-css3": "normal|ultra-condensed|extra-condensed|condensed|semi-condensed|semi-expanded|expanded|extra-expanded|ultra-expanded",
        "system-family-name": "caption|icon|menu|message-box|small-caption|status-bar"
    },
    "properties": {
        "--*": "<declaration-value>",
        "-ms-accelerator": "false|true",
        "-ms-block-progression": "tb|rl|bt|lr",
        "-ms-content-zoom-chaining": "none|chained",
        "-ms-content-zoom-limit": "<'-ms-content-zoom-limit-min'> <'-ms-content-zoom-limit-max'>",
        "-ms-content-zoom-limit-max": "<percentage>",
        "-ms-content-zoom-limit-min": "<percentage>",
        "-ms-content-zoom-snap": "<'-ms-content-zoom-snap-type'>||<'-ms-content-zoom-snap-points'>",
        "-ms-content-zoom-snap-points": "snapInterval( <percentage> , <percentage> )|snapList( <percentage># )",
        "-ms-content-zoom-snap-type": "none|proximity|mandatory",
        "-ms-content-zooming": "none|zoom",
        "-ms-filter": "<string>",
        "-ms-flow-from": "[none|<custom-ident>]#",
        "-ms-flow-into": "[none|<custom-ident>]#",
        "-ms-grid-columns": "none|<track-list>|<auto-track-list>",
        "-ms-grid-rows": "none|<track-list>|<auto-track-list>",
        "-ms-high-contrast-adjust": "auto|none",
        "-ms-hyphenate-limit-chars": "auto|<integer>{1,3}",
        "-ms-hyphenate-limit-lines": "no-limit|<integer>",
        "-ms-hyphenate-limit-zone": "<percentage>|<length>",
        "-ms-ime-align": "auto|after",
        "-ms-overflow-style": "auto|none|scrollbar|-ms-autohiding-scrollbar",
        "-ms-scroll-chaining": "chained|none",
        "-ms-scroll-limit": "<'-ms-scroll-limit-x-min'> <'-ms-scroll-limit-y-min'> <'-ms-scroll-limit-x-max'> <'-ms-scroll-limit-y-max'>",
        "-ms-scroll-limit-x-max": "auto|<length>",
        "-ms-scroll-limit-x-min": "<length>",
        "-ms-scroll-limit-y-max": "auto|<length>",
        "-ms-scroll-limit-y-min": "<length>",
        "-ms-scroll-rails": "none|railed",
        "-ms-scroll-snap-points-x": "snapInterval( <length-percentage> , <length-percentage> )|snapList( <length-percentage># )",
        "-ms-scroll-snap-points-y": "snapInterval( <length-percentage> , <length-percentage> )|snapList( <length-percentage># )",
        "-ms-scroll-snap-type": "none|proximity|mandatory",
        "-ms-scroll-snap-x": "<'-ms-scroll-snap-type'> <'-ms-scroll-snap-points-x'>",
        "-ms-scroll-snap-y": "<'-ms-scroll-snap-type'> <'-ms-scroll-snap-points-y'>",
        "-ms-scroll-translation": "none|vertical-to-horizontal",
        "-ms-scrollbar-3dlight-color": "<color>",
        "-ms-scrollbar-arrow-color": "<color>",
        "-ms-scrollbar-base-color": "<color>",
        "-ms-scrollbar-darkshadow-color": "<color>",
        "-ms-scrollbar-face-color": "<color>",
        "-ms-scrollbar-highlight-color": "<color>",
        "-ms-scrollbar-shadow-color": "<color>",
        "-ms-scrollbar-track-color": "<color>",
        "-ms-text-autospace": "none|ideograph-alpha|ideograph-numeric|ideograph-parenthesis|ideograph-space",
        "-ms-touch-select": "grippers|none",
        "-ms-user-select": "none|element|text",
        "-ms-wrap-flow": "auto|both|start|end|maximum|clear",
        "-ms-wrap-margin": "<length>",
        "-ms-wrap-through": "wrap|none",
        "-moz-appearance": "none|button|button-arrow-down|button-arrow-next|button-arrow-previous|button-arrow-up|button-bevel|button-focus|caret|checkbox|checkbox-container|checkbox-label|checkmenuitem|dualbutton|groupbox|listbox|listitem|menuarrow|menubar|menucheckbox|menuimage|menuitem|menuitemtext|menulist|menulist-button|menulist-text|menulist-textfield|menupopup|menuradio|menuseparator|meterbar|meterchunk|progressbar|progressbar-vertical|progresschunk|progresschunk-vertical|radio|radio-container|radio-label|radiomenuitem|range|range-thumb|resizer|resizerpanel|scale-horizontal|scalethumbend|scalethumb-horizontal|scalethumbstart|scalethumbtick|scalethumb-vertical|scale-vertical|scrollbarbutton-down|scrollbarbutton-left|scrollbarbutton-right|scrollbarbutton-up|scrollbarthumb-horizontal|scrollbarthumb-vertical|scrollbartrack-horizontal|scrollbartrack-vertical|searchfield|separator|sheet|spinner|spinner-downbutton|spinner-textfield|spinner-upbutton|splitter|statusbar|statusbarpanel|tab|tabpanel|tabpanels|tab-scroll-arrow-back|tab-scroll-arrow-forward|textfield|textfield-multiline|toolbar|toolbarbutton|toolbarbutton-dropdown|toolbargripper|toolbox|tooltip|treeheader|treeheadercell|treeheadersortarrow|treeitem|treeline|treetwisty|treetwistyopen|treeview|-moz-mac-unified-toolbar|-moz-win-borderless-glass|-moz-win-browsertabbar-toolbox|-moz-win-communicationstext|-moz-win-communications-toolbox|-moz-win-exclude-glass|-moz-win-glass|-moz-win-mediatext|-moz-win-media-toolbox|-moz-window-button-box|-moz-window-button-box-maximized|-moz-window-button-close|-moz-window-button-maximize|-moz-window-button-minimize|-moz-window-button-restore|-moz-window-frame-bottom|-moz-window-frame-left|-moz-window-frame-right|-moz-window-titlebar|-moz-window-titlebar-maximized",
        "-moz-binding": "<url>|none",
        "-moz-border-bottom-colors": "<color>+|none",
        "-moz-border-left-colors": "<color>+|none",
        "-moz-border-right-colors": "<color>+|none",
        "-moz-border-top-colors": "<color>+|none",
        "-moz-context-properties": "none|[fill|fill-opacity|stroke|stroke-opacity]#",
        "-moz-float-edge": "border-box|content-box|margin-box|padding-box",
        "-moz-force-broken-image-icon": "0|1",
        "-moz-image-region": "<shape>|auto",
        "-moz-orient": "inline|block|horizontal|vertical",
        "-moz-outline-radius": "<outline-radius>{1,4} [/ <outline-radius>{1,4}]?",
        "-moz-outline-radius-bottomleft": "<outline-radius>",
        "-moz-outline-radius-bottomright": "<outline-radius>",
        "-moz-outline-radius-topleft": "<outline-radius>",
        "-moz-outline-radius-topright": "<outline-radius>",
        "-moz-stack-sizing": "ignore|stretch-to-fit",
        "-moz-text-blink": "none|blink",
        "-moz-user-focus": "ignore|normal|select-after|select-before|select-menu|select-same|select-all|none",
        "-moz-user-input": "auto|none|enabled|disabled",
        "-moz-user-modify": "read-only|read-write|write-only",
        "-moz-window-dragging": "drag|no-drag",
        "-moz-window-shadow": "default|menu|tooltip|sheet|none",
        "-webkit-appearance": "none|button|button-bevel|caps-lock-indicator|caret|checkbox|default-button|inner-spin-button|listbox|listitem|media-controls-background|media-controls-fullscreen-background|media-current-time-display|media-enter-fullscreen-button|media-exit-fullscreen-button|media-fullscreen-button|media-mute-button|media-overlay-play-button|media-play-button|media-seek-back-button|media-seek-forward-button|media-slider|media-sliderthumb|media-time-remaining-display|media-toggle-closed-captions-button|media-volume-slider|media-volume-slider-container|media-volume-sliderthumb|menulist|menulist-button|menulist-text|menulist-textfield|meter|progress-bar|progress-bar-value|push-button|radio|scrollbarbutton-down|scrollbarbutton-left|scrollbarbutton-right|scrollbarbutton-up|scrollbargripper-horizontal|scrollbargripper-vertical|scrollbarthumb-horizontal|scrollbarthumb-vertical|scrollbartrack-horizontal|scrollbartrack-vertical|searchfield|searchfield-cancel-button|searchfield-decoration|searchfield-results-button|searchfield-results-decoration|slider-horizontal|slider-vertical|sliderthumb-horizontal|sliderthumb-vertical|square-button|textarea|textfield|-apple-pay-button",
        "-webkit-border-before": "<'border-width'>||<'border-style'>||<color>",
        "-webkit-border-before-color": "<color>",
        "-webkit-border-before-style": "<'border-style'>",
        "-webkit-border-before-width": "<'border-width'>",
        "-webkit-box-reflect": "[above|below|right|left]? <length>? <image>?",
        "-webkit-line-clamp": "none|<integer>",
        "-webkit-mask": "[<mask-reference>||<position> [/ <bg-size>]?||<repeat-style>||[<visual-box>|border|padding|content|text]||[<visual-box>|border|padding|content]]#",
        "-webkit-mask-attachment": "<attachment>#",
        "-webkit-mask-clip": "[<coord-box>|no-clip|border|padding|content|text]#",
        "-webkit-mask-composite": "<composite-style>#",
        "-webkit-mask-image": "<mask-reference>#",
        "-webkit-mask-origin": "[<coord-box>|border|padding|content]#",
        "-webkit-mask-position": "<position>#",
        "-webkit-mask-position-x": "[<length-percentage>|left|center|right]#",
        "-webkit-mask-position-y": "[<length-percentage>|top|center|bottom]#",
        "-webkit-mask-repeat": "<repeat-style>#",
        "-webkit-mask-repeat-x": "repeat|no-repeat|space|round",
        "-webkit-mask-repeat-y": "repeat|no-repeat|space|round",
        "-webkit-mask-size": "<bg-size>#",
        "-webkit-overflow-scrolling": "auto|touch",
        "-webkit-tap-highlight-color": "<color>",
        "-webkit-text-fill-color": "<color>",
        "-webkit-text-stroke": "<length>||<color>",
        "-webkit-text-stroke-color": "<color>",
        "-webkit-text-stroke-width": "<length>",
        "-webkit-touch-callout": "default|none",
        "-webkit-user-modify": "read-only|read-write|read-write-plaintext-only",
        "-webkit-user-select": "auto|none|text|all",
        "accent-color": "auto|<color>",
        "align-content": "normal|<baseline-position>|<content-distribution>|<overflow-position>? <content-position>",
        "align-items": "normal|stretch|<baseline-position>|[<overflow-position>? <self-position>]",
        "align-self": "auto|normal|stretch|<baseline-position>|<overflow-position>? <self-position>",
        "align-tracks": "[normal|<baseline-position>|<content-distribution>|<overflow-position>? <content-position>]#",
        "alignment-baseline": "auto|baseline|before-edge|text-before-edge|middle|central|after-edge|text-after-edge|ideographic|alphabetic|hanging|mathematical",
        "all": "initial|inherit|unset|revert|revert-layer",
        "anchor-name": "none|<dashed-ident>#",
        "anchor-scope": "none|all|<dashed-ident>#",
        "animation": "<single-animation>#",
        "animation-composition": "<single-animation-composition>#",
        "animation-delay": "<time>#",
        "animation-direction": "<single-animation-direction>#",
        "animation-duration": "<time>#",
        "animation-fill-mode": "<single-animation-fill-mode>#",
        "animation-iteration-count": "<single-animation-iteration-count>#",
        "animation-name": "[none|<keyframes-name>]#",
        "animation-play-state": "<single-animation-play-state>#",
        "animation-range": "[<'animation-range-start'> <'animation-range-end'>?]#",
        "animation-range-end": "[normal|<length-percentage>|<timeline-range-name> <length-percentage>?]#",
        "animation-range-start": "[normal|<length-percentage>|<timeline-range-name> <length-percentage>?]#",
        "animation-timeline": "<single-animation-timeline>#",
        "animation-timing-function": "<easing-function>#",
        "appearance": "none|auto|textfield|menulist-button|<compat-auto>",
        "aspect-ratio": "auto||<ratio>",
        "backdrop-filter": "none|<filter-value-list>",
        "backface-visibility": "visible|hidden",
        "background": "[<bg-layer> ,]* <final-bg-layer>",
        "background-attachment": "<attachment>#",
        "background-blend-mode": "<blend-mode>#",
        "background-clip": "<bg-clip>#",
        "background-color": "<color>",
        "background-image": "<bg-image>#",
        "background-origin": "<visual-box>#",
        "background-position": "<bg-position>#",
        "background-position-x": "[center|[[left|right|x-start|x-end]? <length-percentage>?]!]#",
        "background-position-y": "[center|[[top|bottom|y-start|y-end]? <length-percentage>?]!]#",
        "background-repeat": "<repeat-style>#",
        "background-size": "<bg-size>#",
        "baseline-shift": "baseline|sub|super|<svg-length>",
        "block-size": "<'width'>",
        "border": "<line-width>||<line-style>||<color>",
        "border-block": "<'border-block-start'>",
        "border-block-color": "<'border-top-color'>{1,2}",
        "border-block-end": "<'border-top-width'>||<'border-top-style'>||<color>",
        "border-block-end-color": "<'border-top-color'>",
        "border-block-end-style": "<'border-top-style'>",
        "border-block-end-width": "<'border-top-width'>",
        "border-block-start": "<'border-top-width'>||<'border-top-style'>||<color>",
        "border-block-start-color": "<'border-top-color'>",
        "border-block-start-style": "<'border-top-style'>",
        "border-block-start-width": "<'border-top-width'>",
        "border-block-style": "<'border-top-style'>{1,2}",
        "border-block-width": "<'border-top-width'>{1,2}",
        "border-bottom": "<line-width>||<line-style>||<color>",
        "border-bottom-color": "<'border-top-color'>",
        "border-bottom-left-radius": "<length-percentage>{1,2}",
        "border-bottom-right-radius": "<length-percentage>{1,2}",
        "border-bottom-style": "<line-style>",
        "border-bottom-width": "<line-width>",
        "border-collapse": "collapse|separate",
        "border-color": "<color>{1,4}",
        "border-end-end-radius": "<'border-top-left-radius'>",
        "border-end-start-radius": "<'border-top-left-radius'>",
        "border-image": "<'border-image-source'>||<'border-image-slice'> [/ <'border-image-width'>|/ <'border-image-width'>? / <'border-image-outset'>]?||<'border-image-repeat'>",
        "border-image-outset": "[<length>|<number>]{1,4}",
        "border-image-repeat": "[stretch|repeat|round|space]{1,2}",
        "border-image-slice": "<number-percentage>{1,4}&&fill?",
        "border-image-source": "none|<image>",
        "border-image-width": "[<length-percentage>|<number>|auto]{1,4}",
        "border-inline": "<'border-block-start'>",
        "border-inline-color": "<'border-top-color'>{1,2}",
        "border-inline-end": "<'border-top-width'>||<'border-top-style'>||<color>",
        "border-inline-end-color": "<'border-top-color'>",
        "border-inline-end-style": "<'border-top-style'>",
        "border-inline-end-width": "<'border-top-width'>",
        "border-inline-start": "<'border-top-width'>||<'border-top-style'>||<color>",
        "border-inline-start-color": "<'border-top-color'>",
        "border-inline-start-style": "<'border-top-style'>",
        "border-inline-start-width": "<'border-top-width'>",
        "border-inline-style": "<'border-top-style'>{1,2}",
        "border-inline-width": "<'border-top-width'>{1,2}",
        "border-left": "<line-width>||<line-style>||<color>",
        "border-left-color": "<color>",
        "border-left-style": "<line-style>",
        "border-left-width": "<line-width>",
        "border-radius": "<length-percentage>{1,4} [/ <length-percentage>{1,4}]?",
        "border-right": "<line-width>||<line-style>||<color>",
        "border-right-color": "<color>",
        "border-right-style": "<line-style>",
        "border-right-width": "<line-width>",
        "border-spacing": "<length> <length>?",
        "border-start-end-radius": "<'border-top-left-radius'>",
        "border-start-start-radius": "<'border-top-left-radius'>",
        "border-style": "<line-style>{1,4}",
        "border-top": "<line-width>||<line-style>||<color>",
        "border-top-color": "<color>",
        "border-top-left-radius": "<length-percentage>{1,2}",
        "border-top-right-radius": "<length-percentage>{1,2}",
        "border-top-style": "<line-style>",
        "border-top-width": "<line-width>",
        "border-width": "<line-width>{1,4}",
        "bottom": "<length>|<percentage>|auto",
        "box-align": "start|center|end|baseline|stretch",
        "box-decoration-break": "slice|clone",
        "box-direction": "normal|reverse|inherit",
        "box-flex": "<number>",
        "box-flex-group": "<integer>",
        "box-lines": "single|multiple",
        "box-ordinal-group": "<integer>",
        "box-orient": "horizontal|vertical|inline-axis|block-axis|inherit",
        "box-pack": "start|center|end|justify",
        "box-shadow": "none|<shadow>#",
        "box-sizing": "content-box|border-box",
        "break-after": "auto|avoid|always|all|avoid-page|page|left|right|recto|verso|avoid-column|column|avoid-region|region",
        "break-before": "auto|avoid|always|all|avoid-page|page|left|right|recto|verso|avoid-column|column|avoid-region|region",
        "break-inside": "auto|avoid|avoid-page|avoid-column|avoid-region",
        "caption-side": "top|bottom",
        "caret": "<'caret-color'>||<'caret-shape'>",
        "caret-color": "auto|<color>",
        "caret-shape": "auto|bar|block|underscore",
        "clear": "none|left|right|both|inline-start|inline-end",
        "clip": "<shape>|auto",
        "clip-path": "<clip-source>|[<basic-shape>||<geometry-box>]|none",
        "clip-rule": "nonzero|evenodd",
        "color": "<color>",
        "color-interpolation-filters": "auto|sRGB|linearRGB",
        "color-scheme": "normal|[light|dark|<custom-ident>]+&&only?",
        "column-count": "<integer>|auto",
        "column-fill": "auto|balance",
        "column-gap": "normal|<length-percentage>",
        "column-rule": "<'column-rule-width'>||<'column-rule-style'>||<'column-rule-color'>",
        "column-rule-color": "<color>",
        "column-rule-style": "<'border-style'>",
        "column-rule-width": "<'border-width'>",
        "column-span": "none|all",
        "column-width": "<length>|auto",
        "columns": "<'column-width'>||<'column-count'>",
        "contain": "none|strict|content|[[size||inline-size]||layout||style||paint]",
        "contain-intrinsic-block-size": "auto? [none|<length>]",
        "contain-intrinsic-height": "auto? [none|<length>]",
        "contain-intrinsic-inline-size": "auto? [none|<length>]",
        "contain-intrinsic-size": "[auto? [none|<length>]]{1,2}",
        "contain-intrinsic-width": "auto? [none|<length>]",
        "container": "<'container-name'> [/ <'container-type'>]?",
        "container-name": "none|<custom-ident>+",
        "container-type": "normal|[[size|inline-size]||scroll-state]",
        "content": "normal|none|[<content-replacement>|<content-list>] [/ [<string>|<counter>]+]?",
        "content-visibility": "visible|auto|hidden",
        "counter-increment": "[<counter-name> <integer>?]+|none",
        "counter-reset": "[<counter-name> <integer>?|<reversed-counter-name> <integer>?]+|none",
        "counter-set": "[<counter-name> <integer>?]+|none",
        "cursor": "[[<url> [<x> <y>]? ,]* [auto|default|none|context-menu|help|pointer|progress|wait|cell|crosshair|text|vertical-text|alias|copy|move|no-drop|not-allowed|e-resize|n-resize|ne-resize|nw-resize|s-resize|se-resize|sw-resize|w-resize|ew-resize|ns-resize|nesw-resize|nwse-resize|col-resize|row-resize|all-scroll|zoom-in|zoom-out|grab|grabbing|hand|-webkit-grab|-webkit-grabbing|-webkit-zoom-in|-webkit-zoom-out|-moz-grab|-moz-grabbing|-moz-zoom-in|-moz-zoom-out]]",
        "cx": "<length>|<percentage>",
        "cy": "<length>|<percentage>",
        "d": "none|path( <string> )",
        "direction": "ltr|rtl",
        "display": "[<display-outside>||<display-inside>]|<display-listitem>|<display-internal>|<display-box>|<display-legacy>|<-non-standard-display>",
        "dominant-baseline": "auto|use-script|no-change|reset-size|ideographic|alphabetic|hanging|mathematical|central|middle|text-after-edge|text-before-edge",
        "empty-cells": "show|hide",
        "field-sizing": "content|fixed",
        "fill": "<paint>",
        "fill-opacity": "<number-zero-one>",
        "fill-rule": "nonzero|evenodd",
        "filter": "none|<filter-value-list>|<-ms-filter-function-list>",
        "flex": "none|[<'flex-grow'> <'flex-shrink'>?||<'flex-basis'>]",
        "flex-basis": "content|<'width'>",
        "flex-direction": "row|row-reverse|column|column-reverse",
        "flex-flow": "<'flex-direction'>||<'flex-wrap'>",
        "flex-grow": "<number>",
        "flex-shrink": "<number>",
        "flex-wrap": "nowrap|wrap|wrap-reverse",
        "float": "left|right|none|inline-start|inline-end",
        "flood-color": "<color>",
        "flood-opacity": "<'opacity'>",
        "font": "[[<'font-style'>||<font-variant-css2>||<'font-weight'>||<font-width-css3>]? <'font-size'> [/ <'line-height'>]? <'font-family'>#]|<system-family-name>|<-non-standard-font>",
        "font-family": "[<family-name>|<generic-family>]#",
        "font-feature-settings": "normal|<feature-tag-value>#",
        "font-kerning": "auto|normal|none",
        "font-language-override": "normal|<string>",
        "font-optical-sizing": "auto|none",
        "font-palette": "normal|light|dark|<palette-identifier>|<palette-mix()>",
        "font-size": "<absolute-size>|<relative-size>|<length-percentage [0,∞]>|math",
        "font-size-adjust": "none|[ex-height|cap-height|ch-width|ic-width|ic-height]? [from-font|<number>]",
        "font-smooth": "auto|never|always|<absolute-size>|<length>",
        "font-stretch": "<font-stretch-absolute>",
        "font-style": "normal|italic|oblique <angle>?",
        "font-synthesis": "none|[weight||style||small-caps||position]",
        "font-synthesis-position": "auto|none",
        "font-synthesis-small-caps": "auto|none",
        "font-synthesis-style": "auto|none",
        "font-synthesis-weight": "auto|none",
        "font-variant": "normal|none|[<common-lig-values>||<discretionary-lig-values>||<historical-lig-values>||<contextual-alt-values>||stylistic( <feature-value-name> )||historical-forms||styleset( <feature-value-name># )||character-variant( <feature-value-name># )||swash( <feature-value-name> )||ornaments( <feature-value-name> )||annotation( <feature-value-name> )||[small-caps|all-small-caps|petite-caps|all-petite-caps|unicase|titling-caps]||<numeric-figure-values>||<numeric-spacing-values>||<numeric-fraction-values>||ordinal||slashed-zero||<east-asian-variant-values>||<east-asian-width-values>||ruby]",
        "font-variant-alternates": "normal|[stylistic( <feature-value-name> )||historical-forms||styleset( <feature-value-name># )||character-variant( <feature-value-name># )||swash( <feature-value-name> )||ornaments( <feature-value-name> )||annotation( <feature-value-name> )]",
        "font-variant-caps": "normal|small-caps|all-small-caps|petite-caps|all-petite-caps|unicase|titling-caps",
        "font-variant-east-asian": "normal|[<east-asian-variant-values>||<east-asian-width-values>||ruby]",
        "font-variant-emoji": "normal|text|emoji|unicode",
        "font-variant-ligatures": "normal|none|[<common-lig-values>||<discretionary-lig-values>||<historical-lig-values>||<contextual-alt-values>]",
        "font-variant-numeric": "normal|[<numeric-figure-values>||<numeric-spacing-values>||<numeric-fraction-values>||ordinal||slashed-zero]",
        "font-variant-position": "normal|sub|super",
        "font-variation-settings": "normal|[<string> <number>]#",
        "font-weight": "<font-weight-absolute>|bolder|lighter",
        "forced-color-adjust": "auto|none|preserve-parent-color",
        "gap": "<'row-gap'> <'column-gap'>?",
        "grid": "<'grid-template'>|<'grid-template-rows'> / [auto-flow&&dense?] <'grid-auto-columns'>?|[auto-flow&&dense?] <'grid-auto-rows'>? / <'grid-template-columns'>",
        "grid-area": "<grid-line> [/ <grid-line>]{0,3}",
        "grid-auto-columns": "<track-size>+",
        "grid-auto-flow": "[row|column]||dense",
        "grid-auto-rows": "<track-size>+",
        "grid-column": "<grid-line> [/ <grid-line>]?",
        "grid-column-end": "<grid-line>",
        "grid-column-gap": "<length-percentage>",
        "grid-column-start": "<grid-line>",
        "grid-gap": "<'grid-row-gap'> <'grid-column-gap'>?",
        "grid-row": "<grid-line> [/ <grid-line>]?",
        "grid-row-end": "<grid-line>",
        "grid-row-gap": "<length-percentage>",
        "grid-row-start": "<grid-line>",
        "grid-template": "none|[<'grid-template-rows'> / <'grid-template-columns'>]|[<line-names>? <string> <track-size>? <line-names>?]+ [/ <explicit-track-list>]?",
        "grid-template-areas": "none|<string>+",
        "grid-template-columns": "none|<track-list>|<auto-track-list>|subgrid <line-name-list>?",
        "grid-template-rows": "none|<track-list>|<auto-track-list>|subgrid <line-name-list>?",
        "hanging-punctuation": "none|[first||[force-end|allow-end]||last]",
        "height": "auto|<length-percentage [0,∞]>|min-content|max-content|fit-content|fit-content( <length-percentage [0,∞]> )|<calc-size()>|<anchor-size()>|stretch|<-non-standard-size>",
        "hyphenate-character": "auto|<string>",
        "hyphenate-limit-chars": "[auto|<integer>]{1,3}",
        "hyphens": "none|manual|auto",
        "image-orientation": "from-image|<angle>|[<angle>? flip]",
        "image-rendering": "auto|crisp-edges|pixelated|smooth|optimizeSpeed|optimizeQuality|<-non-standard-image-rendering>",
        "image-resolution": "[from-image||<resolution>]&&snap?",
        "ime-mode": "auto|normal|active|inactive|disabled",
        "initial-letter": "normal|[<number> <integer>?]",
        "initial-letter-align": "[auto|alphabetic|hanging|ideographic]",
        "inline-size": "<'width'>",
        "inset": "<'top'>{1,4}",
        "inset-block": "<'top'>{1,2}",
        "inset-block-end": "<'top'>",
        "inset-block-start": "<'top'>",
        "inset-inline": "<'top'>{1,2}",
        "inset-inline-end": "<'top'>",
        "inset-inline-start": "<'top'>",
        "interpolate-size": "numeric-only|allow-keywords",
        "isolation": "auto|isolate",
        "justify-content": "normal|<content-distribution>|<overflow-position>? [<content-position>|left|right]",
        "justify-items": "normal|stretch|<baseline-position>|<overflow-position>? [<self-position>|left|right]|legacy|legacy&&[left|right|center]",
        "justify-self": "auto|normal|stretch|<baseline-position>|<overflow-position>? [<self-position>|left|right]",
        "justify-tracks": "[normal|<content-distribution>|<overflow-position>? [<content-position>|left|right]]#",
        "left": "<length>|<percentage>|auto",
        "letter-spacing": "normal|<length-percentage>",
        "lighting-color": "<color>",
        "line-break": "auto|loose|normal|strict|anywhere",
        "line-clamp": "none|<integer>",
        "line-height": "normal|<number>|<length>|<percentage>",
        "line-height-step": "<length>",
        "list-style": "<'list-style-type'>||<'list-style-position'>||<'list-style-image'>",
        "list-style-image": "<image>|none",
        "list-style-position": "inside|outside",
        "list-style-type": "<counter-style>|<string>|none",
        "margin": "<'margin-top'>{1,4}",
        "margin-block": "<'margin-top'>{1,2}",
        "margin-block-end": "<'margin-top'>",
        "margin-block-start": "<'margin-top'>",
        "margin-bottom": "<length-percentage>|auto",
        "margin-inline": "<'margin-top'>{1,2}",
        "margin-inline-end": "<'margin-top'>",
        "margin-inline-start": "<'margin-top'>",
        "margin-left": "<length-percentage>|auto",
        "margin-right": "<length-percentage>|auto",
        "margin-top": "<length-percentage>|auto",
        "margin-trim": "none|in-flow|all",
        "marker": "none|<url>",
        "marker-end": "none|<url>",
        "marker-mid": "none|<url>",
        "marker-start": "none|<url>",
        "mask": "<mask-layer>#",
        "mask-border": "<'mask-border-source'>||<'mask-border-slice'> [/ <'mask-border-width'>? [/ <'mask-border-outset'>]?]?||<'mask-border-repeat'>||<'mask-border-mode'>",
        "mask-border-mode": "luminance|alpha",
        "mask-border-outset": "[<length>|<number>]{1,4}",
        "mask-border-repeat": "[stretch|repeat|round|space]{1,2}",
        "mask-border-slice": "<number-percentage>{1,4} fill?",
        "mask-border-source": "none|<image>",
        "mask-border-width": "[<length-percentage>|<number>|auto]{1,4}",
        "mask-clip": "[<coord-box>|no-clip]#",
        "mask-composite": "<compositing-operator>#",
        "mask-image": "<mask-reference>#",
        "mask-mode": "<masking-mode>#",
        "mask-origin": "<coord-box>#",
        "mask-position": "<position>#",
        "mask-repeat": "<repeat-style>#",
        "mask-size": "<bg-size>#",
        "mask-type": "luminance|alpha",
        "masonry-auto-flow": "[pack|next]||[definite-first|ordered]",
        "math-depth": "auto-add|add( <integer> )|<integer>",
        "math-shift": "normal|compact",
        "math-style": "normal|compact",
        "max-block-size": "<'max-width'>",
        "max-height": "none|<length-percentage [0,∞]>|min-content|max-content|fit-content|fit-content( <length-percentage [0,∞]> )|<calc-size()>|<anchor-size()>|stretch|<-non-standard-size>",
        "max-inline-size": "<'max-width'>",
        "max-lines": "none|<integer>",
        "max-width": "none|<length-percentage [0,∞]>|min-content|max-content|fit-content|fit-content( <length-percentage [0,∞]> )|<calc-size()>|<anchor-size()>|stretch|<-non-standard-size>",
        "min-block-size": "<'min-width'>",
        "min-height": "auto|<length-percentage [0,∞]>|min-content|max-content|fit-content|fit-content( <length-percentage [0,∞]> )|<calc-size()>|<anchor-size()>|stretch|<-non-standard-size>",
        "min-inline-size": "<'min-width'>",
        "min-width": "auto|<length-percentage [0,∞]>|min-content|max-content|fit-content|fit-content( <length-percentage [0,∞]> )|<calc-size()>|<anchor-size()>|stretch|<-non-standard-size>",
        "mix-blend-mode": "<blend-mode>|plus-lighter",
        "object-fit": "fill|contain|cover|none|scale-down",
        "object-position": "<position>",
        "object-view-box": "none|<basic-shape-rect>",
        "offset": "[<'offset-position'>? [<'offset-path'> [<'offset-distance'>||<'offset-rotate'>]?]?]! [/ <'offset-anchor'>]?",
        "offset-anchor": "auto|<position>",
        "offset-distance": "<length-percentage>",
        "offset-path": "none|<offset-path>||<coord-box>",
        "offset-position": "normal|auto|<position>",
        "offset-rotate": "[auto|reverse]||<angle>",
        "opacity": "<opacity-value>",
        "order": "<integer>",
        "orphans": "<integer>",
        "outline": "<'outline-width'>||<'outline-style'>||<'outline-color'>",
        "outline-color": "auto|<color>",
        "outline-offset": "<length>",
        "outline-style": "auto|<outline-line-style>",
        "outline-width": "<line-width>",
        "overflow": "[visible|hidden|clip|scroll|auto]{1,2}|<-non-standard-overflow>",
        "overflow-anchor": "auto|none",
        "overflow-block": "visible|hidden|clip|scroll|auto",
        "overflow-clip-box": "padding-box|content-box",
        "overflow-clip-margin": "<visual-box>||<length [0,∞]>",
        "overflow-inline": "visible|hidden|clip|scroll|auto",
        "overflow-wrap": "normal|break-word|anywhere",
        "overflow-x": "visible|hidden|clip|scroll|auto|<-non-standard-overflow>",
        "overflow-y": "visible|hidden|clip|scroll|auto|<-non-standard-overflow>",
        "overlay": "none|auto",
        "overscroll-behavior": "[contain|none|auto]{1,2}",
        "overscroll-behavior-block": "contain|none|auto",
        "overscroll-behavior-inline": "contain|none|auto",
        "overscroll-behavior-x": "contain|none|auto",
        "overscroll-behavior-y": "contain|none|auto",
        "padding": "<'padding-top'>{1,4}",
        "padding-block": "<'padding-top'>{1,2}",
        "padding-block-end": "<'padding-top'>",
        "padding-block-start": "<'padding-top'>",
        "padding-bottom": "<length-percentage [0,∞]>",
        "padding-inline": "<'padding-top'>{1,2}",
        "padding-inline-end": "<'padding-top'>",
        "padding-inline-start": "<'padding-top'>",
        "padding-left": "<length-percentage [0,∞]>",
        "padding-right": "<length-percentage [0,∞]>",
        "padding-top": "<length-percentage [0,∞]>",
        "page": "auto|<custom-ident>",
        "page-break-after": "auto|always|avoid|left|right|recto|verso",
        "page-break-before": "auto|always|avoid|left|right|recto|verso",
        "page-break-inside": "auto|avoid",
        "paint-order": "normal|[fill||stroke||markers]",
        "perspective": "none|<length>",
        "perspective-origin": "<position>",
        "place-content": "<'align-content'> <'justify-content'>?",
        "place-items": "<'align-items'> <'justify-items'>?",
        "place-self": "<'align-self'> <'justify-self'>?",
        "pointer-events": "auto|none|visiblePainted|visibleFill|visibleStroke|visible|painted|fill|stroke|all|inherit",
        "position": "static|relative|absolute|sticky|fixed|-webkit-sticky",
        "position-anchor": "auto|<anchor-name>",
        "position-area": "none|<position-area>",
        "position-try": "<'position-try-order'>? <'position-try-fallbacks'>",
        "position-try-fallbacks": "none|[[<dashed-ident>||<try-tactic>]|<'position-area'>]#",
        "position-try-order": "normal|<try-size>",
        "position-visibility": "always|[anchors-valid||anchors-visible||no-overflow]",
        "print-color-adjust": "economy|exact",
        "quotes": "none|auto|[<string> <string>]+",
        "r": "<length>|<percentage>",
        "resize": "none|both|horizontal|vertical|block|inline",
        "right": "<length>|<percentage>|auto",
        "rotate": "none|<angle>|[x|y|z|<number>{3}]&&<angle>",
        "row-gap": "normal|<length-percentage>",
        "ruby-align": "start|center|space-between|space-around",
        "ruby-merge": "separate|collapse|auto",
        "ruby-position": "[alternate||[over|under]]|inter-character",
        "rx": "<length>|<percentage>",
        "ry": "<length>|<percentage>",
        "scale": "none|[<number>|<percentage>]{1,3}",
        "scroll-behavior": "auto|smooth",
        "scroll-initial-target": "none|nearest",
        "scroll-margin": "<length>{1,4}",
        "scroll-margin-block": "<length>{1,2}",
        "scroll-margin-block-end": "<length>",
        "scroll-margin-block-start": "<length>",
        "scroll-margin-bottom": "<length>",
        "scroll-margin-inline": "<length>{1,2}",
        "scroll-margin-inline-end": "<length>",
        "scroll-margin-inline-start": "<length>",
        "scroll-margin-left": "<length>",
        "scroll-margin-right": "<length>",
        "scroll-margin-top": "<length>",
        "scroll-padding": "[auto|<length-percentage>]{1,4}",
        "scroll-padding-block": "[auto|<length-percentage>]{1,2}",
        "scroll-padding-block-end": "auto|<length-percentage>",
        "scroll-padding-block-start": "auto|<length-percentage>",
        "scroll-padding-bottom": "auto|<length-percentage>",
        "scroll-padding-inline": "[auto|<length-percentage>]{1,2}",
        "scroll-padding-inline-end": "auto|<length-percentage>",
        "scroll-padding-inline-start": "auto|<length-percentage>",
        "scroll-padding-left": "auto|<length-percentage>",
        "scroll-padding-right": "auto|<length-percentage>",
        "scroll-padding-top": "auto|<length-percentage>",
        "scroll-snap-align": "[none|start|end|center]{1,2}",
        "scroll-snap-coordinate": "none|<position>#",
        "scroll-snap-destination": "<position>",
        "scroll-snap-points-x": "none|repeat( <length-percentage> )",
        "scroll-snap-points-y": "none|repeat( <length-percentage> )",
        "scroll-snap-stop": "normal|always",
        "scroll-snap-type": "none|[x|y|block|inline|both] [mandatory|proximity]?",
        "scroll-snap-type-x": "none|mandatory|proximity",
        "scroll-snap-type-y": "none|mandatory|proximity",
        "scroll-timeline": "[<'scroll-timeline-name'> <'scroll-timeline-axis'>?]#",
        "scroll-timeline-axis": "[block|inline|x|y]#",
        "scroll-timeline-name": "[none|<dashed-ident>]#",
        "scrollbar-color": "auto|<color>{2}",
        "scrollbar-gutter": "auto|stable&&both-edges?",
        "scrollbar-width": "auto|thin|none",
        "shape-image-threshold": "<opacity-value>",
        "shape-margin": "<length-percentage>",
        "shape-outside": "none|[<shape-box>||<basic-shape>]|<image>",
        "shape-rendering": "auto|optimizeSpeed|crispEdges|geometricPrecision",
        "speak-as": "normal|spell-out||digits||[literal-punctuation|no-punctuation]",
        "stop-color": "<'color'>",
        "stop-opacity": "<'opacity'>",
        "stroke": "<paint>",
        "stroke-dasharray": "none|[<svg-length>+]#",
        "stroke-dashoffset": "<svg-length>",
        "stroke-linecap": "butt|round|square",
        "stroke-linejoin": "miter|round|bevel",
        "stroke-miterlimit": "<number-one-or-greater>",
        "stroke-opacity": "<'opacity'>",
        "stroke-width": "<svg-length>",
        "tab-size": "<integer>|<length>",
        "table-layout": "auto|fixed",
        "text-align": "start|end|left|right|center|justify|match-parent",
        "text-align-last": "auto|start|end|left|right|center|justify",
        "text-anchor": "start|middle|end",
        "text-box": "normal|<'text-box-trim'>||<'text-box-edge'>",
        "text-box-edge": "auto|<text-edge>",
        "text-box-trim": "none|trim-start|trim-end|trim-both",
        "text-combine-upright": "none|all|[digits <integer>?]",
        "text-decoration": "<'text-decoration-line'>||<'text-decoration-style'>||<'text-decoration-color'>||<'text-decoration-thickness'>",
        "text-decoration-color": "<color>",
        "text-decoration-line": "none|[underline||overline||line-through||blink]|spelling-error|grammar-error",
        "text-decoration-skip": "none|[objects||[spaces|[leading-spaces||trailing-spaces]]||edges||box-decoration]",
        "text-decoration-skip-ink": "auto|all|none",
        "text-decoration-style": "solid|double|dotted|dashed|wavy",
        "text-decoration-thickness": "auto|from-font|<length>|<percentage>",
        "text-emphasis": "<'text-emphasis-style'>||<'text-emphasis-color'>",
        "text-emphasis-color": "<color>",
        "text-emphasis-position": "auto|[over|under]&&[right|left]?",
        "text-emphasis-style": "none|[[filled|open]||[dot|circle|double-circle|triangle|sesame]]|<string>",
        "text-indent": "<length-percentage>&&hanging?&&each-line?",
        "text-justify": "auto|inter-character|inter-word|none",
        "text-orientation": "mixed|upright|sideways",
        "text-overflow": "[clip|ellipsis|<string>]{1,2}",
        "text-rendering": "auto|optimizeSpeed|optimizeLegibility|geometricPrecision",
        "text-shadow": "none|<shadow-t>#",
        "text-size-adjust": "none|auto|<percentage>",
        "text-spacing-trim": "space-all|normal|space-first|trim-start",
        "text-transform": "none|[capitalize|uppercase|lowercase]||full-width||full-size-kana|math-auto",
        "text-underline-offset": "auto|<length>|<percentage>",
        "text-underline-position": "auto|from-font|[under||[left|right]]",
        "text-wrap": "<'text-wrap-mode'>||<'text-wrap-style'>",
        "text-wrap-mode": "wrap|nowrap",
        "text-wrap-style": "auto|balance|stable|pretty",
        "timeline-scope": "none|<dashed-ident>#",
        "top": "<length>|<percentage>|auto",
        "touch-action": "auto|none|[[pan-x|pan-left|pan-right]||[pan-y|pan-up|pan-down]||pinch-zoom]|manipulation",
        "transform": "none|<transform-list>",
        "transform-box": "content-box|border-box|fill-box|stroke-box|view-box",
        "transform-origin": "[<length-percentage>|left|center|right|top|bottom]|[[<length-percentage>|left|center|right]&&[<length-percentage>|top|center|bottom]] <length>?",
        "transform-style": "flat|preserve-3d",
        "transition": "<single-transition>#",
        "transition-behavior": "<transition-behavior-value>#",
        "transition-delay": "<time>#",
        "transition-duration": "<time>#",
        "transition-property": "none|<single-transition-property>#",
        "transition-timing-function": "<easing-function>#",
        "translate": "none|<length-percentage> [<length-percentage> <length>?]?",
        "unicode-bidi": "normal|embed|isolate|bidi-override|isolate-override|plaintext|-moz-isolate|-moz-isolate-override|-moz-plaintext|-webkit-isolate|-webkit-isolate-override|-webkit-plaintext",
        "user-select": "auto|text|none|all",
        "vector-effect": "none|non-scaling-stroke|non-scaling-size|non-rotation|fixed-position",
        "vertical-align": "baseline|sub|super|text-top|text-bottom|middle|top|bottom|<percentage>|<length>",
        "view-timeline": "[<'view-timeline-name'> [<'view-timeline-axis'>||<'view-timeline-inset'>]?]#",
        "view-timeline-axis": "[block|inline|x|y]#",
        "view-timeline-inset": "[[auto|<length-percentage>]{1,2}]#",
        "view-timeline-name": "[none|<dashed-ident>]#",
        "view-transition-class": "none|<custom-ident>+",
        "view-transition-name": "none|<custom-ident>",
        "visibility": "visible|hidden|collapse",
        "white-space": "normal|pre|pre-wrap|pre-line|<'white-space-collapse'>||<'text-wrap-mode'>",
        "white-space-collapse": "collapse|preserve|preserve-breaks|preserve-spaces|break-spaces",
        "widows": "<integer>",
        "width": "auto|<length-percentage [0,∞]>|min-content|max-content|fit-content|fit-content( <length-percentage [0,∞]> )|<calc-size()>|<anchor-size()>|stretch|<-non-standard-size>",
        "will-change": "auto|<animateable-feature>#",
        "word-break": "normal|break-all|keep-all|break-word|auto-phrase",
        "word-spacing": "normal|<length>",
        "word-wrap": "normal|break-word",
        "writing-mode": "horizontal-tb|vertical-rl|vertical-lr|sideways-rl|sideways-lr|<svg-writing-mode>",
        "x": "<length>|<percentage>",
        "y": "<length>|<percentage>",
        "z-index": "auto|<integer>",
        "zoom": "normal|reset|<number [0,∞]>||<percentage [0,∞]>",
        "-moz-background-clip": "padding|border",
        "-moz-border-radius-bottomleft": "<'border-bottom-left-radius'>",
        "-moz-border-radius-bottomright": "<'border-bottom-right-radius'>",
        "-moz-border-radius-topleft": "<'border-top-left-radius'>",
        "-moz-border-radius-topright": "<'border-bottom-right-radius'>",
        "-moz-control-character-visibility": "visible|hidden",
        "-moz-osx-font-smoothing": "auto|grayscale",
        "-moz-user-select": "none|text|all|-moz-none",
        "-ms-flex-align": "start|end|center|baseline|stretch",
        "-ms-flex-item-align": "auto|start|end|center|baseline|stretch",
        "-ms-flex-line-pack": "start|end|center|justify|distribute|stretch",
        "-ms-flex-negative": "<'flex-shrink'>",
        "-ms-flex-pack": "start|end|center|justify|distribute",
        "-ms-flex-order": "<integer>",
        "-ms-flex-positive": "<'flex-grow'>",
        "-ms-flex-preferred-size": "<'flex-basis'>",
        "-ms-interpolation-mode": "nearest-neighbor|bicubic",
        "-ms-grid-column-align": "start|end|center|stretch",
        "-ms-grid-row-align": "start|end|center|stretch",
        "-ms-hyphenate-limit-last": "none|always|column|page|spread",
        "-webkit-background-clip": "[<visual-box>|border|padding|content|text]#",
        "-webkit-column-break-after": "always|auto|avoid",
        "-webkit-column-break-before": "always|auto|avoid",
        "-webkit-column-break-inside": "always|auto|avoid",
        "-webkit-font-smoothing": "auto|none|antialiased|subpixel-antialiased",
        "-webkit-mask-box-image": "[<url>|<gradient>|none] [<length-percentage>{4} <-webkit-mask-box-repeat>{2}]?",
        "-webkit-print-color-adjust": "economy|exact",
        "-webkit-text-security": "none|circle|disc|square",
        "-webkit-user-drag": "none|element|auto",
        "behavior": "<url>+",
        "cue": "<'cue-before'> <'cue-after'>?",
        "cue-after": "<url> <decibel>?|none",
        "cue-before": "<url> <decibel>?|none",
        "glyph-orientation-horizontal": "<angle>",
        "glyph-orientation-vertical": "<angle>",
        "kerning": "auto|<svg-length>",
        "pause": "<'pause-before'> <'pause-after'>?",
        "pause-after": "<time>|none|x-weak|weak|medium|strong|x-strong",
        "pause-before": "<time>|none|x-weak|weak|medium|strong|x-strong",
        "position-try-options": "<'position-try-fallbacks'>",
        "rest": "<'rest-before'> <'rest-after'>?",
        "rest-after": "<time>|none|x-weak|weak|medium|strong|x-strong",
        "rest-before": "<time>|none|x-weak|weak|medium|strong|x-strong",
        "speak": "auto|never|always",
        "voice-balance": "<number>|left|center|right|leftwards|rightwards",
        "voice-duration": "auto|<time>",
        "voice-family": "[[<family-name>|<generic-voice>] ,]* [<family-name>|<generic-voice>]|preserve",
        "voice-pitch": "<frequency>&&absolute|[[x-low|low|medium|high|x-high]||[<frequency>|<semitones>|<percentage>]]",
        "voice-range": "<frequency>&&absolute|[[x-low|low|medium|high|x-high]||[<frequency>|<semitones>|<percentage>]]",
        "voice-rate": "[normal|x-slow|slow|medium|fast|x-fast]||<percentage>",
        "voice-stress": "normal|strong|moderate|none|reduced",
        "voice-volume": "silent|[[x-soft|soft|medium|loud|x-loud]||<decibel>]",
        "white-space-trim": "none|discard-before||discard-after||discard-inner"
    },
    "atrules": {
        "charset": {
            "prelude": "<string>",
            "descriptors": null
        },
        "counter-style": {
            "prelude": "<counter-style-name>",
            "descriptors": {
                "additive-symbols": "[<integer>&&<symbol>]#",
                "fallback": "<counter-style-name>",
                "negative": "<symbol> <symbol>?",
                "pad": "<integer>&&<symbol>",
                "prefix": "<symbol>",
                "range": "[[<integer>|infinite]{2}]#|auto",
                "speak-as": "auto|bullets|numbers|words|spell-out|<counter-style-name>",
                "suffix": "<symbol>",
                "symbols": "<symbol>+",
                "system": "cyclic|numeric|alphabetic|symbolic|additive|[fixed <integer>?]|[extends <counter-style-name>]"
            }
        },
        "container": {
            "prelude": "[<container-name>]? <container-condition>",
            "descriptors": null
        },
        "document": {
            "prelude": "[<url>|url-prefix( <string> )|domain( <string> )|media-document( <string> )|regexp( <string> )]#",
            "descriptors": null
        },
        "font-face": {
            "prelude": null,
            "descriptors": {
                "ascent-override": "normal|<percentage>",
                "descent-override": "normal|<percentage>",
                "font-display": "auto|block|swap|fallback|optional",
                "font-family": "<family-name>",
                "font-feature-settings": "normal|<feature-tag-value>#",
                "font-stretch": "<font-stretch-absolute>{1,2}",
                "font-style": "normal|italic|oblique <angle>{0,2}",
                "font-variation-settings": "normal|[<string> <number>]#",
                "font-weight": "<font-weight-absolute>{1,2}",
                "line-gap-override": "normal|<percentage>",
                "size-adjust": "<percentage>",
                "src": "[<url> [format( <string># )]?|local( <family-name> )]#",
                "unicode-range": "<unicode-range-token>#"
            }
        },
        "font-feature-values": {
            "prelude": "<family-name>#",
            "descriptors": null
        },
        "font-palette-values": {
            "prelude": "<dashed-ident>",
            "descriptors": {
                "base-palette": "light|dark|<integer [0,∞]>",
                "font-family": "<family-name>#",
                "override-colors": "[<integer [0,∞]> <color>]#"
            }
        },
        "import": {
            "prelude": "[<string>|<url>] [layer|layer( <layer-name> )]? [supports( [<supports-condition>|<declaration>] )]? <media-query-list>?",
            "descriptors": null
        },
        "keyframes": {
            "prelude": "<keyframes-name>",
            "descriptors": null
        },
        "layer": {
            "prelude": "[<layer-name>#|<layer-name>?]",
            "descriptors": null
        },
        "media": {
            "prelude": "<media-query-list>",
            "descriptors": null
        },
        "namespace": {
            "prelude": "<namespace-prefix>? [<string>|<url>]",
            "descriptors": null
        },
        "page": {
            "prelude": "<page-selector-list>",
            "descriptors": {
                "bleed": "auto|<length>",
                "marks": "none|[crop||cross]",
                "page-orientation": "upright|rotate-left|rotate-right",
                "size": "<length>{1,2}|auto|[<page-size>||[portrait|landscape]]"
            }
        },
        "position-try": {
            "prelude": "<dashed-ident>",
            "descriptors": {
                "top": "<'top'>",
                "left": "<'left'>",
                "bottom": "<'bottom'>",
                "right": "<'right'>",
                "inset-block-start": "<'inset-block-start'>",
                "inset-block-end": "<'inset-block-end'>",
                "inset-inline-start": "<'inset-inline-start'>",
                "inset-inline-end": "<'inset-inline-end'>",
                "inset-block": "<'inset-block'>",
                "inset-inline": "<'inset-inline'>",
                "inset": "<'inset'>",
                "margin-top": "<'margin-top'>",
                "margin-left": "<'margin-left'>",
                "margin-bottom": "<'margin-bottom'>",
                "margin-right": "<'margin-right'>",
                "margin-block-start": "<'margin-block-start'>",
                "margin-block-end": "<'margin-block-end'>",
                "margin-inline-start": "<'margin-inline-start'>",
                "margin-inline-end": "<'margin-inline-end'>",
                "margin": "<'margin'>",
                "margin-block": "<'margin-block'>",
                "margin-inline": "<'margin-inline'>",
                "width": "<'width'>",
                "height": "<'height'>",
                "min-width": "<'min-width'>",
                "min-height": "<'min-height'>",
                "max-width": "<'max-width'>",
                "max-height": "<'max-height'>",
                "block-size": "<'block-size'>",
                "inline-size": "<'inline-size'>",
                "min-block-size": "<'min-block-size'>",
                "min-inline-size": "<'min-inline-size'>",
                "max-block-size": "<'max-block-size'>",
                "max-inline-size": "<'max-inline-size'>",
                "align-self": "<'align-self'>|anchor-center",
                "justify-self": "<'justify-self'>|anchor-center"
            }
        },
        "property": {
            "prelude": "<custom-property-name>",
            "descriptors": {
                "inherits": "true|false",
                "initial-value": "<declaration-value>?",
                "syntax": "<string>"
            }
        },
        "scope": {
            "prelude": "[( <scope-start> )]? [to ( <scope-end> )]?",
            "descriptors": null
        },
        "starting-style": {
            "prelude": null,
            "descriptors": null
        },
        "supports": {
            "prelude": "<supports-condition>",
            "descriptors": null
        },
        "view-transition": {
            "prelude": null,
            "descriptors": {
                "navigation": "auto|none",
                "types": "none|<custom-ident>+"
            }
        },
        "nest": {
            "prelude": "<complex-selector-list>",
            "descriptors": null
        }
    }
};

const PLUSSIGN$5 = 0x002B;    // U+002B PLUS SIGN (+)
const HYPHENMINUS$2 = 0x002D; // U+002D HYPHEN-MINUS (-)
const N = 0x006E;           // U+006E LATIN SMALL LETTER N (n)
const DISALLOW_SIGN = true;
const ALLOW_SIGN = false;

function checkInteger(offset, disallowSign) {
    let pos = this.tokenStart + offset;
    const code = this.charCodeAt(pos);

    if (code === PLUSSIGN$5 || code === HYPHENMINUS$2) {
        if (disallowSign) {
            this.error('Number sign is not allowed');
        }
        pos++;
    }

    for (; pos < this.tokenEnd; pos++) {
        if (!isDigit(this.charCodeAt(pos))) {
            this.error('Integer is expected', pos);
        }
    }
}

function checkTokenIsInteger(disallowSign) {
    return checkInteger.call(this, 0, disallowSign);
}

function expectCharCode(offset, code) {
    if (!this.cmpChar(this.tokenStart + offset, code)) {
        let msg = '';

        switch (code) {
            case N:
                msg = 'N is expected';
                break;
            case HYPHENMINUS$2:
                msg = 'HyphenMinus is expected';
                break;
        }

        this.error(msg, this.tokenStart + offset);
    }
}

// ... <signed-integer>
// ... ['+' | '-'] <signless-integer>
function consumeB() {
    let offset = 0;
    let sign = 0;
    let type = this.tokenType;

    while (type === WhiteSpace$1 || type === Comment$1) {
        type = this.lookupType(++offset);
    }

    if (type !== Number$2) {
        if (this.isDelim(PLUSSIGN$5, offset) ||
            this.isDelim(HYPHENMINUS$2, offset)) {
            sign = this.isDelim(PLUSSIGN$5, offset) ? PLUSSIGN$5 : HYPHENMINUS$2;

            do {
                type = this.lookupType(++offset);
            } while (type === WhiteSpace$1 || type === Comment$1);

            if (type !== Number$2) {
                this.skip(offset);
                checkTokenIsInteger.call(this, DISALLOW_SIGN);
            }
        } else {
            return null;
        }
    }

    if (offset > 0) {
        this.skip(offset);
    }

    if (sign === 0) {
        type = this.charCodeAt(this.tokenStart);
        if (type !== PLUSSIGN$5 && type !== HYPHENMINUS$2) {
            this.error('Number sign is expected');
        }
    }

    checkTokenIsInteger.call(this, sign !== 0);
    return sign === HYPHENMINUS$2 ? '-' + this.consume(Number$2) : this.consume(Number$2);
}

// An+B microsyntax https://www.w3.org/TR/css-syntax-3/#anb
const name$M = 'AnPlusB';
const structure$M = {
    a: [String, null],
    b: [String, null]
};

function parse$N() {
    /* eslint-disable brace-style*/
    const start = this.tokenStart;
    let a = null;
    let b = null;

    // <integer>
    if (this.tokenType === Number$2) {
        checkTokenIsInteger.call(this, ALLOW_SIGN);
        b = this.consume(Number$2);
    }

    // -n
    // -n <signed-integer>
    // -n ['+' | '-'] <signless-integer>
    // -n- <signless-integer>
    // <dashndashdigit-ident>
    else if (this.tokenType === Ident && this.cmpChar(this.tokenStart, HYPHENMINUS$2)) {
        a = '-1';

        expectCharCode.call(this, 1, N);

        switch (this.tokenEnd - this.tokenStart) {
            // -n
            // -n <signed-integer>
            // -n ['+' | '-'] <signless-integer>
            case 2:
                this.next();
                b = consumeB.call(this);
                break;

            // -n- <signless-integer>
            case 3:
                expectCharCode.call(this, 2, HYPHENMINUS$2);

                this.next();
                this.skipSC();

                checkTokenIsInteger.call(this, DISALLOW_SIGN);

                b = '-' + this.consume(Number$2);
                break;

            // <dashndashdigit-ident>
            default:
                expectCharCode.call(this, 2, HYPHENMINUS$2);
                checkInteger.call(this, 3, DISALLOW_SIGN);
                this.next();

                b = this.substrToCursor(start + 2);
        }
    }

    // '+'? n
    // '+'? n <signed-integer>
    // '+'? n ['+' | '-'] <signless-integer>
    // '+'? n- <signless-integer>
    // '+'? <ndashdigit-ident>
    else if (this.tokenType === Ident || (this.isDelim(PLUSSIGN$5) && this.lookupType(1) === Ident)) {
        let sign = 0;
        a = '1';

        // just ignore a plus
        if (this.isDelim(PLUSSIGN$5)) {
            sign = 1;
            this.next();
        }

        expectCharCode.call(this, 0, N);

        switch (this.tokenEnd - this.tokenStart) {
            // '+'? n
            // '+'? n <signed-integer>
            // '+'? n ['+' | '-'] <signless-integer>
            case 1:
                this.next();
                b = consumeB.call(this);
                break;

            // '+'? n- <signless-integer>
            case 2:
                expectCharCode.call(this, 1, HYPHENMINUS$2);

                this.next();
                this.skipSC();

                checkTokenIsInteger.call(this, DISALLOW_SIGN);

                b = '-' + this.consume(Number$2);
                break;

            // '+'? <ndashdigit-ident>
            default:
                expectCharCode.call(this, 1, HYPHENMINUS$2);
                checkInteger.call(this, 2, DISALLOW_SIGN);
                this.next();

                b = this.substrToCursor(start + sign + 1);
        }
    }

    // <ndashdigit-dimension>
    // <ndash-dimension> <signless-integer>
    // <n-dimension>
    // <n-dimension> <signed-integer>
    // <n-dimension> ['+' | '-'] <signless-integer>
    else if (this.tokenType === Dimension$1) {
        const code = this.charCodeAt(this.tokenStart);
        const sign = code === PLUSSIGN$5 || code === HYPHENMINUS$2;
        let i = this.tokenStart + sign;

        for (; i < this.tokenEnd; i++) {
            if (!isDigit(this.charCodeAt(i))) {
                break;
            }
        }

        if (i === this.tokenStart + sign) {
            this.error('Integer is expected', this.tokenStart + sign);
        }

        expectCharCode.call(this, i - this.tokenStart, N);
        a = this.substring(start, i);

        // <n-dimension>
        // <n-dimension> <signed-integer>
        // <n-dimension> ['+' | '-'] <signless-integer>
        if (i + 1 === this.tokenEnd) {
            this.next();
            b = consumeB.call(this);
        } else {
            expectCharCode.call(this, i - this.tokenStart + 1, HYPHENMINUS$2);

            // <ndash-dimension> <signless-integer>
            if (i + 2 === this.tokenEnd) {
                this.next();
                this.skipSC();
                checkTokenIsInteger.call(this, DISALLOW_SIGN);
                b = '-' + this.consume(Number$2);
            }
            // <ndashdigit-dimension>
            else {
                checkInteger.call(this, i - this.tokenStart + 2, DISALLOW_SIGN);
                this.next();
                b = this.substrToCursor(i + 1);
            }
        }
    } else {
        this.error();
    }

    if (a !== null && a.charCodeAt(0) === PLUSSIGN$5) {
        a = a.substr(1);
    }

    if (b !== null && b.charCodeAt(0) === PLUSSIGN$5) {
        b = b.substr(1);
    }

    return {
        type: 'AnPlusB',
        loc: this.getLocation(start, this.tokenStart),
        a,
        b
    };
}

function generate$N(node) {
    if (node.a) {
        const a =
            node.a === '+1' && 'n' ||
            node.a ===  '1' && 'n' ||
            node.a === '-1' && '-n' ||
            node.a + 'n';

        if (node.b) {
            const b = node.b[0] === '-' || node.b[0] === '+'
                ? node.b
                : '+' + node.b;
            this.tokenize(a + b);
        } else {
            this.tokenize(a);
        }
    } else {
        this.tokenize(node.b);
    }
}

var AnPlusB = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$M,
    structure: structure$M,
    parse: parse$N,
    generate: generate$N
});

function consumeRaw$4() {
    return this.Raw(this.consumeUntilLeftCurlyBracketOrSemicolon, true);
}

function isDeclarationBlockAtrule() {
    for (let offset = 1, type; type = this.lookupType(offset); offset++) {
        if (type === RightCurlyBracket) {
            return true;
        }

        if (type === LeftCurlyBracket ||
            type === AtKeyword) {
            return false;
        }
    }

    return false;
}


const name$L = 'Atrule';
const walkContext$9 = 'atrule';
const structure$L = {
    name: String,
    prelude: ['AtrulePrelude', 'Raw', null],
    block: ['Block', null]
};

function parse$M(isDeclaration = false) {
    const start = this.tokenStart;
    let name;
    let nameLowerCase;
    let prelude = null;
    let block = null;

    this.eat(AtKeyword);

    name = this.substrToCursor(start + 1);
    nameLowerCase = name.toLowerCase();
    this.skipSC();

    // parse prelude
    if (this.eof === false &&
        this.tokenType !== LeftCurlyBracket &&
        this.tokenType !== Semicolon) {
        if (this.parseAtrulePrelude) {
            prelude = this.parseWithFallback(this.AtrulePrelude.bind(this, name, isDeclaration), consumeRaw$4);
        } else {
            prelude = consumeRaw$4.call(this, this.tokenIndex);
        }

        this.skipSC();
    }

    switch (this.tokenType) {
        case Semicolon:
            this.next();
            break;

        case LeftCurlyBracket:
            if (hasOwnProperty.call(this.atrule, nameLowerCase) &&
                typeof this.atrule[nameLowerCase].block === 'function') {
                block = this.atrule[nameLowerCase].block.call(this, isDeclaration);
            } else {
                // TODO: should consume block content as Raw?
                block = this.Block(isDeclarationBlockAtrule.call(this));
            }

            break;
    }

    return {
        type: 'Atrule',
        loc: this.getLocation(start, this.tokenStart),
        name,
        prelude,
        block
    };
}

function generate$M(node) {
    this.token(AtKeyword, '@' + node.name);

    if (node.prelude !== null) {
        this.node(node.prelude);
    }

    if (node.block) {
        this.node(node.block);
    } else {
        this.token(Semicolon, ';');
    }
}

var Atrule = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$L,
    walkContext: walkContext$9,
    structure: structure$L,
    parse: parse$M,
    generate: generate$M
});

const name$K = 'AtrulePrelude';
const walkContext$8 = 'atrulePrelude';
const structure$K = {
    children: [[]]
};

function parse$L(name) {
    let children = null;

    if (name !== null) {
        name = name.toLowerCase();
    }

    this.skipSC();

    if (hasOwnProperty.call(this.atrule, name) &&
        typeof this.atrule[name].prelude === 'function') {
        // custom consumer
        children = this.atrule[name].prelude.call(this);
    } else {
        // default consumer
        children = this.readSequence(this.scope.AtrulePrelude);
    }

    this.skipSC();

    if (this.eof !== true &&
        this.tokenType !== LeftCurlyBracket &&
        this.tokenType !== Semicolon) {
        this.error('Semicolon or block is expected');
    }

    return {
        type: 'AtrulePrelude',
        loc: this.getLocationFromList(children),
        children
    };
}

function generate$L(node) {
    this.children(node);
}

var AtrulePrelude = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$K,
    walkContext: walkContext$8,
    structure: structure$K,
    parse: parse$L,
    generate: generate$L
});

const DOLLARSIGN$1 = 0x0024;       // U+0024 DOLLAR SIGN ($)
const ASTERISK$5 = 0x002A;         // U+002A ASTERISK (*)
const EQUALSSIGN$1 = 0x003D;       // U+003D EQUALS SIGN (=)
const CIRCUMFLEXACCENT = 0x005E; // U+005E (^)
const VERTICALLINE$2 = 0x007C;     // U+007C VERTICAL LINE (|)
const TILDE$2 = 0x007E;            // U+007E TILDE (~)

function getAttributeName() {
    if (this.eof) {
        this.error('Unexpected end of input');
    }

    const start = this.tokenStart;
    let expectIdent = false;

    if (this.isDelim(ASTERISK$5)) {
        expectIdent = true;
        this.next();
    } else if (!this.isDelim(VERTICALLINE$2)) {
        this.eat(Ident);
    }

    if (this.isDelim(VERTICALLINE$2)) {
        if (this.charCodeAt(this.tokenStart + 1) !== EQUALSSIGN$1) {
            this.next();
            this.eat(Ident);
        } else if (expectIdent) {
            this.error('Identifier is expected', this.tokenEnd);
        }
    } else if (expectIdent) {
        this.error('Vertical line is expected');
    }

    return {
        type: 'Identifier',
        loc: this.getLocation(start, this.tokenStart),
        name: this.substrToCursor(start)
    };
}

function getOperator() {
    const start = this.tokenStart;
    const code = this.charCodeAt(start);

    if (code !== EQUALSSIGN$1 &&        // =
        code !== TILDE$2 &&             // ~=
        code !== CIRCUMFLEXACCENT &&  // ^=
        code !== DOLLARSIGN$1 &&        // $=
        code !== ASTERISK$5 &&          // *=
        code !== VERTICALLINE$2         // |=
    ) {
        this.error('Attribute selector (=, ~=, ^=, $=, *=, |=) is expected');
    }

    this.next();

    if (code !== EQUALSSIGN$1) {
        if (!this.isDelim(EQUALSSIGN$1)) {
            this.error('Equal sign is expected');
        }

        this.next();
    }

    return this.substrToCursor(start);
}

// '[' <wq-name> ']'
// '[' <wq-name> <attr-matcher> [ <string-token> | <ident-token> ] <attr-modifier>? ']'
const name$J = 'AttributeSelector';
const structure$J = {
    name: 'Identifier',
    matcher: [String, null],
    value: ['String', 'Identifier', null],
    flags: [String, null]
};

function parse$K() {
    const start = this.tokenStart;
    let name;
    let matcher = null;
    let value = null;
    let flags = null;

    this.eat(LeftSquareBracket);
    this.skipSC();

    name = getAttributeName.call(this);
    this.skipSC();

    if (this.tokenType !== RightSquareBracket) {
        // avoid case `[name i]`
        if (this.tokenType !== Ident) {
            matcher = getOperator.call(this);

            this.skipSC();

            value = this.tokenType === String$2
                ? this.String()
                : this.Identifier();

            this.skipSC();
        }

        // attribute flags
        if (this.tokenType === Ident) {
            flags = this.consume(Ident);

            this.skipSC();
        }
    }

    this.eat(RightSquareBracket);

    return {
        type: 'AttributeSelector',
        loc: this.getLocation(start, this.tokenStart),
        name,
        matcher,
        value,
        flags
    };
}

function generate$K(node) {
    this.token(Delim, '[');
    this.node(node.name);

    if (node.matcher !== null) {
        this.tokenize(node.matcher);
        this.node(node.value);
    }

    if (node.flags !== null) {
        this.token(Ident, node.flags);
    }

    this.token(Delim, ']');
}

var AttributeSelector = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$J,
    structure: structure$J,
    parse: parse$K,
    generate: generate$K
});

const AMPERSAND$4 = 0x0026;       // U+0026 AMPERSAND (&)

function consumeRaw$3() {
    return this.Raw(null, true);
}
function consumeRule() {
    return this.parseWithFallback(this.Rule, consumeRaw$3);
}
function consumeRawDeclaration() {
    return this.Raw(this.consumeUntilSemicolonIncluded, true);
}
function consumeDeclaration() {
    if (this.tokenType === Semicolon) {
        return consumeRawDeclaration.call(this, this.tokenIndex);
    }

    const node = this.parseWithFallback(this.Declaration, consumeRawDeclaration);

    if (this.tokenType === Semicolon) {
        this.next();
    }

    return node;
}

const name$I = 'Block';
const walkContext$7 = 'block';
const structure$I = {
    children: [[
        'Atrule',
        'Rule',
        'Declaration'
    ]]
};

function parse$J(isStyleBlock) {
    const consumer = isStyleBlock ? consumeDeclaration : consumeRule;
    const start = this.tokenStart;
    let children = this.createList();

    this.eat(LeftCurlyBracket);

    scan:
    while (!this.eof) {
        switch (this.tokenType) {
            case RightCurlyBracket:
                break scan;

            case WhiteSpace$1:
            case Comment$1:
                this.next();
                break;

            case AtKeyword:
                children.push(this.parseWithFallback(this.Atrule.bind(this, isStyleBlock), consumeRaw$3));
                break;

            default:
                if (isStyleBlock && this.isDelim(AMPERSAND$4))  {
                    children.push(consumeRule.call(this));
                } else {
                    children.push(consumer.call(this));
                }
        }
    }

    if (!this.eof) {
        this.eat(RightCurlyBracket);
    }

    return {
        type: 'Block',
        loc: this.getLocation(start, this.tokenStart),
        children
    };
}

function generate$J(node) {
    this.token(LeftCurlyBracket, '{');
    this.children(node, prev => {
        if (prev.type === 'Declaration') {
            this.token(Semicolon, ';');
        }
    });
    this.token(RightCurlyBracket, '}');
}

var Block = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$I,
    walkContext: walkContext$7,
    structure: structure$I,
    parse: parse$J,
    generate: generate$J
});

const name$H = 'Brackets';
const structure$H = {
    children: [[]]
};

function parse$I(readSequence, recognizer) {
    const start = this.tokenStart;
    let children = null;

    this.eat(LeftSquareBracket);

    children = readSequence.call(this, recognizer);

    if (!this.eof) {
        this.eat(RightSquareBracket);
    }

    return {
        type: 'Brackets',
        loc: this.getLocation(start, this.tokenStart),
        children
    };
}

function generate$I(node) {
    this.token(Delim, '[');
    this.children(node);
    this.token(Delim, ']');
}

var Brackets = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$H,
    structure: structure$H,
    parse: parse$I,
    generate: generate$I
});

const name$G = 'CDC';
const structure$G = [];

function parse$H() {
    const start = this.tokenStart;

    this.eat(CDC$1); // -->

    return {
        type: 'CDC',
        loc: this.getLocation(start, this.tokenStart)
    };
}

function generate$H() {
    this.token(CDC$1, '-->');
}

var CDC = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$G,
    structure: structure$G,
    parse: parse$H,
    generate: generate$H
});

const name$F = 'CDO';
const structure$F = [];

function parse$G() {
    const start = this.tokenStart;

    this.eat(CDO$1); // <!--

    return {
        type: 'CDO',
        loc: this.getLocation(start, this.tokenStart)
    };
}

function generate$G() {
    this.token(CDO$1, '<!--');
}

var CDO = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$F,
    structure: structure$F,
    parse: parse$G,
    generate: generate$G
});

const FULLSTOP$2 = 0x002E; // U+002E FULL STOP (.)

// '.' ident
const name$E = 'ClassSelector';
const structure$E = {
    name: String
};

function parse$F() {
    this.eatDelim(FULLSTOP$2);

    return {
        type: 'ClassSelector',
        loc: this.getLocation(this.tokenStart - 1, this.tokenEnd),
        name: this.consume(Ident)
    };
}

function generate$F(node) {
    this.token(Delim, '.');
    this.token(Ident, node.name);
}

var ClassSelector = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$E,
    structure: structure$E,
    parse: parse$F,
    generate: generate$F
});

const PLUSSIGN$4 = 0x002B;        // U+002B PLUS SIGN (+)
const SOLIDUS$7 = 0x002F;         // U+002F SOLIDUS (/)
const GREATERTHANSIGN$2 = 0x003E; // U+003E GREATER-THAN SIGN (>)
const TILDE$1 = 0x007E;           // U+007E TILDE (~)

const name$D = 'Combinator';
const structure$D = {
    name: String
};

// + | > | ~ | /deep/
function parse$E() {
    const start = this.tokenStart;
    let name;

    switch (this.tokenType) {
        case WhiteSpace$1:
            name = ' ';
            break;

        case Delim:
            switch (this.charCodeAt(this.tokenStart)) {
                case GREATERTHANSIGN$2:
                case PLUSSIGN$4:
                case TILDE$1:
                    this.next();
                    break;

                case SOLIDUS$7:
                    this.next();
                    this.eatIdent('deep');
                    this.eatDelim(SOLIDUS$7);
                    break;

                default:
                    this.error('Combinator is expected');
            }

            name = this.substrToCursor(start);
            break;
    }

    return {
        type: 'Combinator',
        loc: this.getLocation(start, this.tokenStart),
        name
    };
}

function generate$E(node) {
    this.tokenize(node.name);
}

var Combinator = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$D,
    structure: structure$D,
    parse: parse$E,
    generate: generate$E
});

const ASTERISK$4 = 0x002A;        // U+002A ASTERISK (*)
const SOLIDUS$6 = 0x002F;         // U+002F SOLIDUS (/)


const name$C = 'Comment';
const structure$C = {
    value: String
};

function parse$D() {
    const start = this.tokenStart;
    let end = this.tokenEnd;

    this.eat(Comment$1);

    if ((end - start + 2) >= 2 &&
        this.charCodeAt(end - 2) === ASTERISK$4 &&
        this.charCodeAt(end - 1) === SOLIDUS$6) {
        end -= 2;
    }

    return {
        type: 'Comment',
        loc: this.getLocation(start, this.tokenStart),
        value: this.substring(start + 2, end)
    };
}

function generate$D(node) {
    this.token(Comment$1, '/*' + node.value + '*/');
}

var Comment = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$C,
    structure: structure$C,
    parse: parse$D,
    generate: generate$D
});

const likelyFeatureToken = new Set([Colon, RightParenthesis, EOF$1]);

const name$B = 'Condition';
const structure$B = {
    kind: String,
    children: [[
        'Identifier',
        'Feature',
        'FeatureFunction',
        'FeatureRange',
        'SupportsDeclaration'
    ]]
};

function featureOrRange(kind) {
    if (this.lookupTypeNonSC(1) === Ident &&
        likelyFeatureToken.has(this.lookupTypeNonSC(2))) {
        return this.Feature(kind);
    }

    return this.FeatureRange(kind);
}

const parentheses = {
    media: featureOrRange,
    container: featureOrRange,
    supports() {
        return this.SupportsDeclaration();
    }
};

function parse$C(kind = 'media') {
    const children = this.createList();

    scan: while (!this.eof) {
        switch (this.tokenType) {
            case Comment$1:
            case WhiteSpace$1:
                this.next();
                continue;

            case Ident:
                children.push(this.Identifier());
                break;

            case LeftParenthesis: {
                let term = this.parseWithFallback(
                    () => parentheses[kind].call(this, kind),
                    () => null
                );

                if (!term) {
                    term = this.parseWithFallback(
                        () => {
                            this.eat(LeftParenthesis);
                            const res = this.Condition(kind);
                            this.eat(RightParenthesis);
                            return res;
                        },
                        () => {
                            return this.GeneralEnclosed(kind);
                        }
                    );
                }

                children.push(term);
                break;
            }

            case Function$1: {
                let term = this.parseWithFallback(
                    () => this.FeatureFunction(kind),
                    () => null
                );

                if (!term) {
                    term = this.GeneralEnclosed(kind);
                }

                children.push(term);
                break;
            }

            default:
                break scan;
        }
    }

    if (children.isEmpty) {
        this.error('Condition is expected');
    }

    return {
        type: 'Condition',
        loc: this.getLocationFromList(children),
        kind,
        children
    };
}

function generate$C(node) {
    node.children.forEach(child => {
        if (child.type === 'Condition') {
            this.token(LeftParenthesis, '(');
            this.node(child);
            this.token(RightParenthesis, ')');
        } else {
            this.node(child);
        }
    });
}

var Condition = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$B,
    structure: structure$B,
    parse: parse$C,
    generate: generate$C
});

const EXCLAMATIONMARK$1 = 0x0021; // U+0021 EXCLAMATION MARK (!)
const NUMBERSIGN$2 = 0x0023;      // U+0023 NUMBER SIGN (#)
const DOLLARSIGN = 0x0024;      // U+0024 DOLLAR SIGN ($)
const AMPERSAND$3 = 0x0026;       // U+0026 AMPERSAND (&)
const ASTERISK$3 = 0x002A;        // U+002A ASTERISK (*)
const PLUSSIGN$3 = 0x002B;        // U+002B PLUS SIGN (+)
const SOLIDUS$5 = 0x002F;         // U+002F SOLIDUS (/)

function consumeValueRaw() {
    return this.Raw(this.consumeUntilExclamationMarkOrSemicolon, true);
}

function consumeCustomPropertyRaw() {
    return this.Raw(this.consumeUntilExclamationMarkOrSemicolon, false);
}

function consumeValue() {
    const startValueToken = this.tokenIndex;
    const value = this.Value();

    if (value.type !== 'Raw' &&
        this.eof === false &&
        this.tokenType !== Semicolon &&
        this.isDelim(EXCLAMATIONMARK$1) === false &&
        this.isBalanceEdge(startValueToken) === false) {
        this.error();
    }

    return value;
}

const name$A = 'Declaration';
const walkContext$6 = 'declaration';
const structure$A = {
    important: [Boolean, String],
    property: String,
    value: ['Value', 'Raw']
};

function parse$B() {
    const start = this.tokenStart;
    const startToken = this.tokenIndex;
    const property = readProperty.call(this);
    const customProperty = isCustomProperty(property);
    const parseValue = customProperty ? this.parseCustomProperty : this.parseValue;
    const consumeRaw = customProperty ? consumeCustomPropertyRaw : consumeValueRaw;
    let important = false;
    let value;

    this.skipSC();
    this.eat(Colon);

    const valueStart = this.tokenIndex;

    if (!customProperty) {
        this.skipSC();
    }

    if (parseValue) {
        value = this.parseWithFallback(consumeValue, consumeRaw);
    } else {
        value = consumeRaw.call(this, this.tokenIndex);
    }

    if (customProperty && value.type === 'Value' && value.children.isEmpty) {
        for (let offset = valueStart - this.tokenIndex; offset <= 0; offset++) {
            if (this.lookupType(offset) === WhiteSpace$1) {
                value.children.appendData({
                    type: 'WhiteSpace',
                    loc: null,
                    value: ' '
                });
                break;
            }
        }
    }

    if (this.isDelim(EXCLAMATIONMARK$1)) {
        important = getImportant.call(this);
        this.skipSC();
    }

    // Do not include semicolon to range per spec
    // https://drafts.csswg.org/css-syntax/#declaration-diagram

    if (this.eof === false &&
        this.tokenType !== Semicolon &&
        this.isBalanceEdge(startToken) === false) {
        this.error();
    }

    return {
        type: 'Declaration',
        loc: this.getLocation(start, this.tokenStart),
        important,
        property,
        value
    };
}

function generate$B(node) {
    this.token(Ident, node.property);
    this.token(Colon, ':');
    this.node(node.value);

    if (node.important) {
        this.token(Delim, '!');
        this.token(Ident, node.important === true ? 'important' : node.important);
    }
}

function readProperty() {
    const start = this.tokenStart;

    // hacks
    if (this.tokenType === Delim) {
        switch (this.charCodeAt(this.tokenStart)) {
            case ASTERISK$3:
            case DOLLARSIGN:
            case PLUSSIGN$3:
            case NUMBERSIGN$2:
            case AMPERSAND$3:
                this.next();
                break;

            // TODO: not sure we should support this hack
            case SOLIDUS$5:
                this.next();
                if (this.isDelim(SOLIDUS$5)) {
                    this.next();
                }
                break;
        }
    }

    if (this.tokenType === Hash$1) {
        this.eat(Hash$1);
    } else {
        this.eat(Ident);
    }

    return this.substrToCursor(start);
}

// ! ws* important
function getImportant() {
    this.eat(Delim);
    this.skipSC();

    const important = this.consume(Ident);

    // store original value in case it differ from `important`
    // for better original source restoring and hacks like `!ie` support
    return important === 'important' ? true : important;
}

var Declaration = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$A,
    walkContext: walkContext$6,
    structure: structure$A,
    parse: parse$B,
    generate: generate$B
});

const AMPERSAND$2 = 0x0026;       // U+0026 AMPERSAND (&)

function consumeRaw$2() {
    return this.Raw(this.consumeUntilSemicolonIncluded, true);
}

const name$z = 'DeclarationList';
const structure$z = {
    children: [[
        'Declaration',
        'Atrule',
        'Rule'
    ]]
};

function parse$A() {
    const children = this.createList();

    while (!this.eof) {
        switch (this.tokenType) {
            case WhiteSpace$1:
            case Comment$1:
            case Semicolon:
                this.next();
                break;

            case AtKeyword:
                children.push(this.parseWithFallback(this.Atrule.bind(this, true), consumeRaw$2));
                break;

            default:
                if (this.isDelim(AMPERSAND$2))  {
                    children.push(this.parseWithFallback(this.Rule, consumeRaw$2));
                } else {
                    children.push(this.parseWithFallback(this.Declaration, consumeRaw$2));
                }
        }
    }

    return {
        type: 'DeclarationList',
        loc: this.getLocationFromList(children),
        children
    };
}

function generate$A(node) {
    this.children(node, prev => {
        if (prev.type === 'Declaration') {
            this.token(Semicolon, ';');
        }
    });
}

var DeclarationList = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$z,
    structure: structure$z,
    parse: parse$A,
    generate: generate$A
});

const name$y = 'Dimension';
const structure$y = {
    value: String,
    unit: String
};

function parse$z() {
    const start = this.tokenStart;
    const value = this.consumeNumber(Dimension$1);

    return {
        type: 'Dimension',
        loc: this.getLocation(start, this.tokenStart),
        value,
        unit: this.substring(start + value.length, this.tokenStart)
    };
}

function generate$z(node) {
    this.token(Dimension$1, node.value + node.unit);
}

var Dimension = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$y,
    structure: structure$y,
    parse: parse$z,
    generate: generate$z
});

const SOLIDUS$4 = 0x002F;  // U+002F SOLIDUS (/)

const name$x = 'Feature';
const structure$x = {
    kind: String,
    name: String,
    value: ['Identifier', 'Number', 'Dimension', 'Ratio', 'Function', null]
};

function parse$y(kind) {
    const start = this.tokenStart;
    let name;
    let value = null;

    this.eat(LeftParenthesis);
    this.skipSC();

    name = this.consume(Ident);
    this.skipSC();

    if (this.tokenType !== RightParenthesis) {
        this.eat(Colon);
        this.skipSC();

        switch (this.tokenType) {
            case Number$2:
                if (this.lookupNonWSType(1) === Delim) {
                    value = this.Ratio();
                } else {
                    value = this.Number();
                }

                break;

            case Dimension$1:
                value = this.Dimension();
                break;

            case Ident:
                value = this.Identifier();
                break;

            case Function$1:
                value = this.parseWithFallback(
                    () => {
                        const res = this.Function(this.readSequence, this.scope.Value);

                        this.skipSC();

                        if (this.isDelim(SOLIDUS$4)) {
                            this.error();
                        }

                        return res;
                    },
                    () => {
                        return this.Ratio();
                    }
                );
                break;

            default:
                this.error('Number, dimension, ratio or identifier is expected');
        }

        this.skipSC();
    }

    if (!this.eof) {
        this.eat(RightParenthesis);
    }

    return {
        type: 'Feature',
        loc: this.getLocation(start, this.tokenStart),
        kind,
        name,
        value
    };
}

function generate$y(node) {
    this.token(LeftParenthesis, '(');
    this.token(Ident, node.name);

    if (node.value !== null) {
        this.token(Colon, ':');
        this.node(node.value);
    }

    this.token(RightParenthesis, ')');
}

var Feature = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$x,
    structure: structure$x,
    parse: parse$y,
    generate: generate$y
});

const name$w = 'FeatureFunction';
const structure$w = {
    kind: String,
    feature: String,
    value: ['Declaration', 'Selector']
};

function getFeatureParser(kind, name) {
    const featuresOfKind = this.features[kind] || {};
    const parser = featuresOfKind[name];

    if (typeof parser !== 'function') {
        this.error(`Unknown feature ${name}()`);
    }

    return parser;
}

function parse$x(kind = 'unknown') {
    const start = this.tokenStart;
    const functionName = this.consumeFunctionName();
    const valueParser = getFeatureParser.call(this, kind, functionName.toLowerCase());

    this.skipSC();

    const value = this.parseWithFallback(
        () => {
            const startValueToken = this.tokenIndex;
            const value = valueParser.call(this);

            if (this.eof === false &&
                this.isBalanceEdge(startValueToken) === false) {
                this.error();
            }

            return value;
        },
        () => this.Raw(null, false)
    );

    if (!this.eof) {
        this.eat(RightParenthesis);
    }

    return {
        type: 'FeatureFunction',
        loc: this.getLocation(start, this.tokenStart),
        kind,
        feature: functionName,
        value
    };
}

function generate$x(node) {
    this.token(Function$1, node.feature + '(');
    this.node(node.value);
    this.token(RightParenthesis, ')');
}

var FeatureFunction = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$w,
    structure: structure$w,
    parse: parse$x,
    generate: generate$x
});

const SOLIDUS$3 = 0x002F;         // U+002F SOLIDUS (/)
const LESSTHANSIGN = 0x003C;    // U+003C LESS-THAN SIGN (<)
const EQUALSSIGN = 0x003D;      // U+003D EQUALS SIGN (=)
const GREATERTHANSIGN$1 = 0x003E; // U+003E GREATER-THAN SIGN (>)

const name$v = 'FeatureRange';
const structure$v = {
    kind: String,
    left: ['Identifier', 'Number', 'Dimension', 'Ratio', 'Function'],
    leftComparison: String,
    middle: ['Identifier', 'Number', 'Dimension', 'Ratio', 'Function'],
    rightComparison: [String, null],
    right: ['Identifier', 'Number', 'Dimension', 'Ratio', 'Function', null]
};

function readTerm() {
    this.skipSC();

    switch (this.tokenType) {
        case Number$2:
            if (this.isDelim(SOLIDUS$3, this.lookupOffsetNonSC(1))) {
                return this.Ratio();
            } else {
                return this.Number();
            }

        case Dimension$1:
            return this.Dimension();

        case Ident:
            return this.Identifier();

        case Function$1:
            return this.parseWithFallback(
                () => {
                    const res = this.Function(this.readSequence, this.scope.Value);

                    this.skipSC();

                    if (this.isDelim(SOLIDUS$3)) {
                        this.error();
                    }

                    return res;
                },
                () => {
                    return this.Ratio();
                }
            );

        default:
            this.error('Number, dimension, ratio or identifier is expected');
    }
}

function readComparison(expectColon) {
    this.skipSC();

    if (this.isDelim(LESSTHANSIGN) ||
        this.isDelim(GREATERTHANSIGN$1)) {
        const value = this.source[this.tokenStart];

        this.next();

        if (this.isDelim(EQUALSSIGN)) {
            this.next();
            return value + '=';
        }

        return value;
    }

    if (this.isDelim(EQUALSSIGN)) {
        return '=';
    }

    this.error(`Expected ${expectColon ? '":", ' : ''}"<", ">", "=" or ")"`);
}

function parse$w(kind = 'unknown') {
    const start = this.tokenStart;

    this.skipSC();
    this.eat(LeftParenthesis);

    const left = readTerm.call(this);
    const leftComparison = readComparison.call(this, left.type === 'Identifier');
    const middle = readTerm.call(this);
    let rightComparison = null;
    let right = null;

    if (this.lookupNonWSType(0) !== RightParenthesis) {
        rightComparison = readComparison.call(this);
        right = readTerm.call(this);
    }

    this.skipSC();
    this.eat(RightParenthesis);

    return {
        type: 'FeatureRange',
        loc: this.getLocation(start, this.tokenStart),
        kind,
        left,
        leftComparison,
        middle,
        rightComparison,
        right
    };
}

function generate$w(node) {
    this.token(LeftParenthesis, '(');
    this.node(node.left);
    this.tokenize(node.leftComparison);
    this.node(node.middle);

    if (node.right) {
        this.tokenize(node.rightComparison);
        this.node(node.right);
    }

    this.token(RightParenthesis, ')');
}

var FeatureRange = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$v,
    structure: structure$v,
    parse: parse$w,
    generate: generate$w
});

const name$u = 'Function';
const walkContext$5 = 'function';
const structure$u = {
    name: String,
    children: [[]]
};

// <function-token> <sequence> )
function parse$v(readSequence, recognizer) {
    const start = this.tokenStart;
    const name = this.consumeFunctionName();
    const nameLowerCase = name.toLowerCase();
    let children;

    children = recognizer.hasOwnProperty(nameLowerCase)
        ? recognizer[nameLowerCase].call(this, recognizer)
        : readSequence.call(this, recognizer);

    if (!this.eof) {
        this.eat(RightParenthesis);
    }

    return {
        type: 'Function',
        loc: this.getLocation(start, this.tokenStart),
        name,
        children
    };
}

function generate$v(node) {
    this.token(Function$1, node.name + '(');
    this.children(node);
    this.token(RightParenthesis, ')');
}

var Function = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$u,
    walkContext: walkContext$5,
    structure: structure$u,
    parse: parse$v,
    generate: generate$v
});

const name$t = 'GeneralEnclosed';
const structure$t = {
    kind: String,
    function: [String, null],
    children: [[]]
};

// <function-token> <any-value> )
// ( <any-value> )
function parse$u(kind) {
    const start = this.tokenStart;
    let functionName = null;

    if (this.tokenType === Function$1) {
        functionName = this.consumeFunctionName();
    } else {
        this.eat(LeftParenthesis);
    }

    const children = this.parseWithFallback(
        () => {
            const startValueToken = this.tokenIndex;
            const children = this.readSequence(this.scope.Value);

            if (this.eof === false &&
                this.isBalanceEdge(startValueToken) === false) {
                this.error();
            }

            return children;
        },
        () => this.createSingleNodeList(
            this.Raw(null, false)
        )
    );

    if (!this.eof) {
        this.eat(RightParenthesis);
    }

    return {
        type: 'GeneralEnclosed',
        loc: this.getLocation(start, this.tokenStart),
        kind,
        function: functionName,
        children
    };
}

function generate$u(node) {
    if (node.function) {
        this.token(Function$1, node.function + '(');
    } else {
        this.token(LeftParenthesis, '(');
    }

    this.children(node);
    this.token(RightParenthesis, ')');
}

var GeneralEnclosed = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$t,
    structure: structure$t,
    parse: parse$u,
    generate: generate$u
});

// '#' ident
const xxx = 'XXX';
const name$s = 'Hash';
const structure$s = {
    value: String
};
function parse$t() {
    const start = this.tokenStart;

    this.eat(Hash$1);

    return {
        type: 'Hash',
        loc: this.getLocation(start, this.tokenStart),
        value: this.substrToCursor(start + 1)
    };
}
function generate$t(node) {
    this.token(Hash$1, '#' + node.value);
}

var Hash = /*#__PURE__*/Object.freeze({
    __proto__: null,
    xxx: xxx,
    name: name$s,
    structure: structure$s,
    parse: parse$t,
    generate: generate$t
});

const name$r = 'Identifier';
const structure$r = {
    name: String
};

function parse$s() {
    return {
        type: 'Identifier',
        loc: this.getLocation(this.tokenStart, this.tokenEnd),
        name: this.consume(Ident)
    };
}

function generate$s(node) {
    this.token(Ident, node.name);
}

var Identifier = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$r,
    structure: structure$r,
    parse: parse$s,
    generate: generate$s
});

const name$q = 'IdSelector';
const structure$q = {
    name: String
};

function parse$r() {
    const start = this.tokenStart;

    // TODO: check value is an ident
    this.eat(Hash$1);

    return {
        type: 'IdSelector',
        loc: this.getLocation(start, this.tokenStart),
        name: this.substrToCursor(start + 1)
    };
}

function generate$r(node) {
    // Using Delim instead of Hash is a hack to avoid for a whitespace between ident and id-selector
    // in safe mode (e.g. "a#id"), because IE11 doesn't allow a sequence <ident-token> <hash-token>
    // without a whitespace in values (e.g. "1px solid#000")
    this.token(Delim, '#' + node.name);
}

var IdSelector = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$q,
    structure: structure$q,
    parse: parse$r,
    generate: generate$r
});

const FULLSTOP$1 = 0x002E; // U+002E FULL STOP (.)

const name$p = 'Layer';
const structure$p = {
    name: String
};

function parse$q() {
    let tokenStart = this.tokenStart;
    let name = this.consume(Ident);

    while (this.isDelim(FULLSTOP$1)) {
        this.eat(Delim);
        name += '.' + this.consume(Ident);
    }

    return {
        type: 'Layer',
        loc: this.getLocation(tokenStart, this.tokenStart),
        name
    };
}

function generate$q(node) {
    this.tokenize(node.name);
}

var Layer = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$p,
    structure: structure$p,
    parse: parse$q,
    generate: generate$q
});

const name$o = 'LayerList';
const structure$o = {
    children: [[
        'Layer'
    ]]
};

function parse$p() {
    const children = this.createList();

    this.skipSC();

    while (!this.eof) {
        children.push(this.Layer());

        if (this.lookupTypeNonSC(0) !== Comma) {
            break;
        }

        this.skipSC();
        this.next();
        this.skipSC();
    }

    return {
        type: 'LayerList',
        loc: this.getLocationFromList(children),
        children
    };
}

function generate$p(node) {
    this.children(node, () => this.token(Comma, ','));
}

var LayerList = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$o,
    structure: structure$o,
    parse: parse$p,
    generate: generate$p
});

const name$n = 'MediaQuery';
const structure$n = {
    modifier: [String, null],
    mediaType: [String, null],
    condition: ['Condition', null]
};

function parse$o() {
    const start = this.tokenStart;
    let modifier = null;
    let mediaType = null;
    let condition = null;

    this.skipSC();

    if (this.tokenType === Ident && this.lookupTypeNonSC(1) !== LeftParenthesis) {
        // [ not | only ]? <media-type>
        const ident = this.consume(Ident);
        const identLowerCase = ident.toLowerCase();

        if (identLowerCase === 'not' || identLowerCase === 'only') {
            this.skipSC();
            modifier = identLowerCase;
            mediaType = this.consume(Ident);
        } else {
            mediaType = ident;
        }

        switch (this.lookupTypeNonSC(0)) {
            case Ident: {
                // and <media-condition-without-or>
                this.skipSC();
                this.eatIdent('and');
                condition = this.Condition('media');
                break;
            }

            case LeftCurlyBracket:
            case Semicolon:
            case Comma:
            case EOF$1:
                break;

            default:
                this.error('Identifier or parenthesis is expected');
        }
    } else {
        switch (this.tokenType) {
            case Ident:
            case LeftParenthesis:
            case Function$1: {
                // <media-condition>
                condition = this.Condition('media');
                break;
            }

            case LeftCurlyBracket:
            case Semicolon:
            case EOF$1:
                break;

            default:
                this.error('Identifier or parenthesis is expected');
        }
    }

    return {
        type: 'MediaQuery',
        loc: this.getLocation(start, this.tokenStart),
        modifier,
        mediaType,
        condition
    };
}

function generate$o(node) {
    if (node.mediaType) {
        if (node.modifier) {
            this.token(Ident, node.modifier);
        }

        this.token(Ident, node.mediaType);

        if (node.condition) {
            this.token(Ident, 'and');
            this.node(node.condition);
        }
    } else if (node.condition) {
        this.node(node.condition);
    }
}

var MediaQuery = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$n,
    structure: structure$n,
    parse: parse$o,
    generate: generate$o
});

const name$m = 'MediaQueryList';
const structure$m = {
    children: [[
        'MediaQuery'
    ]]
};

function parse$n() {
    const children = this.createList();

    this.skipSC();

    while (!this.eof) {
        children.push(this.MediaQuery());

        if (this.tokenType !== Comma) {
            break;
        }

        this.next();
    }

    return {
        type: 'MediaQueryList',
        loc: this.getLocationFromList(children),
        children
    };
}

function generate$n(node) {
    this.children(node, () => this.token(Comma, ','));
}

var MediaQueryList = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$m,
    structure: structure$m,
    parse: parse$n,
    generate: generate$n
});

const AMPERSAND$1 = 0x0026;       // U+0026 AMPERSAND (&)

const name$l = 'NestingSelector';
const structure$l = {
};

function parse$m() {
    const start = this.tokenStart;

    this.eatDelim(AMPERSAND$1);

    return {
        type: 'NestingSelector',
        loc: this.getLocation(start, this.tokenStart)
    };
}

function generate$m() {
    this.token(Delim, '&');
}

var NestingSelector = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$l,
    structure: structure$l,
    parse: parse$m,
    generate: generate$m
});

const name$k = 'Nth';
const structure$k = {
    nth: ['AnPlusB', 'Identifier'],
    selector: ['SelectorList', null]
};

function parse$l() {
    this.skipSC();

    const start = this.tokenStart;
    let end = start;
    let selector = null;
    let nth;

    if (this.lookupValue(0, 'odd') || this.lookupValue(0, 'even')) {
        nth = this.Identifier();
    } else {
        nth = this.AnPlusB();
    }

    end = this.tokenStart;
    this.skipSC();

    if (this.lookupValue(0, 'of')) {
        this.next();

        selector = this.SelectorList();
        end = this.tokenStart;
    }

    return {
        type: 'Nth',
        loc: this.getLocation(start, end),
        nth,
        selector
    };
}

function generate$l(node) {
    this.node(node.nth);
    if (node.selector !== null) {
        this.token(Ident, 'of');
        this.node(node.selector);
    }
}

var Nth = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$k,
    structure: structure$k,
    parse: parse$l,
    generate: generate$l
});

const name$j = 'Number';
const structure$j = {
    value: String
};

function parse$k() {
    return {
        type: 'Number',
        loc: this.getLocation(this.tokenStart, this.tokenEnd),
        value: this.consume(Number$2)
    };
}

function generate$k(node) {
    this.token(Number$2, node.value);
}

var Number$1 = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$j,
    structure: structure$j,
    parse: parse$k,
    generate: generate$k
});

// '/' | '*' | ',' | ':' | '+' | '-'
const name$i = 'Operator';
const structure$i = {
    value: String
};

function parse$j() {
    const start = this.tokenStart;

    this.next();

    return {
        type: 'Operator',
        loc: this.getLocation(start, this.tokenStart),
        value: this.substrToCursor(start)
    };
}

function generate$j(node) {
    this.tokenize(node.value);
}

var Operator = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$i,
    structure: structure$i,
    parse: parse$j,
    generate: generate$j
});

const name$h = 'Parentheses';
const structure$h = {
    children: [[]]
};

function parse$i(readSequence, recognizer) {
    const start = this.tokenStart;
    let children = null;

    this.eat(LeftParenthesis);

    children = readSequence.call(this, recognizer);

    if (!this.eof) {
        this.eat(RightParenthesis);
    }

    return {
        type: 'Parentheses',
        loc: this.getLocation(start, this.tokenStart),
        children
    };
}

function generate$i(node) {
    this.token(LeftParenthesis, '(');
    this.children(node);
    this.token(RightParenthesis, ')');
}

var Parentheses = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$h,
    structure: structure$h,
    parse: parse$i,
    generate: generate$i
});

const name$g = 'Percentage';
const structure$g = {
    value: String
};

function parse$h() {
    return {
        type: 'Percentage',
        loc: this.getLocation(this.tokenStart, this.tokenEnd),
        value: this.consumeNumber(Percentage$1)
    };
}

function generate$h(node) {
    this.token(Percentage$1, node.value + '%');
}

var Percentage = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$g,
    structure: structure$g,
    parse: parse$h,
    generate: generate$h
});

const name$f = 'PseudoClassSelector';
const walkContext$4 = 'function';
const structure$f = {
    name: String,
    children: [['Raw'], null]
};

// : [ <ident> | <function-token> <any-value>? ) ]
function parse$g() {
    const start = this.tokenStart;
    let children = null;
    let name;
    let nameLowerCase;

    this.eat(Colon);

    if (this.tokenType === Function$1) {
        name = this.consumeFunctionName();
        nameLowerCase = name.toLowerCase();

        if (this.lookupNonWSType(0) == RightParenthesis) {
            children = this.createList();
        } else if (hasOwnProperty.call(this.pseudo, nameLowerCase)) {
            this.skipSC();
            children = this.pseudo[nameLowerCase].call(this);
            this.skipSC();
        } else {
            children = this.createList();
            children.push(
                this.Raw(null, false)
            );
        }

        this.eat(RightParenthesis);
    } else {
        name = this.consume(Ident);
    }

    return {
        type: 'PseudoClassSelector',
        loc: this.getLocation(start, this.tokenStart),
        name,
        children
    };
}

function generate$g(node) {
    this.token(Colon, ':');

    if (node.children === null) {
        this.token(Ident, node.name);
    } else {
        this.token(Function$1, node.name + '(');
        this.children(node);
        this.token(RightParenthesis, ')');
    }
}

var PseudoClassSelector = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$f,
    walkContext: walkContext$4,
    structure: structure$f,
    parse: parse$g,
    generate: generate$g
});

const name$e = 'PseudoElementSelector';
const walkContext$3 = 'function';
const structure$e = {
    name: String,
    children: [['Raw'], null]
};

// :: [ <ident> | <function-token> <any-value>? ) ]
function parse$f() {
    const start = this.tokenStart;
    let children = null;
    let name;
    let nameLowerCase;

    this.eat(Colon);
    this.eat(Colon);

    if (this.tokenType === Function$1) {
        name = this.consumeFunctionName();
        nameLowerCase = name.toLowerCase();

        if (this.lookupNonWSType(0) == RightParenthesis) {
            children = this.createList();
        } else if (hasOwnProperty.call(this.pseudo, nameLowerCase)) {
            this.skipSC();
            children = this.pseudo[nameLowerCase].call(this);
            this.skipSC();
        } else {
            children = this.createList();
            children.push(
                this.Raw(null, false)
            );
        }

        this.eat(RightParenthesis);
    } else {
        name = this.consume(Ident);
    }

    return {
        type: 'PseudoElementSelector',
        loc: this.getLocation(start, this.tokenStart),
        name,
        children
    };
}

function generate$f(node) {
    this.token(Colon, ':');
    this.token(Colon, ':');

    if (node.children === null) {
        this.token(Ident, node.name);
    } else {
        this.token(Function$1, node.name + '(');
        this.children(node);
        this.token(RightParenthesis, ')');
    }
}

var PseudoElementSelector = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$e,
    walkContext: walkContext$3,
    structure: structure$e,
    parse: parse$f,
    generate: generate$f
});

const SOLIDUS$2 = 0x002F;  // U+002F SOLIDUS (/)

// Media Queries Level 3 defines terms of <ratio> as a positive (not zero or negative)
// integers (see https://drafts.csswg.org/mediaqueries-3/#values)
// However, Media Queries Level 4 removes any definition of values
// (see https://drafts.csswg.org/mediaqueries-4/#values) and refers to
// CSS Values and Units for detail. In CSS Values and Units Level 4 a <ratio>
// definition was added (see https://drafts.csswg.org/css-values-4/#ratios) which
// defines ratio as "<number [0,∞]> [ / <number [0,∞]> ]?" and based on it
// any constrains on terms were removed. Parser also doesn't test numbers
// in any way to make possible for linting and fixing them by the tools using CSSTree.
// An additional syntax examination may be applied by a lexer.
function consumeTerm() {
    this.skipSC();

    switch (this.tokenType) {
        case Number$2:
            return this.Number();

        case Function$1:
            return this.Function(this.readSequence, this.scope.Value);

        default:
            this.error('Number of function is expected');
    }
}

const name$d = 'Ratio';
const structure$d = {
    left: ['Number', 'Function'],
    right: ['Number', 'Function', null]
};

// <number [0,∞]> [ / <number [0,∞]> ]?
function parse$e() {
    const start = this.tokenStart;
    const left = consumeTerm.call(this);
    let right = null;

    this.skipSC();
    if (this.isDelim(SOLIDUS$2)) {
        this.eatDelim(SOLIDUS$2);
        right = consumeTerm.call(this);
    }

    return {
        type: 'Ratio',
        loc: this.getLocation(start, this.tokenStart),
        left,
        right
    };
}

function generate$e(node) {
    this.node(node.left);
    this.token(Delim, '/');
    if (node.right) {
        this.node(node.right);
    } else {
        this.node(Number$2, 1);
    }
}

var Ratio = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$d,
    structure: structure$d,
    parse: parse$e,
    generate: generate$e
});

function getOffsetExcludeWS() {
    if (this.tokenIndex > 0) {
        if (this.lookupType(-1) === WhiteSpace$1) {
            return this.tokenIndex > 1
                ? this.getTokenStart(this.tokenIndex - 1)
                : this.firstCharOffset;
        }
    }

    return this.tokenStart;
}

const name$c = 'Raw';
const structure$c = {
    value: String
};

function parse$d(consumeUntil, excludeWhiteSpace) {
    const startOffset = this.getTokenStart(this.tokenIndex);
    let endOffset;

    this.skipUntilBalanced(this.tokenIndex, consumeUntil || this.consumeUntilBalanceEnd);

    if (excludeWhiteSpace && this.tokenStart > startOffset) {
        endOffset = getOffsetExcludeWS.call(this);
    } else {
        endOffset = this.tokenStart;
    }

    return {
        type: 'Raw',
        loc: this.getLocation(startOffset, endOffset),
        value: this.substring(startOffset, endOffset)
    };
}

function generate$d(node) {
    this.tokenize(node.value);
}

var Raw = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$c,
    structure: structure$c,
    parse: parse$d,
    generate: generate$d
});

function consumeRaw$1() {
    return this.Raw(this.consumeUntilLeftCurlyBracket, true);
}

function consumePrelude() {
    const prelude = this.SelectorList();

    if (prelude.type !== 'Raw' &&
        this.eof === false &&
        this.tokenType !== LeftCurlyBracket) {
        this.error();
    }

    return prelude;
}

const name$b = 'Rule';
const walkContext$2 = 'rule';
const structure$b = {
    prelude: ['SelectorList', 'Raw'],
    block: ['Block']
};

function parse$c() {
    const startToken = this.tokenIndex;
    const startOffset = this.tokenStart;
    let prelude;
    let block;

    if (this.parseRulePrelude) {
        prelude = this.parseWithFallback(consumePrelude, consumeRaw$1);
    } else {
        prelude = consumeRaw$1.call(this, startToken);
    }

    block = this.Block(true);

    return {
        type: 'Rule',
        loc: this.getLocation(startOffset, this.tokenStart),
        prelude,
        block
    };
}
function generate$c(node) {
    this.node(node.prelude);
    this.node(node.block);
}

var Rule = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$b,
    walkContext: walkContext$2,
    structure: structure$b,
    parse: parse$c,
    generate: generate$c
});

const name$a = 'Scope';
const structure$a = {
    root: ['SelectorList', 'Raw', null],
    limit: ['SelectorList', 'Raw', null]
};

function parse$b() {
    let root = null;
    let limit = null;

    this.skipSC();

    const startOffset = this.tokenStart;
    if (this.tokenType === LeftParenthesis) {
        this.next();
        this.skipSC();
        root = this.parseWithFallback(
            this.SelectorList,
            () => this.Raw(false, true)
        );
        this.skipSC();
        this.eat(RightParenthesis);
    }

    if (this.lookupNonWSType(0) === Ident) {
        this.skipSC();
        this.eatIdent('to');
        this.skipSC();
        this.eat(LeftParenthesis);
        this.skipSC();
        limit = this.parseWithFallback(
            this.SelectorList,
            () => this.Raw(false, true)
        );
        this.skipSC();
        this.eat(RightParenthesis);
    }

    return {
        type: 'Scope',
        loc: this.getLocation(startOffset, this.tokenStart),
        root,
        limit
    };
}

function generate$b(node) {
    if (node.root) {
        this.token(LeftParenthesis, '(');
        this.node(node.root);
        this.token(RightParenthesis, ')');
    }

    if (node.limit) {
        this.token(Ident, 'to');
        this.token(LeftParenthesis, '(');
        this.node(node.limit);
        this.token(RightParenthesis, ')');
    }
}

var Scope = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$a,
    structure: structure$a,
    parse: parse$b,
    generate: generate$b
});

const name$9 = 'Selector';
const structure$9 = {
    children: [[
        'TypeSelector',
        'IdSelector',
        'ClassSelector',
        'AttributeSelector',
        'PseudoClassSelector',
        'PseudoElementSelector',
        'Combinator'
    ]]
};

function parse$a() {
    const children = this.readSequence(this.scope.Selector);

    // nothing were consumed
    if (this.getFirstListNode(children) === null) {
        this.error('Selector is expected');
    }

    return {
        type: 'Selector',
        loc: this.getLocationFromList(children),
        children
    };
}

function generate$a(node) {
    this.children(node);
}

var Selector = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$9,
    structure: structure$9,
    parse: parse$a,
    generate: generate$a
});

const name$8 = 'SelectorList';
const walkContext$1 = 'selector';
const structure$8 = {
    children: [[
        'Selector',
        'Raw'
    ]]
};

function parse$9() {
    const children = this.createList();

    while (!this.eof) {
        children.push(this.Selector());

        if (this.tokenType === Comma) {
            this.next();
            continue;
        }

        break;
    }

    return {
        type: 'SelectorList',
        loc: this.getLocationFromList(children),
        children
    };
}

function generate$9(node) {
    this.children(node, () => this.token(Comma, ','));
}

var SelectorList = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$8,
    walkContext: walkContext$1,
    structure: structure$8,
    parse: parse$9,
    generate: generate$9
});

const REVERSE_SOLIDUS$2 = 0x005c; // U+005C REVERSE SOLIDUS (\)
const QUOTATION_MARK$1 = 0x0022;  // "
const APOSTROPHE$1 = 0x0027;      // '

function decode$2(str) {
    const len = str.length;
    const firstChar = str.charCodeAt(0);
    const start = firstChar === QUOTATION_MARK$1 || firstChar === APOSTROPHE$1 ? 1 : 0;
    const end = start === 1 && len > 1 && str.charCodeAt(len - 1) === firstChar ? len - 2 : len - 1;
    let decoded = '';

    for (let i = start; i <= end; i++) {
        let code = str.charCodeAt(i);

        if (code === REVERSE_SOLIDUS$2) {
            // special case at the ending
            if (i === end) {
                // if the next input code point is EOF, do nothing
                // otherwise include last quote as escaped
                if (i !== len - 1) {
                    decoded = str.substr(i + 1);
                }
                break;
            }

            code = str.charCodeAt(++i);

            // consume escaped
            if (isValidEscape(REVERSE_SOLIDUS$2, code)) {
                const escapeStart = i - 1;
                const escapeEnd = consumeEscaped(str, escapeStart);

                i = escapeEnd - 1;
                decoded += decodeEscaped(str.substring(escapeStart + 1, escapeEnd));
            } else {
                // \r\n
                if (code === 0x000d && str.charCodeAt(i + 1) === 0x000a) {
                    i++;
                }
            }
        } else {
            decoded += str[i];
        }
    }

    return decoded;
}

// https://drafts.csswg.org/cssom/#serialize-a-string
// § 2.1. Common Serializing Idioms
function encode$2(str, apostrophe) {
    const quote = apostrophe ? '\'' : '"';
    const quoteCode = apostrophe ? APOSTROPHE$1 : QUOTATION_MARK$1;
    let encoded = '';
    let wsBeforeHexIsNeeded = false;

    for (let i = 0; i < str.length; i++) {
        const code = str.charCodeAt(i);

        // If the character is NULL (U+0000), then the REPLACEMENT CHARACTER (U+FFFD).
        if (code === 0x0000) {
            encoded += '\uFFFD';
            continue;
        }

        // If the character is in the range [\1-\1f] (U+0001 to U+001F) or is U+007F,
        // the character escaped as code point.
        // Note: Do not compare with 0x0001 since 0x0000 is precessed before
        if (code <= 0x001f || code === 0x007F) {
            encoded += '\\' + code.toString(16);
            wsBeforeHexIsNeeded = true;
            continue;
        }

        // If the character is '"' (U+0022) or "\" (U+005C), the escaped character.
        if (code === quoteCode || code === REVERSE_SOLIDUS$2) {
            encoded += '\\' + str.charAt(i);
            wsBeforeHexIsNeeded = false;
        } else {
            if (wsBeforeHexIsNeeded && (isHexDigit(code) || isWhiteSpace(code))) {
                encoded += ' ';
            }

            // Otherwise, the character itself.
            encoded += str.charAt(i);
            wsBeforeHexIsNeeded = false;
        }
    }

    return quote + encoded + quote;
}

var string = /*#__PURE__*/Object.freeze({
    __proto__: null,
    decode: decode$2,
    encode: encode$2
});

const name$7 = 'String';
const structure$7 = {
    value: String
};

function parse$8() {
    return {
        type: 'String',
        loc: this.getLocation(this.tokenStart, this.tokenEnd),
        value: decode$2(this.consume(String$2))
    };
}

function generate$8(node) {
    this.token(String$2, encode$2(node.value));
}

var String$1 = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$7,
    structure: structure$7,
    parse: parse$8,
    generate: generate$8
});

const EXCLAMATIONMARK = 0x0021; // U+0021 EXCLAMATION MARK (!)

function consumeRaw() {
    return this.Raw(null, false);
}

const name$6 = 'StyleSheet';
const walkContext = 'stylesheet';
const structure$6 = {
    children: [[
        'Comment',
        'CDO',
        'CDC',
        'Atrule',
        'Rule',
        'Raw'
    ]]
};

function parse$7() {
    const start = this.tokenStart;
    const children = this.createList();
    let child;

    while (!this.eof) {
        switch (this.tokenType) {
            case WhiteSpace$1:
                this.next();
                continue;

            case Comment$1:
                // ignore comments except exclamation comments (i.e. /*! .. */) on top level
                if (this.charCodeAt(this.tokenStart + 2) !== EXCLAMATIONMARK) {
                    this.next();
                    continue;
                }

                child = this.Comment();
                break;

            case CDO$1: // <!--
                child = this.CDO();
                break;

            case CDC$1: // -->
                child = this.CDC();
                break;

            // CSS Syntax Module Level 3
            // §2.2 Error handling
            // At the "top level" of a stylesheet, an <at-keyword-token> starts an at-rule.
            case AtKeyword:
                child = this.parseWithFallback(this.Atrule, consumeRaw);
                break;

            // Anything else starts a qualified rule ...
            default:
                child = this.parseWithFallback(this.Rule, consumeRaw);
        }

        children.push(child);
    }

    return {
        type: 'StyleSheet',
        loc: this.getLocation(start, this.tokenStart),
        children
    };
}

function generate$7(node) {
    this.children(node);
}

var StyleSheet = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$6,
    walkContext: walkContext,
    structure: structure$6,
    parse: parse$7,
    generate: generate$7
});

const name$5 = 'SupportsDeclaration';
const structure$5 = {
    declaration: 'Declaration'
};

function parse$6() {
    const start = this.tokenStart;

    this.eat(LeftParenthesis);
    this.skipSC();

    const declaration = this.Declaration();

    if (!this.eof) {
        this.eat(RightParenthesis);
    }

    return {
        type: 'SupportsDeclaration',
        loc: this.getLocation(start, this.tokenStart),
        declaration
    };
}

function generate$6(node) {
    this.token(LeftParenthesis, '(');
    this.node(node.declaration);
    this.token(RightParenthesis, ')');
}

var SupportsDeclaration = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$5,
    structure: structure$5,
    parse: parse$6,
    generate: generate$6
});

const ASTERISK$2 = 0x002A;     // U+002A ASTERISK (*)
const VERTICALLINE$1 = 0x007C; // U+007C VERTICAL LINE (|)

function eatIdentifierOrAsterisk() {
    if (this.tokenType !== Ident &&
        this.isDelim(ASTERISK$2) === false) {
        this.error('Identifier or asterisk is expected');
    }

    this.next();
}

const name$4 = 'TypeSelector';
const structure$4 = {
    name: String
};

// ident
// ident|ident
// ident|*
// *
// *|ident
// *|*
// |ident
// |*
function parse$5() {
    const start = this.tokenStart;

    if (this.isDelim(VERTICALLINE$1)) {
        this.next();
        eatIdentifierOrAsterisk.call(this);
    } else {
        eatIdentifierOrAsterisk.call(this);

        if (this.isDelim(VERTICALLINE$1)) {
            this.next();
            eatIdentifierOrAsterisk.call(this);
        }
    }

    return {
        type: 'TypeSelector',
        loc: this.getLocation(start, this.tokenStart),
        name: this.substrToCursor(start)
    };
}

function generate$5(node) {
    this.tokenize(node.name);
}

var TypeSelector = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$4,
    structure: structure$4,
    parse: parse$5,
    generate: generate$5
});

const PLUSSIGN$2 = 0x002B;     // U+002B PLUS SIGN (+)
const HYPHENMINUS$1 = 0x002D;  // U+002D HYPHEN-MINUS (-)
const QUESTIONMARK = 0x003F; // U+003F QUESTION MARK (?)

function eatHexSequence(offset, allowDash) {
    let len = 0;

    for (let pos = this.tokenStart + offset; pos < this.tokenEnd; pos++) {
        const code = this.charCodeAt(pos);

        if (code === HYPHENMINUS$1 && allowDash && len !== 0) {
            eatHexSequence.call(this, offset + len + 1, false);
            return -1;
        }

        if (!isHexDigit(code)) {
            this.error(
                allowDash && len !== 0
                    ? 'Hyphen minus' + (len < 6 ? ' or hex digit' : '') + ' is expected'
                    : (len < 6 ? 'Hex digit is expected' : 'Unexpected input'),
                pos
            );
        }

        if (++len > 6) {
            this.error('Too many hex digits', pos);
        }    }

    this.next();
    return len;
}

function eatQuestionMarkSequence(max) {
    let count = 0;

    while (this.isDelim(QUESTIONMARK)) {
        if (++count > max) {
            this.error('Too many question marks');
        }

        this.next();
    }
}

function startsWith(code) {
    if (this.charCodeAt(this.tokenStart) !== code) {
        this.error((code === PLUSSIGN$2 ? 'Plus sign' : 'Hyphen minus') + ' is expected');
    }
}

// https://drafts.csswg.org/css-syntax/#urange
// Informally, the <urange> production has three forms:
// U+0001
//      Defines a range consisting of a single code point, in this case the code point "1".
// U+0001-00ff
//      Defines a range of codepoints between the first and the second value, in this case
//      the range between "1" and "ff" (255 in decimal) inclusive.
// U+00??
//      Defines a range of codepoints where the "?" characters range over all hex digits,
//      in this case defining the same as the value U+0000-00ff.
// In each form, a maximum of 6 digits is allowed for each hexadecimal number (if you treat "?" as a hexadecimal digit).
//
// <urange> =
//   u '+' <ident-token> '?'* |
//   u <dimension-token> '?'* |
//   u <number-token> '?'* |
//   u <number-token> <dimension-token> |
//   u <number-token> <number-token> |
//   u '+' '?'+
function scanUnicodeRange() {
    let hexLength = 0;

    switch (this.tokenType) {
        case Number$2:
            // u <number-token> '?'*
            // u <number-token> <dimension-token>
            // u <number-token> <number-token>
            hexLength = eatHexSequence.call(this, 1, true);

            if (this.isDelim(QUESTIONMARK)) {
                eatQuestionMarkSequence.call(this, 6 - hexLength);
                break;
            }

            if (this.tokenType === Dimension$1 ||
                this.tokenType === Number$2) {
                startsWith.call(this, HYPHENMINUS$1);
                eatHexSequence.call(this, 1, false);
                break;
            }

            break;

        case Dimension$1:
            // u <dimension-token> '?'*
            hexLength = eatHexSequence.call(this, 1, true);

            if (hexLength > 0) {
                eatQuestionMarkSequence.call(this, 6 - hexLength);
            }

            break;

        default:
            // u '+' <ident-token> '?'*
            // u '+' '?'+
            this.eatDelim(PLUSSIGN$2);

            if (this.tokenType === Ident) {
                hexLength = eatHexSequence.call(this, 0, true);
                if (hexLength > 0) {
                    eatQuestionMarkSequence.call(this, 6 - hexLength);
                }
                break;
            }

            if (this.isDelim(QUESTIONMARK)) {
                this.next();
                eatQuestionMarkSequence.call(this, 5);
                break;
            }

            this.error('Hex digit or question mark is expected');
    }
}

const name$3 = 'UnicodeRange';
const structure$3 = {
    value: String
};

function parse$4() {
    const start = this.tokenStart;

    // U or u
    this.eatIdent('u');
    scanUnicodeRange.call(this);

    return {
        type: 'UnicodeRange',
        loc: this.getLocation(start, this.tokenStart),
        value: this.substrToCursor(start)
    };
}

function generate$4(node) {
    this.tokenize(node.value);
}

var UnicodeRange = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$3,
    structure: structure$3,
    parse: parse$4,
    generate: generate$4
});

const SPACE$1 = 0x0020;            // U+0020 SPACE
const REVERSE_SOLIDUS$1 = 0x005c;  // U+005C REVERSE SOLIDUS (\)
const QUOTATION_MARK = 0x0022;   // "
const APOSTROPHE = 0x0027;       // '
const LEFTPARENTHESIS = 0x0028;  // U+0028 LEFT PARENTHESIS (()
const RIGHTPARENTHESIS = 0x0029; // U+0029 RIGHT PARENTHESIS ())

function decode$1(str) {
    const len = str.length;
    let start = 4; // length of "url("
    let end = str.charCodeAt(len - 1) === RIGHTPARENTHESIS ? len - 2 : len - 1;
    let decoded = '';

    while (start < end && isWhiteSpace(str.charCodeAt(start))) {
        start++;
    }

    while (start < end && isWhiteSpace(str.charCodeAt(end))) {
        end--;
    }

    for (let i = start; i <= end; i++) {
        let code = str.charCodeAt(i);

        if (code === REVERSE_SOLIDUS$1) {
            // special case at the ending
            if (i === end) {
                // if the next input code point is EOF, do nothing
                // otherwise include last left parenthesis as escaped
                if (i !== len - 1) {
                    decoded = str.substr(i + 1);
                }
                break;
            }

            code = str.charCodeAt(++i);

            // consume escaped
            if (isValidEscape(REVERSE_SOLIDUS$1, code)) {
                const escapeStart = i - 1;
                const escapeEnd = consumeEscaped(str, escapeStart);

                i = escapeEnd - 1;
                decoded += decodeEscaped(str.substring(escapeStart + 1, escapeEnd));
            } else {
                // \r\n
                if (code === 0x000d && str.charCodeAt(i + 1) === 0x000a) {
                    i++;
                }
            }
        } else {
            decoded += str[i];
        }
    }

    return decoded;
}

function encode$1(str) {
    let encoded = '';
    let wsBeforeHexIsNeeded = false;

    for (let i = 0; i < str.length; i++) {
        const code = str.charCodeAt(i);

        // If the character is NULL (U+0000), then the REPLACEMENT CHARACTER (U+FFFD).
        if (code === 0x0000) {
            encoded += '\uFFFD';
            continue;
        }

        // If the character is in the range [\1-\1f] (U+0001 to U+001F) or is U+007F,
        // the character escaped as code point.
        // Note: Do not compare with 0x0001 since 0x0000 is precessed before
        if (code <= 0x001f || code === 0x007F) {
            encoded += '\\' + code.toString(16);
            wsBeforeHexIsNeeded = true;
            continue;
        }

        if (code === SPACE$1 ||
            code === REVERSE_SOLIDUS$1 ||
            code === QUOTATION_MARK ||
            code === APOSTROPHE ||
            code === LEFTPARENTHESIS ||
            code === RIGHTPARENTHESIS) {
            encoded += '\\' + str.charAt(i);
            wsBeforeHexIsNeeded = false;
        } else {
            if (wsBeforeHexIsNeeded && isHexDigit(code)) {
                encoded += ' ';
            }

            encoded += str.charAt(i);
            wsBeforeHexIsNeeded = false;
        }
    }

    return 'url(' + encoded + ')';
}

var url = /*#__PURE__*/Object.freeze({
    __proto__: null,
    decode: decode$1,
    encode: encode$1
});

const name$2 = 'Url';
const structure$2 = {
    value: String
};

// <url-token> | <function-token> <string> )
function parse$3() {
    const start = this.tokenStart;
    let value;

    switch (this.tokenType) {
        case Url$1:
            value = decode$1(this.consume(Url$1));
            break;

        case Function$1:
            if (!this.cmpStr(this.tokenStart, this.tokenEnd, 'url(')) {
                this.error('Function name must be `url`');
            }

            this.eat(Function$1);
            this.skipSC();
            value = decode$2(this.consume(String$2));
            this.skipSC();
            if (!this.eof) {
                this.eat(RightParenthesis);
            }
            break;

        default:
            this.error('Url or Function is expected');
    }

    return {
        type: 'Url',
        loc: this.getLocation(start, this.tokenStart),
        value
    };
}

function generate$3(node) {
    this.token(Url$1, encode$1(node.value));
}

var Url = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$2,
    structure: structure$2,
    parse: parse$3,
    generate: generate$3
});

const name$1 = 'Value';
const structure$1 = {
    children: [[]]
};

function parse$2() {
    const start = this.tokenStart;
    const children = this.readSequence(this.scope.Value);

    return {
        type: 'Value',
        loc: this.getLocation(start, this.tokenStart),
        children
    };
}

function generate$2(node) {
    this.children(node);
}

var Value = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name$1,
    structure: structure$1,
    parse: parse$2,
    generate: generate$2
});

const SPACE = Object.freeze({
    type: 'WhiteSpace',
    loc: null,
    value: ' '
});

const name = 'WhiteSpace';
const structure = {
    value: String
};

function parse$1() {
    this.eat(WhiteSpace$1);
    return SPACE;

    // return {
    //     type: 'WhiteSpace',
    //     loc: this.getLocation(this.tokenStart, this.tokenEnd),
    //     value: this.consume(WHITESPACE)
    // };
}

function generate$1(node) {
    this.token(WhiteSpace$1, node.value);
}

var WhiteSpace = /*#__PURE__*/Object.freeze({
    __proto__: null,
    name: name,
    structure: structure,
    parse: parse$1,
    generate: generate$1
});

var node$1 = /*#__PURE__*/Object.freeze({
    __proto__: null,
    AnPlusB: AnPlusB,
    Atrule: Atrule,
    AtrulePrelude: AtrulePrelude,
    AttributeSelector: AttributeSelector,
    Block: Block,
    Brackets: Brackets,
    CDC: CDC,
    CDO: CDO,
    ClassSelector: ClassSelector,
    Combinator: Combinator,
    Comment: Comment,
    Condition: Condition,
    Declaration: Declaration,
    DeclarationList: DeclarationList,
    Dimension: Dimension,
    Feature: Feature,
    FeatureFunction: FeatureFunction,
    FeatureRange: FeatureRange,
    Function: Function,
    GeneralEnclosed: GeneralEnclosed,
    Hash: Hash,
    Identifier: Identifier,
    IdSelector: IdSelector,
    Layer: Layer,
    LayerList: LayerList,
    MediaQuery: MediaQuery,
    MediaQueryList: MediaQueryList,
    NestingSelector: NestingSelector,
    Nth: Nth,
    Number: Number$1,
    Operator: Operator,
    Parentheses: Parentheses,
    Percentage: Percentage,
    PseudoClassSelector: PseudoClassSelector,
    PseudoElementSelector: PseudoElementSelector,
    Ratio: Ratio,
    Raw: Raw,
    Rule: Rule,
    Scope: Scope,
    Selector: Selector,
    SelectorList: SelectorList,
    String: String$1,
    StyleSheet: StyleSheet,
    SupportsDeclaration: SupportsDeclaration,
    TypeSelector: TypeSelector,
    UnicodeRange: UnicodeRange,
    Url: Url,
    Value: Value,
    WhiteSpace: WhiteSpace
});

var lexerConfig = {
    generic: true,
    cssWideKeywords,
    ...definitions,
    node: node$1
};

const NUMBERSIGN$1 = 0x0023;  // U+0023 NUMBER SIGN (#)
const ASTERISK$1 = 0x002A;    // U+002A ASTERISK (*)
const PLUSSIGN$1 = 0x002B;    // U+002B PLUS SIGN (+)
const HYPHENMINUS = 0x002D; // U+002D HYPHEN-MINUS (-)
const SOLIDUS$1 = 0x002F;     // U+002F SOLIDUS (/)
const U = 0x0075;           // U+0075 LATIN SMALL LETTER U (u)

function defaultRecognizer(context) {
    switch (this.tokenType) {
        case Hash$1:
            return this.Hash();

        case Comma:
            return this.Operator();

        case LeftParenthesis:
            return this.Parentheses(this.readSequence, context.recognizer);

        case LeftSquareBracket:
            return this.Brackets(this.readSequence, context.recognizer);

        case String$2:
            return this.String();

        case Dimension$1:
            return this.Dimension();

        case Percentage$1:
            return this.Percentage();

        case Number$2:
            return this.Number();

        case Function$1:
            return this.cmpStr(this.tokenStart, this.tokenEnd, 'url(')
                ? this.Url()
                : this.Function(this.readSequence, context.recognizer);

        case Url$1:
            return this.Url();

        case Ident:
            // check for unicode range, it should start with u+ or U+
            if (this.cmpChar(this.tokenStart, U) &&
                this.cmpChar(this.tokenStart + 1, PLUSSIGN$1)) {
                return this.UnicodeRange();
            } else {
                return this.Identifier();
            }

        case Delim: {
            const code = this.charCodeAt(this.tokenStart);

            if (code === SOLIDUS$1 ||
                code === ASTERISK$1 ||
                code === PLUSSIGN$1 ||
                code === HYPHENMINUS) {
                return this.Operator(); // TODO: replace with Delim
            }

            // TODO: produce a node with Delim node type

            if (code === NUMBERSIGN$1) {
                this.error('Hex or identifier is expected', this.tokenStart + 1);
            }

            break;
        }
    }
}

var atrulePrelude = {
    getNode: defaultRecognizer
};

const NUMBERSIGN = 0x0023;      // U+0023 NUMBER SIGN (#)
const AMPERSAND = 0x0026;       // U+0026 AMPERSAND (&)
const ASTERISK = 0x002A;        // U+002A ASTERISK (*)
const PLUSSIGN = 0x002B;        // U+002B PLUS SIGN (+)
const SOLIDUS = 0x002F;         // U+002F SOLIDUS (/)
const FULLSTOP = 0x002E;        // U+002E FULL STOP (.)
const GREATERTHANSIGN = 0x003E; // U+003E GREATER-THAN SIGN (>)
const VERTICALLINE = 0x007C;    // U+007C VERTICAL LINE (|)
const TILDE = 0x007E;           // U+007E TILDE (~)

function onWhiteSpace(next, children) {
    if (children.last !== null && children.last.type !== 'Combinator' &&
        next !== null && next.type !== 'Combinator') {
        children.push({  // FIXME: this.Combinator() should be used instead
            type: 'Combinator',
            loc: null,
            name: ' '
        });
    }
}

function getNode() {
    switch (this.tokenType) {
        case LeftSquareBracket:
            return this.AttributeSelector();

        case Hash$1:
            return this.IdSelector();

        case Colon:
            if (this.lookupType(1) === Colon) {
                return this.PseudoElementSelector();
            } else {
                return this.PseudoClassSelector();
            }

        case Ident:
            return this.TypeSelector();

        case Number$2:
        case Percentage$1:
            return this.Percentage();

        case Dimension$1:
            // throws when .123ident
            if (this.charCodeAt(this.tokenStart) === FULLSTOP) {
                this.error('Identifier is expected', this.tokenStart + 1);
            }
            break;

        case Delim: {
            const code = this.charCodeAt(this.tokenStart);

            switch (code) {
                case PLUSSIGN:
                case GREATERTHANSIGN:
                case TILDE:
                case SOLIDUS:  // /deep/
                    return this.Combinator();

                case FULLSTOP:
                    return this.ClassSelector();

                case ASTERISK:
                case VERTICALLINE:
                    return this.TypeSelector();

                case NUMBERSIGN:
                    return this.IdSelector();

                case AMPERSAND:
                    return this.NestingSelector();
            }

            break;
        }
    }
}
var selector$1 = {
    onWhiteSpace,
    getNode
};

// legacy IE function
// expression( <any-value> )
function expressionFn() {
    return this.createSingleNodeList(
        this.Raw(null, false)
    );
}

// var( <ident> , <value>? )
function varFn() {
    const children = this.createList();

    this.skipSC();

    // NOTE: Don't check more than a first argument is an ident, rest checks are for lexer
    children.push(this.Identifier());

    this.skipSC();

    if (this.tokenType === Comma) {
        children.push(this.Operator());

        const startIndex = this.tokenIndex;
        const value = this.parseCustomProperty
            ? this.Value(null)
            : this.Raw(this.consumeUntilExclamationMarkOrSemicolon, false);

        if (value.type === 'Value' && value.children.isEmpty) {
            for (let offset = startIndex - this.tokenIndex; offset <= 0; offset++) {
                if (this.lookupType(offset) === WhiteSpace$1) {
                    value.children.appendData({
                        type: 'WhiteSpace',
                        loc: null,
                        value: ' '
                    });
                    break;
                }
            }
        }

        children.push(value);
    }

    return children;
}

function isPlusMinusOperator(node) {
    return (
        node !== null &&
        node.type === 'Operator' &&
        (node.value[node.value.length - 1] === '-' || node.value[node.value.length - 1] === '+')
    );
}

var value = {
    getNode: defaultRecognizer,
    onWhiteSpace(next, children) {
        if (isPlusMinusOperator(next)) {
            next.value = ' ' + next.value;
        }
        if (isPlusMinusOperator(children.last)) {
            children.last.value += ' ';
        }
    },
    'expression': expressionFn,
    'var': varFn
};

var scope$1 = /*#__PURE__*/Object.freeze({
    __proto__: null,
    AtrulePrelude: atrulePrelude,
    Selector: selector$1,
    Value: value
});

// https://drafts.csswg.org/css-contain-3/#container-rule
// The keywords `none`, `and`, `not`, and `or` are excluded from the <custom-ident> above.
const nonContainerNameKeywords = new Set(['none', 'and', 'not', 'or']);

var container = {
    parse: {
        prelude() {
            const children = this.createList();

            if (this.tokenType === Ident) {
                const name = this.substring(this.tokenStart, this.tokenEnd);

                if (!nonContainerNameKeywords.has(name.toLowerCase())) {
                    children.push(this.Identifier());
                }
            }

            children.push(this.Condition('container'));

            return children;
        },
        block(nested = false) {
            return this.Block(nested);
        }
    }
};

var fontFace = {
    parse: {
        prelude: null,
        block() {
            return this.Block(true);
        }
    }
};

function parseWithFallback(parse, fallback) {
    return this.parseWithFallback(
        () => {
            try {
                return parse.call(this);
            } finally {
                this.skipSC();
                if (this.lookupNonWSType(0) !== RightParenthesis) {
                    this.error();
                }
            }
        },
        fallback || (() => this.Raw(null, true))
    );
}

const parseFunctions = {
    layer() {
        this.skipSC();

        const children = this.createList();
        const node = parseWithFallback.call(this, this.Layer);

        if (node.type !== 'Raw' || node.value !== '') {
            children.push(node);
        }

        return children;
    },
    supports() {
        this.skipSC();

        const children = this.createList();
        const node = parseWithFallback.call(
            this,
            this.Declaration,
            () => parseWithFallback.call(this, () => this.Condition('supports'))
        );

        if (node.type !== 'Raw' || node.value !== '') {
            children.push(node);
        }

        return children;
    }
};

var importAtrule = {
    parse: {
        prelude() {
            const children = this.createList();

            switch (this.tokenType) {
                case String$2:
                    children.push(this.String());
                    break;

                case Url$1:
                case Function$1:
                    children.push(this.Url());
                    break;

                default:
                    this.error('String or url() is expected');
            }

            this.skipSC();

            if (this.tokenType === Ident &&
                this.cmpStr(this.tokenStart, this.tokenEnd, 'layer')) {
                children.push(this.Identifier());
            } else if (
                this.tokenType === Function$1 &&
                this.cmpStr(this.tokenStart, this.tokenEnd, 'layer(')
            ) {
                children.push(this.Function(null, parseFunctions));
            }

            this.skipSC();

            if (this.tokenType === Function$1 &&
                this.cmpStr(this.tokenStart, this.tokenEnd, 'supports(')) {
                children.push(this.Function(null, parseFunctions));
            }

            if (this.lookupNonWSType(0) === Ident ||
                this.lookupNonWSType(0) === LeftParenthesis) {
                children.push(this.MediaQueryList());
            }

            return children;
        },
        block: null
    }
};

var layer = {
    parse: {
        prelude() {
            return this.createSingleNodeList(
                this.LayerList()
            );
        },
        block() {
            return this.Block(false);
        }
    }
};

var media = {
    parse: {
        prelude() {
            return this.createSingleNodeList(
                this.MediaQueryList()
            );
        },
        block(nested = false) {
            return this.Block(nested);
        }
    }
};

var nest = {
    parse: {
        prelude() {
            return this.createSingleNodeList(
                this.SelectorList()
            );
        },
        block() {
            return this.Block(true);
        }
    }
};

var page = {
    parse: {
        prelude() {
            return this.createSingleNodeList(
                this.SelectorList()
            );
        },
        block() {
            return this.Block(true);
        }
    }
};

var scope = {
    parse: {
        prelude() {
            return this.createSingleNodeList(
                this.Scope()
            );
        },
        block(nested = false) {
            return this.Block(nested);
        }
    }
};

var startingStyle = {
    parse: {
        prelude: null,
        block(nested = false) {
            return this.Block(nested);
        }
    }
};

var supports = {
    parse: {
        prelude() {
            return this.createSingleNodeList(
                this.Condition('supports')
            );
        },
        block(nested = false) {
            return this.Block(nested);
        }
    }
};

var atrule = {
    container,
    'font-face': fontFace,
    import: importAtrule,
    layer,
    media,
    nest,
    page,
    scope,
    'starting-style': startingStyle,
    supports
};

function parseLanguageRangeList() {
    const children = this.createList();

    this.skipSC();

    loop: while (!this.eof) {
        switch (this.tokenType) {
            case Ident:
                children.push(this.Identifier());
                break;

            case String$2:
                children.push(this.String());
                break;

            case Comma:
                children.push(this.Operator());
                break;

            case RightParenthesis:
                break loop;

            default:
                this.error('Identifier, string or comma is expected');
        }

        this.skipSC();
    }

    return children;
}

const selectorList = {
    parse() {
        return this.createSingleNodeList(
            this.SelectorList()
        );
    }
};

const selector = {
    parse() {
        return this.createSingleNodeList(
            this.Selector()
        );
    }
};

const identList = {
    parse() {
        return this.createSingleNodeList(
            this.Identifier()
        );
    }
};

const langList = {
    parse: parseLanguageRangeList
};

const nth = {
    parse() {
        return this.createSingleNodeList(
            this.Nth()
        );
    }
};

var pseudo = {
    'dir': identList,
    'has': selectorList,
    'lang': langList,
    'matches': selectorList,
    'is': selectorList,
    '-moz-any': selectorList,
    '-webkit-any': selectorList,
    'where': selectorList,
    'not': selectorList,
    'nth-child': nth,
    'nth-last-child': nth,
    'nth-last-of-type': nth,
    'nth-of-type': nth,
    'slotted': selector,
    'host': selector,
    'host-context': selector
};

var node = /*#__PURE__*/Object.freeze({
    __proto__: null,
    AnPlusB: parse$N,
    Atrule: parse$M,
    AtrulePrelude: parse$L,
    AttributeSelector: parse$K,
    Block: parse$J,
    Brackets: parse$I,
    CDC: parse$H,
    CDO: parse$G,
    ClassSelector: parse$F,
    Combinator: parse$E,
    Comment: parse$D,
    Condition: parse$C,
    Declaration: parse$B,
    DeclarationList: parse$A,
    Dimension: parse$z,
    Feature: parse$y,
    FeatureFunction: parse$x,
    FeatureRange: parse$w,
    Function: parse$v,
    GeneralEnclosed: parse$u,
    Hash: parse$t,
    Identifier: parse$s,
    IdSelector: parse$r,
    Layer: parse$q,
    LayerList: parse$p,
    MediaQuery: parse$o,
    MediaQueryList: parse$n,
    NestingSelector: parse$m,
    Nth: parse$l,
    Number: parse$k,
    Operator: parse$j,
    Parentheses: parse$i,
    Percentage: parse$h,
    PseudoClassSelector: parse$g,
    PseudoElementSelector: parse$f,
    Ratio: parse$e,
    Raw: parse$d,
    Rule: parse$c,
    Scope: parse$b,
    Selector: parse$a,
    SelectorList: parse$9,
    String: parse$8,
    StyleSheet: parse$7,
    SupportsDeclaration: parse$6,
    TypeSelector: parse$5,
    UnicodeRange: parse$4,
    Url: parse$3,
    Value: parse$2,
    WhiteSpace: parse$1
});

var parserConfig = {
    parseContext: {
        default: 'StyleSheet',
        stylesheet: 'StyleSheet',
        atrule: 'Atrule',
        atrulePrelude(options) {
            return this.AtrulePrelude(options.atrule ? String(options.atrule) : null);
        },
        mediaQueryList: 'MediaQueryList',
        mediaQuery: 'MediaQuery',
        condition(options) {
            return this.Condition(options.kind);
        },
        rule: 'Rule',
        selectorList: 'SelectorList',
        selector: 'Selector',
        block() {
            return this.Block(true);
        },
        declarationList: 'DeclarationList',
        declaration: 'Declaration',
        value: 'Value'
    },
    features: {
        supports: {
            selector() {
                return this.Selector();
            }
        },
        container: {
            style() {
                return this.Declaration();
            }
        }
    },
    scope: scope$1,
    atrule,
    pseudo,
    node
};

var walkerConfig = {
    node: node$1
};

var syntax = createSyntax$1({
    ...lexerConfig,
    ...parserConfig,
    ...walkerConfig
});

const version = "3.1.0";

function clone(node) {
    const result = {};

    for (const key of Object.keys(node)) {
        let value = node[key];

        if (value) {
            if (Array.isArray(value) || value instanceof List) {
                value = value.map(clone);
            } else if (value.constructor === Object) {
                value = clone(value);
            }
        }

        result[key] = value;
    }

    return result;
}

const REVERSE_SOLIDUS = 0x005c; // U+005C REVERSE SOLIDUS (\)

function decode(str) {
    const end = str.length - 1;
    let decoded = '';

    for (let i = 0; i < str.length; i++) {
        let code = str.charCodeAt(i);

        if (code === REVERSE_SOLIDUS) {
            // special case at the ending
            if (i === end) {
                // if the next input code point is EOF, do nothing
                break;
            }

            code = str.charCodeAt(++i);

            // consume escaped
            if (isValidEscape(REVERSE_SOLIDUS, code)) {
                const escapeStart = i - 1;
                const escapeEnd = consumeEscaped(str, escapeStart);

                i = escapeEnd - 1;
                decoded += decodeEscaped(str.substring(escapeStart + 1, escapeEnd));
            } else {
                // \r\n
                if (code === 0x000d && str.charCodeAt(i + 1) === 0x000a) {
                    i++;
                }
            }
        } else {
            decoded += str[i];
        }
    }

    return decoded;
}

// https://drafts.csswg.org/cssom/#serialize-an-identifier
// § 2.1. Common Serializing Idioms
function encode(str) {
    let encoded = '';

    // If the character is the first character and is a "-" (U+002D),
    // and there is no second character, then the escaped character.
    // Note: That's means a single dash string "-" return as escaped dash,
    // so move the condition out of the main loop
    if (str.length === 1 && str.charCodeAt(0) === 0x002D) {
        return '\\-';
    }

    // To serialize an identifier means to create a string represented
    // by the concatenation of, for each character of the identifier:
    for (let i = 0; i < str.length; i++) {
        const code = str.charCodeAt(i);

        // If the character is NULL (U+0000), then the REPLACEMENT CHARACTER (U+FFFD).
        if (code === 0x0000) {
            encoded += '\uFFFD';
            continue;
        }

        if (
            // If the character is in the range [\1-\1f] (U+0001 to U+001F) or is U+007F ...
            // Note: Do not compare with 0x0001 since 0x0000 is precessed before
            code <= 0x001F || code === 0x007F ||
            // [or] ... is in the range [0-9] (U+0030 to U+0039),
            (code >= 0x0030 && code <= 0x0039 && (
                // If the character is the first character ...
                i === 0 ||
                // If the character is the second character ... and the first character is a "-" (U+002D)
                i === 1 && str.charCodeAt(0) === 0x002D
            ))
        ) {
            // ... then the character escaped as code point.
            encoded += '\\' + code.toString(16) + ' ';
            continue;
        }

        // If the character is not handled by one of the above rules and is greater
        // than or equal to U+0080, is "-" (U+002D) or "_" (U+005F), or is in one
        // of the ranges [0-9] (U+0030 to U+0039), [A-Z] (U+0041 to U+005A),
        // or \[a-z] (U+0061 to U+007A), then the character itself.
        if (isName(code)) {
            encoded += str.charAt(i);
        } else {
            // Otherwise, the escaped character.
            encoded += '\\' + str.charAt(i);
        }
    }

    return encoded;
}

var ident = /*#__PURE__*/Object.freeze({
    __proto__: null,
    decode: decode,
    encode: encode
});

const {
    tokenize,
    parse,
    generate,
    lexer,
    createLexer,

    walk,
    find,
    findLast,
    findAll,

    toPlainObject,
    fromPlainObject,

    fork
} = syntax;

export { Lexer, List, OffsetToLocation, TokenStream, clone, createLexer, createSyntax$1 as createSyntax, index as definitionSyntax, find, findAll, findLast, fork, fromPlainObject, generate, ident, isCustomProperty, keyword, lexer, parse, property, string, toPlainObject, tokenNames, types as tokenTypes, tokenize, url, vendorPrefix, version, walk };
