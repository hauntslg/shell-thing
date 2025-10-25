package main

import (
	"log"

	"github.com/gdamore/tcell/v2"
)

func main() {
	entries := loadEntries()
	filteredEntries := entries
	selected := 0
	searchMode := false
	searchQuery := ""

	screen, err := tcell.NewScreen()
	if err != nil {
		log.Fatal(err)
	}
	if err := screen.Init(); err != nil {
		log.Fatal(err)
	}
	defer screen.Fini()

	draw(screen, entries, filteredEntries, selected, searchMode, searchQuery)

	for {
		ev := screen.PollEvent()
		keyEvent, ok := ev.(*tcell.EventKey)
		if !ok {
			continue
		}

		exit := handleInput(keyEvent, screen, entries, &filteredEntries, &selected, &searchMode, &searchQuery)

		if exit {
			break
		}

		draw(screen, entries, filteredEntries, selected, searchMode, searchQuery)
	}
}
