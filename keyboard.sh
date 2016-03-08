#!/bin/bash

## Configure keyboard.


source 'homebrew.sh'


# Use function keys as standard function keys. (Require Fn modifier key to enable special media functions.)
# Use all F1, F2, etc. keys as standard function keys
# NOTE: This requires a reboot to take effect. See http://apple.stackexchange.com/questions/59178 for details.
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

# Make Caps Lock key do nothing. (We'll have Seil fix it later.)
# See http://apple.stackexchange.com/a/88096 for more details.
# TODO: Determine these programatically, and for each keyboard we find, loop through the vendor and product ID.
KEYBOARD_VENDOR=$(ioreg -n IOHIDKeyboard -r | grep '"VendorID"' | awk '{print $4}') # 1452 (0x05AC)
KEYBOARD_PRODUCT=$(ioreg -n IOHIDKeyboard -r | grep '"ProductID"' | awk '{print $4}') # 610 (0x0262)
KEYBOARD_ID=0  # TODO: Not sure if this is VendorIDSource, or if we have to keep track manually.
defaults -currentHost write -g "com.apple.keyboard.modifiermapping.$KEYBOARD_VENDOR-$KEYBOARD_PRODUCT-$KEYBOARD_ID" -array-add '<dict><key>HIDKeyboardModifierMappingDst</key><integer>-1</integer><key>HIDKeyboardModifierMappingSrc</key><integer>0</integer></dict>'


# Automatically illuminate built-in MacBook keyboard in low light.
defaults write com.apple.BezelServices kDim -bool true

# Turn off keyboard illumination when computer is not used for 5 minutes.
defaults write com.apple.BezelServices kDimTime -int 300


# Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs).
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3


# Disable automatic fancy quotes, but enable automatic en-dash and em-dash substitution.
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -boolean false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -boolean true


# Remap the Caps Lock key to the "Application" key.
# NOTE: Requires configuring the Caps Lock key to "No Action" in System Preferences.
brew cask install seil # Requires password.
cat > /usr/local/bin/seil <<'EOF' # Can’t soft-link the binary. See https://github.com/tekezo/Karabiner/issues/194
#!/bin/sh
/Applications/Seil.app/Contents/Library/bin/seil $@
EOF
chmod +x /usr/local/bin/seil
seil set enable_capslock 1
seil set keycode_capslock 110 # Application Key, per https://pqrs.org/osx/karabiner/faq.html.en#capslock
seil relaunch

# TODO: Seil doesn't seem to work until I run the GUI.
# TODO: Do I need to enable the


brew cask install karabiner # Requires password.
cat > /usr/local/bin/karabiner <<'EOF' # Can’t soft-link the binary. See https://github.com/tekezo/Karabiner/issues/194
#!/bin/sh
/Applications/Karabiner.app/Contents/Library/bin/karabiner $@
EOF
chmod +x /usr/local/bin/karabiner
defaults write -app Karabiner isStatusWindowEnabled 0
defaults write -app Karabiner isStatusbarEnable 0
karabiner reloadxml
IS_LAPTOP=$(/usr/sbin/system_profiler SPHardwareDataType | grep "Model Identifier" | grep "Book")
if $IS_LAPTOP; then
    karabiner enable remap.fnletter_to_ctrlletter
fi
karabiner enable remap.pc_application2controlL # Or remap.jis_pc_application2controlL_capslock, if you want CapsLock by itself to work as CapsLock.


# TODO: Enable Fn-to-Insert mappings if not on laptop (or if we can identify Apple keyboard with numeric keypad. Better yet, only enable them in the XML file for that keyboard device.

# TODO: For desktop keyboard, would like to use PC Style Copy/Paste #3, but that would require changing Fn key to Insert key. (And I don’t think I’ve been able to figure out how to do that.)


# Make sure we've got our Karabiner customizations available.
ln -sf ~/config_files/karabiner.xml "~/Library/Application Support/Karabiner/private.xml"

# TODO: Can we get OPTION_R or OPTION_L by itself to do ^F2 (move focus to menu bar in Keyboard/Shortcuts/Keyboard)? NOTE: I usually remap that to Command+/.

# TODO: F2 in Finder to rename, but not if in a text field.
# TODO: Enter in Finder to open, but not if in a text field.


# TODO: Check “Use all F1, F2, etc. keys as standard function keys.
# TODO: Adjust keyboard brightness in low light; turn off when computer not used for: 5 min
# TODO: --- to — (em dash).

# TODO: See these web pages:
#			http://apple.stackexchange.com/questions/13598/updating-modifier-key-mappings-through-defaults-command-tool#comment103161_88096
#			http://superuser.com/questions/590526/switch-function-keys-on-os-x-via-via-command-line



## Key bindings (shortcuts) for apps.

# NOTE: Use \u200b (zero-width space) to disable a shortcut for a menu item.
# NOTE: We can replace `-g` with the app name (in reverse DNS form) for app-specific bindings.
# NOTE: For a menu item in the preferences like A->B-C, use "\033A\033B\033C".

# Allow Ctrl+PageDown and Ctrl+PageUp to cycle between tabs, same as Ctrl+Tab and Ctrl+Shift+Tab.
# FIXME: We'll probably have to use Karabiner to allow 2 sets of bindings for the same function.
defaults write -g NSUserKeyEquivalents -dict-add "Next Tab" -string "^\UF72D"
defaults write -g NSUserKeyEquivalents -dict-add "Previous Tab" -string "^\UF72C"
defaults write -g NSUserKeyEquivalents -dict-add "Select Next Tab" -string "^\UF72D"
defaults write -g NSUserKeyEquivalents -dict-add "Select Previous Tab" -string "^\UF72C"
defaults write -g NSUserKeyEquivalents -dict-add "Show Next Tab" -string "^\UF72D"
defaults write -g NSUserKeyEquivalents -dict-add "Show Previous Tab" -string "^\UF72C"

# TODO: Might have to try \U21E5 instead of \U0011. Might also need to limit this to Terminal.
defaults write -g NSUserKeyEquivalents -dict-add "Show Next Tab" -string "^\U0011"
defaults write -g NSUserKeyEquivalents -dict-add "Show Previous Tab" -string "^\$\U0011"




# TODO: Allow Ctrl+Enter and/or Command+Enter to send emails (Command+Shift+D in Mac Mail).

# TODO: Manually added these (since above didn't work) in Preferences / Keyboard:
#           Ctrl+Tab        Show Next Tab
#           Ctrl+Shift+Tab  Show Previous Tab

# TODO: Manually disabled Ctrl+Up and Ctrl+Down in Preferences / Keyboard / Shortcuts / Mission Control:
#           UNCHECK Mission Control
#           UNCHECK Application windows
# Also disable Ctrl+Left and Ctrl+Right, so we can use them to move by words.
#           UNCHECK Mission Control / Move left a space
#           UNCHECK Mission Control / Move right a space
# This will allow us to use Ctrl+Shift+Up and Ctrl+Shift+Down for Sublime Text multi-line selection.
# NOTE: Ideally, these should all be Command-prefixed, as they're global.
