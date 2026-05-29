print("✅ COOLGUI TEST SCRIPT LOADED SUCCESSFULLY")

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "CoolGUI",
    Text = "Test script works! You are NOT cool",
    Duration = 10
})

warn("If you see this in console, the script is running")
