/*
 * Copyright (C) 2019 Martin Mroz
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

#import "IBBoardingPassLeg.h"
#import "IBBoardingPassLeg_Private.h"

#import "IBBcbp.h"
#import "NSDate+Bcbp.h"

@implementation IBBoardingPassLeg

// MARK: - Class Methods

+ (instancetype)legWithBcbp:(IBBcbp *)bcbp scannedAt:(NSDate *)date;
{
    NSParameterAssert(bcbp != NULL);
    NSParameterAssert(date != nil);
    if (bcbp == NULL || date == nil) {
        return nil;
    }

    return [[self alloc] initWithScannedAt:date];
}

// MARK: - Initialization

- (_Nullable instancetype)init;
{
    [NSException raise:NSInternalInconsistencyException
                format:@"%s is not a supported initializer", __PRETTY_FUNCTION__];

    return nil;
}

- (instancetype)initWithScannedAt:(NSDate *)date;
{
    NSParameterAssert(date != nil);
    if (date == nil) {
        return nil;
    }

    self = [super init];
    if (!self) {
        return nil;
    }

    _scannedAt = date;

    return self;
}

// MARK: - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder;
{
    NSDate * const scannedAt =
        [coder decodeObjectOfClass:[NSDate class] forKey:@"scannedAt"];

    return [self initWithScannedAt:scannedAt];
}

- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeObject:self.scannedAt
                 forKey:@"scannedAt"];
}

// MARK: - NSCopying

- (id)copyWithZone:(NSZone *)zone;
{
    return self;
}

// MARK: - NSObject

- (NSUInteger)hash;
{
    return 0;
}

- (NSString *)debugDescription;
{
    return [NSString stringWithFormat:@"<%@:%p>",
        NSStringFromClass(self.class),
        (void *)self
    ];
}

- (BOOL)isEqual:(id _Nullable)object;
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[IBBoardingPassLeg class]]) {
        return NO;
    }
    
    return [self isEqualToBoardingPassLeg:(IBBoardingPassLeg *)object];
}

// MARK: - Public Methods

- (BOOL)isEqualToBoardingPassLeg:(IBBoardingPassLeg *)leg;
{
    NSParameterAssert(leg != nil);
    if (leg == nil) {
        return NO;
    }

    return YES;
}

@end
