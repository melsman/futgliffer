
let font_firstlineidx : [N]i32 =
  ([0] ++ scan (+) 0 font_nlines)[:N]

let font_firstcurveidx : [N]i32 =
  ([0] ++ scan (+) 0 font_ncurves)[:N]

let glyph_infos : [N]glyph_info =
  map5 (\c (nl,nc) a fli fci -> {char=c,nlines=nl,ncurves=nc,advance=a,
				 firstlineidx=fli,firstcurveidx=fci})
  font_chars (zip font_nlines font_ncurves) font_advances
  font_firstlineidx font_firstcurveidx

let glyphs : [N]u8 = font_chars

let allglyphs : [256](option glyph_info) =
  loop all = replicate 256 #None for i < N do
    let char = font_chars[i]
    let nlines = font_nlines[i]
    let ncurves = font_ncurves[i]
    let advance = font_advances[i]
    let firstlineidx = font_firstlineidx[i]
    let firstcurveidx = font_firstcurveidx[i]
    in unsafe all with [(i32.u8 char)] = #Some {char,nlines,ncurves,advance,firstlineidx,firstcurveidx}

let glyph (c:u8) : option glyph_info =
  unsafe allglyphs[(i32.u8 c)]

}
