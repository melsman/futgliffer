structure J = Json

fun println s = print (s ^ "\n")
fun die s = (println ("ERROR: " ^ s); Process.exit 1)
fun int_to_string (i:int) : string =
    if i < 0 then "-" ^ Int.toString (~i)
    else Int.toString i

val glyph_ref : bool ref = ref true
val contour_ref : bool ref = ref false
val verbose_ref : bool ref = ref false

fun process_args ("-g"::xs) = (glyph_ref := true; contour_ref := false; process_args xs)
  | process_args ("-c"::xs) = (glyph_ref := false; contour_ref := true; process_args xs)
  | process_args ("-verbose"::xs) = (verbose_ref := true; process_args xs)
  | process_args rest = rest

val filename = case process_args(CommandLine.arguments()) of
                   [filename] => filename
                 | _ => die "expecting file name"

val is = TextIO.openIn filename
         handle _ => die "failed to open file"

val content = TextIO.inputAll is
              handle  _ => die "failed to read file"

val () = TextIO.closeIn is

val json = J.fromString content
           handle Fail s => die s

fun look json nil = json
  | look json (x::xs) =
    case json of
        J.OBJECT obj => (case J.objLook obj x of
                             SOME json' => look json' xs
                           | NONE => die ("expecting attribute " ^ x))
      | _ => die "expecting object"

fun advance json =
    case look json ["items"] of
        J.ARRAY ts =>
        let val advance = List.filter (fn J.OBJECT obj => (case J.objLook obj "name" of
                                                               SOME (J.STRING "advance") => true
                                                             | _ => false)
                                      | _ => false) ts
        in case advance of
               [advance] => (case look advance ["attrs"] of
                                 J.OBJECT obj => (case J.objLook obj "width" of
                                                      SOME (J.STRING s) => (case Int.fromString s of
                                                                                SOME i => i
                                                                              | NONE => die "expecting integer as advance width")
                                                    | _ => die "expecting width attribute for advance item")
                               | _ => die "expecting attrs")
             | _ => die "expecting one advance field"
        end
      | _ => die "advance.expecting ARRAY"

fun contours json =
    case look json ["items"] of
        J.ARRAY ts =>
        let val outline = List.filter (fn J.OBJECT obj => (case J.objLook obj "name" of
                                                               SOME (J.STRING "outline") => true
                                                             | _ => false)
                                      | _ => false) ts
        in case outline of
               [outline] => (case look outline ["items"] of
                                 J.ARRAY ts => ts
                               | _ => die "expecting items")
             | [] => []
             | _ => die "expecting one outline"
        end
        | _ => die "expecting ARRAY"

type point = int * int
type line = point * point
type cbezier = point * point * point * point

datatype point_type = LINE | CURVE | ANON | MOVE

fun parseJpoint (j:J.t) : point * point_type =
    case j of
        J.OBJECT obj =>
        (case J.objLook obj "name" of
             SOME (J.STRING "point") =>
             (case J.objLook obj "attrs" of
                  SOME (J.OBJECT attrs) =>
                  let val p = case (J.objLook attrs "x", J.objLook attrs "y") of
                                  (SOME (J.STRING x), SOME (J.STRING y)) =>
                                  (case (Int.fromString x, Int.fromString y) of
                                       (SOME x,SOME y) => (x,y)
                                     | _ => die "parseJpoint: expecting integers for x and y")
                                | _ => die "parseJpoint: expecting x and y attributes for point"
                      val k = case J.objLook attrs "type" of
                                  SOME (J.STRING "line") => LINE
                                | SOME (J.STRING "curve") => CURVE
                                | SOME (J.STRING "move") => MOVE
                                | NONE => ANON
                                | _ => die "parseJpoint.expecting optional point type is either line or curve"
                  in (p,k)
                  end
                | _ => die "parseJpoint: expecting attributes")
           | _ => die "parseJpoint: expecting point")
      | _ => die "parseJpoint: expecting object"

fun processPoints (first:point list) (points:point list) (jpoints:J.t list)
                  (lines: line list, curves :cbezier list) : line list * cbezier list =
    case jpoints of
        nil => (case (points,first) of
                    ([p0],[p1]) => (rev((p0,p1)::lines),rev curves)
                  | ([p2,p1,p0],[p3]) => (rev lines,rev ((p0,p1,p2,p3)::curves))
                  | ([p0],[p3,p2,p1]) => (rev lines,rev ((p0,p1,p2,p3)::curves))
                  | _ => (rev lines,rev curves))
      | jp::jpoints =>
        let fun add_first p =
                case first of
                    [] => processPoints (p::points) [p] jpoints (lines,curves)
                  | _ => die "processPoints - first already set"
        in case parseJpoint jp of
               (p,LINE) =>
               (case points of
                    [p0] => processPoints first [p] jpoints ((p0,p)::lines,curves)
                  | [] => add_first p
                  | _ => die "processPoints - too many anonymous points for a line")
             | (p,CURVE) =>
               (case points of
                    [p2,p1,p0] => processPoints first [p] jpoints (lines,(p0,p1,p2,p)::curves)
                  | _ => add_first p)
(*
                  | _ => die ("expecting four points for a curve - got "
                              ^ Int.toString (1 + length points)))
*)
             | (p,ANON) => processPoints first (p::points) jpoints (lines,curves)
             | (p,MOVE) => processPoints first points jpoints (lines,curves)
        end

fun processContour (json:J.t) : line list * cbezier list * int option =
    let val points =
            case json of
                J.OBJECT obj => (case J.objLook obj "items" of
                                     SOME (J.ARRAY ts) => ts
                                   | _ => die "processContour: expecting ARRAY")
              | _ => die "processContour: expecting OBJECT"
        val (lines,curves) = processPoints nil nil points (nil,nil)
    in (lines,curves,NONE)
    end

val name = case look json ["attrs","name"] of
               J.STRING s => s
             | _ => die "expecting string"

val () =
    if !verbose_ref then println ("[processing glif " ^ name ^"]")
    else ()

val cs = contours json

val pcs = map processContour cs

fun pp_point ((x,y):point) : string =
    "(" ^ int_to_string x ^ "," ^ int_to_string y ^ ")"
fun pp_line ((p0,p1):line) : string =
    "ln " ^ pp_point p0 ^ " " ^ pp_point p1
fun pp_curve ((p0,p1,p2,p3):cbezier) : string =
    "curve " ^ String.concatWith " " (map pp_point [p0,p1,p2,p3])

fun pp_pc (ty:string) (lines,curves,advance) : string =
    let fun pp_elems pp elems =
            case elems of
                nil => "[]"
              | _ => ("[\n" ^
                      String.concatWith ",\n" (map (fn e => "      " ^ pp e) elems) ^
                      "\n    ]")
        fun maybe_add_advance NONE s = s
          | maybe_add_advance (SOME i) s = s ^ ",\n   advance=" ^ int_to_string i
        val rows =
            ["let " ^ ty ^ "_" ^ name ^ " : " ^ ty ^ " = ",
             "  {lines=" ^ pp_elems pp_line lines ^ ",",
             maybe_add_advance advance
             ("   curves=" ^ pp_elems pp_curve curves),
             "  }",
             ""]
    in String.concatWith "\n" rows
    end

fun flatten nil = nil
  | flatten (x::xs) = x @ flatten xs

val glyph : line list * cbezier list * int option =
    let val lines = map #1 pcs
        val curves = map #2 pcs
        val adv = advance json
    in (flatten lines, flatten curves, SOME adv)
    end

val () = if !glyph_ref then print (pp_pc "glyph" glyph)
         else ()

val () = if !contour_ref then print (String.concatWith "\n" (map (pp_pc "contour") pcs))
         else ()
