# A list of devices you want to take the screenshots from
devices([
  "iPhone SE (3rd generation)",
  "iPhone 8 Plus",
  "iPhone 13 Pro",
  "iPhone 13 Pro Max",
])

# A list of languages which should be used. See https://docs.fastlane.tools/actions/snapshot/#available-language-codes
languages(["ru"])

# By default, the latest version should be used automatically. If you want to change it, do it here. 
# ios_version("15")

# Enabling this option will configure the Simulator to be in dark mode (false for light, true for dark)
dark_mode(true)

# Enabling this option will configure the Simulator's system language
localize_simulator(true)

# Should snapshot stop immediately after the tests completely failed on one device?
stop_after_first_error(true)

# Prevents packages from automatically being resolved to versions other than those recorded in the Package.resolved file
disable_package_automatic_updates(true)

# The name of the scheme which contains the UI Tests
scheme("WorkoutAppUITests")

# Where should the resulting screenshots be stored?
output_directory("./screenshots")

# remove the '#' to clear all previously generated screenshots before creating new ones
clear_previous_screenshots(true)

# Enabling this option will automatically override the status bar to show 9:41 AM, full battery, and full reception
override_status_bar(true)

# Arguments to pass to the app on launch. See https://docs.fastlane.tools/actions/snapshot/#launch-arguments
launch_arguments(["UITest"])

# For more information about all available options run
# fastlane action snapshot
