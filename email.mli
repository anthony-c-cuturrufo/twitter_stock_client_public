(** Handles SMTP Emails *)

(** From email *)
val email_address : string

(** From email password *)
val email_password : string

(** Configure from email with roots.pem certificate *)
val conf : Letters.Config.t

(** Takes in email configure arguement [config], from email [email],
    stocker ticker [ticker], number of shares bought or sold
    [number_shares], the price the stock was bought at [price], and the
    order type (buy or sell) [order]. Composes an email with these
    arguements and sends the email. *)
val send_email :
  Letters.Config.t ->
  string ->
  string ->
  string ->
  string ->
  string ->
  unit Lwt.t
