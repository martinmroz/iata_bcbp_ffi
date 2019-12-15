/*
 * Copyright (C) 2019 Martin Mroz
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

#import "IBBoardingPass.h"

#import "IBBcbp.h"
#import "IBBoardingPassLeg.h"
#import "IBBoardingPassLeg_Private.h"
#import "IBBoardingPassSecurityData.h"
#import "IBBoardingPassSecurityData_Private.h"
#import "NSDate+Bcbp.h"

@implementation IBBoardingPass

// MARK: - Class Methods

+ (_Nullable instancetype)boardingPassWithBcbpString:(NSString *)passString;
{
    NSParameterAssert(passString != nil);
    if (passString.length == 0) {
        return nil;
    }

    return [self boardingPassWithBcbpString:passString scannedAt:[NSDate date]];
}

+ (_Nullable instancetype)boardingPassWithBcbpString:(NSString *)passString scannedAt:(NSDate *)date;
{
    NSParameterAssert(passString != nil);
    NSParameterAssert(date != nil);
    if (passString.length == 0 || date == nil) {
        return nil;
    }

    IBBcbp *const bcbp = [IBBcbp bcbpWithString:passString];
    if (!bcbp) {
        return nil;
    }

    return [self boardingPassWithBcbp:bcbp scannedAt:date];
}

+ (_Nullable instancetype)boardingPassWithBcbp:(IBBcbp *)bcbp scannedAt:(NSDate *)date;
{
    NSParameterAssert(bcbp != NULL);
    NSParameterAssert(date != nil);
    if (bcbp == NULL || date == nil) {
        return nil;
    }

    // Mandatory top-level fields.
    NSString * const passengerName =
        [bcbp fieldWithId:BCBP_FIELD_ID_PASSENGER_NAME];
    NSString * const electronicTicketIndicatorValue =
        [bcbp fieldWithId:BCBP_FIELD_ID_ELECTRONIC_TICKET_INDICATOR];
    if (passengerName.length == 0 || electronicTicketIndicatorValue.length != 1) {
        return nil;
    }

    // Optional top-level fields.
    NSDate * const dateOfIssueOfBoardingPass = ^ NSDate * _Nullable {
        NSString * const julianRepresentation =
            [bcbp fieldWithId:BCBP_FIELD_ID_DATE_OF_ISSUE_OF_BOARDING_PASS];
        if (julianRepresentation.length > 0) {
            return [NSDate IB_dateWithFourDigitJulianString:julianRepresentation onOrBefore:date];
        } else {
            return nil;
        }
    }();

    NSString * const versionNumber =
        [bcbp fieldWithId:BCBP_FIELD_ID_VERSION_NUMBER];
    NSString * const passengerDescription =
        [bcbp fieldWithId:BCBP_FIELD_ID_PASSENGER_DESCRIPTION];
    NSString * const sourceOfCheckIn =
        [bcbp fieldWithId:BCBP_FIELD_ID_SOURCE_OF_CHECK_IN];
    NSString * const sourceOfBoardingPassIssuance =
        [bcbp fieldWithId:BCBP_FIELD_ID_SOURCE_OF_BOARDING_PASS_ISSUANCE];
    NSString * const documentType =
        [bcbp fieldWithId:BCBP_FIELD_ID_DOCUMENT_TYPE];
    NSString * const airlineDesignatorOfBoardingPassIssuer =
        [bcbp fieldWithId:BCBP_FIELD_ID_AIRLINE_DESIGNATOR_OF_BOARDING_PASS_ISSUER];
    NSString * const baggageTagLicensePlateNumbers =
        [bcbp fieldWithId:BCBP_FIELD_ID_BAGGAGE_TAG_LICENSE_PLATE_NUMBERS];
    NSString * const firstNonConsecutiveBaggageTagLicensePlateNumbers =
        [bcbp fieldWithId:BCBP_FIELD_ID_FIRST_NON_CONSECUTIVE_BAGGAGE_TAG_LICENSE_PLATE_NUMBERS];
    NSString * const secondNonConsecutiveBaggageTagLicensePlateNumbers =
        [bcbp fieldWithId:BCBP_FIELD_ID_SECOND_NON_CONSECUTIVE_BAGGAGE_TAG_LICENSE_PLATE_NUMBERS];

    // Create an array of the baggage tag license plate number ranges.
    NSMutableArray<NSString *> * const allBaggageTagLicensePlateRanges = [NSMutableArray new];

    if (baggageTagLicensePlateNumbers.length > 0) {
        [allBaggageTagLicensePlateRanges addObject:baggageTagLicensePlateNumbers];
    }
    if (firstNonConsecutiveBaggageTagLicensePlateNumbers.length > 0) {
        [allBaggageTagLicensePlateRanges addObject:firstNonConsecutiveBaggageTagLicensePlateNumbers];
    }
    if (secondNonConsecutiveBaggageTagLicensePlateNumbers.length > 0) {
        [allBaggageTagLicensePlateRanges addObject:secondNonConsecutiveBaggageTagLicensePlateNumbers];
    }

    // Nested flight leg data.
    NSMutableArray<IBBoardingPassLeg *> * const legs = [NSMutableArray arrayWithCapacity:bcbp.numberOfLegs];

    for (NSInteger i = 0; i < bcbp.numberOfLegs; ++i) {
        IBBoardingPassLeg * const leg = [IBBoardingPassLeg legWithBcbp:bcbp legIndex:i scannedAt:date];
        if (leg == nil) {
            return nil;
        } else {
            [legs addObject:leg];
        }
    }

    // Optional, nested security data structure.
    IBBoardingPassSecurityData * const securityData = [IBBoardingPassSecurityData securityDataWithBcbp:bcbp];

    return [[IBBoardingPass alloc] initWithPassengerName:passengerName
                               electronicTicketIndicator:[electronicTicketIndicatorValue characterAtIndex:0]
                               dateOfIssueOfBoardingPass:dateOfIssueOfBoardingPass
                                           versionNumber:versionNumber
                                    passengerDescription:passengerDescription
                                         sourceOfCheckIn:sourceOfCheckIn
                            sourceOfBoardingPassIssuance:sourceOfBoardingPassIssuance
                                            documentType:documentType
                   airlineDesignatorOfBoardingPassIssuer:airlineDesignatorOfBoardingPassIssuer
                         allBaggageTagLicensePlateRanges:allBaggageTagLicensePlateRanges
                                                    legs:legs
                                            securityData:securityData
                                               scannedAt:date];
}

// MARK: - Initialization

- (_Nullable instancetype)init;
{
    [NSException raise:NSInternalInconsistencyException
            format:@"%s is not a supported initializer", __PRETTY_FUNCTION__];

    return nil;
}

- (_Nullable instancetype)initWithPassengerName:(NSString *)passengerName
                      electronicTicketIndicator:(unichar)electronicTicketIndicator
                      dateOfIssueOfBoardingPass:(NSDate * _Nullable)dateOfIssueOfBoardingPass
                                  versionNumber:(NSString * _Nullable)versionNumber
                           passengerDescription:(NSString * _Nullable)passengerDescription
                                sourceOfCheckIn:(NSString * _Nullable)sourceOfCheckIn
                   sourceOfBoardingPassIssuance:(NSString * _Nullable)sourceOfBoardingPassIssuance
                                   documentType:(NSString * _Nullable)documentType
          airlineDesignatorOfBoardingPassIssuer:(NSString * _Nullable)airlineDesignatorOfBoardingPassIssuer
                allBaggageTagLicensePlateRanges:(NSArray<NSString *> *)allBaggageTagLicensePlateRanges
                                           legs:(NSArray<IBBoardingPassLeg *> *)legs
                                   securityData:(IBBoardingPassSecurityData *)securityData
                                      scannedAt:(NSDate *)date;
{
    NSParameterAssert(passengerName.length > 0);
    NSParameterAssert(securityData != nil);
    NSParameterAssert(allBaggageTagLicensePlateRanges != nil);
    NSParameterAssert(legs != nil);
    NSParameterAssert(date != nil);
    if (passengerName.length == 0 ||
        securityData == nil ||
        allBaggageTagLicensePlateRanges == nil ||
        legs == nil ||
        date == nil) {
        return nil;
    }

    self = [super init];
    if (!self) {
        return nil;
    }

    _passengerName = [passengerName copy];
    _electronicTicketIndicator = electronicTicketIndicator;
    _dateOfIssueOfBoardingPass = dateOfIssueOfBoardingPass;
    _versionNumber = [versionNumber copy];
    _passengerDescription = [passengerDescription copy];
    _sourceOfCheckIn = [sourceOfCheckIn copy];
    _sourceOfBoardingPassIssuance = [sourceOfBoardingPassIssuance copy];
    _documentType = [documentType copy];
    _airlineDesignatorOfBoardingPassIssuer = [airlineDesignatorOfBoardingPassIssuer copy];
    _allBaggageTagLicensePlateRanges = [allBaggageTagLicensePlateRanges copy];
    _legs = [legs copy];
    _securityData = securityData;
    _scannedAt = date;

    return self;
}

// MARK: - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder;
{
    NSString * const passengerName =
        [coder decodeObjectOfClass:[NSString class] forKey:@"passengerName"];
    unichar const electronicTicketIndicator =
        (unichar)[coder decodeInt64ForKey:@"electronicTicketIndicator"];
    NSDate * const dateOfIssueOfBoardingPass =
        [coder decodeObjectOfClass:[NSDate class] forKey:@"dateOfIssueOfBoardingPass"];
    NSString * const versionNumber =
        [coder decodeObjectOfClass:[NSString class] forKey:@"versionNumber"];
    NSString * const passengerDescription =
        [coder decodeObjectOfClass:[NSString class] forKey:@"passengerDescription"];
    NSString * const sourceOfCheckIn =
        [coder decodeObjectOfClass:[NSString class] forKey:@"sourceOfCheckIn"];
    NSString * const sourceOfBoardingPassIssuance =
        [coder decodeObjectOfClass:[NSString class] forKey:@"sourceOfBoardingPassIssuance"];
    NSString * const documentType =
        [coder decodeObjectOfClass:[NSString class] forKey:@"documentType"];
    NSString * const airlineDesignatorOfBoardingPassIssuer =
        [coder decodeObjectOfClass:[NSString class] forKey:@"airlineDesignatorOfBoardingPassIssuer"];
    NSArray<NSString *> * const allBaggageTagLicensePlateRanges =
        [coder decodeObjectOfClass:[NSArray class] forKey:@"allBaggageTagLicensePlateRanges"];
    NSArray<IBBoardingPassLeg *> * const legs =
        [coder decodeObjectOfClass:[NSArray class] forKey:@"legs"];
    IBBoardingPassSecurityData * const securityData =
        [coder decodeObjectOfClass:[IBBoardingPassSecurityData class] forKey:@"securityData"];
    NSDate * const scannedAt =
        [coder decodeObjectOfClass:[NSDate class] forKey:@"scannedAt"];

    return [self initWithPassengerName:passengerName
             electronicTicketIndicator:electronicTicketIndicator
             dateOfIssueOfBoardingPass:dateOfIssueOfBoardingPass
                         versionNumber:versionNumber
                  passengerDescription:passengerDescription
                       sourceOfCheckIn:sourceOfCheckIn
          sourceOfBoardingPassIssuance:sourceOfBoardingPassIssuance
                          documentType:documentType
 airlineDesignatorOfBoardingPassIssuer:airlineDesignatorOfBoardingPassIssuer
       allBaggageTagLicensePlateRanges:allBaggageTagLicensePlateRanges
                                  legs:legs
                          securityData:securityData
                             scannedAt:scannedAt];
}

- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeObject:self.passengerName
                 forKey:@"passengerName"];
    [coder encodeInt64:self.electronicTicketIndicator
                forKey:@"electronicTicketIndicator"];
    [coder encodeObject:self.dateOfIssueOfBoardingPass
                 forKey:@"dateOfIssueOfBoardingPass"];
    [coder encodeObject:self.versionNumber
                 forKey:@"versionNumber"];
    [coder encodeObject:self.passengerDescription
                 forKey:@"passengerDescription"];
    [coder encodeObject:self.sourceOfCheckIn
                 forKey:@"sourceOfCheckIn"];
    [coder encodeObject:self.sourceOfBoardingPassIssuance
                 forKey:@"sourceOfBoardingPassIssuance"];
    [coder encodeObject:self.documentType
                 forKey:@"documentType"];
    [coder encodeObject:self.airlineDesignatorOfBoardingPassIssuer
                 forKey:@"airlineDesignatorOfBoardingPassIssuer"];
    [coder encodeObject:self.allBaggageTagLicensePlateRanges
                 forKey:@"allBaggageTagLicensePlateRanges"];
    [coder encodeObject:self.legs
                 forKey:@"legs"];
    [coder encodeObject:self.securityData
                 forKey:@"securityData"];
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
    return (self.passengerName.hash ^
            self.electronicTicketIndicator ^
            self.dateOfIssueOfBoardingPass.hash ^
            self.versionNumber.hash ^
            self.passengerDescription.hash ^
            self.sourceOfCheckIn.hash ^
            self.sourceOfBoardingPassIssuance.hash ^
            self.documentType.hash ^
            self.airlineDesignatorOfBoardingPassIssuer.hash ^
            self.allBaggageTagLicensePlateRanges.hash ^
            self.legs.hash ^
            self.securityData.hash);
}

- (NSString *)debugDescription;
{
    return [NSString stringWithFormat:@"<%@:%p with %@ legs>",
        NSStringFromClass(self.class),
        (void *)self,
        @(self.legs.count)
    ];
}

- (BOOL)isEqual:(id _Nullable)object;
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[IBBoardingPass class]]) {
        return NO;
    }
    
    return [self isEqualToBoardingPass:(IBBoardingPass *)object];
}

// MARK: - Public Methods

- (BOOL)isEqualToBoardingPass:(IBBoardingPass *)boardingPass;
{
    NSParameterAssert(boardingPass != nil);
    if (boardingPass == nil) {
        return NO;
    }

    BOOL const hasEqualPassengerName =
        (self.passengerName == boardingPass.passengerName) ||
        [self.passengerName isEqual:boardingPass.passengerName];
    BOOL const hasEqualElectronicTicketIndicator =
        (self.electronicTicketIndicator == boardingPass.electronicTicketIndicator);
    BOOL const hasEqualDateOfIssueOfBoardingPass =
        (self.dateOfIssueOfBoardingPass == boardingPass.dateOfIssueOfBoardingPass) ||
        ([self.dateOfIssueOfBoardingPass compare:boardingPass.dateOfIssueOfBoardingPass] == NSOrderedSame);
    BOOL const hasEqualVersionNumber =
        (self.versionNumber == boardingPass.versionNumber) ||
        [self.versionNumber isEqual:boardingPass.versionNumber];
    BOOL const hasEqualPassengerDescription =
        (self.passengerDescription == boardingPass.passengerDescription) ||
        [self.passengerDescription isEqual:boardingPass.passengerDescription];
    BOOL const hasEqualSourceOfCheckIn =
        (self.sourceOfCheckIn == boardingPass.sourceOfCheckIn) ||
        [self.sourceOfCheckIn isEqual:boardingPass.sourceOfCheckIn];
    BOOL const hasEqualSourceOfBoardingPassIssuance =
        (self.sourceOfBoardingPassIssuance == boardingPass.sourceOfBoardingPassIssuance) ||
        [self.sourceOfBoardingPassIssuance isEqual:boardingPass.sourceOfBoardingPassIssuance];
    BOOL const hasEqualDocumentType =
        (self.documentType == boardingPass.documentType) ||
        [self.documentType isEqual:boardingPass.documentType];
    BOOL const hasEqualAirlineDesignatorOfBoardingPassIssuer =
        (self.airlineDesignatorOfBoardingPassIssuer == boardingPass.airlineDesignatorOfBoardingPassIssuer) ||
        [self.airlineDesignatorOfBoardingPassIssuer isEqual:boardingPass.airlineDesignatorOfBoardingPassIssuer];
    BOOL const hasEqualAllBaggageTagLicensePlateRanges =
        (self.allBaggageTagLicensePlateRanges == boardingPass.allBaggageTagLicensePlateRanges) ||
        [self.allBaggageTagLicensePlateRanges isEqual:boardingPass.allBaggageTagLicensePlateRanges];
    BOOL const hasEqualLegs =
        (self.legs == boardingPass.legs) ||
        [self.legs isEqual:boardingPass.legs];
    BOOL const hasEqualSecurityData =
        (self.securityData == boardingPass.securityData) ||
        [self.securityData isEqual:boardingPass.securityData];

    return (hasEqualPassengerName &&
            hasEqualElectronicTicketIndicator &&
            hasEqualDateOfIssueOfBoardingPass &&
            hasEqualVersionNumber &&
            hasEqualPassengerDescription &&
            hasEqualSourceOfCheckIn &&
            hasEqualSourceOfBoardingPassIssuance &&
            hasEqualDocumentType &&
            hasEqualAirlineDesignatorOfBoardingPassIssuer &&
            hasEqualAllBaggageTagLicensePlateRanges &&
            hasEqualLegs &&
            hasEqualSecurityData);
}

@end
