#SingleInstance Force  ; Prevent multiple instances of the script running
#MaxThreadsPerHotkey 2  ; Improve hotkey responsiveness during typing

/*
Auto Text Typer via AutoHotkey

Purpose:
This script mimics typing of text entered into the text box below.

Developer:
Seyed Mahmood Taghavi Shahri
Senior Statistician, Ph.D.
Steno Diabetes Center Copenhagen, Denmark

License:
GNU General Public License v3.0

Copyright © 2026 S. Mahmood Taghavi S.
*/

appVersionDate := "2026-04-12"
appWebURL := "https://github.com/Mahmood-Taghavi/Auto-Text-Typer"

typingSpeedX := 3
typingDelayMs := Round(100 / typingSpeedX)  ; 1X=100, 2X=50, 3X=33, 4X=25, 5X=20

; Runtime state variables
isRunning := false
isPaused := false
isCountdown := false
resumeAfterPause := false
typingText := ""
typingCharCount := 0
typingIndex := 0
nextProgressPct := 5
remainingDelaySeconds := 0

myGui := Gui(, "Auto Text Typer via AutoHotkey")

myGui.Add("Text", "w520", "This tool types the text entered below into the active window.")
myGui.Add("Text", "w520", "1. Enter text in the box below, or use 'Paste Clipboard'.")
myGui.Add("Text", "w520", "2. Choose a typing speed and review the estimated typing time.")
myGui.Add("Text", "w520", "3. Select a start delay (e.g., ~5 seconds) to allow time to switch to the destination typing area.")
myGui.Add("Text", "w520", "4. Click ‘Start Typing’ or press the corresponding shortcut (Ctrl+Shift+Y or Ctrl+Alt+Y) to start, pause, or resume typing. To cancel typing, click ‘Stop’.")
myGui.Add("Text", "w520", "Note: Some programming editors (e.g., RStudio) may unexpectedly add closing brackets or quotes. Use a simple typing destination such as Notepad if possible.")

myGui.Add("Text", "w520", "Text to type:")
textInput := myGui.Add("Edit", "w520 r12 WantTab")
textInput.OnEvent("Change", UpdateEstimate)

pasteBtn := myGui.Add("Button", "xm w120 h30", "Paste Clipboard")
pasteBtn.OnEvent("Click", PasteClipboard)

clearBtn := myGui.Add("Button", "x+10 w80 h30", "Clear Text")
clearBtn.OnEvent("Click", ClearText)

charCountText := myGui.Add("Text", "x+15 yp+5 w180", "Text Length: 0 chars")

myGui.Add("Text", "xm w520", "Typing speed (ms per character):")
typingSpeedCombo := myGui.Add("DropDownList", "w160 Choose3", ["1X (100 ms)", "2X (50 ms)", "3X (33 ms)", "4X (25 ms)", "5X (20 ms)"])
typingSpeedCombo.OnEvent("Change", OnTypingSpeedChanged)

estimateText := myGui.Add("Text", "xm w520", "Estimated total time: 5 sec")

myGui.Add("Text", "xm w520", "Delay before typing starts:")
delaySlider := myGui.Add("Slider", "w300 Range0-10 TickInterval1 ToolTip", 5)
delayValueText := myGui.Add("Text", "x+10 yp+3 w120", "5 seconds")
delaySlider.OnEvent("Change", OnDelayChanged)

statusText := myGui.Add("Text", "xm w520", "Status: Ready")

; Start / Pause / Continue button
startBtn := myGui.Add("Button", "xm w120 h35", "Start Typing")
startBtn.OnEvent("Click", TogglePauseResume)

; Abort button
abortBtn := myGui.Add("Button", "x+10 yp w80 h35", "Stop")
abortBtn.OnEvent("Click", AbortTyping)

; About button
aboutBtn := myGui.Add("Button", "x+110 yp w80 h35", "About")
aboutBtn.OnEvent("Click", ShowAbout)

; Exit button
exitBtn := myGui.Add("Button", "x+10 yp w80 h35", "Exit")
exitBtn.OnEvent("Click", ExitAppFunc)

myGui.Show()

UpdateDelayText()
UpdateEstimate()

; Global shortcuts: Start / Pause / Continue
$*^+y::
{
    TogglePauseResume()
}

$*^!y::
{
    TogglePauseResume()
}

OnDelayChanged(*)
{
    UpdateDelayText()
    UpdateEstimate()
}

OnTypingSpeedChanged(*)
{
    global typingSpeedCombo, typingSpeedX, typingDelayMs

    speedText := typingSpeedCombo.Text
    typingSpeedX := Integer(SubStr(speedText, 1, 1))
    typingDelayMs := Round(100 / typingSpeedX)

    UpdateEstimate()
}

UpdateDelayText()
{
    global delaySlider, delayValueText
    delayValueText.Text := delaySlider.Value " second" (delaySlider.Value = 1 ? "" : "s")
}

UpdateEstimate(*)
{
    global textInput, estimateText, typingDelayMs, charCountText

    text := textInput.Value
    charCount := StrLen(text)
    typingSeconds := (charCount * typingDelayMs) / 1000

    charCountText.Text := "Text Length: " charCount " chars"
    estimateText.Text := "Estimated typing time: " FormatDuration(typingSeconds)
}

FormatDuration(typingSeconds)
{
    typingSeconds := Ceil(typingSeconds)
    minutes := Floor(typingSeconds / 60)
    seconds := Mod(typingSeconds, 60)

    if (minutes > 0)
        return minutes " min " seconds " sec"
    else
        return seconds " sec"
}

PasteClipboard(*)
{
    global textInput

    textInput.Value := A_Clipboard
    UpdateEstimate()
}

ClearText(*)
{
    global textInput, statusText, isRunning

    if (isRunning)
        return

    textInput.Value := ""
    statusText.Text := "Status: Ready"
    UpdateEstimate()
}

TogglePauseResume(*)
{
    global isRunning, isPaused

    if (!isRunning)
        StartTyping()
    else if (isPaused)
        ResumeTyping()
    else
        PauseTyping()
}

StartTyping()
{
    global textInput, statusText, delaySlider, startBtn
    global isRunning, isPaused, isCountdown, resumeAfterPause
    global typingText, typingCharCount, typingIndex, nextProgressPct, remainingDelaySeconds

    text := textInput.Value

    if (text = "")
    {
        MsgBox "The text box is empty!"
        return
    }

    typingText := text
    typingCharCount := StrLen(typingText)
    typingIndex := 0
    nextProgressPct := 5
    remainingDelaySeconds := delaySlider.Value

    isRunning := true
    isPaused := false
    isCountdown := true
    resumeAfterPause := false
    startBtn.Text := "Pause Typing"

    if (remainingDelaySeconds > 0)
    {
        statusText.Text := "Status: Typing starts in " remainingDelaySeconds " second" (remainingDelaySeconds = 1 ? "" : "s") "..."
        SetTimer CountdownStep, 1000
    }
    else
    {
        BeginTyping()
    }
}

PauseTyping()
{
    global isRunning, isPaused, isCountdown, startBtn, statusText

    if (!isRunning || isPaused)
        return

    SetTimer CountdownStep, 0
    SetTimer TypeNextChar, 0

    isPaused := true
    startBtn.Text := "Continue Typing"

    if (isCountdown)
        statusText.Text := "Status: Paused during countdown"
    else
        statusText.Text := "Status: Typing paused"
}

ResumeTyping()
{
    global isRunning, isPaused, isCountdown, startBtn, statusText
    global remainingDelaySeconds, typingCharCount, typingIndex, resumeAfterPause, delaySlider, typingDelayMs

    if (!isRunning || !isPaused)
        return

    isPaused := false
    startBtn.Text := "Pause Typing"

    remainingDelaySeconds := delaySlider.Value

    if (isCountdown)
    {
        if (remainingDelaySeconds > 0)
        {
            statusText.Text := "Status: Typing starts in " remainingDelaySeconds " second" (remainingDelaySeconds = 1 ? "" : "s") "..."
            SetTimer CountdownStep, 1000
        }
        else
        {
            BeginTyping()
        }
    }
    else
    {
        if (remainingDelaySeconds > 0)
        {
            isCountdown := true
            resumeAfterPause := true
            statusText.Text := "Status: Continuing in " remainingDelaySeconds " second" (remainingDelaySeconds = 1 ? "" : "s") "..."
            SetTimer CountdownStep, 1000
        }
        else
        {
            if (typingCharCount < 20)
                statusText.Text := "Status: Typing in progress..."
            else
                statusText.Text := "Status: Typing in progress... " Floor((typingIndex / typingCharCount) * 100) "%"

            SetTimer TypeNextChar, typingDelayMs
        }
    }
}

AbortTyping(*)
{
    global isRunning, isPaused, isCountdown, resumeAfterPause, startBtn, statusText
    global typingText, typingCharCount, typingIndex, nextProgressPct, remainingDelaySeconds

    SetTimer CountdownStep, 0
    SetTimer TypeNextChar, 0

    isRunning := false
    isPaused := false
    isCountdown := false
    resumeAfterPause := false
    typingText := ""
    typingCharCount := 0
    typingIndex := 0
    nextProgressPct := 5
    remainingDelaySeconds := 0

    startBtn.Text := "Start Typing"
    statusText.Text := "Status: Typing stopped"
}

CountdownStep()
{
    global remainingDelaySeconds, statusText, isRunning, isPaused, isCountdown, resumeAfterPause
    global typingCharCount, typingIndex, typingDelayMs

    if (!isRunning || isPaused)
    {
        SetTimer CountdownStep, 0
        return
    }

    remainingDelaySeconds -= 1

    if (remainingDelaySeconds <= 0)
    {
        SetTimer CountdownStep, 0

        if (resumeAfterPause)
        {
            resumeAfterPause := false
            isCountdown := false

            if (typingCharCount < 20)
                statusText.Text := "Status: Typing in progress..."
            else
                statusText.Text := "Status: Typing in progress... " Floor((typingIndex / typingCharCount) * 100) "%"

            SetTimer TypeNextChar, typingDelayMs
        }
        else
        {
            BeginTyping()
        }
    }
    else
    {
        if (resumeAfterPause)
            statusText.Text := "Status: Continuing in " remainingDelaySeconds " second" (remainingDelaySeconds = 1 ? "" : "s") "..."
        else
            statusText.Text := "Status: Typing starts in " remainingDelaySeconds " second" (remainingDelaySeconds = 1 ? "" : "s") "..."
    }
}

BeginTyping()
{
    global statusText, typingCharCount, typingDelayMs, isCountdown, isPaused, startBtn, resumeAfterPause

    isCountdown := false
    isPaused := false
    resumeAfterPause := false
    startBtn.Text := "Pause Typing"

    if (typingCharCount < 20)
        statusText.Text := "Status: Typing in progress..."
    else
        statusText.Text := "Status: Typing in progress... 0%"

    SetTimer TypeNextChar, typingDelayMs
}

TypeNextChar()
{
    global isRunning, isPaused, typingText, typingCharCount, typingIndex, nextProgressPct
    global statusText, startBtn

    if (!isRunning || isPaused)
    {
        SetTimer TypeNextChar, 0
        return
    }

    typingIndex += 1

    if (typingIndex > typingCharCount)
    {
        SetTimer TypeNextChar, 0
        isRunning := false
        isPaused := false
        startBtn.Text := "Start Typing"
        statusText.Text := "Status: Done"
        return
    }

    char := SubStr(typingText, typingIndex, 1)
    SendText char
    Sleep 0

    if (typingCharCount >= 20)
    {
        progressPct := Floor((typingIndex / typingCharCount) * 100)

        if (progressPct >= nextProgressPct)
        {
            statusText.Text := "Status: Typing in progress... " nextProgressPct "%"
            nextProgressPct += 5
        }
    }
}

ShowAbout(*)
{
    global appVersionDate, appWebURL

    aboutText :=
        "Auto Text Typer via AutoHotkey`n`n"
        . "Version date: " appVersionDate "`n`n"
        . "Developed by S. Mahmood Taghavi S.`n"
        . "Senior Statistician, PhD`n"
        . "Steno Diabetes Center Copenhagen`n`n"
        . "Website:`n"
        . appWebURL "`n`n"
        . "Would you like to visit the website now?"

    result := MsgBox(aboutText, "About", "YesNo Iconi")

    if (result = "Yes")
        Run appWebURL
}

ExitAppFunc(*)
{
    ExitApp
}