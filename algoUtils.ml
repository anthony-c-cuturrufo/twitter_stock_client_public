open Yojson.Basic.Util

(* returns current price of [ticker] *)
let get_current_price ticker =
  Stock.ticker_info_json ticker |> Stock.stock_price ticker

(* takes in json list [price_history] directly from http response and
   looks for all occuences of [tag] and returns list of values
   corresponding to tag Examples of tag can be "high" or "volume"*)
let parse price_history tag =
  let price_history_lst =
    price_history |> Yojson.Basic.from_string |> member "candles"
    |> Yojson.Basic.Util.to_list
  in
  let rec parse_tags lst acc =
    match lst with
    | [] -> acc
    | h :: t -> parse_tags t ((member tag h |> to_float) :: acc)
  in
  List.rev (parse_tags price_history_lst [])

(* adds [item] to file [csv_name]. Item must formated as a list of
   strings *)
let csv_add csv_name item =
  let csv = Csv.load csv_name in
  let fields, data = (List.hd csv, List.tl csv) in
  let new_data = if data = [ [ "" ] ] then [ item ] else item :: data in
  let new_csv = fields :: new_data in
  Csv.save csv_name new_csv

(* removes first element in the csv [csv_name]. This function is used
   predominantly for testing with the csv files *)
let csv_remove_first csv_name =
  let csv = Csv.load csv_name in
  let fields, data = (List.hd csv, List.tl csv) in
  let new_data = match data with [] -> [] | h :: t -> t in
  let new_csv = fields :: new_data in
  Csv.save csv_name new_csv

(* find most recent purchase of [ticker] and returns field corresponding
   to [col_number] in file [csv_name] *)
let member_of_last_purchase ticker col_number csv_name =
  let csv = Csv.load csv_name in
  let fields, data = (List.hd csv, List.tl csv) in
  let row_opt =
    List.find_opt
      (fun lst -> List.hd lst = "BUY" && List.nth lst 1 = ticker)
      data
  in
  let row =
    match row_opt with
    | None -> failwith "never purchases ticker"
    | Some r -> r
  in
  try List.nth row col_number with _ -> failwith "invalid col_number"

(* takes a [dict] that maps [ticker] to highest price reached since
   bought. If [current_price] is higher than the max then it replaces
   the highest value with [current_price]. If [ticker] has no mapping,
   then the mapping [ticker] -> [current_price] is added to [dict]*)
let log_high ticker current_price dict =
  if Hashtbl.mem dict ticker then
    if Hashtbl.find dict ticker < current_price then
      Hashtbl.replace dict ticker current_price
    else ()
  else Hashtbl.add dict ticker current_price

(* calculates target by setting to rolling max unless if with a given
   error it is at the high then the target is set to [current_price] +
   [current_price] * [profit_target] *)
let calc_target curr_price rolling_max profit_target_const error =
  let offset = rolling_max *. error in
  if curr_price > rolling_max -. offset then
    curr_price +. (curr_price *. profit_target_const)
  else rolling_max
