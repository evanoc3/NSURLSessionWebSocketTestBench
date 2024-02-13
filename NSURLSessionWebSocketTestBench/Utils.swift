//
//  Utils.swift
//  NSURLSessionWebSocketTestBench
//
//  Created by Evan O'Connor on 12/02/2024.
//

import Foundation


// MARK: - WebSocketManagerUtils struct
struct Utils {
    
    private init() {}
    
    static func getErrorName(fromCode code: Int) -> String? {
        // See: https://developer.apple.com/documentation/foundation/1508628-url_loading_system_error_codes
        let possibleErrorNames: [Int: String] = [
            NSURLErrorAppTransportSecurityRequiresSecureConnection: "NSURLErrorAppTransportSecurityRequiresSecureConnection",
            NSURLErrorBackgroundSessionInUseByAnotherProcess: "NSURLErrorBackgroundSessionInUseByAnotherProcess",
            NSURLErrorBackgroundSessionRequiresSharedContainer: "NSURLErrorBackgroundSessionRequiresSharedContainer",
            NSURLErrorBackgroundSessionWasDisconnected: "NSURLErrorBackgroundSessionWasDisconnected",
            NSURLErrorBadServerResponse: "NSURLErrorBadServerResponse",
            NSURLErrorBadURL: "NSURLErrorBadURL",
            NSURLErrorCallIsActive: "NSURLErrorCallIsActive",
            NSURLErrorCancelled: "NSURLErrorCancelled",
            NSURLErrorCannotCloseFile: "NSURLErrorCannotCloseFile",
            NSURLErrorCannotConnectToHost: "NSURLErrorCannotConnectToHost",
            NSURLErrorCannotCreateFile: "NSURLErrorCannotCreateFile",
            NSURLErrorCannotDecodeContentData: "NSURLErrorCannotDecodeContentData",
            NSURLErrorCannotDecodeRawData: "NSURLErrorCannotDecodeRawData",
            NSURLErrorCannotFindHost: "NSURLErrorCannotFindHost",
            NSURLErrorCannotLoadFromNetwork: "NSURLErrorCannotLoadFromNetwork",
            NSURLErrorCannotMoveFile: "NSURLErrorCannotMoveFile",
            NSURLErrorCannotOpenFile: "NSURLErrorCannotOpenFile",
            NSURLErrorCannotParseResponse: "NSURLErrorCannotParseResponse",
            NSURLErrorCannotRemoveFile: "NSURLErrorCannotRemoveFile",
            NSURLErrorCannotWriteToFile: "NSURLErrorCannotWriteToFile",
            NSURLErrorClientCertificateRejected: "NSURLErrorClientCertificateRejected",
            NSURLErrorClientCertificateRequired: "NSURLErrorClientCertificateRequired",
            NSURLErrorDataLengthExceedsMaximum: "NSURLErrorDataLengthExceedsMaximum",
            NSURLErrorDataNotAllowed: "NSURLErrorDataNotAllowed",
            NSURLErrorDNSLookupFailed: "NSURLErrorDNSLookupFailed",
            NSURLErrorDownloadDecodingFailedMidStream: "NSURLErrorDownloadDecodingFailedMidStream",
            NSURLErrorDownloadDecodingFailedToComplete: "NSURLErrorDownloadDecodingFailedToComplete",
            NSURLErrorFileDoesNotExist: "NSURLErrorFileDoesNotExist",
            NSURLErrorFileIsDirectory: "NSURLErrorFileIsDirectory",
            NSURLErrorFileOutsideSafeArea: "NSURLErrorFileOutsideSafeArea",
            NSURLErrorHTTPTooManyRedirects: "NSURLErrorHTTPTooManyRedirects",
            NSURLErrorInternationalRoamingOff: "NSURLErrorInternationalRoamingOff",
            NSURLErrorNetworkConnectionLost: "NSURLErrorNetworkConnectionLost",
            NSURLErrorNoPermissionsToReadFile: "NSURLErrorNoPermissionsToReadFile",
            NSURLErrorNotConnectedToInternet: "NSURLErrorNotConnectedToInternet",
            NSURLErrorRedirectToNonExistentLocation: "NSURLErrorRedirectToNonExistentLocation",
            NSURLErrorRequestBodyStreamExhausted: "NSURLErrorRequestBodyStreamExhausted",
            NSURLErrorResourceUnavailable: "NSURLErrorResourceUnavailable",
            NSURLErrorSecureConnectionFailed: "NSURLErrorSecureConnectionFailed",
            NSURLErrorServerCertificateHasBadDate: "NSURLErrorServerCertificateHasBadDate",
            NSURLErrorServerCertificateHasUnknownRoot: "NSURLErrorServerCertificateHasUnknownRoot",
            NSURLErrorServerCertificateNotYetValid: "NSURLErrorServerCertificateNotYetValid",
            NSURLErrorServerCertificateUntrusted: "NSURLErrorServerCertificateUntrusted",
            NSURLErrorTimedOut: "NSURLErrorTimedOut",
            NSURLErrorUnknown: "NSURLErrorUnknown",
            NSURLErrorUnsupportedURL: "NSURLErrorUnsupportedURL",
            NSURLErrorUserAuthenticationRequired: "NSURLErrorUserAuthenticationRequired",
            NSURLErrorUserCancelledAuthentication: "NSURLErrorUserCancelledAuthentication",
            NSURLErrorZeroByteResource: "NSURLErrorZeroByteResource"
        ]
        
        return possibleErrorNames.first(where: { $0.key == code })?.value
    }
    
}
