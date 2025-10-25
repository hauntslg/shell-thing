package main

import "github.com/gdamore/tcell/v2"

// Handle key input for search and navigation
func handleInput(ev *tcell.EventKey, screen tcell.Screen, entries []NavEntry, filteredEntries *[]NavEntry, selected *int, searchMode *bool, searchQuery *string) bool {
	switch ev.Key() {
	case tcell.KeyEscape:
		if *searchMode {
			*searchMode = false
			*searchQuery = ""
			*filteredEntries = entries
			*selected = 0
			return false
		}
		return true // exit program

	case tcell.KeyEnter:
		if len(*filteredEntries) > 0 {
			println(expandPath((*filteredEntries)[*selected].Path))
		}
		return true // exit program

	case tcell.KeyBackspace, tcell.KeyBackspace2:
		if *searchMode && len(*searchQuery) > 0 {
			*searchQuery = (*searchQuery)[:len(*searchQuery)-1]
			*filteredEntries = filterEntries(entries, *searchQuery)
			*selected = 0
		}

	case tcell.KeyRune:
		r := ev.Rune()
		if *searchMode {
			*searchQuery += string(r)
			*filteredEntries = filterEntries(entries, *searchQuery)
			*selected = 0
		} else {
			switch r {
			case 'q':
				return true
			case '/':
				*searchMode = true
				*searchQuery = ""
			case 'j':
				if *selected < len(*filteredEntries)-1 {
					*selected++
				}
			case 'k':
				if *selected > 0 {
					*selected--
				}
			case 'g':
				*selected = 0
			case 'G':
				*selected = len(*filteredEntries) - 1
			}
		}
	}
	return false
}
