// Copyright (C) 2018 Martin Mroz
//
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE file for details.

//! iata_bcbp_ffi is a set of FFI bindings for the iata_bcbp library.
//! The library supports reading 'M' type IATA BCBP pass data and
//! supports all the fields defined in version 6 of the standard as
//! defined in IATA Resolution 792.

extern crate iata_bcbp;
extern crate libc;

use std::collections::hash_map::DefaultHasher;
use std::ffi;
use std::hash::{Hash, Hasher};
use std::ptr;
use std::str::FromStr;

use iata_bcbp::Bcbp;
use libc::{c_char, c_int};

/// Construct a new `Bcbp` by parsing the provided input string.
///
/// # Note
///
/// If the string passed in isn't a valid BCBP Type 'M' data string
/// this will return a null pointer.
///
/// # Safety
///
/// Make sure you destroy the object with [`BcbpDestroy()`] once you are
/// done with it.
///
/// [`BcbpDestroy()`]: fn.BcbpDestroy.html
///
/// # Issues
/// _: Return an error if parse fails instead of `null`.
#[no_mangle]
pub unsafe extern "C" fn BcbpCreateWithCString(input: *const c_char) -> *mut Bcbp {
    if input.is_null() {
        return ptr::null_mut();
    }

    let input_str = {
        if let Ok(value) = ffi::CStr::from_ptr(input).to_str() {
            value
        } else {
            return ptr::null_mut();
        }
    };

    if let Ok(bcbp) = Bcbp::from_str(input_str) {
        Box::into_raw(Box::new(bcbp))
    } else {
        ptr::null_mut()
    }
}

/// Construct a new `Bcbp` by copying the receiver.
///
/// # Note
///
/// If the receiver is a null pointer, this will return a null pointer.
/// If the receiver is a valid Bcbp instance, a new instance will be returned.
///
/// # Safety
///
/// Make sure you destroy the object with [`BcbpDestroy()`] once you are
/// done with it.
///
/// [`BcbpDestroy()`]: fn.BcbpDestroy.html
#[no_mangle]
pub unsafe extern "C" fn BcbpCreateCopy(bcbp_ptr: *const Bcbp) -> *mut Bcbp {
    if bcbp_ptr.is_null() {
        ptr::null_mut()
    } else {
        Box::into_raw(Box::new((&*bcbp_ptr).clone()))
    }
}

/// Computes the hash of the receiver.
///
/// # Note
///
/// If the receiver is a null pointer, this will return 0.
#[no_mangle]
pub unsafe extern "C" fn BcbpHash(bcbp_ptr: *const Bcbp) -> u64 {
    if bcbp_ptr.is_null() {
        0
    } else {
        let mut s = DefaultHasher::new();
        (&*bcbp_ptr).hash(&mut s);
        s.finish()
    }
}

/// Checks that two Bcbp instances are equal.
///
/// # Note
///
/// Returns `true` if both `lhs` and `rhs` are `NULL`.
/// Otherwise, returns `false` if either the `lhs` or `rhs` are `NULL`.
#[no_mangle]
pub unsafe extern "C" fn BcbpIsEqual(lhs: *const Bcbp, rhs: *const Bcbp) -> bool {
    if lhs == rhs {
        true
    } else if lhs == ptr::null() || rhs == ptr::null() {
        false
    } else {
        (&*lhs) == (&*rhs)
    }
}

/// Returns the debug description of the receiver.
///
/// # Note
///
/// If the receiver is a null pointer, this will return a null pointer.
///
/// # Safety
///
/// Make sure you destroy the result with [`BcbpDestroyString()`] once you are
/// done with it.
///
/// [`BcbpDestroyString()`]: fn.BcbpDestroyString.html
#[no_mangle]
pub unsafe extern "C" fn BcbpCopyDebugDesc(bcbp_ptr: *const Bcbp) -> *mut c_char {
    if bcbp_ptr.is_null() {
        ptr::null_mut()
    } else {
        let bcbp = &*bcbp_ptr;
        let debug_desc = format!("{:?}", bcbp);

        ffi::CString::new(debug_desc)
            .map(ffi::CString::into_raw)
            .unwrap_or(ptr::null_mut())
    }
}

/// Destroy a `Bcbp` once you are done with it.
#[no_mangle]
pub unsafe extern "C" fn BcbpDestroy(bcbp_ptr: *mut Bcbp) {
    if !bcbp_ptr.is_null() {
        drop(Box::from_raw(bcbp_ptr));
    }
}

/// Destroy a string copied out of a `Bcbp` instance once copied.
#[no_mangle]
pub unsafe extern "C" fn BcbpDestroyString(string: *mut c_char) {
    if !string.is_null() {
        drop(ffi::CString::from_raw(string));
    }
}

/// Returns the number of legs encoded within a boarding pass.
///
/// # Note
///
/// If the `Bcbp` object provided is null, this will return 0.
#[no_mangle]
pub unsafe extern "C" fn BcbpGetNumberOfLegs(bcbp_ptr: *const Bcbp) -> c_int {
    if bcbp_ptr.is_null() {
        0
    } else {
        (&*bcbp_ptr).legs().len() as c_int
    }
}

#[repr(C)]
#[derive(Copy, Clone, Eq, PartialEq, Ord, PartialOrd, Hash, Debug)]
/// Identifies a field at the root level of a boarding pass.
pub enum BcbpFieldId {
    /// Always `null`.
    Unknown = 0,
    /// The name of the passenger, required, 20 bytes.
    PassengerName,
    /// Electronic ticket indicator, required, 1 byte.
    ElectronicTicketIndicator,
    /// Version number, optional, 1 byte.
    VersionNumber,
    /// Passenger description, optional, 1 byte.
    PassengerDescription,
    /// Source of check-in, optional, 1 byte.
    SourceOfCheckIn,
    /// Source of boarding pass issuance, optional, 1 byte.
    SourceOfBoardingPassIssuance,
    /// Date of issue of boarding pass, optional, 4 bytes.
    DateOfIssueOfBoardingPass,
    /// Document type, optional, 1 byte.
    DocumentType,
    /// Airline designator of boarding pass issuer, optional, 3 bytes.
    AirlineDesignatorOfBoardingPassIssuer,
    /// Baggage tag license plate numbers, optional, 13 bytes.
    BaggageTagLicensePlateNumbers,
    /// First non-consecutive baggage tag license plate numbers, optional, 13 bytes.
    FirstNonConsecutiveBaggageTagLicensePlateNumbers,
    /// Second non-consecutive baggage tag license plate numbers, optional, 13 bytes.
    SecondNonConsecutiveBaggageTagLicensePlateNumbers,
}

/// Returns a copy of the specified field.
///
/// # Note
///
/// If the `Bcbp` object provided is null, this will return `false`.
/// If a `result` out-pointer is null, this will return `false`.
///
/// When a field is retrieved, a value is written into `result` and, if not null, the number
/// of bytes written into `result` are written into `length`. If no exists for the specified
/// field, `NULL` is written to `result` and, if not null, 0 is written into `length`.
/// The function then returns `true`.
///
/// Even if a field is specified within a boarding pass, it may be empty (all space)
/// or contain invalid data.
///
/// # Safety
///
/// Make sure you destroy the result with [`BcbpDestroyString()`] once you are
/// done with it. Make sure not to pass an invalid `field_id` into this function,
/// otherwise undefined behavior will ensue.
///
/// [`BcbpDestroyString()`]: fn.BcbpDestroyString.html
#[no_mangle]
pub unsafe extern "C" fn BcbpCopyField(
    bcbp_ptr: *const Bcbp,
    field_id: BcbpFieldId,
    result: *mut *mut c_char,
    length: *mut usize,
) -> bool {
    if bcbp_ptr.is_null() || result.is_null() {
        return false;
    }

    // Write default values into the result and length out-parameters.
    result.write(ptr::null_mut());
    if !length.is_null() {
        length.write(0);
    }

    let bcbp = &*bcbp_ptr;

     // Extract the specified field from the boarding pass root.
    let field_value: Option<Vec<u8>> = match field_id {
        BcbpFieldId::PassengerName =>
            Some(Vec::from(bcbp.passenger_name().as_bytes())),
        BcbpFieldId::ElectronicTicketIndicator =>
            Some(vec![bcbp.electronic_ticket_indicator() as u8]),
        BcbpFieldId::VersionNumber =>
            bcbp.version_number().map(|c| vec![c as u8]),
        BcbpFieldId::PassengerDescription =>
            bcbp.passenger_description().map(|c| vec![c as u8]),
        BcbpFieldId::SourceOfCheckIn =>
            bcbp.source_of_check_in().map(|c| vec![c as u8]),
        BcbpFieldId::SourceOfBoardingPassIssuance =>
            bcbp.source_of_boarding_pass_issuance().map(|c| vec![c as u8]),
        BcbpFieldId::DateOfIssueOfBoardingPass =>
            bcbp.date_of_issue_of_boarding_pass().map(|s| Vec::from(s.as_bytes())),
        BcbpFieldId::DocumentType =>
            bcbp.document_type().map(|c| vec![c as u8]),
        BcbpFieldId::AirlineDesignatorOfBoardingPassIssuer =>
            bcbp.airline_designator_of_boarding_pass_issuer().map(|s| Vec::from(s.as_bytes())),
        BcbpFieldId::BaggageTagLicensePlateNumbers =>
            bcbp.baggage_tag_license_plate_numbers().map(|s| Vec::from(s.as_bytes())),
        BcbpFieldId::FirstNonConsecutiveBaggageTagLicensePlateNumbers =>
            bcbp.first_non_consecutive_baggage_tag_license_plate_numbers().map(|s| Vec::from(s.as_bytes())),
        BcbpFieldId::SecondNonConsecutiveBaggageTagLicensePlateNumbers =>
            bcbp.second_non_consecutive_baggage_tag_license_plate_numbers().map(|s| Vec::from(s.as_bytes())),
        _ =>
            None,
    };

    if let Some(byte_vec) = field_value {
        let ffi_string_length = byte_vec.len();
        result.write(ffi::CString::from_vec_unchecked(byte_vec).into_raw());
        if !length.is_null() {
            length.write(ffi_string_length);
        }
    }

    return true;
}

#[repr(C)]
#[derive(Copy, Clone, Eq, PartialEq, Ord, PartialOrd, Hash, Debug)]
/// Identifies a field within the security data section of a boarding pass.
pub enum BcbpSecurityFieldId {
    /// Always `null`.
    Unknown = 0,
    /// The name of the passenger, optional, 1 byte.
    TypeOfSecurityData,
    /// Electronic ticket indicator, optional, arbitrary length up to 255 bytes.
    SecurityData,
}

/// Returns a copy of the specified security data field.
///
/// # Note
///
/// If the `Bcbp` object provided is null, this will return `false`.
/// If a `result` out-pointer is null, this will return `false`.
///
/// When a field is retrieved, a value is written into `result` and, if not null, the number
/// of bytes written into `result` are written into `length`. If no exists for the specified
/// field, `NULL` is written to `result` and, if not null, 0 is written into `length`.
/// The function then returns `true`.
///
/// Even if a field is specified within a boarding pass, it may be empty (all space)
/// or contain invalid data.
///
/// # Safety
///
/// Make sure you destroy the result with [`BcbpDestroyString()`] once you are
/// done with it. Make sure not to pass an invalid `field_id` into this function,
/// otherwise undefined behavior will ensue.
///
/// [`BcbpDestroyString()`]: fn.BcbpDestroyString.html
#[no_mangle]
pub unsafe extern "C" fn BcbpCopySecurityField(
    bcbp_ptr: *const Bcbp,
    field_id: BcbpSecurityFieldId,
    result: *mut *mut c_char,
    length: *mut usize,
) -> bool {
    if bcbp_ptr.is_null() || result.is_null() {
        return false;
    }

    // Write default values into the result and length out-parameters.
    result.write(ptr::null_mut());
    if !length.is_null() {
        length.write(0);
    }

    let bcbp = &*bcbp_ptr;

    // Extract the specified field from the boarding pass root.
    let field_value: Option<Vec<u8>> = match field_id {
        BcbpSecurityFieldId::TypeOfSecurityData =>
            bcbp.security_data().type_of_security_data().map(|c| vec![c as u8]),
        BcbpSecurityFieldId::SecurityData =>
            bcbp.security_data().security_data().map(|s| Vec::from(s.as_bytes())),
        _ =>
            None,
    };

    if let Some(byte_vec) = field_value {
        let ffi_string_length = byte_vec.len();
        result.write(ffi::CString::from_vec_unchecked(byte_vec).into_raw());
        if !length.is_null() {
            length.write(ffi_string_length);
        }
    }

    return true;
}

#[repr(C)]
#[derive(Copy, Clone, Eq, PartialEq, Ord, PartialOrd, Hash, Debug)]
/// Identifies a field associated with a specific leg of a boarding pass.
pub enum BcbpFlightLegFieldId {
    /// Always `null`.
    Unknown = 0,
    /// Operating carrier PNR code, required, 6 bytes.
    OperatingCarrierPNRCode,
    /// From city airport code, required, 4 bytes.
    FromCityAirportCode,
    /// To city airport code, required, 4 bytes.
    ToCityAirportCode,
    /// Operating carrier designator, required, 3 bytes.
    OperatingCarrierDesignator,
    /// Flight number, required, 5 bytes.
    FlightNumber,
    /// Date of flight, required, 3 bytes.
    DateOfFlight,
    /// Compartment code, required, 1 byte.
    CompartmentCode,
    /// Seat number, required, 4 bytes.
    SeatNumber,
    /// Check-in Sequence Number, required, 5 bytes.
    CheckInSequenceNumber,
    /// Passenger status, required, 1 byte.
    PassengerStatus,
    /// Airline numeric code, optional, 3 bytes.
    AirlineNumericCode,
    /// Document form serial number, optional, 10 bytes.
    DocumentFormSerialNumber,
    /// Selectee Indicator, optional, 1 byte.
    SelecteeIndicator,
    /// International Document Verification, optional, 1 byte.
    InternationalDocumentVerification,
    /// Marketing Carrier Designator, optional, 3 bytes.
    MarketingCarrierDesignator,
    /// Frequent Flyer Airline Designator, optional, 3 bytes.
    FrequentFlyerAirlineDesignator,
    /// Frequent Flyer Number, optional, 16 bytes.
    FrequentFlyerNumber,
    /// ID/AD Indicator, optional, 1 byte.
    IdAdIndicator,
    /// Free Baggage Allowance, optional, 3 bytes.
    FreeBaggageAllowance,
    /// Fast Track, optional, 1 byte.
    FastTrack,
    /// Airline Individual Use, optional, n bytes.
    AirlineIndividualUse,
}

/// Returns a copy of the specified flight leg data field.
///
/// # Note
///
/// If the `Bcbp` object provided is null, this will return `false`.
/// If a `result` out-pointer is null, this will return `false`.
///
/// When a field is retrieved, a value is written into `result` and, if not null, the number
/// of bytes written into `result` are written into `length`. If no exists for the specified
/// field, `NULL` is written to `result` and, if not null, 0 is written into `length`.
/// The function then returns `true`.
///
/// Even if a field is specified within a boarding pass, it may be empty (all space)
/// or contain invalid data.
///
/// # Safety
///
/// Make sure you destroy the result with [`BcbpDestroyString()`] once you are
/// done with it. Make sure not to pass an invalid `field_id` into this function,
/// otherwise undefined behavior will ensue.
///
/// [`BcbpDestroyString()`]: fn.BcbpDestroyString.html
///
/// # Issues
/// _: Return a specific error in the event an invalid leg is provided.
#[no_mangle]
pub unsafe extern "C" fn BcbpCopyFlightLegField(
    bcbp_ptr: *const Bcbp,
    leg: c_int,
    field_id: BcbpFlightLegFieldId,
    result: *mut *mut c_char,
    length: *mut usize,
) -> bool {
    if bcbp_ptr.is_null() || result.is_null() {
        return false;
    }

    let bcbp = &*bcbp_ptr;

    // Validate the specified leg index is valid.
    if leg < 0 || (leg as usize) >= bcbp.legs().len() {
        return false;
    }

    // Write default values into the result and length out-parameters.
    result.write(ptr::null_mut());
    if !length.is_null() {
        length.write(0);
    }

    let flight_leg = &bcbp.legs()[leg as usize];

    // Extract the specified field from the leg.
    let field_value: Option<Vec<u8>> = match field_id {
        BcbpFlightLegFieldId::OperatingCarrierPNRCode =>
            Some(Vec::from(flight_leg.operating_carrier_pnr_code().as_bytes())),
        BcbpFlightLegFieldId::FromCityAirportCode =>
            Some(Vec::from(flight_leg.from_city_airport_code().as_bytes())),
        BcbpFlightLegFieldId::ToCityAirportCode =>
            Some(Vec::from(flight_leg.to_city_airport_code().as_bytes())),
        BcbpFlightLegFieldId::OperatingCarrierDesignator =>
            Some(Vec::from(flight_leg.operating_carrier_designator().as_bytes())),
        BcbpFlightLegFieldId::FlightNumber =>
            Some(Vec::from(flight_leg.flight_number().as_bytes())),
        BcbpFlightLegFieldId::DateOfFlight =>
            Some(Vec::from(flight_leg.date_of_flight().as_bytes())),
        BcbpFlightLegFieldId::CompartmentCode =>
            Some(vec![flight_leg.compartment_code() as u8]),
        BcbpFlightLegFieldId::SeatNumber =>
            Some(Vec::from(flight_leg.seat_number().as_bytes())),
        BcbpFlightLegFieldId::CheckInSequenceNumber =>
            Some(Vec::from(flight_leg.check_in_sequence_number().as_bytes())),
        BcbpFlightLegFieldId::PassengerStatus =>
            Some(vec![flight_leg.passenger_status() as u8]),
        BcbpFlightLegFieldId::AirlineNumericCode =>
            flight_leg.airline_numeric_code().map(|s| Vec::from(s.as_bytes())),
        BcbpFlightLegFieldId::DocumentFormSerialNumber =>
            flight_leg.document_form_serial_number().map(|s| Vec::from(s.as_bytes())),
        BcbpFlightLegFieldId::SelecteeIndicator =>
            flight_leg.selectee_indicator().map(|c| vec![c as u8]),
        BcbpFlightLegFieldId::InternationalDocumentVerification =>
            flight_leg.international_document_verification().map(|c| vec![c as u8]),
        BcbpFlightLegFieldId::MarketingCarrierDesignator =>
            flight_leg.marketing_carrier_designator().map(|s| Vec::from(s.as_bytes())),
        BcbpFlightLegFieldId::FrequentFlyerAirlineDesignator =>
            flight_leg.frequent_flyer_airline_designator().map(|s| Vec::from(s.as_bytes())),
        BcbpFlightLegFieldId::FrequentFlyerNumber =>
            flight_leg.frequent_flyer_number().map(|s| Vec::from(s.as_bytes())),
        BcbpFlightLegFieldId::IdAdIndicator =>
            flight_leg.id_ad_indicator().map(|c| vec![c as u8]),
        BcbpFlightLegFieldId::FreeBaggageAllowance =>
            flight_leg.free_baggage_allowance().map(|s| Vec::from(s.as_bytes())),
        BcbpFlightLegFieldId::FastTrack =>
            flight_leg.fast_track().map(|c| vec![c as u8]),
        BcbpFlightLegFieldId::AirlineIndividualUse =>
            flight_leg.airline_individual_use().map(|s| Vec::from(s.as_bytes())),
        _ =>
            None,
    };

    if let Some(byte_vec) = field_value {
        let ffi_string_length = byte_vec.len();
        result.write(ffi::CString::from_vec_unchecked(byte_vec).into_raw());
        if !length.is_null() {
            length.write(ffi_string_length);
        }
    }

    return true;
}
