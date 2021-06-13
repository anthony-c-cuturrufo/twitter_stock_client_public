(** Buys and sells stock and calls Algo for exit strategy*)

(** Calls TD Ameritrade Buy function, email function, stock.csv function *)
val buy_helper : string -> string -> string -> string -> float -> unit

(** buys stock [ticker] and logs to stocks.csv *)
val buy : Core_kernel__.Import.string -> unit

(** Calls TD Ameritrade Sell function, email function, stock.csv
    function *)
val sell_helper : string -> string -> string -> string -> unit

(** sells stock [ticker] and logs to stocks.csv *)
val sell : Core_kernel__.Import.string -> unit
