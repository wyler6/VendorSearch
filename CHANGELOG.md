# Changelog

## v1.0.1

- Moved the search box under ElvUI to the strip above the page arrows. ElvUI's
  merchant skin leaves no usable room in the frame header, where the box used to
  sit on top of the first item row. It is anchored to the page arrow itself, so
  it follows wherever the skin places it.
- No change to placement on the default Blizzard merchant frame.

## v1.0.0

Initial release.

- Adds a search box to the vendor window that filters the items for sale.
- Multi-word searches are ANDed: `heavy leather` matches items containing both.
- Pagination, prices, extended-cost currencies, tooltips, stack splitting and
  buying all continue to work on the filtered list.
- The box hides on the Buyback tab and clears itself between vendors.
- `Esc` clears the box; `/vs <text>` focuses it and pre-fills a search.
- Placement adapts automatically to ElvUI's merchant skin.
