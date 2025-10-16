package main

import (
	"encoding/json"
	"fmt"
	"os"
	"os/user"
	"path/filepath"
	"sort"
	"strings"

	"github.com/gdamore/tcell/v2"
	"github.com/mattn/go-runewidth"
)

type NavEntry struct {
	Name string `json:"name"`
	Path string `json:"path"`
}

func expandPath(path string) string {
	usr, _ := user.Current()
	return strings.Replace(path, "~", usr.HomeDir, 1)
}

func loadEntries() []NavEntry {
	dir, _ := os.Executable()
	configPath := filepath.Join(filepath.Dir(dir), "navvi.json")
	file, err := os.Open(configPath)
	
	if err != nil {
		panic(err)
	}
	defer file.Close()

	var entries []NavEntry
	if err := json.NewDecoder(file).Decode(&entries); err != nil {
		panic(err)
	}
	sort.Slice(entries, func(i, j int) bool {
		return entries[i].Name < entries[j].Name
	})
	return entries
}



func main() {
	// Get json and read data
	entries := loadEntries()
	screen, _ := tcell.NewScreen()
	screen.Init()
	defer screen.Fini()

	// Draw menu
	selected := 0
	draw := func() {
		screen.Clear()
		width, height := screen.Size()

		menuHeight := len(entries)
		startY := (height - menuHeight) / 2

		for i, entry := range entries {
			style:= tcell.StyleDefault
			str := fmt.Sprintf(" %s", entry.Name)

			if i == selected {
				style = tcell.StyleDefault.Foreground(tcell.ColorYellow)
				str = fmt.Sprintf(">>  %s  <<", entry.Name)
			}

			// Calculate horizontal center
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
	draw()

	// Update screen on input
	for {
		ev := screen.PollEvent()
		switch ev := ev.(type) {
		case *tcell.EventKey:
			switch ev.Key() {

			// Exit navvi
			case tcell.KeyEscape:
				screen.Clear()
				screen.Fini()
				return

			// Write selected option
			case tcell.KeyEnter:
				fmt.Println(expandPath(entries[selected].Path))
				screen.Clear()
				screen.Fini()
				return

			// Navigate options
			case tcell.KeyRune:
				switch ev.Rune() {
				case 'j':
					if selected < len(entries)-1 {
						selected++
					}
				case 'k':
					if selected > 0 {
						selected--
					}
				case 'g':
					selected = 0
				case 'G':
					selected = len(entries) - 1
				}
			}
			draw()
		}
	}
}
