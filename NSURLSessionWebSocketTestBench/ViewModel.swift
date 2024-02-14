//
//  ViewModel.swift
//  NSURLSessionWebSocketTestBench
//
//  Created by Evan O'Connor on 22/01/2024.
//

import Foundation
import Network


fileprivate let textViewPlaceholderText = "WebSocket traffic will appear here...\n"


// MARK: - ViewModelDelegate protocol
protocol ViewModelDelegate: AnyObject {
	func proxySettingsUpdated()
	func textViewTextChanged()
}


// MARK: - ViewModel class
class ViewModel {
	
	// MARK: Properties
    
    private(set) var hostInputText = "wss://ws.postman-echo.com/raw"
	var connectionProxyDictionaryTabIsVisible: Bool {
        return overrideOsProxySettingsCheckboxIsChecked
	}
	var proxyConfigurationsTabIsVisible: Bool {
        guard #available(macOS 14.0, *) else { return false }
        return overrideOsProxySettingsCheckboxIsChecked
	}
	private(set) var overrideOsProxySettingsCheckboxIsChecked = false
    private(set) var legacyHttpProxyHost = ""
	private(set) var legacyHttpProxyPort: UInt16?
    private(set) var legacyHttpsProxyHost = ""
	private(set) var legacyHttpsProxyPort: UInt16?
    private(set) var legacySocksProxyHost = ""
	private(set) var legacySocksProxyPort: UInt16?
    private(set) var newHttpProxyHost = ""
	private(set) var newHttpProxyPort: UInt16?
    private(set) var newSocksProxyHost = ""
	private(set) var newSocksProxyPort: UInt16?
    private(set) var authenticationMethod: String?
    private(set) var authenticationUsername = ""
    private(set) var authenticationPassword = ""
    var connectButtonText: String {
        webSocketManager.isConnected ? "Disconnect" : "Connect"
    }
	private(set) var textViewText: String = textViewPlaceholderText
    var clearButtonIsVisible: Bool {
        !textViewText.isEmpty && textViewText != textViewPlaceholderText
    }
	var messageInputIsEnabled: Bool {
		webSocketManager.isConnected
	}
	var sendMessageButtonIsEnabled: Bool {
		webSocketManager.isConnected
	}
	weak var delegate: ViewModelDelegate?
	
	
	// MARK: Public API
	
	init() {
		webSocketManager.delegate = self
	}
	
    func saveProxySettings(overrideOsProxySettingsEnabled: Bool, host: String,
                           legacyHttpProxyHost: String, legacyHttpProxyPort: UInt16?,
						   legacyHttpsProxyHost: String, legacyHttpsProxyPort: UInt16?,
						   legacySocksProxyHost: String, legacySocksProxyPort: UInt16?,
						   newHttpProxyHost: String, newHttpProxyPort: UInt16?,
						   newSocksProxyHost: String, newSocksProxyPort: UInt16?,
                           authenticationMethod: String?, credentialsUsername: String, credentialsPassword: String) {
        self.overrideOsProxySettingsCheckboxIsChecked = overrideOsProxySettingsEnabled
        self.hostInputText = host
        
		self.legacyHttpProxyHost = legacyHttpProxyHost
		self.legacyHttpProxyPort = legacyHttpProxyPort
		
		self.legacyHttpsProxyHost = legacyHttpsProxyHost
		self.legacyHttpsProxyPort = legacyHttpsProxyPort
		
		self.legacySocksProxyHost = legacySocksProxyHost
		self.legacySocksProxyPort = legacySocksProxyPort
		
		self.newHttpProxyHost = newHttpProxyHost
		self.newHttpProxyPort = newHttpProxyPort
		
		self.newSocksProxyHost = newSocksProxyHost
		self.newSocksProxyPort = newSocksProxyPort
        
        self.authenticationMethod = authenticationMethod
        self.authenticationUsername = credentialsUsername
        self.authenticationPassword = credentialsPassword
        
		webSocketManager.proxyConfigurations = buildProxyConfigurations()
		webSocketManager.connectionProxyDictionary = buildConnectionProxyDictionary()
        webSocketManager.authenticationCredential = buildAuthenticationCredential()
        webSocketManager.authenticationMethod = buildAuthenticationMethod()
	}
	
	func buildConnectionProxyDictionary() -> [AnyHashable: Any]? {
		guard overrideOsProxySettingsCheckboxIsChecked else { return nil }
        let legacyHttpProxyIsEnabled = !legacyHttpProxyHost.isEmpty && legacyHttpProxyPort != nil
        let legacyHttpsProxyIsEnabled = !legacyHttpsProxyHost.isEmpty && legacyHttpsProxyPort != nil
        let legacySocksProxyIsEnabled = !legacySocksProxyHost.isEmpty && legacySocksProxyPort != nil
        guard legacyHttpProxyIsEnabled || legacyHttpsProxyIsEnabled || legacySocksProxyIsEnabled else { return nil }
        
        var connectionProxyDictionary: [AnyHashable: Any] = [:]
        
        if legacyHttpProxyIsEnabled {
            connectionProxyDictionary[kCFNetworkProxiesHTTPEnable] = 1
            connectionProxyDictionary[kCFNetworkProxiesHTTPProxy] = legacyHttpProxyHost
            connectionProxyDictionary[kCFNetworkProxiesHTTPPort] = legacyHttpProxyPort!
        }
        
        if legacyHttpsProxyIsEnabled {
            connectionProxyDictionary[kCFNetworkProxiesHTTPSEnable] = 1
            connectionProxyDictionary[kCFNetworkProxiesHTTPSProxy] = legacyHttpsProxyHost
            connectionProxyDictionary[kCFNetworkProxiesHTTPSPort] = legacyHttpsProxyPort!
        }
        
        if legacySocksProxyIsEnabled {
            connectionProxyDictionary[kCFNetworkProxiesSOCKSEnable] = 1
            connectionProxyDictionary[kCFNetworkProxiesSOCKSProxy] = legacySocksProxyHost
            connectionProxyDictionary[kCFNetworkProxiesSOCKSPort] = legacySocksProxyPort!
        }

        return connectionProxyDictionary
	}
	
	func buildProxyConfigurations() -> [ProxyConfiguration]? {
        guard overrideOsProxySettingsCheckboxIsChecked else { return nil }
        let newSocksProxyIsEnabled = !newSocksProxyHost.isEmpty && newSocksProxyPort != nil
        let newHttpProxyIsEnabled = !newHttpProxyHost.isEmpty && newHttpProxyPort != nil
        guard newSocksProxyIsEnabled || newHttpProxyIsEnabled else { return nil }
		
		var proxyConfigurations: [ProxyConfiguration] = []
		
        if newSocksProxyIsEnabled, let ipAddress = IPv4Address(newSocksProxyHost), let port = NWEndpoint.Port(rawValue: newSocksProxyPort!) {
			proxyConfigurations.append(
				ProxyConfiguration(socksv5Proxy: NWEndpoint.hostPort(host: NWEndpoint.Host.ipv4(ipAddress), port: port))
			)
		}
		
        if newHttpProxyIsEnabled, let ipAddress = IPv4Address(newHttpProxyHost), let port = NWEndpoint.Port(rawValue: newHttpProxyPort!) {
			proxyConfigurations.append(
				ProxyConfiguration(httpCONNECTProxy: NWEndpoint.hostPort(host: NWEndpoint.Host.ipv4(ipAddress), port: port))
			)
		}
		
		return proxyConfigurations
	}
	
    func buildAuthenticationCredential() -> URLCredential? {
        guard !authenticationUsername.isEmpty && !authenticationPassword.isEmpty else { return nil }
        return URLCredential(user: authenticationUsername, password: authenticationPassword, persistence: .forSession)
    }
    
    func buildAuthenticationMethod() -> String? {
        guard let authenticationMethod else { return nil }
        
        return switch authenticationMethod {
            case "Basic":
                NSURLAuthenticationMethodHTTPBasic
            case "NTLM":
                NSURLAuthenticationMethodNTLM
            case "Negotiate":
                NSURLAuthenticationMethodNegotiate
            default:
                nil
        }
    }
    
    func clearButtonPressed() {
        textViewText = ""
        delegate?.textViewTextChanged()
    }
    
	func connectButtonPressed() {
		if !webSocketManager.isConnected {
            let newlinesCount = textViewText.filter({ $0 == "\n" }).count
            if newlinesCount > 1 {
                appendToTextView(text: "––––––––––––––––––––––––––––––")
            }
            else if newlinesCount == 1 {
                textViewText = ""
            }
            
            guard let url = URL(string: hostInputText) else {
                appendToTextView(text: "Error: invalid URL \"\(hostInputText)\"")
                return
            }
            webSocketManager.connect(url: url)
		}
		else {
			webSocketManager.disconnect()
		}
	}
	
	func sendMessage(message: String) {
		guard webSocketManager.isConnected else { return }
		webSocketManager.sendMessage(message: message)
	}
    
    
    // MARK: Private Methods
    
    private func appendToTextView(text: String) {
        var printLine = text
        
        if !textViewText.isEmpty && !printLine.hasPrefix("\n") {
            printLine = "\n\(printLine)"
        }
        if !printLine.hasSuffix("\n") {
            printLine = "\(printLine)\n"
        }
        
        textViewText += printLine
        delegate?.textViewTextChanged()
    }
}


// MARK: - WebSocketManagerDelegate extension
extension ViewModel: WebSocketManagerDelegate {
	func webSocketEventDidHappen(message: String) {
		DispatchQueue.main.async(execute: { [weak self, message] in
            self?.appendToTextView(text: message)
		})
	}
	
}
