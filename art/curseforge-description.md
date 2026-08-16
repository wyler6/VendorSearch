# Vendor Search

Adds a search box to the vendor window. Type part of an item's name and the
merchant's list filters down to what matches — no more clicking **Next** four
times looking for one glyph, gem, or reagent.

Built for **Mists of Pandaria Classic**.

## Why

Some vendors carry a lot. Reagent vendors, glyph vendors, and the big Valor and
justice quartermasters run to several pages, and the only way to find one item
is to page through and read every row. This puts a search box in the frame's
header and filters as you type.

## Features

- **Live filtering** — the list narrows as you type, and page numbers recalculate to match.
- **Multi-word search** — all terms must match, so `heavy leather` finds *Heavy Leather Ball* but not every leather item in the shop.
- **Nothing else breaks.** Prices, stack counts, limited-supply counts, extended-cost currencies (Valor, tokens, marks), tooltips, shift-click linking, split-stack purchases and the confirmation popup for token-cost items all behave exactly as they do unfiltered.
- **Stays out of the way** — hides itself on the Buyback tab, and clears between vendors so you never open a shop into a stale filter.
- **ElvUI aware** — detects ElvUI's merchant skin and positions the box to suit whichever frame you're actually looking at.

## Usage

Open any vendor and type in the box at the top-right of the merchant window.

- `Esc` clears the box and drops focus.
- `/vs` focuses the box; `/vs cloth` focuses it with a search already entered.

## Compatibility

- Mists of Pandaria Classic (interface 50504).
- Works with the default Blizzard merchant frame and with ElvUI's skinned one.
- No configuration, no saved variables, no dependencies.

## How it works

The addon does **not** reimplement Blizzard's merchant layout — that approach is
what usually breaks this kind of addon on a patch, and it tends to mangle
token-cost items.

Instead, Blizzard's own code draws the page. For the duration of that single
call the merchant query functions are swapped for wrappers that translate a
filtered position into the real merchant index; they're restored immediately
afterwards, and each item button is re-pointed at its true index. Every click
path — buy, link, split stack, extended-cost confirmation — runs through
unmodified Blizzard code with the correct index.

## Source and bug reports

Source is on GitHub: https://github.com/wyler6/VendorSearch

Issues and suggestions are welcome there.
