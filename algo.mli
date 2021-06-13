(** Handles trading algorithm for buying and selling stocks *)

(** keeps track of highest values reached by stocks that are currently
    being held. Each entry is {Ticker : Highest_Price} *)
val high_dictionary : (string, float) Hashtbl.t

(** index of rolling max value in stocks.csv *)
val rolling_max_index : int

(** takes in a stock [ticker] for TD Ameritrade and returns the highest
    price in a period defined by *)
val calc_rolling_max : string -> float

(** checks if [current_price] falls below the *)
val hit_trailing_stop : string -> float -> bool

(** checks "stocks.csv" if [current_price] of [stock] passing rolling
    max *)
val hit_rolling_max : string -> float -> bool

(** considers [stock] to have "broken" rolling max if it passes with a
    margin of [rebuy_thresh] *)
val breaks_rolling_max : ?rebuy_thresh:float -> string -> bool

(** Takes in a stock ticker and decides if it should sell. Returns
    boolean tuple (sell_stock, keep_watching). It could decide to sell
    for two reasons: 1. It hits rolling max. 2. It hits trailing stop
    loss. If it hits rolling max, then (true, true), if it hits trailing
    stop, then (true, false), else (false, false) *)
val keep_stock : string -> bool * bool

(** looks at specified stock on watchlist and returns true if it should
    rebuy. The decision is made from whether or not it "breaks" from the
    rolling max *)
val rebuy : string -> bool
