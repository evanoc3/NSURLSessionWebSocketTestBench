//
//  WebSocketManager.swift
//  NSURLSessionWebSocketTestBench
//
//  Created by Evan O'Connor on 22/01/2024.
//

import Foundation
import Network


let webSocketManager = WebSocketManager()


// MARK: - WebSocketManagerDelegate protocol
protocol WebSocketManagerDelegate: AnyObject {
	func webSocketEventDidHappen(message: String)
}


// MARK: - WebSocketManager class
class WebSocketManager: NSObject {
	
	// MARK: Properties
	
	var proxyConfigurations: [ProxyConfiguration]?
	var connectionProxyDictionary: [AnyHashable: Any]?
	var isConnected: Bool {
		urlSession != nil && webSocketTask != nil
	}
	weak var delegate: WebSocketManagerDelegate?
	private var urlSession: URLSession?
	private var webSocketTask: URLSessionWebSocketTask?
	private let dispatchQueue = DispatchQueue(label: "ie.evanoconnor.WebSocketProxyTestBench", qos: .userInitiated)
	
	
	// MARK: Public API
	
    public func connect(url: URL) {
		let sessionConfiguration = buildSessionConfiguration()
		urlSession = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: OperationQueue())
		webSocketTask = urlSession!.webSocketTask(with: url)
		webSocketTask?.resume()
		listenForMessage()
	}
	
	public func disconnect() {
		webSocketTask?.cancel()
		urlSession?.invalidateAndCancel()
		
		webSocketTask = nil
		urlSession = nil
	}
	
    public func sendMessage(message: String) {
		guard let webSocketTask else { return }
		
		webSocketTask.send(.string(message), completionHandler: { [weak self, message] (error) in
			guard let self else { return }
			
			if let error {
				self.delegate?.webSocketEventDidHappen(message: "Error sending: \(error.localizedDescription)")
				return
			}
			
			self.delegate?.webSocketEventDidHappen(message: "Sent: \(message)")
		})
	}
	
	
	// MARK: Private Methods
	
	private func buildSessionConfiguration() -> URLSessionConfiguration {
		let config = URLSessionConfiguration.default
		
		if let connectionProxyDictionary {
			config.connectionProxyDictionary = connectionProxyDictionary
		}
		
		if #available(macOS 14.0, *) {
			if let proxyConfigurations {
				config.proxyConfigurations = proxyConfigurations
			}
		}
		
		return config
	}
	
	private func listenForMessage() {
		guard let webSocketTask else { return }
		
		dispatchQueue.async { [weak self] in
			
			webSocketTask.receive { [weak self] (result) in
				guard let self else { return }
				
				switch result {
					case .failure(let error):
						self.delegate?.webSocketEventDidHappen(message: "listen.failure: \(error.localizedDescription)")
					
					case .success(let message):
						switch message {
							case .string(let text):
								self.delegate?.webSocketEventDidHappen(message: "Received: \(text)")
							
							case .data(let data):
								let message = String(decoding: data, as: UTF8.self)
								self.delegate?.webSocketEventDidHappen(message: "Received: \(message)")
							
							@unknown default:
								self.delegate?.webSocketEventDidHappen(message: "Received unknown data.")
						}
						self.listenForMessage()
				}
			}
		}
	}

}


// MARK: - URLSessionWebSocketDelegate extension
extension WebSocketManager: URLSessionWebSocketDelegate {
	
	func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocolStr: String?) {
		delegate?.webSocketEventDidHappen(message: "URLSessionWebSocketDelegate.didOpenWithProtocol protocolStr:\(protocolStr != nil ? "\"\(protocolStr!)\"" : "nil")")
	}
	
	func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
		delegate?.webSocketEventDidHappen(message: "URLSessionWebSocketDelegate.didCloseWith closeCode:\(closeCode)")
	}
	
}


// MARK: - URLSessionTaskDelegate extension
extension WebSocketManager: URLSessionTaskDelegate {
	
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard task.state != .completed || (error as? NSError)?.code != NSURLErrorCancelled else { return }
        
        var errMsg = "URLSessionTaskDelegate.didCompleteWithError error:\(error != nil ? "\"\(error!.localizedDescription)\"" : "nil")"
        if let error, let errMsgDesc = WebSocketManagerUtils.getErrorName(fromCode: (error as NSError).code) {
            errMsg += " a.k.a. \(errMsgDesc)"
        }
		delegate?.webSocketEventDidHappen(message: errMsg)
	}

	func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
		delegate?.webSocketEventDidHappen(message: "URLSessionTaskDelegate.didReceive(challenge:)")
		return (.performDefaultHandling, nil)
	}
	
	func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard error != nil else { return }
        var errMsg = "URLSessionTaskDelegate.didBecomeInvalidWithError error:\(error != nil ? "\"\(error!.localizedDescription)\"" : "nil")"
        if let error, let errMsgDesc = WebSocketManagerUtils.getErrorName(fromCode: (error as NSError).code) {
            errMsg += " a.k.a. \(errMsgDesc)"
        }
		delegate?.webSocketEventDidHappen(message: errMsg)
	}
	
}


// MARK: - WebSocketManagerUtils struct
struct WebSocketManagerUtils {
    
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
