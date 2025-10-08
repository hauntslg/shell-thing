package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"os/user"
	"path/filepath"
	"sort"
	"strings"
)

type NavEntry struct {
	Name string `json:"name"`
	Path string `json:"path"`
}

func expandPath(path string) string {
	usr, _ := user.Current()
	return strings.Replace(path, "~", usr.HomeDir, 1)
}

func getExeDir() (string, error) {
	exe, err := os.Executable()
	if err != nil {
		return "", err
	}
	return filepath.Dir(exe), nil
}

func main() {
	dir, _ := getExeDir()
	configPath := filepath.Join(dir, "navvi.json")

	file, err := os.Open(configPath)
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error opening .json: ", err)
		return
	}
	defer file.Close()

	var entries []NavEntry
	if err := json.NewDecoder(file).Decode(&entries); err != nil {
		fmt.Fprintln(os.Stderr, "Error decoding .json: ", err)
		return
	}

	if len(entries) == 0 {
		fmt.Fprintln(os.Stderr, "No entries found")
		return
	}

	// sort by Name
	sort.Slice(entries, func(i, j int) bool {
		return entries[i].Name < entries[j].Name
	})

	// print menu to stderr so stdout is clean
	fmt.Fprintln(os.Stderr, "Select a location:")
	for i, e := range entries {
		fmt.Fprintf(os.Stderr, "[%d] %s\n", i+1, e.Name)
	}

	fmt.Fprint(os.Stderr, "> ")
	reader := bufio.NewReader(os.Stdin)
	input, _ := reader.ReadString('\n')
	choice := strings.TrimSpace(input)

	idx := 0
	fmt.Sscanf(choice, "%d", &idx)
	if idx < 1 || idx > len(entries) {
		fmt.Fprintln(os.Stderr, "Invalid")
		return
	}

	selected := expandPath(entries[idx-1].Path)

	// **stdout only has the selected path**
	fmt.Println(selected)
}
