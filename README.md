# Vendor Search

Adds a search box to the vendor (merchant) window in WoW: Mists of Pandaria Classic.
Typing filters the list of items for sale; pagination, prices, extended-cost
currencies, tooltips, stack splitting and buying all keep working normally.

## Install

Copy the `VendorSearch` folder into:

```
World of Warcraft\_classic_\Interface\AddOns\VendorSearch\
```

so that you end up with `...\AddOns\VendorSearch\VendorSearch.toc`. Restart the
client (or `/reload`) and enable it in the AddOns list.

## Usage

- Open any vendor and type in the box at the top-right of the merchant window.
- Multiple words are ANDed: `heavy leather` matches items containing both.
- `Esc` clears the box; `/vs <text>` focuses it and pre-fills a search.
- The box hides on the Buyback tab.

## How it works

Blizzard's `MerchantFrame_UpdateMerchantInfo` draws the page. For the duration
of that one call, the merchant query API (`GetMerchantNumItems`,
`GetMerchantItemInfo`, `GetMerchantItemLink`, cost/stack helpers) is swapped for
wrappers that translate a filtered index into the real merchant index. The API
is restored immediately after, and each item button's ID is re-pointed at its
real merchant index — so every click path (buy, modified-click link, split
stack, extended-cost confirmation) runs through unmodified Blizzard code with
the correct index.

This avoids re-implementing the merchant layout, which is what usually breaks
this kind of addon on a patch.

## Tweaks

The search box has two placement presets, picked automatically at each vendor:

```lua
local PLACEMENT = {
	elvui   = { ..., x = -30, y = -18, width = 110, height = 18 },
	default = { ..., x = -40, y = -34, width = 130, height = 20 },
}
```

`elvui` is used only when ElvUI is loaded **and** its Blizzard-frame merchant
skin is enabled (`E.private.skins.blizzard.merchant`) — that skin removes the
portrait and pulls the item rows up, leaving very little header room. Otherwise
the `default` preset drops the box into the empty band the stock frame has
between its title bar and the first item row.

The check runs on every `MERCHANT_SHOW`, so toggling ElvUI profiles mid-session
moves the box without a reload.

If MoP Classic moves past 5.5.x, bump `## Interface:` in `VendorSearch.toc`.

## License

MIT — see [LICENSE](LICENSE).
