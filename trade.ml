open Cohttp
open Yojson.Basic.Util
open Curl

let get_bearer apikey token =
  let headers =
    Header.init () |> fun h ->
    Header.add h "Content-Type" "application/x-www-form-urlencoded"
  in
  let data =
    [
      ("client_id", apikey);
      ("refresh_token", token);
      ("grant_type", "refresh_token");
    ]
  in
  let body = data_map data in
  let json =
    get_curl_data "https://api.tdameritrade.com/v1/oauth2/token" headers
      body
  in
  json |> Yojson.Basic.from_string |> member "access_token" |> to_string

let get_refresh apikey token =
  let headers =
    Header.init () |> fun h ->
    Header.add h "Content-Type" "application/x-www-form-urlencoded"
  in
  let data =
    [
      ("client_id", apikey);
      ("refresh_token", token);
      ("grant_type", "refresh_token");
      ("access_type", "offline");
    ]
  in
  let body = data_map data in
  get_curl_data
    "https://api.tdameritrade.com/v1/accounts/235920696/orders" headers
    body

let check_bearer apikey token =
  let current_time = Core.Time.now () in
  let time_change =
    Core.Time.abs_diff current_time
      (Core.Time.of_localized_string Core.Time.Zone.utc
         (Config.td_bearer_date "config.json"))
  in
  let time_change_float = Core.Time.Span.to_min time_change in
  if time_change_float >= 25.0 then
    Json_writer.update_td_ameritrade_bearer
      (get_bearer apikey token)
      (Core.Time.to_sec_string current_time Core.Time.Zone.utc)

let check_refresh apikey token =
  let current_time = Core.Time.now () in
  let time_change =
    Core.Time.abs_diff current_time
      (Core.Time.of_localized_string Core.Time.Zone.utc
         (Config.td_refresh_date "config.json"))
  in
  let time_change_float = Core.Time.Span.to_day time_change in
  if time_change_float >= 85.0 then
    Json_writer.update_td_ameritrade_refresh
      (get_refresh apikey token)
      (Core.Time.to_sec_string current_time Core.Time.Zone.utc)

let account_info_json bearer =
  let headers =
    Header.init () |> fun h ->
    Header.add h "Authorization" ("Bearer " ^ bearer)
  in
  let json =
    get_curl "https://api.tdameritrade.com/v1/accounts" headers
  in
  String.sub json 2 (String.length json - 4)

type account_info = {
  account_id : string;
  available_funds : float;
}

let account_info_of_json j =
  {
    account_id =
      j |> member "securitiesAccount" |> member "accountId" |> to_string;
    available_funds =
      j
      |> member "securitiesAccount"
      |> member "currentBalances"
      |> member "availableFunds" |> to_float;
  }

let account_from_json json =
  json |> Yojson.Basic.from_string |> account_info_of_json

let account_id json = (account_from_json json).account_id

let available_funds json = (account_from_json json).available_funds

let order order_type ticker quantity =
  "{\"orderType\": \"MARKET\",\"session\": \"NORMAL\",\"duration\": \
   \"DAY\",\"orderStrategyType\": \"SINGLE\",\"orderLegCollection\": \
   [{\"instruction\": \"" ^ order_type ^ "\",\"quantity\": " ^ quantity
  ^ ",\"instrument\": {\"symbol\": \"" ^ ticker
  ^ "\",\"assetType\": \"EQUITY\"}}]}"

let place_order order_type bearer ticker quantity =
  let headers =
    Header.init () |> fun h ->
    Header.add h "Authorization" ("Bearer " ^ bearer) |> fun h ->
    Header.add h "Content-Type" "application/json"
  in
  let body =
    order order_type ticker quantity |> Cohttp_lwt.Body.of_string
  in
  get_curl_data
    ("https://api.tdameritrade.com/v1/accounts/"
    ^ account_id (account_info_json bearer)
    ^ "/orders")
    headers body
