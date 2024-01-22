//
//  ViewModel.swift
//  NSURLSessionWebSocketTestBench
//
//  Created by Evan O'Connor on 22/01/2024.
//

import Foundation
import Network


// MARK: - ViewModelDelegate protocol
protocol ViewModelDelegate: AnyObject {
	func proxySettingsUpdated()
	func textViewTextChanged()
}


// MARK: - ViewModel class
class ViewModel {
	
	// MARK: Properties
	
	var generalProxySettingsTabIsVisible: Bool {
		true
	}
	var connectionProxyDictionaryTabIsVisible: Bool {
		true
	}
	var proxyConfigurationsTabIsVisible: Bool {
		if #available(macOS 14.0, *) {
			return true
		}
		else {
			return false
		}
	}
	private(set) var overrideOsProxySettingsCheckboxIsChecked: Bool = true
	private(set) var legacyHttpProxyEnabled: Bool = true
	var legacyHttpProxyHostInputEnabled: Bool {
		return legacyHttpProxyEnabled
	}
	private(set) var legacyHttpProxyHost: String = "127.0.0.1"
	var legacyHttpProxyPortInputEnabled: Bool {
		return legacyHttpProxyEnabled
	}
	private(set) var legacyHttpProxyPort: UInt16 = 9090
	private(set) var legacyHttpsProxyEnabled: Bool = true
	var legacyHttpsProxyHostInputEnabled: Bool {
		return legacyHttpsProxyEnabled
	}
	private(set) var legacyHttpsProxyHost: String = "127.0.0.1"
	var legacyHttpsProxyPortInputEnabled: Bool {
		return legacyHttpsProxyEnabled
	}
	private(set) var legacyHttpsProxyPort: UInt16 = 9090
	private(set) var legacySocksProxyEnabled: Bool = true
	var legacySocksProxyHostInputEnabled: Bool {
		return legacySocksProxyEnabled
	}
	private(set) var legacySocksProxyHost: String = "127.0.0.1"
	var legacySocksProxyPortInputEnabled: Bool {
		return legacySocksProxyEnabled
	}
	private(set) var legacySocksProxyPort: UInt16 = 8889
	private(set) var newHttpProxyEnabled: Bool = true
	var newHttpProxyHostInputEnabled: Bool {
		return newHttpProxyEnabled
	}
	private(set) var newHttpProxyHost: String = "127.0.0.1"
	var newHttpProxyPortInputEnabled: Bool {
		return newHttpProxyEnabled
	}
	private(set) var newHttpProxyPort: UInt16 = 9090
	private(set) var newSocksProxyEnabled: Bool = true
	var newSocksProxyHostInputEnabled: Bool {
		return legacySocksProxyEnabled
	}
	private(set) var newSocksProxyHost: String = "127.0.0.1"
	var newSocksProxyPortInputEnabled: Bool {
		return legacySocksProxyEnabled
	}
	private(set) var newSocksProxyPort: UInt16 = 8889
	var saveProxySettingsButtonTitle: String {
		"Save Proxy Settings"
	}
	var connectButtonTitle: String {
		webSocketManager.isConnected ? "Disconnect" : "Connect"
	}
	private(set) var textViewText: String = "WebSocket traffic will appear here..."
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
	
	func saveProxySettings(legacyHttpProxyEnabled: Bool, legacyHttpProxyHost: String, legacyHttpProxyPort: UInt16,
						   legacyHttpsProxyEnabled: Bool, legacyHttpsProxyHost: String, legacyHttpsProxyPort: UInt16,
						   legacySocksProxyEnabled: Bool, legacySocksProxyHost: String, legacySocksProxyPort: UInt16,
						   newHttpProxyEnabled: Bool, newHttpProxyHost: String, newHttpProxyPort: UInt16,
						   newSocksProxyEnabled: Bool, newSocksProxyHost: String, newSocksProxyPort: UInt16) {
		self.legacyHttpProxyEnabled = legacyHttpProxyEnabled
		self.legacyHttpProxyHost = legacyHttpProxyHost
		self.legacyHttpProxyPort = legacyHttpProxyPort
		
		self.legacyHttpsProxyEnabled = legacyHttpsProxyEnabled
		self.legacyHttpsProxyHost = legacyHttpsProxyHost
		self.legacyHttpsProxyPort = legacyHttpsProxyPort
		
		self.legacySocksProxyEnabled = legacySocksProxyEnabled
		self.legacySocksProxyHost = legacySocksProxyHost
		self.legacySocksProxyPort = legacySocksProxyPort
		
		self.newHttpProxyEnabled = newHttpProxyEnabled
		self.newHttpProxyHost = newHttpProxyHost
		self.newHttpProxyPort = newHttpProxyPort
		
		self.newSocksProxyEnabled = newSocksProxyEnabled
		self.newSocksProxyHost = newSocksProxyHost
		self.newSocksProxyPort = newSocksProxyPort
		
		webSocketManager.proxyConfigurations = buildProxyConfigurations()
		webSocketManager.connectionProxyDictionary = buildConnectionProxyDictionary()
	}
	
	func buildConnectionProxyDictionary() -> [AnyHashable: Any]? {
		if !legacySocksProxyEnabled && !legacyHttpProxyEnabled && !legacyHttpsProxyEnabled {
			return nil
		}
		
		return [
			// kCFProxyTypeKey: "",
			
			kCFNetworkProxiesSOCKSEnable: legacySocksProxyEnabled ? 1 : 0,
			kCFNetworkProxiesSOCKSProxy: legacySocksProxyHost,
			kCFNetworkProxiesSOCKSPort: legacySocksProxyPort,
			
			kCFNetworkProxiesHTTPEnable: legacyHttpProxyEnabled ? 1 : 0,
			kCFNetworkProxiesHTTPProxy: legacyHttpProxyHost,
			kCFNetworkProxiesHTTPPort: legacyHttpProxyPort,
			
			kCFNetworkProxiesHTTPSEnable: legacyHttpsProxyEnabled ? 1 : 0,
			kCFNetworkProxiesHTTPSProxy: legacyHttpsProxyHost,
			kCFNetworkProxiesHTTPSPort: legacyHttpsProxyPort,
		]
	}
	
	func buildProxyConfigurations() -> [ProxyConfiguration]? {
		if !newSocksProxyEnabled && !newHttpProxyEnabled {
			return nil
		}
		
		var proxyConfigurations: [ProxyConfiguration] = []
		
		if newSocksProxyEnabled {
			proxyConfigurations.append(
				ProxyConfiguration(socksv5Proxy: NWEndpoint.hostPort(host: NWEndpoint.Host.ipv4(IPv4Address(newSocksProxyHost)!), port: NWEndpoint.Port(rawValue: newSocksProxyPort)!))
			)
		}
		
		if newHttpProxyEnabled {
			proxyConfigurations.append(
				ProxyConfiguration(httpCONNECTProxy: NWEndpoint.hostPort(host: NWEndpoint.Host.ipv4(IPv4Address(newHttpProxyHost)!), port: NWEndpoint.Port(rawValue: newHttpProxyPort)!))
			)
		}
		
		return proxyConfigurations
	}
	
	func connectButtonPressed() {
		if !webSocketManager.isConnected {
			webSocketManager.connect()
		}
		else {
			webSocketManager.disconnect()
		}
	}
	
	func sendMessage(message: String) {
		guard webSocketManager.isConnected else { return }
		webSocketManager.sendMessage(message: message)
	}
}


// MARK: - WebSocketManagerDelegate extension
extension ViewModel: WebSocketManagerDelegate {
	
	func webSocketEventDidHappen(message: String) {
		DispatchQueue.main.async(execute: { [weak self, message] in
			guard let self else { return }
			self.textViewText += "\n\(message)\n"
			self.delegate?.textViewTextChanged()
		})
	}
	
}
