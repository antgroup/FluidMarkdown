//
//  MathAtomFactory.m
//  iosMath
//
//  Created by Kostub Deshmukh on 8/28/13.
//  Copyright (C) 2013 MathChat
//   
//  This software may be modified and distributed under the terms of the
//  MIT license. See the LICENSE file for details.
//

#import "MTMathAtomFactory.h"
#import "MTMathListBuilder.h"


NSString *const MTSymbolMultiplication = @"\u00D7";
NSString *const MTSymbolDivision = @"\u00F7";
NSString *const MTSymbolFractionSlash = @"\u2044";
NSString *const MTSymbolWhiteSquare = @"\u25A1";
NSString *const MTSymbolBlackSquare = @"\u25A0";
NSString *const MTSymbolLessEqual = @"\u2264";
NSString *const MTSymbolGreaterEqual = @"\u2265";
NSString *const MTSymbolNotEqual = @"\u2260";
NSString *const MTSymbolSquareRoot = @"\u221A"; // \sqrt
NSString *const MTSymbolCubeRoot = @"\u221B";
NSString *const MTSymbolInfinity = @"\u221E"; // \infty
NSString *const MTSymbolAngle = @"\u2220"; // \angle
NSString *const MTSymbolDegree = @"\u00B0"; // \circ

@implementation MTMathAtomFactory

+ (MTMathAtom *)times
{
    return [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:MTSymbolMultiplication];
}

+ (MTMathAtom *)divide
{
    return [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:MTSymbolDivision];
}

+ (MTMathAtom *)placeholder
{
    return [MTMathAtom atomWithType:kMTMathAtomPlaceholder value:MTSymbolWhiteSquare];
}

+ (MTFraction *)placeholderFraction
{
    MTFraction *frac = [MTFraction new];
    frac.numerator = [MTMathList new];
    [frac.numerator addAtom:[self placeholder]];
    frac.denominator = [MTMathList new];
    [frac.denominator addAtom:[self placeholder]];
    return frac;
}

+ (MTRadical*) placeholderRadical
{
    MTRadical* rad = [MTRadical new];
    rad.degree = [MTMathList new];
    rad.radicand = [MTMathList new];
    [rad.degree addAtom:self.placeholder];
    [rad.radicand addAtom:self.placeholder];
    return rad;
}

+ (MTMathAtom *)placeholderSquareRoot
{
    MTRadical *rad = [MTRadical new];
    rad.radicand = [MTMathList new];
    [rad.radicand addAtom:[self placeholder]];
    return rad;
}

+ (MTLargeOperator *)operatorWithName:(NSString *)name limits:(bool) limits
{
    return [[MTLargeOperator alloc] initWithValue:name limits:limits];
}

+ (nullable MTMathAtom *)atomForCharacter:(unichar)ch
{
    NSString *chStr = [NSString stringWithCharacters:&ch length:1];
    if (ch > 0x0410 && ch < 0x044F){
        // show basic cyrillic alphabet. Latin Modern Math font is not good for cyrillic symbols
        return [MTMathAtom atomWithType:kMTMathAtomOrdinary value:chStr];
    } else if (ch < 0x21 || ch > 0x7E) {
        if (0x4E00 <= ch && ch <= 0x9FA5) {
            return [MTMathAtom atomWithType:kMTMathAtomVariable value:chStr];
        }
        // skip non ascii characters and spaces
        return nil;
    } else if (ch == '$' || ch == '%' || ch == '#' || ch == '&' || ch == '~' || ch == '\'') {
        // These are latex control characters that have special meanings. We don't support them.
        return nil;
    } else if (ch == '^' || ch == '_' || ch == '{' || ch == '}' || ch == '\\') {
        // more special characters for Latex.
        return nil;
    } else if (ch == '(' || ch == '[') {
        return [MTMathAtom atomWithType:kMTMathAtomOpen value:chStr];
    } else if (ch == ')' || ch == ']' || ch == '!' || ch == '?') {
        return [MTMathAtom atomWithType:kMTMathAtomClose value:chStr];
    } else if (ch == ',' || ch == ';') {
        return [MTMathAtom atomWithType:kMTMathAtomPunctuation value:chStr];
    } else if (ch == '=' || ch == '>' || ch == '<') {
        return [MTMathAtom atomWithType:kMTMathAtomRelation value:chStr];
    } else if (ch == ':') {
        // Math colon is ratio. Regular colon is \colon
        return [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2236"];
    } else if (ch == '-') {
        // Use the math minus sign
        return [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2212"];
    } else if (ch == '+' || ch == '*') {
        return [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:chStr];
    } else if (ch == '.' || (ch >= '0' && ch <= '9')) {
        return [MTMathAtom atomWithType:kMTMathAtomNumber value:chStr];
    } else if ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z')) {
        return [MTMathAtom atomWithType:kMTMathAtomVariable value:chStr];
    } else if (ch == '"' || ch == '/' || ch == '@' || ch == '`' || ch == '|') {
        // just an ordinary character. The following are allowed ordinary chars
        // | / ` @ "
        return [MTMathAtom atomWithType:kMTMathAtomOrdinary value:chStr];
    } else {
        NSAssert(false, @"Unknown ascii character %@. Should have been accounted for.", @(ch));
        return nil;
    }
}

+ (MTMathList *)mathListForCharacters:(NSString *)chars
{
    NSParameterAssert(chars);
    NSInteger len = chars.length;
    unichar buff[len];
    [chars getCharacters:buff range:NSMakeRange(0, len)];
    MTMathList* list = [[MTMathList alloc] init];
    for (NSInteger i = 0; i < len; i++) {
        MTMathAtom* atom = [self atomForCharacter:buff[i]];
        if (atom) {
            [list addAtom:atom];
        }
    }
    return list;
}

+ (MTMathList *)pmod:(NSString *)mod
{
    MTMathList *list = [MTMathList new];
    MTMathAtom *op = [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@""];
    [list addAtom:op];
    MTMathAtom *leftParen = [MTMathAtom atomWithType:kMTMathAtomOpen value:@"("];
    [list addAtom:leftParen];
    MTMathAtom *m = [MTMathAtom atomWithType:kMTMathAtomVariable value:@"m"];
    MTMathAtom *o = [MTMathAtom atomWithType:kMTMathAtomVariable value:@"o"];
    MTMathAtom *d = [MTMathAtom atomWithType:kMTMathAtomVariable value:@"d"];
    m.fontStyle = kMTFontStyleRoman;
    o.fontStyle = kMTFontStyleRoman;
    d.fontStyle = kMTFontStyleRoman;
    [list addAtom:m];
    [list addAtom:o];
    [list addAtom:d];
    MTMathSpace *space = [[MTMathSpace alloc] initWithSpace:3];
    [list addAtom:space];
    if (mod.length > 0) {
        for (NSUInteger i = 0; i < mod.length; i++) {
            unichar ch = [mod characterAtIndex:i];
            MTMathAtom *atom = [MTMathAtomFactory atomForCharacter:ch];
            if (atom) {
                [list addAtom:atom];
            }
        }
    }
    MTMathAtom *rightParen = [MTMathAtom atomWithType:kMTMathAtomClose value:@")"];
    [list addAtom:rightParen];
    return list;
}

+ (nullable MTMathAtom *)atomForLatexSymbolName:(NSString *)symbolName
{
    NSParameterAssert(symbolName);
    NSDictionary* aliases = [MTMathAtomFactory aliases];
    // First check if this is an alias
    NSString* canonicalName = aliases[symbolName];
    if (canonicalName) {
        // Switch to the canonical name
        symbolName = canonicalName;
    }
    
    NSDictionary* commands = [self supportedLatexSymbols];
    MTMathAtom* atom = commands[symbolName];
    if (atom) {
        // Return a copy of the atom since atoms are mutable.
        return [atom copy];
    }
    return nil;
}

+ (nullable NSString*) latexSymbolNameForAtom:(MTMathAtom*) atom
{
    if (atom.nucleus.length == 0) {
        return nil;
    }
    NSDictionary* dict = [MTMathAtomFactory textToLatexSymbolNames];
    return dict[atom.nucleus];
}

+ (void)addLatexSymbol:(NSString *)name value:(MTMathAtom *)atom
{
    NSParameterAssert(name);
    NSParameterAssert(atom);
    NSMutableDictionary<NSString*, MTMathAtom*>* commands = [self supportedLatexSymbols];
    commands[name] = atom;
    if (atom.nucleus.length != 0) {
        NSMutableDictionary<NSString*, NSString*>* dict = [self textToLatexSymbolNames];
        dict[atom.nucleus] = name;
    }
}

+ (NSArray<NSString *> *)supportedLatexSymbolNames
{
    NSDictionary<NSString*, MTMathAtom*>* commands = [MTMathAtomFactory supportedLatexSymbols];
    return commands.allKeys;
}

+ (nullable MTAccent*) accentWithName:(NSString*) accentName
{
    NSDictionary<NSString*, NSString*> *accents = [MTMathAtomFactory accents];
    NSString* accentValue = accents[accentName];
    if (accentValue) {
        return [[MTAccent alloc] initWithValue:accentValue];
    } else {
        return nil;
    }
}

+(NSString*) accentName:(MTAccent*) accent
{
    NSDictionary* dict = [MTMathAtomFactory accentValueToName];
    return dict[accent.nucleus];
}

+ (nullable MTMathAtom *)boundaryAtomForDelimiterName:(NSString *)delimName
{
    NSDictionary<NSString*, NSString*>* delims = [MTMathAtomFactory delimiters];
    NSString* delimValue = delims[delimName];
    if (!delimValue) {
        return nil;
    }
    return [MTMathAtom atomWithType:kMTMathAtomBoundary value:delimValue];
}

+ (NSString*) delimiterNameForBoundaryAtom:(MTMathAtom*) boundary
{
    if (boundary.type != kMTMathAtomBoundary) {
        return nil;
    }
    NSDictionary* dict = [self delimValueToName];
    return dict[boundary.nucleus];
}

+ (MTFontStyle)fontStyleWithName:(NSString *)fontName {
    NSDictionary<NSString*, NSNumber*>* fontStyles = [self fontStyles];
    NSNumber* style = fontStyles[fontName];
    if (style == nil) {
        return NSNotFound;
    }
    return style.integerValue;
}

+ (NSString *)fontNameForStyle:(MTFontStyle)fontStyle
{
    switch (fontStyle) {
        case kMTFontStyleDefault:
            return @"mathnormal";

        case kMTFontStyleRoman:
            return @"mathrm";

        case kMTFontStyleBold:
            return @"mathbf";

        case kMTFontStyleFraktur:
            return @"mathfrak";

        case kMTFontStyleCaligraphic:
            return @"mathcal";

        case kMTFontStyleItalic:
            return @"mathit";

        case kMTFontStyleSansSerif:
            return @"mathsf";

        case kMTFontStyleBlackboard:
            return @"mathbb";

        case kMTFontStyleTypewriter:
            return @"mathtt";

        case kMTFontStyleBoldItalic:
            return @"bm";
    }
}

+ (MTFraction *)fractionWithNumerator:(MTMathList *)num denominator:(MTMathList *)denom
{
    MTFraction *frac = [[MTFraction alloc] init];
    frac.numerator = num;
    frac.denominator = denom;
    return frac;
}

+ (MTFraction *)fractionWithNumeratorStr:(NSString *)numStr denominatorStr:(NSString *)denomStr
{
    MTMathList* num = [self mathListForCharacters:numStr];
    MTMathList* denom = [self mathListForCharacters:denomStr];
    return [self fractionWithNumerator:num denominator:denom];
}

+ (nullable MTMathAtom *)tableWithEnvironment:(NSString *)env config:(MTMathList *)config rows:(NSArray<NSArray<MTMathList *> *> *)rows error:(NSError * _Nullable __autoreleasing *)error
{
    MTMathTable* table = [[MTMathTable alloc] initWithEnvironment:env];
    table.envConfig = config;
    for (int i = 0; i < rows.count; i++) {
        NSArray<MTMathList*>* row = rows[i];
        for (int j = 0; j < row.count; j++) {
            [table setCell:row[j] forRow:i column:j];
        }
    }
    static NSDictionary<NSString*, NSArray*>* matrixEnvs = nil;
    if (!matrixEnvs) {
        matrixEnvs = @{ @"matrix" : @[],
                        @"smallmatrix": @[],
                        @"pmatrix" : @[ @"(", @")"],
                        @"bmatrix" : @[ @"[", @"]"],
                        @"Bmatrix" : @[ @"{", @"}"],
                        @"vmatrix" : @[ @"vert", @"vert"],
                        @"Vmatrix" : @[ @"Vert", @"Vert"], };
    }
    if ([matrixEnvs objectForKey:env]) {
        // it is set to matrix as the delimiters are converted to latex outside the table.
        table.environment = @"matrix";
        table.interRowAdditionalSpacing = 0;
        table.interColumnSpacing = 18;
        if ([env isEqualToString:@"smallmatrix"]) {
            table.interColumnSpacing = 9;
        }
        
        // All the lists are in textstyle
        MTMathAtom* style = [[MTMathStyle alloc] initWithStyle:kMTLineStyleText];
        for (int i = 0; i < table.cells.count; i++) {
            NSArray<MTMathList*>* row = table.cells[i];
            for (int j = 0; j < row.count; j++) {
                [row[j] insertAtom:style atIndex:0];
            }
        }
        // Add delimiters
        NSArray* delims = [matrixEnvs objectForKey:env];
        if (delims.count == 2) {
            MTInner* inner = [[MTInner alloc] init];
            inner.leftBoundary = [self boundaryAtomForDelimiterName:delims[0]];
            inner.rightBoundary = [self boundaryAtomForDelimiterName:delims[1]];
            inner.innerList = [MTMathList mathListWithAtoms:table, nil];
            return inner;
        } else {
            return table;
        }
    } else if (!env) {
        // The default env.
        table.interRowAdditionalSpacing = 1;
        table.interColumnSpacing = 0;
        NSInteger cols = table.numColumns;
        for (int i = 0; i < cols; i++) {
            [table setAlignment:kMTColumnAlignmentLeft forColumn:i];
        }
        return table;
    } else if ([env isEqualToString:@"eqalign"] || [env isEqualToString:@"split"] || [env isEqualToString:@"aligned"] || [env isEqualToString:@"align"]) {
        if (table.numColumns != 1 && table.numColumns != 2) {
            NSString* message = [NSString stringWithFormat:@"%@ environment can only have 2 columns", env];
            if (error != nil) {
                *error = [NSError errorWithDomain:MTParseError code:MTParseErrorInvalidNumColumns userInfo:@{ NSLocalizedDescriptionKey : message }];
            }
            return nil;
        }
        // Add a spacer before each of the second column elements. This is to create the correct spacing for = and other releations.
        MTMathAtom* spacer = [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@""];
        for (int i = 0; i < table.cells.count; i++) {
            NSArray<MTMathList*>* row = table.cells[i];
            if (row.count > 1) {
                [row[1] insertAtom:spacer atIndex:0];
            }
        }
        table.interRowAdditionalSpacing = 1;
        table.interColumnSpacing = 0;
        [table setAlignment:kMTColumnAlignmentRight forColumn:0];
        if (table.numColumns == 2) {
            [table setAlignment:kMTColumnAlignmentLeft forColumn:1];
        }
        return table;
    } else if ([env isEqualToString:@"displaylines"] || [env isEqualToString:@"gather"] || [env isEqualToString:@"gathered"]) {
        if (table.numColumns != 1) {
            NSString* message = [NSString stringWithFormat:@"%@ environment can only have 1 column", env];
            if (error != nil) {
                *error = [NSError errorWithDomain:MTParseError code:MTParseErrorInvalidNumColumns userInfo:@{ NSLocalizedDescriptionKey : message }];
            }
            return nil;
        }
        table.interRowAdditionalSpacing = 1;
        table.interColumnSpacing = 0;
        [table setAlignment:kMTColumnAlignmentCenter forColumn:0];
        return table;
    } else if ([env isEqualToString:@"eqnarray"]) {
        if (table.numColumns != 3) {
            NSString* message = @"eqnarray environment can only have 3 columns";
            if (error != nil) {
                *error = [NSError errorWithDomain:MTParseError code:MTParseErrorInvalidNumColumns userInfo:@{ NSLocalizedDescriptionKey : message }];
            }
            return nil;
        }
        table.interRowAdditionalSpacing = 1;
        table.interColumnSpacing = 18;
        return table;
    }  else if ([env isEqualToString:@"array"]) {
        NSUInteger numCols = table.numColumns;
        table.interRowAdditionalSpacing = 1;
        table.interColumnSpacing = 18;
        for (int i = 0; i < numCols; i++) {
            // set c as default value
            [table setAlignment:kMTColumnAlignmentCenter forColumn:i];
        }
        return table;
    } else if ([env isEqualToString:@"cases"]) {
        if (table.numColumns != 1 && table.numColumns != 2) {
            NSString* message = @"cases environment can only have 1 or 2 columns";
            if (error != nil) {
                *error = [NSError errorWithDomain:MTParseError code:MTParseErrorInvalidNumColumns userInfo:@{ NSLocalizedDescriptionKey : message }];
            }
            return nil;
        }
        table.interRowAdditionalSpacing = 0;
        [table setAlignment:kMTColumnAlignmentLeft forColumn:0];
        if (table.numColumns == 2) {
            [table setAlignment:kMTColumnAlignmentLeft forColumn:1];
        }
        // All the lists are in textstyle
        MTMathAtom* style = [[MTMathStyle alloc] initWithStyle:kMTLineStyleText];
        for (int i = 0; i < table.cells.count; i++) {
            NSArray<MTMathList*>* row = table.cells[i];
            for (int j = 0; j < row.count; j++) {
                [row[j] insertAtom:style atIndex:0];
            }
        }
        // Add delimiters
        MTInner* inner = [[MTInner alloc] init];
        inner.leftBoundary = [self boundaryAtomForDelimiterName:@"{"];
        inner.rightBoundary = [self boundaryAtomForDelimiterName:@"."];
        MTMathAtom* space = [self atomForLatexSymbolName:@","];
        inner.innerList = [MTMathList mathListWithAtoms:space, table, nil];
        return inner;
    }
    if (error) {
        NSString* message = [NSString stringWithFormat:@"Unknown environment: %@", env];
        *error = [NSError errorWithDomain:MTParseError code:MTParseErrorInvalidEnv userInfo:@{ NSLocalizedDescriptionKey : message }];
    }
    return nil;
}

+ (NSMutableDictionary<NSString*, MTMathAtom*>*) supportedLatexSymbols
{
    static NSMutableDictionary<NSString*, MTMathAtom*>* commands = nil;
    if (!commands) {
        commands = [NSMutableDictionary dictionaryWithDictionary:@{
                     @"square" : [MTMathAtomFactory placeholder],
                     
                     // Greek characters
                     @"alpha" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03B1"],
                     @"beta" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03B2"],
                     @"gamma" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03B3"],
                     @"delta" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03B4"],
                     @"varepsilon" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03B5"],
                     @"zeta" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03B6"],
                     @"eta" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03B7"],
                     @"theta" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03B8"],
                     @"iota" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03B9"],
                     @"kappa" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03BA"],
                     @"lambda" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03BB"],
                     @"mu" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03BC"],
                     @"nu" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03BD"],
                     @"xi" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03BE"],
                     @"omicron" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03BF"],
                     @"pi" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03C0"],
                     @"rho" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03C1"],
                     @"varsigma" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03C2"],
                     @"sigma" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03C3"],
                     @"tau" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03C4"],
                     @"upsilon" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03C5"],
                     @"varphi" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03C6"],
                     @"chi" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03C7"],
                     @"psi" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03C8"],
                     @"omega" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03C9"],

                     @"vartheta" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03D1"],
                     @"phi" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03D5"],
                     @"varpi" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03D6"],
                     @"varkappa" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03F0"],
                     @"varrho" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03F1"],
                     @"epsilon" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03F5"],
                     
                     // Custome greek characters
                     @"digamma" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03DD"],
                     @"varcoppa" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03D9"],
                     @"stigma" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03DB"],
                     @"varbeta" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03D0"],

                     // Capital greek characters
                     @"Alpha" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u0391"],
                     @"Beta" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u0392"],
                     @"Epsilon" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u0395"],
                     @"Zeta" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u0396"],
                     @"Eta" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u0397"],
                     @"Iota" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u0399"],
                     @"Kappa" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u039A"],
                     @"Mu" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u039C"],
                     @"Nu" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u039D"],
                     @"Omicron" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u039F"],
                     @"Rho" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03A1"],
                     @"Tau" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03A4"],
                     @"Chi" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03A7"],
                     @"Gamma" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u0393"],
                     @"Delta" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u0394"],
                     @"Theta" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u0398"],
                     @"Lambda" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u039B"],
                     @"Xi" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u039E"],
                     @"Pi" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03A0"],
                     @"Sigma" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03A3"],
                     @"Upsilon" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03A5"],
                     @"Phi" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03A6"],
                     @"Psi" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03A8"],
                     @"Omega" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u03A9"],
                     
                     // Open
                     @"lceil" : [MTMathAtom atomWithType:kMTMathAtomOpen value:@"\u2308"],
                     @"lfloor" : [MTMathAtom atomWithType:kMTMathAtomOpen value:@"\u230A"],
                     @"langle" : [MTMathAtom atomWithType:kMTMathAtomOpen value:@"\u27E8"],
                     @"lgroup" : [MTMathAtom atomWithType:kMTMathAtomOpen value:@"\u27EE"],
                     
                     // Close
                     @"rceil" : [MTMathAtom atomWithType:kMTMathAtomClose value:@"\u2309"],
                     @"rfloor" : [MTMathAtom atomWithType:kMTMathAtomClose value:@"\u230B"],
                     @"rangle" : [MTMathAtom atomWithType:kMTMathAtomClose value:@"\u27E9"],
                     @"rgroup" : [MTMathAtom atomWithType:kMTMathAtomClose value:@"\u27EF"],
                     
                     // Arrows
                     @"leftarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2190"],
                     @"uparrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2191"],
                     @"rightarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2192"],
                     @"downarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2193"],
                     @"leftrightarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2194"],
                     @"updownarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2195"],
                     @"nwarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2196"],
                     @"nearrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2197"],
                     @"searrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2198"],
                     @"swarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2199"],
                     @"mapsto" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21A6"],
                     @"Leftarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21D0"],
                     @"Uparrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21D1"],
                     @"Rightarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21D2"],
                     @"Downarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21D3"],
                     @"Leftrightarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21D4"],
                     @"Updownarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21D5"],
                     @"longleftarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u27F5"],
                     @"longrightarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u27F6"],
                     @"longleftrightarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u27F7"],
                     @"Longleftarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u27F8"],
                     @"Longrightarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u27F9"],
                     @"Longleftrightarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u27FA"],
                     @"longmapsto" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u27FC"],
                     @"hookleftarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21A9"],
                     @"hookrightarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21AA"],
                     @"leftharpoonup" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21BC"],
                     @"leftharpoondown" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21BD"],
                     @"rightharpoonup" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21C0"],
                     @"rightharpoondown" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21C1"],
                     @"rightleftharpoons" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21CC"],
                     @"leadsto" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21DD"],
                     @"curvearrowleft" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21B6"],
                     @"curvearrowright" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21B7"],
                     @"circlearrowleft" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21BA"],
                     @"circlearrowright" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21BB"],
                     @"looparrowleft" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21AB"],
                     @"looparrowright" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21AC"],
                     @"leftleftarrows" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21C7"],
                     @"rightrightarrows" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21C9"],
                     @"leftrightarrows" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21C6"],
                     @"rightleftarrows" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21C4"],
                     @"Lleftarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21DA"],
                     @"Rrightarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21DB"],
                     @"twoheadleftarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u219E"],
                     @"twoheadrightarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21A0"],
                     @"nleftarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u219A"],
                     @"nrightarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u219B"],
                     @"nLeftarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21CD"],
                     @"nRightarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21CF"],
                     @"nleftrightarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21AE"],
                     @"nLeftrightarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21CE"],
                     @"dashleftarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21E0"],
                     @"dashrightarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21E2"],
                     @"leftarrowtail" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21A2"],
                     @"rightarrowtail" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21A3"],
                     @"leftrightsquigarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21AD"],
                     @"rightsquigarrow" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21DD"],
                     @"downharpoonleft" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21C3"],
                     @"downharpoonright" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21C2"],
                     @"upharpoonleft" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21BF"],
                     @"upharpoonright" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21BE"],
                     
                     
                     // Relations
                     @"leq" : [MTMathAtom atomWithType:kMTMathAtomRelation value:MTSymbolLessEqual],
                     @"geq" : [MTMathAtom atomWithType:kMTMathAtomRelation value:MTSymbolGreaterEqual],
                     @"neq" : [MTMathAtom atomWithType:kMTMathAtomRelation value:MTSymbolNotEqual],
                     @"in" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2208"],
                     @"notin" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2209"],
                     @"nin" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2209"],
                     @"ni" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u220B"],
                     @"propto" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u221D"],
                     @"mid" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2223"],
                     @"parallel" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2225"],
                     @"sim" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u223C"],
                     @"simeq" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2243"],
                     @"cong" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2245"],
                     @"approx" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2248"],
                     @"asymp" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u224D"],
                     @"doteq" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2250"],
                     @"equiv" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2261"],
                     @"geqslant" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2A7E"],
                     @"leqslant" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2A7D"],
                     @"gg" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u226B"],
                     @"ll" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u226A"],
                     @"prec" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u227A"],
                     @"succ" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u227B"],
                     @"subset" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2282"],
                     @"supset" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2283"],
                     @"nsubset" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2284"],
                     @"nsupset" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2285"],
                     @"subseteq" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2286"],
                     @"supseteq" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2287"],
                     @"nsubseteq" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2288"],
                     @"nsupseteq" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2289"], // 既不是超集也不等于 (⊉)
                     @"subsetneq" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u228A"], // 真正子集 (⊊)
                     @"supsetneq" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u228B"], // 真正超集 (⊋)
                     @"sqsubset" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u228F"], // 方形子集 (⊏)
                     @"sqsupset" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2290"],
                     @"sqsubseteq" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2291"],
                     @"sqsupseteq" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2292"],
                     @"models" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u22A7"],
                     @"perp" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u27C2"],
                     
                     // operators
                     @"times" : [MTMathAtomFactory times],
                     @"div"   : [MTMathAtomFactory divide],
                     @"pm"    : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u00B1"],
                     @"dagger" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2020"],
                     @"ddagger" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2021"],
                     @"mp"    : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2213"],
                     @"setminus" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2216"],
                     @"ast"   : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2217"],
                     @"circ"  : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2218"],
                     @"bullet" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2219"],
                     @"wedge" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2227"],
                     @"vee" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2228"],
                     @"cap" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2229"],
                     @"cup" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u222A"],
                     @"wr" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2240"],
                     @"multisetmultiplication" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u228C"], // 多重集合乘法 (⊌)
                     @"multisetaddition" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u228D"], // 多重集合加法 (⊍)
                     @"uplus" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u228E"],
                     @"sqcap" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2293"],
                     @"sqcup" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2294"],
                     @"oplus" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2295"],
                     @"ominus" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2296"],
                     @"otimes" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2297"],
                     @"oslash" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2298"],
                     @"odot" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2299"],
                     @"star"  : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u22C6"],
                     @"cdot"  : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u22C5"],
                     @"amalg" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2A3F"],
                     
                     // No limit operators
                     @"log" : [MTMathAtomFactory operatorWithName:@"log" limits:NO],
                     @"lg" : [MTMathAtomFactory operatorWithName:@"lg" limits:NO],
                     @"ln" : [MTMathAtomFactory operatorWithName:@"ln" limits:NO],
                     @"sin" : [MTMathAtomFactory operatorWithName:@"sin" limits:NO],
                     @"arcsin" : [MTMathAtomFactory operatorWithName:@"arcsin" limits:NO],
                     @"sinh" : [MTMathAtomFactory operatorWithName:@"sinh" limits:NO],
                     @"cos" : [MTMathAtomFactory operatorWithName:@"cos" limits:NO],
                     @"arccos" : [MTMathAtomFactory operatorWithName:@"arccos" limits:NO],
                     @"cosh" : [MTMathAtomFactory operatorWithName:@"cosh" limits:NO],
                     @"tan" : [MTMathAtomFactory operatorWithName:@"tan" limits:NO],
                     @"arctan" : [MTMathAtomFactory operatorWithName:@"arctan" limits:NO],
                     @"tanh" : [MTMathAtomFactory operatorWithName:@"tanh" limits:NO],
                     @"cot" : [MTMathAtomFactory operatorWithName:@"cot" limits:NO],
                     @"coth" : [MTMathAtomFactory operatorWithName:@"coth" limits:NO],
                     @"sec" : [MTMathAtomFactory operatorWithName:@"sec" limits:NO],
                     @"csc" : [MTMathAtomFactory operatorWithName:@"csc" limits:NO],
                     @"arg" : [MTMathAtomFactory operatorWithName:@"arg" limits:NO],
                     @"ker" : [MTMathAtomFactory operatorWithName:@"ker" limits:NO],
                     @"dim" : [MTMathAtomFactory operatorWithName:@"dim" limits:NO],
                     @"hom" : [MTMathAtomFactory operatorWithName:@"hom" limits:NO],
                     @"exp" : [MTMathAtomFactory operatorWithName:@"exp" limits:NO],
                     @"deg" : [MTMathAtomFactory operatorWithName:@"deg" limits:NO],
                     @"mod" : [MTMathAtomFactory operatorWithName:@"mod" limits:NO],
                     @"bmod" : [MTMathAtomFactory operatorWithName:@"mod" limits:NO],
                     
                     // Limit operators
                     @"lim" : [MTMathAtomFactory operatorWithName:@"lim" limits:YES],
                     @"limsup" : [MTMathAtomFactory operatorWithName:@"lim sup" limits:YES],
                     @"liminf" : [MTMathAtomFactory operatorWithName:@"lim inf" limits:YES],
                     @"max" : [MTMathAtomFactory operatorWithName:@"max" limits:YES],
                     @"min" : [MTMathAtomFactory operatorWithName:@"min" limits:YES],
                     @"sup" : [MTMathAtomFactory operatorWithName:@"sup" limits:YES],
                     @"inf" : [MTMathAtomFactory operatorWithName:@"inf" limits:YES],
                     @"det" : [MTMathAtomFactory operatorWithName:@"det" limits:YES],
                     @"Pr" : [MTMathAtomFactory operatorWithName:@"Pr" limits:YES],
                     @"gcd" : [MTMathAtomFactory operatorWithName:@"gcd" limits:YES],
                     
                     // Large operators
                     @"prod" : [MTMathAtomFactory operatorWithName:@"\u220F" limits:YES],
                     @"coprod" : [MTMathAtomFactory operatorWithName:@"\u2210" limits:YES],
                     @"sum" : [MTMathAtomFactory operatorWithName:@"\u2211" limits:YES],
                     @"int" : [MTMathAtomFactory operatorWithName:@"\u222B" limits:NO],
                     @"iint" : [MTMathAtomFactory operatorWithName:@"\u222C" limits:NO],            // 双重积分
                     @"iiint" : [MTMathAtomFactory operatorWithName:@"\u222D" limits:NO],           // 三重积分
                     @"oint" : [MTMathAtomFactory operatorWithName:@"\u222E" limits:NO],
                     @"oiint" : [MTMathAtomFactory operatorWithName:@"\u222F" limits:NO],
                     @"oiiint" : [MTMathAtomFactory operatorWithName:@"\u2230" limits:NO],
                     @"bigwedge" : [MTMathAtomFactory operatorWithName:@"\u22C0" limits:YES],
                     @"bigvee" : [MTMathAtomFactory operatorWithName:@"\u22C1" limits:YES],
                     @"bigcap" : [MTMathAtomFactory operatorWithName:@"\u22C2" limits:YES],
                     @"bigcup" : [MTMathAtomFactory operatorWithName:@"\u22C3" limits:YES],
                     @"bigodot" : [MTMathAtomFactory operatorWithName:@"\u2A00" limits:YES],
                     @"bigoplus" : [MTMathAtomFactory operatorWithName:@"\u2A01" limits:YES],
                     @"bigotimes" : [MTMathAtomFactory operatorWithName:@"\u2A02" limits:YES],
                     @"biguplus" : [MTMathAtomFactory operatorWithName:@"\u2A04" limits:YES],
                     @"bigsqcup" : [MTMathAtomFactory operatorWithName:@"\u2A06" limits:YES],
                     
                     // Latex command characters
                     @"{" : [MTMathAtom atomWithType:kMTMathAtomOpen value:@"{"],
                     @"}" : [MTMathAtom atomWithType:kMTMathAtomClose value:@"}"],
                     @"$" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"$"],
                     @"&" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"&"],
                     @"#" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"#"],
                     @"%" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"%"],
                     @"_" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"_"],
                     @" " : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@" "],
                     @"backslash" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\\"],
                     
                     // Punctuation
                     // Note: \colon is different from : which is a relation
                     @"colon" : [MTMathAtom atomWithType:kMTMathAtomPunctuation value:@":"],
                     @"cdotp" : [MTMathAtom atomWithType:kMTMathAtomPunctuation value:@"\u00B7"],
                     
                     // Other symbols
                     @"degree" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u00B0"],
                     @"neg" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u00AC"],
                     @"angstrom" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u00C5"],
                     @"eth" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u00F0"],
                     @"|" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u2016"],
                     @"vert" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"|"],
                     @"ldots" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u2026"],
                     @"prime" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u2032"],
                     @"hbar" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u210F"],
                     @"Im" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u2111"],
                     @"ell" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u2113"],
                     @"wp" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u2118"],
                     @"Re" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u211C"],
                     @"mho" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u2127"],
                     @"hslash" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u210F"],
                     @"aleph" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u2135"],
                     @"forall" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u2200"],
                     @"exists" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u2203"],
                     @"emptyset" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u2205"],
                     @"nabla" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u2207"],
                     @"infty" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u221E"],
                     @"angle" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u2220"],
                     @"top" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u22A4"],
                     @"bot" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u22A5"],
                     @"vdots" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u22EE"],
                     @"cdots" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u22EF"],
                     @"dots" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u22EF"],
                     @"ddots" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u22F1"],
                     @"triangle" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u25B3"],
                     @"imath" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\U0001D6A4"],
                     @"jmath" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\U0001D6A5"],
                     @"partial" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\U0001D715"],
                     @"nmid": [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u2224"],
                     @"triangleq": [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u225C"],
                     @"hslash": [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u210f"],
                     @"eth": [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u00f0"],
                     @"vDash": [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u22a8"],
                     @"geqslant": [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u2265"],
                     @"leqslant": [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u2264"],
                     
                     // Spacing
                     @"," : [[MTMathSpace alloc] initWithSpace:3],
                     @">" : [[MTMathSpace alloc] initWithSpace:4],
                     @";" : [[MTMathSpace alloc] initWithSpace:5],
                     @"!" : [[MTMathSpace alloc] initWithSpace:-3],
                     @"quad" : [[MTMathSpace alloc] initWithSpace:18],  // quad = 1em = 18mu
                     @"qquad" : [[MTMathSpace alloc] initWithSpace:36], // qquad = 2em
                     
                     // Style
                     @"displaystyle" : [[MTMathStyle alloc] initWithStyle:kMTLineStyleDisplay],
                     @"textstyle" : [[MTMathStyle alloc] initWithStyle:kMTLineStyleText],
                     @"scriptstyle" : [[MTMathStyle alloc] initWithStyle:kMTLineStyleScript],
                     @"scriptscriptstyle" : [[MTMathStyle alloc] initWithStyle:kMTLineStyleScriptScript],
                     @"big" : [[MTMathStyle alloc] initWithStyle:kMTLineStylebig],
                     @"Big" : [[MTMathStyle alloc] initWithStyle:kMTLineStyleBig],
                     @"bigg" : [[MTMathStyle alloc] initWithStyle:kMTLineStylebigg],
                     @"Bigg" : [[MTMathStyle alloc] initWithStyle:kMTLineStyleBigg],
                     
                     // custome
                     @"because" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2235"],
                     @"therefore" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2234"],
                     @"land" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2227"],
                     @"iff" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u21D4"],
                     @"lor" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2228"],
                     @"nexists" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u2204"],
                     @"vdash" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u22A2"],
                     @"vDash" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u22A8"],
                     @"dashv" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u22A3"],
                     @"varnothing" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u2205"],
                     @"smallsetminus" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u2216"],
                     @"triangleleft" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u25C3"],
                     @"triangleright" : [MTMathAtom atomWithType:kMTMathAtomBinaryOperator value:@"\u25B9"],
                     @"surd" : [MTMathAtom atomWithType:kMTMathAtomLargeOperator value:@"\u221A"],
                     @"flat" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u266D"],
                     @"natural" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u266E"],
                     @"sharp" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u266F"],
                     @"Box" : [MTMathAtom atomWithType:kMTMathAtomOrdinary value:@"\u25A1"],
                     @"clubsuit" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u2663"],
                     @"diamondsuit" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u2662"],
                     @"heartsuit" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u2661"],
                     @"spadesuit" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u2660"],
                     @"measuredangle" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u2221"],
                     @"lozenge" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u25CA"],
                     @"circledS" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u24C8"],
                     @"bigstar" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u2605"],
                     @"blacksquare" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u25A0"],
                     @"blacktriangle" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u25B2"],
                     @"blacktriangledown" : [MTMathAtom atomWithType:kMTMathAtomVariable value:@"\u25BC"],
                     @"preceq" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2AAF"],
                     @"succeq" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2AB0"],
                     @"bowtie" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u22C8"],
                     @"Join" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u22C9"],
                     @"smile" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2323"],
                     @"frown" : [MTMathAtom atomWithType:kMTMathAtomRelation value:@"\u2322"],
                     }];
        
    }
    return commands;
}

+ (NSDictionary*) aliases
{
    static NSDictionary* aliases = nil;
    if (!aliases) {
        aliases = @{
                    @"lnot" : @"neg",
                    @"land" : @"wedge",
                    @"lor" : @"vee",
                    @"ne" : @"neq",
                    @"le" : @"leq",
                    @"ge" : @"geq",
                    @"lbrace" : @"{",
                    @"rbrace" : @"}",
                    @"Vert" : @"|",
                    @"gets" : @"leftarrow",
                    @"to" : @"rightarrow",
                    @"iff" : @"Longleftrightarrow",
                    @"AA" : @"angstrom",
                    };
    }
    return aliases;
}

+ (NSMutableDictionary<NSString*, NSString*>*) textToLatexSymbolNames
{
    static NSMutableDictionary<NSString*, NSString*>* textToCommands = nil;
    if (!textToCommands) {
        NSDictionary* commands = [self supportedLatexSymbols];
        textToCommands = [NSMutableDictionary dictionaryWithCapacity:commands.count];
        for (NSString* command in commands) {
            MTMathAtom* atom = commands[command];
            if (atom.nucleus.length == 0) {
                continue;
            }
            
            NSString* existingCommand = textToCommands[atom.nucleus];
            if (existingCommand) {
                // If there are 2 commands for the same symbol, choose one deterministically.
                if (command.length > existingCommand.length) {
                    // Keep the shorter command
                    continue;
                } else if (command.length == existingCommand.length) {
                    // If the length is the same, keep the alphabetically first
                    if ([command compare:existingCommand] == NSOrderedDescending) {
                        continue;
                    }
                }
            }
            // In other cases replace the command.
            textToCommands[atom.nucleus] = command;
        }
    }
    return textToCommands;
}

+ (NSDictionary<NSString*, NSString*>*) accents
{
    static NSDictionary* accents = nil;
    if (!accents) {
        accents = @{
                    @"grave" : @"\u0300",
                    @"acute" : @"\u0301",
                    @"hat" : @"\u0302",  // In our implementation hat and widehat behave the same.
                    @"tilde" : @"\u0303", // In our implementation tilde and widetilde behave the same.
                    @"bar" : @"\u0304",
                    @"breve" : @"\u0306",
                    @"dot" : @"\u0307",
                    @"ddot" : @"\u0308",
                    @"check" : @"\u030C",
                    @"vec" : @"\u20D7",
                    @"widehat" : @"\u0302",
                    @"widetilde" : @"\u0303",
                    };
    }
    return accents;
}

+ (NSDictionary*) accentValueToName
{
    static NSDictionary* accentToCommands = nil;
    if (!accentToCommands) {
        NSDictionary* accents = [self accents];
        NSMutableDictionary* mutableDict = [NSMutableDictionary dictionaryWithCapacity:accents.count];
        for (NSString* command in accents) {
            NSString* acc = accents[command];
            NSString* existingCommand = mutableDict[acc];
            if (existingCommand) {
                if (command.length > existingCommand.length) {
                    // Keep the shorter command
                    continue;
                } else if (command.length == existingCommand.length) {
                    // If the length is the same, keep the alphabetically first
                    if ([command compare:existingCommand] == NSOrderedDescending) {
                        continue;
                    }
                }
            }
            // In other cases replace the command.
            mutableDict[acc] = command;
        }
        accentToCommands = [mutableDict copy];
    }
    return accentToCommands;
}

+(NSDictionary<NSString*, NSString*> *) delimiters
{
    static NSDictionary* delims = nil;
    if (!delims) {
        delims = @{
                   @"." : @"", // . means no delimiter
                   @"(" : @"(",
                   @")" : @")",
                   @"[" : @"[",
                   @"]" : @"]",
                   @"<" : @"\u2329",
                   @">" : @"\u232A",
                   @"/" : @"/",
                   @"\\" : @"\\",
                   @"|" : @"|",
                   @"lgroup" : @"\u27EE",
                   @"rgroup" : @"\u27EF",
                   @"||" : @"\u2016",
                   @"Vert" : @"\u2016",
                   @"vert" : @"|",
                   @"uparrow" : @"\u2191",
                   @"downarrow" : @"\u2193",
                   @"updownarrow" : @"\u2195",
                   @"Uparrow" : @"21D1",
                   @"Downarrow" : @"21D3",
                   @"Updownarrow" : @"21D5",
                   @"backslash" : @"\\",
                   @"rangle" : @"\u232A",
                   @"langle" : @"\u2329",
                   @"rbrace" : @"}",
                   @"}" : @"}",
                   @"{" : @"{",
                   @"lbrace" : @"{",
                   @"lceil" : @"\u2308",
                   @"rceil" : @"\u2309",
                   @"lfloor" : @"\u230A",
                   @"rfloor" : @"\u230B",
                   };
    }
    return delims;
}

+ (NSDictionary*) delimValueToName
{
    static NSDictionary* delimToCommands = nil;
    if (!delimToCommands) {
        NSDictionary* delims = [self delimiters];
        NSMutableDictionary* mutableDict = [NSMutableDictionary dictionaryWithCapacity:delims.count];
        for (NSString* command in delims) {
            NSString* delim = delims[command];
            NSString* existingCommand = mutableDict[delim];
            if (existingCommand) {
                if (command.length > existingCommand.length) {
                    // Keep the shorter command
                    continue;
                } else if (command.length == existingCommand.length) {
                    // If the length is the same, keep the alphabetically first
                    if ([command compare:existingCommand] == NSOrderedDescending) {
                        continue;
                    }
                }
            }
            // In other cases replace the command.
            mutableDict[delim] = command;
        }
        delimToCommands = [mutableDict copy];
    }
    return delimToCommands;
}


+(NSDictionary<NSString*, NSNumber*> *) fontStyles
{
    static NSDictionary<NSString*, NSNumber*>* fontStyles = nil;
    if (!fontStyles) {
        fontStyles = @{
                       @"mathnormal" : @(kMTFontStyleDefault),
                       @"mathrm": @(kMTFontStyleRoman),
                       @"textrm": @(kMTFontStyleRoman),
                       @"rm": @(kMTFontStyleRoman),
                       @"mathbf": @(kMTFontStyleBold),
                       // 粗体
                       @"bf": @(kMTFontStyleBold),
                       // 等线体
                       @"sf": @(kMTFontStyleSansSerif),
                       // 打印机字体
                       @"tt": @(kMTFontStyleTypewriter),
                       // 黑板字体
                       @"Bbb": @(kMTFontStyleBlackboard),
                       @"it": @(kMTFontStyleItalic),
                       @"textbf": @(kMTFontStyleBold),
                       @"mathcal": @(kMTFontStyleCaligraphic),
                       @"cal": @(kMTFontStyleCaligraphic),
                       @"mathtt": @(kMTFontStyleTypewriter),
                       @"texttt": @(kMTFontStyleTypewriter),
                       @"mathit": @(kMTFontStyleItalic),
                       @"textit": @(kMTFontStyleItalic),
                       @"mit": @(kMTFontStyleItalic),
                       @"mathsf": @(kMTFontStyleSansSerif),
                       @"textsf": @(kMTFontStyleSansSerif),
                       @"mathfrak": @(kMTFontStyleFraktur),
                       @"frak": @(kMTFontStyleFraktur),
                       @"mathbb": @(kMTFontStyleBlackboard),
                       @"mathbfit": @(kMTFontStyleBoldItalic),
                       @"bm": @(kMTFontStyleBoldItalic),
                       @"text": @(kMTFontStyleRoman),
                   };
    }
    return fontStyles;
}

@end
