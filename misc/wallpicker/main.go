// Usage
// Initial run: wallpicker --generate <path-to-dir>
// Subsequent runs: wallpicker

package main

import (
	"encoding/gob"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const (
	thumbWidth  = 40 // character columns per thumbnail
	thumbHeight = 20 // character rows per thumbnail
	padding     = 2  // gap between thumbnails
)

// ---------------------------------------------------------------------------
// Cache types
// ---------------------------------------------------------------------------

// CachedThumb holds the original image path and its pre-rendered ANSI string.
type CachedThumb struct {
	Path  string
	Thumb string // ANSI-escaped terminal output from chafa
}

// ThumbCache is the top-level cache structure written to disk.
type ThumbCache struct {
	Entries []CachedThumb
}

// ---------------------------------------------------------------------------
// Cache helpers
// ---------------------------------------------------------------------------

func cacheDir() string {
	home, err := os.UserHomeDir()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Cannot determine home directory: %v\n", err)
		os.Exit(1)
	}
	return filepath.Join(home, ".cache", "wallpicker")
}

func cachePath() string {
	return filepath.Join(cacheDir(), "cache.gob")
}

func saveCache(cache ThumbCache) {
	dir := cacheDir()
	if err := os.MkdirAll(dir, 0o755); err != nil {
		fmt.Fprintf(os.Stderr, "Cannot create cache dir: %v\n", err)
		os.Exit(1)
	}
	f, err := os.Create(cachePath())
	if err != nil {
		fmt.Fprintf(os.Stderr, "Cannot create cache file: %v\n", err)
		os.Exit(1)
	}
	defer f.Close()
	if err := gob.NewEncoder(f).Encode(cache); err != nil {
		fmt.Fprintf(os.Stderr, "Cannot write cache: %v\n", err)
		os.Exit(1)
	}
}

func loadCache() (ThumbCache, error) {
	var cache ThumbCache
	f, err := os.Open(cachePath())
	if err != nil {
		return cache, err
	}
	defer f.Close()
	err = gob.NewDecoder(f).Decode(&cache)
	return cache, err
}

// ---------------------------------------------------------------------------
// Image helpers
// ---------------------------------------------------------------------------

var imageExts = map[string]bool{
	".png": true, ".jpg": true, ".jpeg": true,
	".gif": true, ".bmp": true, ".webp": true,
}

func isImage(path string) bool {
	return imageExts[strings.ToLower(filepath.Ext(path))]
}

// renderWithChafa calls chafa to produce a high-quality ANSI thumbnail.
func renderWithChafa(imagePath string, cols, rows int) (string, error) {
	cmd := exec.Command("chafa",
		"--size", fmt.Sprintf("%dx%d", cols, rows),
		"--color-space", "din99d",
		"--dither", "ordered",
		"--dither-intensity", "0.3",
		imagePath,
	)
	out, err := cmd.Output()
	if err != nil {
		return "", err
	}
	// Trim any trailing newline chafa adds.
	return strings.TrimRight(string(out), "\n"), nil
}

// generateCache scans a directory and renders thumbnails via chafa.
func generateCache(dir string) ThumbCache {
	// Verify chafa is available.
	if _, err := exec.LookPath("chafa"); err != nil {
		fmt.Fprintln(os.Stderr, "Error: 'chafa' is not installed. Install it first (e.g. nix-shell -p chafa).")
		os.Exit(1)
	}

	entries, err := os.ReadDir(dir)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error reading directory: %v\n", err)
		os.Exit(1)
	}

	var cache ThumbCache
	for _, e := range entries {
		if e.IsDir() || !isImage(e.Name()) {
			continue
		}
		fullPath := filepath.Join(dir, e.Name())
		thumb, err := renderWithChafa(fullPath, thumbWidth, thumbHeight)
		if err != nil {
			fmt.Fprintf(os.Stderr, "  skipped: %s (%v)\n", e.Name(), err)
			continue
		}
		cache.Entries = append(cache.Entries, CachedThumb{
			Path:  fullPath,
			Thumb: thumb,
		})
		fmt.Fprintf(os.Stderr, "  cached: %s\n", e.Name())
	}

	saveCache(cache)
	fmt.Fprintf(os.Stderr, "Cached %d thumbnails to %s\n", len(cache.Entries), cachePath())
	return cache
}

// ---------------------------------------------------------------------------
// Bubbletea model
// ---------------------------------------------------------------------------

type model struct {
	paths        []string
	thumbs       []string // pre-rendered ANSI thumbnail strings
	cursor       int
	cols         int // thumbnails per row
	scrollOffset int // first visible row index
	termWidth    int
	termHeight   int
	execMsg      string // message after executing foo.sh
}

func modelFromCache(cache ThumbCache) model {
	if len(cache.Entries) == 0 {
		fmt.Fprintln(os.Stderr, "Cache is empty — run with --generate <dir> first.")
		os.Exit(1)
	}

	paths := make([]string, len(cache.Entries))
	thumbs := make([]string, len(cache.Entries))
	for i, entry := range cache.Entries {
		paths[i] = entry.Path
		thumbs[i] = entry.Thumb
	}

	return model{
		paths:  paths,
		thumbs: thumbs,
		cols:   3,
	}
}

func (m model) Init() tea.Cmd {
	return nil
}

// visibleRows returns how many thumbnail rows fit in the terminal.
func (m model) visibleRows() int {
	rowH := thumbHeight + 2       // border adds 2 lines
	available := m.termHeight - 3 // reserve lines for status bar + exec msg + gap
	if available < rowH {
		return 1
	}
	return available / rowH
}

// adjustScroll ensures the cursor's row is within the visible window.
func (m *model) adjustScroll() {
	if m.cols < 1 {
		m.cols = 1
	}
	cursorRow := m.cursor / m.cols
	visible := m.visibleRows()

	if cursorRow < m.scrollOffset {
		m.scrollOffset = cursorRow
	}
	if cursorRow >= m.scrollOffset+visible {
		m.scrollOffset = cursorRow - visible + 1
	}
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.termWidth = msg.Width
		m.termHeight = msg.Height
		cellW := thumbWidth + padding + 2 // +2 for border left/right
		if cellW > 0 {
			m.cols = m.termWidth / cellW
		}
		if m.cols < 1 {
			m.cols = 1
		}
		m.adjustScroll()

	case tea.KeyMsg:
		m.execMsg = ""
		switch msg.String() {
		case "q", "ctrl+c", "esc":
			return m, tea.Quit
		case "left", "h":
			if m.cursor > 0 {
				m.cursor--
			}
		case "right", "l":
			if m.cursor < len(m.thumbs)-1 {
				m.cursor++
			}
		case "up", "k":
			if m.cursor-m.cols >= 0 {
				m.cursor -= m.cols
			}
		case "down", "j":
			if m.cursor+m.cols < len(m.thumbs) {
				m.cursor += m.cols
			}
		case "enter":
			selected := m.paths[m.cursor]

			// Run kill.sh first (wait for it to finish).
			killCmd := exec.Command("/home/rushdynamic/Scripts/dotfiles-nixos/i3/bin/kill.sh")
			killCmd.SysProcAttr = &syscall.SysProcAttr{Setsid: true}
			if err := killCmd.Run(); err != nil {
				m.execMsg = fmt.Sprintf("kill.sh failed: %v", err)
				break
			}

			// Start autostart.sh fully detached (survives terminal closure).
			startCmd := exec.Command("/home/rushdynamic/Scripts/dotfiles-nixos/i3/bin/autostart.sh", selected)
			startCmd.SysProcAttr = &syscall.SysProcAttr{Setsid: true}
			if err := startCmd.Start(); err != nil {
				m.execMsg = fmt.Sprintf("Error: %v", err)
			} else {
				m.execMsg = fmt.Sprintf("Started autostart.sh with %s", filepath.Base(selected))
			}
			return m, tea.Quit
		}
		m.adjustScroll()
	}
	return m, nil
}

func (m model) View() string {
	if len(m.thumbs) == 0 {
		return "No images found."
	}

	selectedBorder := lipgloss.NewStyle().
		Border(lipgloss.RoundedBorder()).
		BorderForeground(lipgloss.Color("#FF79C6")).
		Padding(0)

	normalBorder := lipgloss.NewStyle().
		Border(lipgloss.RoundedBorder()).
		BorderForeground(lipgloss.Color("#555555")).
		Padding(0)

	// Build all rows first.
	var allRows []string
	var rowCells []string

	for i, thumb := range m.thumbs {
		var cell string
		if i == m.cursor {
			cell = selectedBorder.Render(thumb)
		} else {
			cell = normalBorder.Render(thumb)
		}

		rowCells = append(rowCells, cell)

		if len(rowCells) == m.cols || i == len(m.thumbs)-1 {
			allRows = append(allRows, lipgloss.JoinHorizontal(lipgloss.Top, rowCells...))
			rowCells = nil
		}
	}

	// Slice to only the visible rows based on scroll offset.
	visible := m.visibleRows()
	start := m.scrollOffset
	end := start + visible
	if end > len(allRows) {
		end = len(allRows)
	}
	if start > len(allRows) {
		start = 0
	}
	visibleRows := allRows[start:end]

	// Scroll indicator
	totalRows := len(allRows)
	scrollInfo := ""
	if totalRows > visible {
		scrollInfo = fmt.Sprintf("  │  row %d-%d of %d", start+1, end, totalRows)
	}

	gallery := lipgloss.JoinVertical(lipgloss.Left, visibleRows...)

	// Status bar
	name := filepath.Base(m.paths[m.cursor])
	status := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#F8F8F2")).
		Background(lipgloss.Color("#44475A")).
		Padding(0, 1).
		Render(fmt.Sprintf(" %s  │  ←↑↓→ navigate  │  enter run foo.sh  │  q quit%s ", name, scrollInfo))

	var parts []string
	parts = append(parts, gallery, "", status)
	if m.execMsg != "" {
		execStyle := lipgloss.NewStyle().
			Foreground(lipgloss.Color("#50FA7B")).
			Bold(true)
		parts = append(parts, execStyle.Render("▸ "+m.execMsg))
	}

	return lipgloss.JoinVertical(lipgloss.Left, parts...)
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

func main() {
	generateDir := flag.String("generate", "", "Path to image directory — generates and caches thumbnails")
	flag.Parse()

	var m model

	if *generateDir != "" {
		// --generate mode: scan directory, cache thumbnails, then show gallery.
		info, err := os.Stat(*generateDir)
		if err != nil || !info.IsDir() {
			fmt.Fprintf(os.Stderr, "'%s' is not a valid directory.\n", *generateDir)
			os.Exit(1)
		}
		fmt.Fprintln(os.Stderr, "Generating thumbnail cache...")
		cache := generateCache(*generateDir)
		m = modelFromCache(cache)
	} else {
		// Default mode: load from cache.
		cache, err := loadCache()
		if err != nil {
			fmt.Fprintf(os.Stderr, "No cache found. Run with --generate <dir> first.\n")
			os.Exit(1)
		}
		m = modelFromCache(cache)
	}

	p := tea.NewProgram(m, tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Error running program: %v\n", err)
		os.Exit(1)
	}
}
