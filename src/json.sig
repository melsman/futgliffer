(* Copyright 2015, Martin Elsman, MIT-license *)

signature JSON = sig
  type obj
  datatype t = RAW of string (* embedded json string *)
             | OBJECT of obj
             | STRING of string
             | ARRAY of t list
             | NULL
             | BOOL of bool
             | NUMBER of string

  (* Operations on maps *)
  val objFromList      : (string*t) list -> obj
  val objFromKeyValues : (string*string) list -> obj
  val objLook          : obj -> string -> t option
  val objFold          : ((string*t)*'a -> 'a) -> 'a -> obj -> 'a
  val objList          : obj -> (string*t) list
  val objAdd           : obj -> string -> t -> obj
  val objEmp           : obj

  (* Operations on Json values *)
  val toString      : t -> string
  val fromKeyValues : (string*string)list -> t

  val foldlArray    : (t * 'a -> 'a) -> 'a -> t -> 'a
  val foldrArray    : (t * 'a -> 'a) -> 'a -> t -> 'a

  val getBool       : t -> string -> bool   (* may raise Fail *)
  val getString     : t -> string -> string (* may raise Fail *)
  val getStringOpt  : t -> string -> string -> string

  (* Operations directly on strings containing json *)
  val fromString     : string -> t
  val foldlArrayJson : (t*'a -> 'a) -> 'a -> string -> 'a
end

(**

[type t] json representation.

[toString v] returns a string representation of the json value v.

[fromString s] returns a t-representation of the json string s. Raises
Fail(msg) in case of parse error.

[fromKeyValues kvs] returns an object t-representation of the
key-value pairs in kvs.

*)
