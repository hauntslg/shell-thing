package main

import (
	"fmt"

	"github.com/gdamore/tcell/v2"
	"github.com/mattn/go-runewidth"
)

// Draw the menu and search prompt
func draw(screen tcell.Screen, entries []NavEntry, filteredEntries []NavEntry, selected int, searchMode bool, searchQuery string) {
	screen.Clear()
	width, height := screen.Size()

	if len(filteredEntries) == 0 {
		selected = 0
		msg := "No matches found"
		startX := (width - len(msg)) / 2
		startY := height / 2
		for i, r := range msg {
			screen.SetContent(startX+i, startY, r, nil, tcell.StyleDefault.Foreground(tcell.ColorRed))
		}
		screen.Show()
		return
	} else if selected >= len(filteredEntries) {
		selected = len(filteredEntries) - 1
	}

	menuHeight := len(filteredEntries)
	startY := (height - menuHeight) / 2

	// Draw search prompt
	if searchMode {
		prompt := fmt.Sprintf("/%s", searchQuery)
		for i, r := range prompt {
			screen.SetContent(i, 0, r, nil, tcell.StyleDefault.Foreground(tcell.ColorGreen))
		}
	}

	// Draw entries
	for i, entry := range filteredEntries {
		style := tcell.StyleDefault
		str := fmt.Sprintf(" %s", entry.Name)

		if i == selected {
			style = tcell.StyleDefault.Foreground(tcell.ColorYellow)
			str = fmt.Sprintf(">>  %s  <<", entry.Name)
		}

		strWidth := runewidth.StringWidth(str)
		startX := (width - strWidth) / 2
		x := startX
		for _, r := range str {
			w := runewidth.RuneWidth(r)
			screen.SetContent(x, startY+i, r, nil, style)
			x += w
		}
	}
	screen.Show()
}
