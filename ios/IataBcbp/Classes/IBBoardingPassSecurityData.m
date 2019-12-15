//
//  IBBoardingPass.m
//  IataBcbp
//
//  Created by Martin Mroz on 8/16/18.
//  Copyright © 2019 Martin Mroz. All rights reserved.
//

#import "IBBoardingPassSecurityData.h"
#import "IBBoardingPassSecurityData_Private.h"

#import "IBBcbp.h"
#import "NSString+Bcbp.h"

@implementation IBBoardingPassSecurityData

// MARK: - Class Methods

+ (instancetype)securityDataWithBcbp:(IBBcbp *)bcbp;
{
    NSParameterAssert(bcbp != NULL);
    if (bcbp == NULL) {
        return nil;
    }

    NSString * const typeOfSecurityData =
        [bcbp securityFieldWithId:BCBP_SECURITY_FIELD_ID_TYPE_OF_SECURITY_DATA];
    NSString * const securityData =
        [bcbp securityFieldWithId:BCBP_SECURITY_FIELD_ID_SECURITY_DATA];

    return [[self alloc] initWithTypeOfSecurityData:typeOfSecurityData
                                       securityData:securityData];
}

// MARK: - Initialization

- (_Nullable instancetype)init;
{
    [NSException raise:NSInternalInconsistencyException
                format:@"%s is not a supported initializer", __PRETTY_FUNCTION__];

    return nil;
}

- (instancetype)initWithTypeOfSecurityData:(NSString *)typeOfSecurityData
                              securityData:(NSString *)securityData;
{
    self = [super init];
    if (!self) {
        return nil;
    }

    _typeOfSecurityData = [typeOfSecurityData copy];
    _securityData = [securityData copy];

    return self;
}

// MARK: - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder;
{
    return [self initWithTypeOfSecurityData:[coder decodeObjectOfClass:[NSString class] forKey:@"typeOfSecurityData"]
                               securityData:[coder decodeObjectOfClass:[NSString class] forKey:@"securityData"]];
}

- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeObject:self.typeOfSecurityData
                 forKey:@"typeOfSecurityData"];
    [coder encodeObject:self.securityData
                 forKey:@"securityData"];
}

// MARK: - NSObject

- (NSUInteger)hash;
{
    return (self.typeOfSecurityData.hash ^
            self.securityData.hash);
}

- (instancetype)copy;
{
    return self;
}

- (NSString *)debugDescription;
{
    return [NSString stringWithFormat:@"<%@:%p type = %@, data = %@>",
        NSStringFromClass(self.class),
        (void *)self,
        self.typeOfSecurityData,
        self.securityData
    ];
}

- (BOOL)isEqual:(id _Nullable)object;
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[IBBoardingPassSecurityData class]]) {
        return NO;
    }
    
    return [self isEqualToBoardingPassSecurityData:(IBBoardingPassSecurityData *)object];
}

// MARK: - Public Methods

- (BOOL)isEqualToBoardingPassSecurityData:(IBBoardingPassSecurityData *)securityData;
{
    NSParameterAssert(securityData != nil);
    if (securityData == nil) {
        return NO;
    }

    BOOL const hasEqualTypeOfSecurityData =
        (self.typeOfSecurityData == securityData.typeOfSecurityData) ||
        [self.typeOfSecurityData isEqual:securityData.typeOfSecurityData];
    BOOL const hasEqualSecurityData =
        (self.securityData == securityData.securityData) ||
        [self.securityData isEqual:securityData.securityData];

    return (hasEqualTypeOfSecurityData &&
            hasEqualSecurityData);
}

@end
