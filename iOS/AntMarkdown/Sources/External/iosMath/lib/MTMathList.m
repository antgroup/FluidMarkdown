//
//  MathList.m
//  iosMath
//
//  Created by Kostub Deshmukh on 8/26/13.
//  Copyright (C) 2013 MathChat
//   
//  This software may be modified and distributed under the terms of the
//  MIT license. See the LICENSE file for details.
//

#import "MTMathList.h"

// Returns true if the current binary operator is not really binary.
static BOOL isNotBinaryOperator(MTMathAtom* prevNode)
{
    if (!prevNode) {
        return true;
    }
    
    if (prevNode.type == kMTMathAtomBinaryOperator || prevNode.type == kMTMathAtomRelation || prevNode.type == kMTMathAtomOpen || prevNode.type == kMTMathAtomPunctuation || prevNode.type == kMTMathAtomLargeOperator) {
        return true;
    }
    return false;
}

static NSString* typeToText(MTMathAtomType type) {
    switch (type) {
        case kMTMathAtomOrdinary:
            return @"Ordinary";
        case kMTMathAtomNumber:
            return @"Number";
        case kMTMathAtomVariable:
            return @"Variable";
        case kMTMathAtomBinaryOperator:
            return @"Binary Operator";
        case kMTMathAtomUnaryOperator:
            return @"Unary Operator";
        case kMTMathAtomRelation:
            return @"Relation";
        case kMTMathAtomOpen:
            return @"Open";
        case kMTMathAtomClose:
            return @"Close";
        case kMTMathAtomFraction:
            return @"Fraction";
        case kMTMathAtomRadical:
            return @"Radical";
        case kMTMathAtomPunctuation:
            return @"Punctuation";
        case kMTMathAtomPlaceholder:
            return @"Placeholder";
        case kMTMathAtomLargeOperator:
            return @"Large Operator";
        case kMTMathAtomInner:
            return @"Inner";
        case kMTMathAtomUnderline:
            return @"Underline";
        case kMTMathAtomOverline:
            return @"Overline";
        case kMTMathAtomAccent:
            return @"Accent";
        case kMTMathAtomBoundary:
            return @"Boundary";
        case kMTMathAtomSpace:
            return @"Space";
        case kMTMathAtomStyle:
            return @"Style";
        case kMTMathAtomColor:
            return @"Color";
        case kMTMathAtomColorbox:
            return @"Colorbox";
        case kMTMathAtomBoxed:
            return @"Boxed";
        case kMTMathAtomTable:
            return @"Table";
        case kMTMathAtomHline:
            return @"Hline";
    }
}

#pragma mark - MTMathAtom

@interface MTMathAtom ()

@property (nonatomic) NSRange indexRange;

- (instancetype)initWithType:(MTMathAtomType)type value:(NSString *)value NS_DESIGNATED_INITIALIZER;

@end

@implementation MTMathAtom {
    NSMutableArray* _fusedAtoms;
}

+ (instancetype)atomWithType:(MTMathAtomType)type value:(NSString *)value
{
    switch (type) {
        case kMTMathAtomFraction:
            return [[MTFraction alloc] init];
            
        case kMTMathAtomPlaceholder:
            // A placeholder is created with a white square.
            return [[[self class] alloc] initWithType:kMTMathAtomPlaceholder value:@"\u25A1"];
            
        case kMTMathAtomRadical:
            return [[MTRadical alloc] init];
            
        case kMTMathAtomLargeOperator:
            // Default setting of limits is true
            return [[MTLargeOperator alloc] initWithValue:value limits:YES];
            
        case kMTMathAtomInner:
            return [[MTInner alloc] init];
            
        case kMTMathAtomOverline:
            return [[MTOverLine alloc] init];
            
        case kMTMathAtomUnderline:
            return [[MTUnderLine alloc] init];
        case kMTMathAtomHline:
            return [[MTHLine alloc] init];
            
        case kMTMathAtomAccent:
            return [[MTAccent alloc] initWithValue:value];
            
        case kMTMathAtomSpace:
            return [[MTMathSpace alloc] initWithSpace:0];
        
        case kMTMathAtomColor:
            return [[MTMathColor alloc] init];
            
        case kMTMathAtomColorbox:
            return [[MTMathColorbox alloc] init];
        default:
            return [[MTMathAtom alloc] initWithType:type value:value];
    }
}

- (instancetype)initWithType:(MTMathAtomType)type value:(NSString *)value
{
    self = [super init];
    if (self) {
        _type = type;
        _nucleus = [value copy];
        _sizeType = MTSizeTypeDefault;
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"InvalidMethod"
                                   reason:@"[MTMathAtom init] cannot be called. Use [MTMathAtom initWithType:value:] instead."
                                 userInfo:nil];
    return nil;
}

- (NSString *)stringValue
{
    NSMutableString* str = [NSMutableString stringWithString:self.nucleus];
    if (self.superScript) {
        [str appendFormat:@"^{%@}", self.superScript.stringValue];
    }
    if (self.subScript) {
        [str appendFormat:@"_{%@}", self.subScript.stringValue];
    }
    return str;
}

// Note this is a deep copy.
- (id)copyWithZone:(NSZone *)zone
{
    MTMathAtom* atom = [[[self class] allocWithZone:zone] initWithType:self.type value:self.nucleus];
    atom.type = self.type;
    atom.nucleus = self.nucleus;
    atom.subScript = [self.subScript copyWithZone:zone];
    atom.superScript = [self.superScript copyWithZone:zone];
    atom.indexRange = self.indexRange;
    atom.fontStyle = self.fontStyle;
    atom.sizeType = self.sizeType;
    return atom;
}

- (bool)scriptsAllowed
{
    return (self.type < kMTMathAtomBoundary);
}

- (void)setSubScript:(MTMathList *)subScript
{
    if (subScript && !self.scriptsAllowed) {
        @throw [[NSException alloc] initWithName:@"Error"
                                          reason:[NSString stringWithFormat:@"Subscripts not allowed for atom of type %@", typeToText(self.type)]
                                        userInfo:nil];
    }
    _subScript = subScript;
}

- (void)setSuperScript:(MTMathList *)superScript
{
    if (superScript && !self.scriptsAllowed) {
        @throw [[NSException alloc] initWithName:@"Error"
                                          reason:[NSString stringWithFormat:@"Superscripts not allowed for atom of type %@", typeToText(self.type)]
                                        userInfo:nil];
    }
    _superScript = superScript;
}

- (NSString *)description
{
    NSMutableString* str = [NSMutableString stringWithString:typeToText(self.type)];
    [str appendFormat:@": %@", self.stringValue];
    return str;
}

- (void)fuse:(MTMathAtom *)atom
{
    NSAssert(!self.subScript, @"Cannot fuse into an atom which has a subscript: %@", self);
    NSAssert(!self.superScript, @"Cannot fuse into an atom which has a superscript: %@", self);
    NSAssert(atom.type == self.type, @"Only atoms of the same type can be fused. %@, %@", self, atom);
    
    // Update the fused atoms list
    if (!_fusedAtoms) {
        _fusedAtoms = [NSMutableArray arrayWithObject:[self copy]];
    }
    if (atom.fusedAtoms) {
        [_fusedAtoms addObjectsFromArray:atom.fusedAtoms];
    } else {
        [_fusedAtoms addObject:atom];
    }    
    
    // Update the nucleus
    NSMutableString* str = self.nucleus.mutableCopy;
    [str appendString:atom.nucleus];
    self.nucleus = str;
    
    // Update the range
    NSRange newRange = self.indexRange;
    newRange.length += atom.indexRange.length;
    self.indexRange = newRange;
    
    // Update super/sub scripts
    self.subScript = atom.subScript;
    self.superScript = atom.superScript;
}

- (instancetype)finalized
{
    MTMathAtom* newNode = [self copy];
    if (newNode.superScript) {
        newNode.superScript = newNode.superScript.finalized;
    }
    if (newNode.subScript) {
        newNode.subScript = newNode.subScript.finalized;
    }
    return newNode;
}

- (void)updateSizeTypeWithStyle:(MTLineStyle)style {
    if (style == kMTLineStylebig) {
        self.sizeType = MTSizeTypebig;
    } else if (style == kMTLineStyleBig) {
        self.sizeType = MTSizeTypeBig;
    } else if (style == kMTLineStylebigg) {
        self.sizeType = MTSizeTypebigg;
    } else if (style == kMTLineStyleBigg) {
        self.sizeType = MTSizeTypeBigg;
    } else {
        self.sizeType = MTSizeTypeDefault;
    }
}

@end

#pragma mark - MTFraction

@implementation MTFraction

- (instancetype)init
{
    return [self initWithRule:true];
}

- (instancetype)initWithType:(MTMathAtomType)type value:(NSString *)value
{
    if (type == kMTMathAtomFraction) {
        return [self init];
    }
    @throw [NSException exceptionWithName:@"InvalidMethod"
                                   reason:@"[MTFraction initWithType:value:] cannot be called. Use [MTFraction init] instead."
                                 userInfo:nil];
    return nil;
}

- (instancetype)initWithRule:(BOOL)hasRule
{
    // fractions have no nucleus
    self = [super initWithType:kMTMathAtomFraction value:@""];
    if (self) {
        _hasRule = hasRule;
    }
    return self;
}

- (NSString *)stringValue
{
    NSMutableString* str = [[NSMutableString alloc] init];
    if (self.hasRule) {
        [str appendString:@"\\atop"];
    } else {
        [str appendString:@"\\frac"];
    }
    if (self.leftDelimiter || self.rightDelimiter) {
        [str appendFormat:@"[%@][%@]", self.leftDelimiter, self.rightDelimiter];
    }
    
    [str appendFormat:@"{%@}{%@}", self.numerator.stringValue, self.denominator.stringValue];
    if (self.superScript) {
        [str appendFormat:@"^{%@}", self.superScript.stringValue];
    }
    if (self.subScript) {
        [str appendFormat:@"_{%@}", self.subScript.stringValue];
    }
    return str;
}

- (id)copyWithZone:(NSZone *)zone
{
    MTFraction* frac = [super copyWithZone:zone];
    frac.numerator = [self.numerator copyWithZone:zone];
    frac.denominator = [self.denominator copyWithZone:zone];
    frac->_hasRule = self.hasRule;
    frac.leftDelimiter = [self.leftDelimiter copyWithZone:zone];
    frac.isCfrac = self.isCfrac;
    return frac;
}

- (instancetype)finalized
{
    MTFraction* newFrac = [super finalized];
    newFrac.isCfrac = self.isCfrac;
    newFrac.numerator = newFrac.numerator.finalized;
    newFrac.denominator = newFrac.denominator.finalized;
    return newFrac;
}

@end

#pragma mark - MTRadical

@implementation MTRadical

- (instancetype)init
{
    // radicals have no nucleus
    self = [super initWithType:kMTMathAtomRadical value:@""];
    return self;
}

- (instancetype)initWithType:(MTMathAtomType)type value:(NSString *)value
{
    if (type == kMTMathAtomRadical) {
        return [self init];
    }
    @throw [NSException exceptionWithName:@"InvalidMethod"
                                   reason:@"[MTRadical initWithType:value:] cannot be called. Use [MTRadical init] instead."
                                 userInfo:nil];
    return nil;
}

- (NSString *)stringValue
{
    NSMutableString* str = [NSMutableString stringWithString:@"\\sqrt"];
    if (self.degree) {
        [str appendFormat:@"[%@]", self.degree.stringValue];
    }
    [str appendFormat:@"{%@}", self.radicand.stringValue];

    if (self.superScript) {
        [str appendFormat:@"^{%@}", self.superScript.stringValue];
    }
    if (self.subScript) {
        [str appendFormat:@"_{%@}", self.subScript.stringValue];
    }
    return str;
}

- (id)copyWithZone:(NSZone *)zone
{
    MTRadical* rad = [super copyWithZone:zone];
    rad.radicand = [self.radicand copyWithZone:zone];
    rad.degree = [self.degree copyWithZone:zone];
    return rad;
}

- (instancetype)finalized
{
    MTRadical* newRad = [super finalized];
    newRad.radicand = newRad.radicand.finalized;
    newRad.degree = newRad.degree.finalized;
    return newRad;
}

@end

#pragma mark - MTLargeOperator

@implementation MTLargeOperator

- (instancetype) initWithValue:(NSString*) value limits:(BOOL) limits
{
    self = [super initWithType:kMTMathAtomLargeOperator value:value];
    if (self) {
        _limits = limits;
    }
    return self;
}

- (instancetype)initWithType:(MTMathAtomType)type value:(NSString *)value
{
    if (type == kMTMathAtomLargeOperator) {
        return [self initWithValue:value limits:false];
    }
    @throw [NSException exceptionWithName:@"InvalidMethod"
                                   reason:@"[MTLargeOperator initWithType:value:] cannot be called. Use [MTLargeOperator initWithValue:limits:] instead."
                                 userInfo:nil];
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    MTLargeOperator* op = [super copyWithZone:zone];
    op->_limits = self.limits;
    return op;
}

@end

#pragma mark - MTInner

@implementation MTInner

- (instancetype)init
{
    // inner atoms have no nucleus
    self = [super initWithType:kMTMathAtomInner value:@""];
    return self;
}

- (instancetype)initWithType:(MTMathAtomType)type value:(NSString *)value
{
    if (type == kMTMathAtomInner) {
        return [self init];
    }
    @throw [NSException exceptionWithName:@"InvalidMethod"
                                   reason:@"[MTInner initWithType:value:] cannot be called. Use [MTInner init] instead."
                                 userInfo:nil];
    return nil;
}

- (void)setLeftBoundary:(MTMathAtom *)leftBoundary
{
    if (leftBoundary && leftBoundary.type != kMTMathAtomBoundary) {
        @throw [[NSException alloc] initWithName:@"Error"
                                          reason:[NSString stringWithFormat:@"Left boundary must be of type kMTMathAtomBoundary"]
                                        userInfo:nil];
    }
    _leftBoundary = leftBoundary;
}

- (void)setRightBoundary:(MTMathAtom *)rightBoundary
{
    if (rightBoundary && rightBoundary.type != kMTMathAtomBoundary) {
        @throw [[NSException alloc] initWithName:@"Error"
                                          reason:[NSString stringWithFormat:@"Left boundary must be of type kMTMathAtomBoundary"]
                                        userInfo:nil];
    }
    _rightBoundary = rightBoundary;
}

- (NSString *)stringValue
{
    NSMutableString* str = [NSMutableString stringWithString:@"\\inner"];
    if (self.leftBoundary) {
        [str appendFormat:@"[%@]", self.leftBoundary.nucleus];
    }
    [str appendFormat:@"{%@}", self.innerList.stringValue];
    if (self.rightBoundary) {
        [str appendFormat:@"[%@]", self.rightBoundary.nucleus];
    }
    
    if (self.superScript) {
        [str appendFormat:@"^{%@}", self.superScript.stringValue];
    }
    if (self.subScript) {
        [str appendFormat:@"_{%@}", self.subScript.stringValue];
    }
    return str;
}

- (id)copyWithZone:(NSZone *)zone
{
    MTInner* inner = [super copyWithZone:zone];
    inner.innerList = [self.innerList copyWithZone:zone];
    inner.leftBoundary = [self.leftBoundary copyWithZone:zone];
    inner.rightBoundary = [self.rightBoundary copyWithZone:zone];
    return inner;
}

- (instancetype)finalized
{
    MTInner *newInner = [super finalized];
    newInner.innerList = newInner.innerList.finalized;
    return newInner;
}

@end

#pragma mark - MTAdaptive

@implementation MTAdaptive

- (instancetype)init
{
    self = [super initWithType:kMTMathAtomAdaptive value:@""];
    return self;
}

- (instancetype)initWithType:(MTMathAtomType)type value:(NSString *)value
{
    if (type == kMTMathAtomAdaptive) {
        return [self init];
    }
    @throw [NSException exceptionWithName:@"InvalidMethod"
                                   reason:@"[MTAdaptive initWithType:value:] cannot be called. Use [MTAdaptive init] instead."
                                 userInfo:nil];
    return nil;
}

- (void)setBoundary:(MTMathAtom *)boundary
{
    if (boundary && boundary.type != kMTMathAtomBoundary) {
        @throw [[NSException alloc] initWithName:@"Error"
                                          reason:[NSString stringWithFormat:@"boundary must be of type kMTMathAtomBoundary"]
                                        userInfo:nil];
    }
    _boundary = boundary;
}

- (NSString *)stringValue
{
    NSMutableString* str = [NSMutableString stringWithString:@"\\adaptive"];
    if (self.boundary) {
        [str appendFormat:@"[%@]", self.boundary.nucleus];
    }
    
    if (self.superScript) {
        [str appendFormat:@"^{%@}", self.superScript.stringValue];
    }
    if (self.subScript) {
        [str appendFormat:@"_{%@}", self.subScript.stringValue];
    }
    return str;
}

- (NSString *)adaptiveID
{
    if (!_adaptiveID) {
        _adaptiveID = [NSUUID UUID].UUIDString;
    }
    return _adaptiveID;
}

- (id)copyWithZone:(NSZone *)zone
{
    MTAdaptive* adaptive = [super copyWithZone:zone];
    adaptive.boundary = [self.boundary copyWithZone:zone];
    adaptive.adaptiveID = self.adaptiveID;
    return adaptive;
}

- (instancetype)finalized
{
    MTAdaptive *newAdaptive = [super finalized];
    return newAdaptive;
}

@end

#pragma mark - MTOverline

@implementation MTOverLine

- (instancetype)init
{
    self = [super initWithType:kMTMathAtomOverline value:@""];
    return self;
}

- (instancetype)initWithType:(MTMathAtomType)type value:(NSString *)value
{
    if (type == kMTMathAtomOverline) {
        return [self init];
    }
    @throw [NSException exceptionWithName:@"InvalidMethod"
                                   reason:@"[MTOverline initWithType:value:] cannot be called. Use [MTOverline init] instead."
                                 userInfo:nil];
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    MTOverLine* op = [super copyWithZone:zone];
    op.innerList = [self.innerList copyWithZone:zone];
    op.useArrow = self.useArrow;
    return op;
}

- (instancetype)finalized
{
    MTOverLine* newOverline = [super finalized];
    newOverline.innerList = newOverline.innerList.finalized;
    newOverline.useArrow = self.useArrow;
    return newOverline;
}

@end

#pragma mark - MTUnderline

@implementation MTUnderLine

- (instancetype)init
{
    self = [super initWithType:kMTMathAtomUnderline value:@""];
    return self;
}

- (instancetype)initWithType:(MTMathAtomType)type value:(NSString *)value
{
    if (type == kMTMathAtomUnderline) {
        return [self init];
    }
    @throw [NSException exceptionWithName:@"InvalidMethod"
                                   reason:@"[MTUnderline initWithType:value:] cannot be called. Use [MTUnderline init] instead."
                                 userInfo:nil];
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    MTUnderLine* op = [super copyWithZone:zone];
    op.innerList = [self.innerList copyWithZone:zone];
    return op;
}

- (instancetype)finalized
{
    MTUnderLine* newUnderline = [super finalized];
    newUnderline.innerList = newUnderline.innerList.finalized;
    return newUnderline;
}

@end

#pragma mark - MTMiddleLine

@implementation MTHLine

- (instancetype)init
{
    self = [super initWithType:kMTMathAtomHline value:@""];
    return self;
}

- (instancetype)initWithType:(MTMathAtomType)type value:(NSString *)value
{
    if (type == kMTMathAtomHline) {
        return [self init];
    }
    @throw [NSException exceptionWithName:@"InvalidMethod"
                                   reason:@"[MTHline initWithType:value:] cannot be called. Use [MTHline init] instead."
                                 userInfo:nil];
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    MTHLine* hline = [super copyWithZone:zone];
    return hline;
}

- (instancetype)finalized
{
    MTHLine* hline = [super finalized];
    return hline;
}

@end

@implementation MTOverbrace

- (instancetype)init
{
    self = [super initWithType:kMTMathAtomOverbrace value:@""];
    return self;
}

- (instancetype)initWithType:(MTMathAtomType)type value:(NSString *)value
{
    if (type == kMTMathAtomOverbrace) {
        return [self init];
    }
    @throw [NSException exceptionWithName:@"InvalidMethod"
                                   reason:@"[MTHline initWithType:value:] cannot be called. Use [MTHline init] instead."
                                 userInfo:nil];
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    MTOverbrace* overbrace = [super copyWithZone:zone];
    overbrace.contentor = [self.contentor copyWithZone:zone];
    overbrace.labelor = [self.labelor copyWithZone:zone];
    return overbrace;
}

- (instancetype)finalized
{
    MTOverbrace* overbrace = [super finalized];
    overbrace.contentor = overbrace.contentor.finalized;
    overbrace.labelor = overbrace.labelor.finalized;
    return overbrace;
}

@end

@implementation MTUnderbrace

- (instancetype)init
{
    self = [super initWithType:kMTmathAtomUnderbrace value:@""];
    return self;
}

- (instancetype)initWithType:(MTMathAtomType)type value:(NSString *)value
{
    if (type == kMTmathAtomUnderbrace) {
        return [self init];
    }
    @throw [NSException exceptionWithName:@"InvalidMethod"
                                   reason:@"[MTHline initWithType:value:] cannot be called. Use [MTHline init] instead."
                                 userInfo:nil];
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    MTUnderbrace* underbrace = [super copyWithZone:zone];
    underbrace.contentor = [self.contentor copyWithZone:zone];
    underbrace.labelor = [self.labelor copyWithZone:zone];
    return underbrace;
}

- (instancetype)finalized
{
    MTUnderbrace* underbrace = [super finalized];
    underbrace.contentor = underbrace.contentor.finalized;
    underbrace.labelor = underbrace.labelor.finalized;
    return underbrace;
}

@end



#pragma mark - MTAccent

@implementation MTAccent

- (instancetype)initWithValue:(NSString *)value
{
    self = [super initWithType:kMTMathAtomAccent value:value];
    return self;
}

- (instancetype)initWithType:(MTMathAtomType)type value:(NSString *)value
{
    if (type == kMTMathAtomAccent) {
        return [self initWithValue:value];
    }
    @throw [NSException exceptionWithName:@"InvalidMethod"
                                   reason:@"[MTAccent initWithType:value:] cannot be called. Use [MTAccent initWithValue:] instead."
                                 userInfo:nil];
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    MTAccent* op = [super copyWithZone:zone];
    op.innerList = [self.innerList copyWithZone:zone];
    return op;
}

- (instancetype)finalized
{
    MTAccent* newAccent = [super finalized];
    newAccent.innerList = newAccent.innerList.finalized;
    return newAccent;
}

@end

#pragma mark - MTMathSpace

@implementation MTMathSpace

- (instancetype)initWithSpace:(CGFloat)space
{
    self = [super initWithType:kMTMathAtomSpace value:@""];
    if (self) {
        _space = space;
    }
    return self;
}

- (instancetype)initWithType:(MTMathAtomType)type value:(NSString *)value
{
    if (type == kMTMathAtomSpace) {
        return [self initWithSpace:0];
    }
    @throw [NSException exceptionWithName:@"InvalidMethod"
                                   reason:@"[MTMathSpace initWithType:value:] cannot be called. Use [MTMathSpace initWithSpace:] instead."
                                 userInfo:nil];
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    MTMathSpace* op = [super copyWithZone:zone];
    op->_space = self.space;
    return op;
}

@end

#pragma mark - MTMathStyle

@implementation MTMathStyle

- (instancetype)initWithStyle:(MTLineStyle)style
{
    self = [super initWithType:kMTMathAtomStyle value:@""];
    if (self) {
        _style = style;
    }
    return self;
}

- (instancetype)initWithType:(MTMathAtomType)type value:(NSString *)value
{
    if (type == kMTMathAtomStyle) {
        return [self initWithStyle:kMTLineStyleDisplay];
    }
    @throw [NSException exceptionWithName:@"InvalidMethod"
                                   reason:@"[MTMathStyle initWithType:value:] cannot be called. Use [MTMathStyle initWithStyle:] instead."
                                 userInfo:nil];
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    MTMathStyle* op = [super copyWithZone:zone];
    op->_style = self.style;
    return op;
}

@end

#pragma mark - MTMathColor

@implementation MTMathColor


- (instancetype)init
{
    self = [super initWithType:kMTMathAtomColor value:@""];
    return self;
}

- (instancetype)initWithType:(MTMathAtomType)type value:(NSString *)value
{
    if (type == kMTMathAtomColor) {
        return [self init];
    }
    @throw [NSException exceptionWithName:@"InvalidMethod"
                                   reason:@"[MTMathColor initWithType:value:] cannot be called. Use [MTMathColor init] instead."
                                 userInfo:nil];
    return nil;
}

- (NSString *)stringValue
{
    NSMutableString* str = [NSMutableString stringWithString:@"\\color"];
    [str appendFormat:@"{%@}{%@}", self.colorString, self.innerList.stringValue];
    return str;
}

- (id)copyWithZone:(NSZone *)zone
{
    MTMathColor* op = [super copyWithZone:zone];
    op.innerList = [self.innerList copyWithZone:zone];
    op->_colorString = self.colorString;
    return op;
}

- (instancetype)finalized
{
    MTMathColor *newInner = [super finalized];
    newInner.innerList = newInner.innerList.finalized;
    return newInner;
}

@end

#pragma mark - MTMathColorbox

@implementation MTMathColorbox


- (instancetype)init
{
    self = [super initWithType:kMTMathAtomColorbox value:@""];
    return self;
}

- (instancetype)initWithType:(MTMathAtomType)type value:(NSString *)value
{
    if (type == kMTMathAtomColorbox) {
        return [self init];
    }
    @throw [NSException exceptionWithName:@"InvalidMethod"
                                   reason:@"[MTMathColorbox initWithType:value:] cannot be called. Use [MTMathColorbox init] instead."
                                 userInfo:nil];
    return nil;
}

- (NSString *)stringValue
{
    NSMutableString* str = [NSMutableString stringWithString:@"\\colorbox"];
    [str appendFormat:@"{%@}{%@}", self.colorString, self.innerList.stringValue];
    return str;
}

- (id)copyWithZone:(NSZone *)zone
{
    MTMathColorbox* op = [super copyWithZone:zone];
    op.innerList = [self.innerList copyWithZone:zone];
    op->_colorString = self.colorString;
    return op;
}

- (instancetype)finalized
{
    MTMathColorbox *newInner = [super finalized];
    newInner.innerList = newInner.innerList.finalized;
    return newInner;
}

@end

#pragma mark - MTBoxed

@implementation MTBoxed

- (instancetype)init
{
    self = [super initWithType:kMTMathAtomBoxed value:@""];
    if (self) {
        self.type = kMTMathAtomBoxed;
        self.innerList = nil;
        self.isMathMode = YES;
    }
    return self;
}

- (instancetype)initWithType:(MTMathAtomType)type value:(NSString *)value
{
    if (type == kMTMathAtomBoxed) {
        return [self init];
    }
    @throw [NSException exceptionWithName:@"InvalidMethod"
                                   reason:@"[MTBoxed initWithType:value:] cannot be called. Use [MTBoxed init] instead."
                                 userInfo:nil];
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    MTBoxed* op = [super copyWithZone:zone];
    op.innerList = [self.innerList copyWithZone:zone];
    op->_isMathMode = self.isMathMode;
    return op;
}

- (instancetype)finalized
{
    MTBoxed *newInner = [super finalized];
    newInner.innerList = newInner.innerList.finalized;
    return newInner;
}
@end


#pragma mark - MTMathTag
// 布局在外部处理拿不到contex的宽度，放到内部实现
@implementation MTMathTag

- (instancetype)init
{
    self = [super initWithType:KMTMathAtomTag value:@""];
    if (self) {
        self.type = KMTMathAtomTag;
        self.tagStr = nil;
    }
    return self;
}

- (instancetype)initWithType:(MTMathAtomType)type value:(NSString *)value
{
    if (type == KMTMathAtomTag) {
        return [self init];
    }
    @throw [NSException exceptionWithName:@"InvalidMethod"
                                   reason:@"[MTBoxed initWithType:value:] cannot be called. Use [MTBoxed init] instead."
                                 userInfo:nil];
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    MTMathTag* op = [super copyWithZone:zone];
    op.innerList = [self.innerList copyWithZone:zone];
    op.tagStr = [self.tagStr copyWithZone:zone];
    return op;
}

- (instancetype)finalized
{
    MTMathTag *newInner = [super finalized];
    newInner.innerList = newInner.innerList.finalized;
    return newInner;
}
@end


#pragma mark - MTMathTable

@interface MTMathTable ()

@property (nonatomic, nonnull) NSMutableArray<NSNumber*>* alignments;
@property (nonatomic, nonnull) NSMutableArray<NSMutableArray<MTMathList*>*>* cells;

@end

@implementation MTMathTable

- (instancetype)initWithEnvironment:(NSString *)env
{
    self = [super initWithType:kMTMathAtomTable value:@""];
    if (self) {
        self.alignments = [NSMutableArray array];
        self.cells = [NSMutableArray array];
        self.interRowAdditionalSpacing = 0;
        self.interColumnSpacing = 0;
        _environment = env;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithEnvironment:nil];
}

- (instancetype)initWithType:(MTMathAtomType)type value:(NSString *)value
{
    if (type == kMTMathAtomTable) {
        return [self init];
    }
    @throw [NSException exceptionWithName:@"InvalidMethod"
                                   reason:@"[MTMathTable initWithType:value:] cannot be called. Use [MTMathTable init] instead."
                                 userInfo:nil];
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    MTMathTable* op = [super copyWithZone:zone];
    op.interRowAdditionalSpacing = self.interRowAdditionalSpacing;
    op.interColumnSpacing = self.interColumnSpacing;
    op->_environment = self.environment;
    op->_envConfig = self.envConfig;
    op.alignments = [NSMutableArray arrayWithArray:self.alignments];
    // Perform a deep copy of the cells.
    NSMutableArray* cellCopy = [NSMutableArray arrayWithCapacity:self.cells.count];
    for (NSMutableArray* row in self.cells) {
        [cellCopy addObject:[[NSMutableArray alloc] initWithArray:row copyItems:YES]];
    }
    op.cells = cellCopy;
    return op;
}

- (instancetype)finalized
{
    MTMathTable* table = [super finalized];
    for (NSMutableArray<MTMathList*>* row in table.cells) {
        for (int i = 0; i < row.count; i++) {
            row[i] = row[i].finalized;
        }
    }
    table.environment = self.environment;
    table.envConfig = self.envConfig;
    return table;
}

- (void)setCell:(MTMathList *)list forRow:(NSInteger)row column:(NSInteger)column
{
    NSParameterAssert(list);
    
    if (self.cells.count <= row) {
        // Add more rows
        for (NSInteger i = self.cells.count;  i <= row; i++) {
            _cells[i] = [NSMutableArray array];
        }
    }
    NSMutableArray<MTMathList*> *rowArray = _cells[row];
    if (rowArray.count <= column) {
        // Add more columns
        for (NSInteger i = rowArray.count;  i < column; i++) {
            rowArray[i] = [[MTMathList alloc] init];
        }
    }
    rowArray[column] = list;
}

- (void)setAlignment:(MTColumnAlignment)alignment forColumn:(NSInteger)column
{
    if (self.alignments.count < column) {
        // Add more columns
        for (NSInteger i = self.alignments.count; i < column; i++) {
            _alignments[i] = @(kMTColumnAlignmentCenter);
        }
    }
    _alignments[column] = @(alignment);
}

- (MTColumnAlignment)getAlignmentForColumn:(NSInteger)column
{
    if (self.alignments.count <= column) {
        return kMTColumnAlignmentCenter;
    } else {
        return self.alignments[column].integerValue;
    }
}

- (NSUInteger) numColumns
{
    NSUInteger numColumns = 0;
    for (NSArray* row in self.cells) {
        numColumns = MAX(numColumns, row.count);
    }
    return numColumns;
}

- (NSUInteger) numRows
{
    return self.cells.count;
}

@end

#pragma mark - MTMathList

@implementation MTMathList {
    NSMutableArray* _atoms;
}

+ (instancetype)mathListWithAtoms:(MTMathAtom *)firstAtom, ...
{
    MTMathList* list = [[MTMathList alloc] init];
    va_list args;
    va_start(args, firstAtom);
    for (MTMathAtom* atom = firstAtom; atom != nil; atom = va_arg(args, MTMathAtom*))
    {
        [list addAtom:atom];
    }
    va_end(args);
    return list;
}

+ (instancetype)mathListWithAtomsArray:(NSArray<MTMathAtom *> *)atoms
{
    MTMathList* list = [[MTMathList alloc] init];
    [list->_atoms addObjectsFromArray:atoms];
    return list;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _atoms = [NSMutableArray array];
    }
    return self;
}

- (bool) isAtomAllowed:(MTMathAtom*) atom
{
    return atom.type != kMTMathAtomBoundary;
}

- (void)addAtom:(MTMathAtom *)atom
{
    NSParameterAssert(atom);
    if (![self isAtomAllowed:atom]) {
        @throw [[NSException alloc] initWithName:@"Error"
                                          reason:[NSString stringWithFormat:@"Cannot add atom of type %@ in a mathlist", typeToText(atom.type)]
                                        userInfo:nil];
    }
    [_atoms addObject:atom];
}

- (void)insertAtom:(MTMathAtom *)atom atIndex:(NSUInteger) index
{
    if (![self isAtomAllowed:atom]) {
        @throw [[NSException alloc] initWithName:@"Error"
                                          reason:[NSString stringWithFormat:@"Cannot add atom of type %@ in a mathlist", typeToText(atom.type)]
                                        userInfo:nil];
    }
    [_atoms insertObject:atom atIndex:index];
}

- (void)append:(MTMathList *)list
{
    [_atoms addObjectsFromArray:list.atoms];
}

- (void)removeLastAtom
{
    if (_atoms.count > 0) {
        [_atoms removeLastObject];
    }
}

- (void) removeAtomAtIndex:(NSUInteger)index
{
    [_atoms removeObjectAtIndex:index];
}

- (void) removeAtomsInRange:(NSRange) range
{
    [_atoms removeObjectsInRange:range];
}

- (NSString *)stringValue
{
    NSMutableString* str = [NSMutableString string];
    for (MTMathAtom* atom in self.atoms) {
        [str appendString:atom.stringValue];
    }
    return str;
}

- (NSString *)description
{
    return self.atoms.description;
}

- (MTMathList *)finalized
{
    MTMathList* finalized = [MTMathList new];
    NSRange zeroRange = NSMakeRange(0, 0);
    
    MTMathAtom* prevNode = nil;
    for (MTMathAtom* atom in self.atoms) {
        MTMathAtom* newNode = [atom finalized];
        // Each character is given a separate index.
        if (NSEqualRanges(zeroRange, atom.indexRange)) {
            NSUInteger index = (prevNode == nil) ? 0 : prevNode.indexRange.location + prevNode.indexRange.length;
            newNode.indexRange = NSMakeRange(index, 1);
        }

        switch (newNode.type) {
            case kMTMathAtomBinaryOperator: {
                if (isNotBinaryOperator(prevNode)) {
                    newNode.type = kMTMathAtomUnaryOperator;
                }
                break;
            }
            case kMTMathAtomRelation:
            case kMTMathAtomPunctuation:
            case kMTMathAtomClose:
                if (prevNode && prevNode.type == kMTMathAtomBinaryOperator) {
                    prevNode.type = kMTMathAtomUnaryOperator;
                }
                break;
                
            case kMTMathAtomNumber:
                // combine numbers together
                if (prevNode && prevNode.type == kMTMathAtomNumber && !prevNode.subScript && !prevNode.superScript) {
                    [prevNode fuse:newNode];
                    // skip the current node, we are done here.
                    continue;
                }
                break;
            case kMTMathAtomTable:
                [(MTMathTable *)newNode setEnvConfig:[(MTMathTable *)atom envConfig]];
                break;
            case kMTMathAtomFraction:
                ((MTFraction *)newNode).isCfrac = ((MTFraction *)atom).isCfrac;
                break;
            default:
                break;
        }
        [finalized addAtom:newNode];
        prevNode = newNode;
    }
    if (prevNode && prevNode.type == kMTMathAtomBinaryOperator) {
        // it isn't a binary since there is noting after it. Make it a unary
        prevNode.type = kMTMathAtomUnaryOperator;
    }
    return finalized;
}

#pragma mark NSCopying

// Makes a deep copy of the list
- (id)copyWithZone:(NSZone *)zone
{
    MTMathList* list = [[[self class] allocWithZone:zone] init];
    list->_atoms = [[NSMutableArray alloc] initWithArray:self.atoms copyItems:YES];
    return list;
}

@end
