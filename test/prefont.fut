import "drawing"
import "lib/github.com/athas/matte/colour"

type option 'a = #Some a | #None

module type font = {
  type glyph_info = {char:u8, nlines:i32, ncurves:i32, advance:i32,
		     firstlineidx:i32, firstcurveidx:i32}

  val C : i32
  val curves : [C]cbezier               -- all curves in the font

  val L : i32
  val lines  : [L]line                  -- all lines in the font

  val N : i32
  val glyphs : [N]u8                    -- array of available glyphs

  val glyph : u8 -> option glyph_info
}
