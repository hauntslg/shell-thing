package main

import (
	"encoding/json"
	"os"
	"os/user"
	"path/filepath"
	"sort"
	"strings"
)

// NavEntry represents a menu item
type NavEntry struct {
	Name string `json:"name"`
	Path string `json:"path"`
}

// Expand ~ to the user home directory
func expandPath(path string) string {
	usr, err := user.Current()
	if err != nil {
		panic(err)
	}
	return strings.Replace(path, "~", usr.HomeDir, 1)
}

// Load entries from JSON file
func loadEntries() []NavEntry {
	dir, err := os.Executable()
	if err != nil {
		panic(err)
	}
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

	// Sort alphabetically
	sort.Slice(entries, func(i, j int) bool {
		return entries[i].Name < entries[j].Name
	})
	return entries
}

// Filter entries based on query
func filterEntries(entries []NavEntry, query string) []NavEntry {
	var result []NavEntry
	for _, entry := range entries {
		if strings.Contains(strings.ToLower(entry.Name), strings.ToLower(query)) {
			result = append(result, entry)
		}
	}
	return result
}
