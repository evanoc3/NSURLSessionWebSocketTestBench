//
//  ViewController.swift
//  NSURLSessionWebSocketTestBench
//
//  Created by Evan O'Connor on 22/01/2024.
//

import Cocoa


// MARK: - ViewController class
class ViewController: NSViewController {
	
	// MARK: Outlets
	
	@IBOutlet private var tabView: NSTabView!
	@IBOutlet private var proxyTabItem: NSTabViewItem!
	@IBOutlet private var overrideOsProxySettingsCheckbox: NSButton!
    @IBOutlet private var targetInput: NSTextField!
	@IBOutlet private var legacyHttpProxyHostInput: NSTextField!
	@IBOutlet private var legacyHttpProxyPortInput: NSTextField!
	@IBOutlet private var legacyHttpsProxyHostInput: NSTextField!
	@IBOutlet private var legacyHttpsProxyPortInput: NSTextField!
	@IBOutlet private var legacySocksProxyHostInput: NSTextField!
	@IBOutlet private var legacySocksProxyPortInput: NSTextField!
	@IBOutlet private var newHttpProxyHostInput: NSTextField!
	@IBOutlet private var newHttpProxyPortInput: NSTextField!
	@IBOutlet private var newSocksProxyHostInput: NSTextField!
	@IBOutlet private var newSocksProxyPortInput: NSTextField!
    @IBOutlet private var authenticationMethodPopupButton: NSPopUpButton!
    @IBOutlet private var credentialsUsernameInput: NSTextField!
    @IBOutlet private var credentialsPasswordInput: NSTextField!
	@IBOutlet private var websocketTextView: NSTextView!
    @IBOutlet private var clearTextButton: NSButton!
	@IBOutlet private var saveProxySettingsButton: NSButton!
	@IBOutlet private var connectButton: NSButton!
	@IBOutlet private var messageInput: NSTextField!
	@IBOutlet private var sendMessageButton: NSButton!
	
	
	// MARK: Proprties
	
	private var viewModel: ViewModel
	
	
	// MARK: NSViewController
	
	required init?(coder: NSCoder) {
		viewModel = ViewModel()
		super.init(coder: coder)
		viewModel.delegate = self
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		setupUi()
	}
	
	
	// MARK: Actions
	
	@IBAction func saveProxySettingsButtonAction(_ sender: NSButton) {
        let legacyHttpProxyPort = legacyHttpProxyPortInput.stringValue.isEmpty ? nil : (legacyHttpProxyPortInput.formatter as! NumberFormatter).number(from: legacyHttpProxyPortInput.stringValue)?.uint16Value
        let legacyHttpsProxyPort = legacyHttpsProxyPortInput.stringValue.isEmpty ? nil : (legacyHttpsProxyPortInput.formatter as! NumberFormatter).number(from: legacyHttpsProxyPortInput.stringValue)?.uint16Value
        let legacySocksProxyPort = legacySocksProxyPortInput.stringValue.isEmpty ? nil : (legacySocksProxyPortInput.formatter as! NumberFormatter).number(from: legacySocksProxyPortInput.stringValue)?.uint16Value
        let newHttpProxyPort = newHttpProxyPortInput.stringValue.isEmpty ? nil : (newHttpProxyPortInput.formatter as! NumberFormatter).number(from: newHttpProxyPortInput.stringValue)?.uint16Value
        let newSocksProxyPort = newSocksProxyPortInput.stringValue.isEmpty ? nil : (newSocksProxyPortInput.formatter as! NumberFormatter).number(from: newSocksProxyPortInput.stringValue)?.uint16Value
        let authenticationMethod = authenticationMethodPopupButton.titleOfSelectedItem == "None" ? nil : authenticationMethodPopupButton.titleOfSelectedItem
		
        viewModel.saveProxySettings(overrideOsProxySettingsEnabled: overrideOsProxySettingsCheckbox.state == .on, host: targetInput.stringValue,
                                    legacyHttpProxyHost: legacyHttpProxyHostInput.stringValue,   legacyHttpProxyPort: legacyHttpProxyPort,
									legacyHttpsProxyHost: legacyHttpsProxyHostInput.stringValue, legacyHttpsProxyPort: legacyHttpsProxyPort,
									legacySocksProxyHost: legacySocksProxyHostInput.stringValue, legacySocksProxyPort: legacySocksProxyPort,
									newHttpProxyHost: newHttpProxyHostInput.stringValue,         newHttpProxyPort: newHttpProxyPort,
									newSocksProxyHost: newSocksProxyHostInput.stringValue,       newSocksProxyPort: newSocksProxyPort,
                                    authenticationMethod: "None",                  credentialsUsername: "", credentialsPassword: "")
		setupUi()
	}
	
	@IBAction func connectButtonAction(_ sender: NSButton) {
		viewModel.connectButtonPressed()
		setupUi()
	}
	
    @IBAction func clearButtonAction(_ sender: NSButton) {
        viewModel.clearButtonPressed()
    }
    
	@IBAction func sendMessage(_ sender: Any?) {
		viewModel.sendMessage(message: messageInput.stringValue)
		messageInput.stringValue = ""
	}
	
	
	// MARK: Private Methods
	
	private func setupUi() {
		// controls in general tab
		overrideOsProxySettingsCheckbox.state = viewModel.overrideOsProxySettingsCheckboxIsChecked ? .on : .off
        targetInput.stringValue = viewModel.hostInputText
		
		// controls in proxy tab
		legacyHttpProxyHostInput.stringValue = viewModel.legacyHttpProxyHost
		legacyHttpProxyPortInput.stringValue = legacyHttpProxyPortInput.formatter!.string(for: viewModel.legacyHttpProxyPort) ?? ""
		
		legacyHttpsProxyHostInput.stringValue = viewModel.legacyHttpsProxyHost
		legacyHttpsProxyPortInput.stringValue = legacyHttpsProxyPortInput.formatter!.string(for: viewModel.legacyHttpsProxyPort) ?? ""
		legacySocksProxyHostInput.stringValue = viewModel.legacySocksProxyHost
		legacySocksProxyPortInput.stringValue = legacySocksProxyPortInput.formatter!.string(for: viewModel.legacySocksProxyPort) ?? ""
		
		newHttpProxyHostInput.stringValue = viewModel.newHttpProxyHost
		newHttpProxyPortInput.stringValue = newHttpProxyPortInput.formatter!.string(for: viewModel.newHttpProxyPort) ?? ""
		newSocksProxyHostInput.stringValue = viewModel.newSocksProxyHost
		newSocksProxyPortInput.stringValue = newSocksProxyPortInput.formatter!.string(for: viewModel.newSocksProxyPort) ?? ""
		
		// message input and send button
        clearTextButton.isHidden = !viewModel.clearButtonIsVisible
        connectButton.title = viewModel.connectButtonText
		messageInput.isEnabled = viewModel.messageInputIsEnabled
		sendMessageButton.isEnabled = viewModel.sendMessageButtonIsEnabled && !messageInput.stringValue.isEmpty
	}

}


// MARK: - ViewModelDelegate extension
extension ViewController: ViewModelDelegate {
	
	func proxySettingsUpdated() {
		setupUi()
	}
	
	func textViewTextChanged() {
        clearTextButton.isHidden = !viewModel.clearButtonIsVisible
        
		websocketTextView.string = viewModel.textViewText
	}
	
}


// MARK: - NSTextFieldDelegate extension
extension ViewController: NSTextFieldDelegate {
	
	func controlTextDidChange(_ obj: Notification) {
		if let textField = obj.object as? NSTextField, textField == messageInput {
			setupUi()
		}
	}
	
}




