# Auto Text Typer via AutoHotkey

**Auto Text Typer via AutoHotkey** is a lightweight Windows utility that simulates
human typing by sending text as keystrokes to any active window. It is
particularly useful in restricted environments---such as **DST
(Statistics Denmark) research servers**---where copy-paste or file
transfer is limited and text must be entered manually.

------------------------------------------------------------------------

## 🔍 Overview

In secure environments like DST, users typically access projects via
remote desktop (RDP). While this setup ensures compliance with strict
data protection rules, it also restricts standard input/output
operations such as clipboard sharing or file transfer.

As a result, transferring locally prepared text into a DST project can
be slow and cumbersome if done manually.

**Auto Text Typer via AutoHotkey** addresses this by: - Taking locally available text
(typed or pasted) - Simulating keystrokes - Entering the text into the
active window automatically.

------------------------------------------------------------------------

## ✨ Features

- Simulates typing in any active window  
- Estimates total typing time  
- Adjustable typing speed (1X–5X)  
- Configurable start delay  
- Pause and resume typing anytime  
- Displays typing progress (%)  
- Global shortcuts for quick control

------------------------------------------------------------------------

## 🧩 Use Case: DST Research Servers

On **DST (Denmark Statistics) research servers**:
- Clipboard/file transfer are limited as a rule
- Text input is often limited to manual typing

This tool allows researchers to: - Prepare text locally (e.g., code,
notes, documentation) - Transfer it into DST environments efficiently
via simulated typing - Reduce repetitive manual work while staying
compliant with DST policies

> Important: This tool is intended for non-sensitive text only.
> All data must still be handled and submitted according to DST
> regulations.

------------------------------------------------------------------------

## ⚙️ Installation

1.  Install [AutoHotkey v2](https://www.autohotkey.com/), a free and open-source custom scripting language
2.  Download 'Auto Text Typer via AutoHotkey.ahk' from this repository
3.  Double-click the downloaded 'Auto Text Typer via AutoHotkey.ahk' to run

------------------------------------------------------------------------

## 🚀 How to Use

1.  Enter or paste text into the input box
2.  Select typing speed
3.  Set a delay to switch to the destination typing area
4.  Click Start Typing or use a shortcut
5.  The tool will simulate typing into the active window

### Keyboard Shortcuts

-   Ctrl + Shift + Y → Start / Pause / Resume
-   Ctrl + Alt + Y → Start / Pause / Resume

------------------------------------------------------------------------

## 🖥️ Interface Highlights

-   Text Length: Displays number of characters in real time
-   Estimated Typing Time: Based on selected speed
-   Status Indicator: Shows current state

------------------------------------------------------------------------

## ⚠️ Notes & Limitations

- Avoid editors that auto-insert characters (e.g., brackets or quotes)  
- Use simple text editors when possible  
- Long texts may take time to complete  
- Performance depends on system responsiveness 

------------------------------------------------------------------------

## 👤 Author

Seyed Mahmood Taghavi Shahri, PhD
Senior Statistician, PhD
Steno Diabetes Center Copenhagen

GitHub: https://github.com/Mahmood-Taghavi/
LinkedIn: https://www.linkedin.com/in/mahmood-taghavi/

------------------------------------------------------------------------

## 📄 License

GNU General Public License v3.0 (GPL-3.0)
