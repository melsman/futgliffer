import "drawing"
import "lib/github.com/athas/matte/colour"

type^ glyph = {lines:[]line, curves:[]cbezier, advance: i32}

let ln (p0:point0) (p1:point0) : line =
  {p0=p0,p1=p1,z=1,color=argb.black}

let curve (p0:point0) (p1:point0) (p2:point0) (p3:point0) : cbezier =
  {p0=p0,p1=p1,p2=p2,p3=p3,z=1,color=argb.black}
