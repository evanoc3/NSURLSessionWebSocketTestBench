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
	@IBOutlet private var generalTabItem: NSTabViewItem!
	@IBOutlet private var legacyTabItem: NSTabViewItem!
	@IBOutlet private var newTabItem: NSTabViewItem!
	@IBOutlet private var overrideOsProxySettingsCheckbox: NSButton!
	@IBOutlet private var legacyHttpProxyEnabledCheckbox: NSButton!
	@IBOutlet private var legacyHttpProxyHostInput: NSTextField!
	@IBOutlet private var legacyHttpProxyPortInput: NSTextField!
	@IBOutlet private var legacyHttpsProxyEnabledCheckbox: NSButton!
	@IBOutlet private var legacyHttpsProxyHostInput: NSTextField!
	@IBOutlet private var legacyHttpsProxyPortInput: NSTextField!
	@IBOutlet private var legacySocksProxyEnabledCheckbox: NSButton!
	@IBOutlet private var legacySocksProxyHostInput: NSTextField!
	@IBOutlet private var legacySocksProxyPortInput: NSTextField!
	@IBOutlet private var newHttpProxyEnabledCheckbox: NSButton!
	@IBOutlet private var newHttpProxyHostInput: NSTextField!
	@IBOutlet private var newHttpProxyPortInput: NSTextField!
	@IBOutlet private var newSocksProxyEnabledCheckbox: NSButton!
	@IBOutlet private var newSocksProxyHostInput: NSTextField!
	@IBOutlet private var newSocksProxyPortInput: NSTextField!
	@IBOutlet private var websocketTextView: NSTextView!
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
		let legacyHttpProxyPort = (legacyHttpProxyPortInput.formatter as! NumberFormatter).number(from: legacyHttpProxyPortInput.stringValue)!.uint16Value
		let legacyHttpsProxyPort = (legacyHttpsProxyPortInput.formatter as! NumberFormatter).number(from: legacyHttpsProxyPortInput.stringValue)!.uint16Value
		let legacySocksProxyPort = (legacySocksProxyPortInput.formatter as! NumberFormatter).number(from: legacySocksProxyPortInput.stringValue)!.uint16Value
		let newHttpProxyPort = (newHttpProxyPortInput.formatter as! NumberFormatter).number(from: newHttpProxyPortInput.stringValue)!.uint16Value
		let newSocksProxyPort = (newSocksProxyPortInput.formatter as! NumberFormatter).number(from: newSocksProxyPortInput.stringValue)!.uint16Value
		
        viewModel.saveProxySettings(overrideOsProxySettingsEnabled: overrideOsProxySettingsCheckbox.state == .on,
                                    legacyHttpProxyEnabled: legacyHttpProxyEnabledCheckbox.state == .on,   legacyHttpProxyHost: legacyHttpProxyHostInput.stringValue,   legacyHttpProxyPort: legacyHttpProxyPort,
									legacyHttpsProxyEnabled: legacyHttpsProxyEnabledCheckbox.state == .on, legacyHttpsProxyHost: legacyHttpsProxyHostInput.stringValue, legacyHttpsProxyPort: legacyHttpsProxyPort,
									legacySocksProxyEnabled: legacySocksProxyEnabledCheckbox.state == .on, legacySocksProxyHost: legacySocksProxyHostInput.stringValue, legacySocksProxyPort: legacySocksProxyPort,
									newHttpProxyEnabled: newHttpProxyEnabledCheckbox.state == .on,         newHttpProxyHost: newHttpProxyHostInput.stringValue,         newHttpProxyPort: newHttpProxyPort,
									newSocksProxyEnabled: newSocksProxyEnabledCheckbox.state == .on,       newSocksProxyHost: newSocksProxyHostInput.stringValue,       newSocksProxyPort: newSocksProxyPort)
		setupUi()
	}
	
	@IBAction func connectButtonAction(_ sender: NSButton) {
		viewModel.connectButtonPressed()
		setupUi()
	}
	
	@IBAction func sendMessage(_ sender: Any?) {
		viewModel.sendMessage(message: messageInput.stringValue)
		messageInput.stringValue = ""
	}
	
	
	// MARK: Private Methods
	
	private func setupUi() {
		// tabView and tabViewItems
		var visibleTabViews: [NSTabViewItem] = []
		if viewModel.generalProxySettingsTabIsVisible {
			visibleTabViews.append(generalTabItem)
		}
		if viewModel.connectionProxyDictionaryTabIsVisible {
			visibleTabViews.append(legacyTabItem)
		}
		if viewModel.proxyConfigurationsTabIsVisible {
			visibleTabViews.append(newTabItem)
		}
		tabView.tabViewItems = visibleTabViews
		
		// controls in general tab
		overrideOsProxySettingsCheckbox.state = viewModel.overrideOsProxySettingsCheckboxIsChecked ? .on : .off
		
		// controls in legacy tab
		legacyHttpProxyEnabledCheckbox.state = viewModel.legacyHttpProxyEnabled ? .on : .off
		legacyHttpProxyHostInput.isEnabled = viewModel.legacyHttpProxyHostInputEnabled
		legacyHttpProxyHostInput.stringValue = viewModel.legacyHttpProxyHost
		legacyHttpProxyPortInput.isEnabled = viewModel.legacyHttpProxyPortInputEnabled
		legacyHttpProxyPortInput.stringValue = legacyHttpProxyPortInput.formatter!.string(for: viewModel.legacyHttpProxyPort) ?? ""
		
		legacyHttpsProxyEnabledCheckbox.state = viewModel.legacyHttpsProxyEnabled ? .on : .off
		legacyHttpsProxyHostInput.isEnabled = viewModel.legacyHttpsProxyHostInputEnabled
		legacyHttpsProxyHostInput.stringValue = viewModel.legacyHttpsProxyHost
		legacyHttpsProxyPortInput.isEnabled = viewModel.legacyHttpsProxyPortInputEnabled
		legacyHttpsProxyPortInput.stringValue = legacyHttpsProxyPortInput.formatter!.string(for: viewModel.legacyHttpsProxyPort) ?? ""
		legacySocksProxyEnabledCheckbox.state = viewModel.legacySocksProxyEnabled ? .on : .off
		legacySocksProxyHostInput.isEnabled = viewModel.legacySocksProxyHostInputEnabled
		legacySocksProxyHostInput.stringValue = viewModel.legacySocksProxyHost
		legacySocksProxyPortInput.isEnabled = viewModel.legacySocksProxyPortInputEnabled
		legacySocksProxyPortInput.stringValue = legacySocksProxyPortInput.formatter!.string(for: viewModel.legacySocksProxyPort) ?? ""
		
		// controls in new tab
		newHttpProxyEnabledCheckbox.state = viewModel.newHttpProxyEnabled ? .on : .off
		newHttpProxyHostInput.isEnabled = viewModel.newHttpProxyEnabled
		newHttpProxyHostInput.stringValue = viewModel.newHttpProxyHost
		newHttpProxyPortInput.isEnabled = viewModel.newHttpProxyPortInputEnabled
		newHttpProxyPortInput.stringValue = newHttpProxyPortInput.formatter!.string(for: viewModel.newHttpProxyPort) ?? ""
		newSocksProxyEnabledCheckbox.state = viewModel.newSocksProxyEnabled ? .on : .off
		newSocksProxyHostInput.isEnabled = viewModel.newSocksProxyEnabled
		newSocksProxyHostInput.stringValue = viewModel.newSocksProxyHost
		newSocksProxyPortInput.isEnabled = viewModel.newSocksProxyPortInputEnabled
		newSocksProxyPortInput.stringValue = newSocksProxyPortInput.formatter!.string(for: viewModel.newSocksProxyPort) ?? ""
		
		// save proxy settings & connect buttons
		saveProxySettingsButton.title = viewModel.saveProxySettingsButtonTitle
		connectButton.title = viewModel.connectButtonTitle
		
		// message input and send button
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




