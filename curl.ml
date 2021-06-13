open Cohttp
open Cohttp_lwt_unix
open Lwt

let data_map p =
  p
  |> List.map (fun (k, v) -> Printf.sprintf "%s=%s" k v)
  |> String.concat "&" |> Cohttp_lwt.Body.of_string

let get_curl url headers =
  let body =
    Client.call ~headers `GET (Uri.of_string url)
    >>= fun (resp, body) ->
    body |> Cohttp_lwt.Body.to_string >|= fun body ->
    let code = resp |> Response.status |> Code.code_of_status in
    (code, body)
  in
  match Lwt_main.run body with
  | code, body ->
      if code >= 100 && code <= 299 then body
      else
        let _ = print_endline (string_of_int code ^ ": failing code") in
        "{\"error\": \"" ^ string_of_int code ^ ": failing code" ^ "\"}"

let get_curl_data url headers body =
  let body =
    Client.post ~headers ~body (Uri.of_string url)
    >>= fun (resp, body) ->
    body |> Cohttp_lwt.Body.to_string >|= fun body ->
    let code = resp |> Response.status |> Code.code_of_status in
    (code, body)
  in
  match Lwt_main.run body with
  | code, body ->
      if code >= 100 && code <= 299 then body
      else
        let _ = print_endline (string_of_int code ^ ": failing code") in
        "{\"error\": \"" ^ string_of_int code ^ ": failing code" ^ "\"}"
