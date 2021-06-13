open Algo

let buy_helper ticker time price shares target =
  let _ =
    Trade.place_order "BUY"
      (Config.td_bearer "config.json")
      ticker shares
  in
  let () =
    Lwt_main.run
      (Email.send_email Email.conf Config.email_address_destination
         ticker shares price "BUY")
  in
  AlgoUtils.csv_add "stocks.csv"
    [ "BUY"; ticker; price; time; target |> string_of_float ]

(* buys stock [ticker] and logs to stocks.csv *)
let buy ticker =
  let curr_time = Core.Time.now () in
  let string_time =
    Core.Time.to_sec_string curr_time Core.Time.Zone.utc
  in
  let curr_price = AlgoUtils.get_current_price ticker in
  let rolling_max = Algo.calc_rolling_max ticker in
  let profit_target =
    AlgoUtils.calc_target curr_price rolling_max
      Config.algo_profit_target Config.algo_error_margin
  in
  let bought_price = curr_price |> string_of_float in
  let number_shares =
    Config.algo_capital_limit /. (bought_price |> float_of_string)
    |> int_of_float |> string_of_int
  in
  buy_helper ticker string_time bought_price number_shares profit_target

let sell_helper ticker time price shares =
  let _ =
    Trade.place_order "SELL"
      (Config.td_bearer "config.json")
      ticker shares
  in
  let () =
    Lwt_main.run
      (Email.send_email Email.conf Config.email_address_destination
         ticker shares price "SELL")
  in
  AlgoUtils.csv_add "stocks.csv" [ "SELL"; ticker; price; time; "-1" ]

(* sells stock [ticker] and logs to stocks.csv *)
let sell ticker =
  let curr_time = Core.Time.now () in
  let string_time =
    Core.Time.to_sec_string curr_time Core.Time.Zone.utc
  in
  let selling_price =
    AlgoUtils.get_current_price ticker |> string_of_float
  in
  let number_shares =
    Config.algo_capital_limit /. (selling_price |> float_of_string)
    |> int_of_float |> string_of_int
  in
  sell_helper ticker string_time selling_price number_shares
