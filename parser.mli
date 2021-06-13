(** Parses tweet for a stock based on user defined dictionary and
    twitter stock object *)

(** This list represents the custom keywords the user wants to look for
    and it's respective stock ticker *)
val custom_pairings_list : (string * string) list

(** initializing dictionary containing mappings from key word to stock
    ticker*)
val custom_pairings : (string, string) Hashtbl.t

(** converts list [lst] representation of mappings to hashtable
    representation *)
val hash_pairings : (string * string) list -> unit

(** takes in strings [s] [ind] [res] and return subtring with first
    occurence. *)
val custom_parse_helper : string -> int -> string option -> string

(** takes in string [s] first searches for index of first occurence of
    '$<TICKER>'. Then clips off everything after first occurence and
    lastly searches for keywords in [custom_pairings]. If neither are
    found it returns empty string. *)
val custom_parse : string -> string
