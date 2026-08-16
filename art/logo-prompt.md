# Logo prompt

The prompt behind `logo.png`, kept so the art can be regenerated or restyled
consistently later. Written for an image model (ChatGPT / DALL·E class).

Two things matter most and are easy to lose when editing this: the icon must
read at 64x64 (that is the size WoW shows it at in the AddOns list), and the
artwork must fill the square with no transparent margin or rounded corners,
because CurseForge and WoW both crop and scale it themselves.

## Prompt

```
Create a square 1:1 icon in the style of a World of Warcraft ability/item icon,
painted in the game's hand-painted fantasy style: thick confident brushwork,
warm rim lighting from the upper left, deep saturated shadows, slightly worn
and tactile surfaces — like an oil-painted texture, not vector art, not a
glossy 3D render, not flat minimalist design.

Subject: a brass-rimmed magnifying glass held over a small heap of gold coins
and a partly unrolled merchant's parchment. The lens catches a warm highlight
and visibly enlarges the coins seen through it.

Composition: one centered subject filling about 85% of the frame, tilted
slightly on the diagonal for energy. Dark background — deep warm brown fading
to charcoal at the corners — with a soft radial glow behind the subject so the
silhouette reads clearly. The silhouette must stay legible when the image is
scaled down to 64x64 pixels, so keep shapes bold and avoid thin details.

Palette: aged brass and gold, warm amber highlights, deep brown-black shadows,
with one small accent of teal-green on the parchment's ribbon for contrast.

No text, letters, numbers, runes, watermarks, or UI elements of any kind.
Artwork must fill the entire square edge to edge: no transparent margins, no
rounded corners, no outer border or frame, no drop shadow outside the square.
Output at 1024x1024.
```

## Alternate subjects

Swap only the Subject paragraph, keep the rest:

- A magnifying glass over a merchant's price tag or ledger — reads more
  "search a list", less "treasure".
- A magnifying glass over an open coin purse spilling coins — reads more
  "vendor".

## Derived files

Everything below is generated from `logo.png`; regenerate rather than edit by
hand. The script lives in the commit that added the icon.

| File | Size | Purpose |
| --- | --- | --- |
| `logo.png` | 1254x1254 | source art, never shipped |
| `curseforge-logo-400.png` | 400x400 | CurseForge project avatar, uploaded on the website |
| `../Media/icon.tga` | 64x64 | in-game icon, referenced by `## IconTexture` in the .toc |

`icon.tga` must be uncompressed 32-bit TGA with bottom-up row order
(image type 2, descriptor byte `0x08`) — that is the format the client reads.
