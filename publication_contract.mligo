type publication_supply = { publication_stock : nat ; publication_address : address ; publication_price : tez ; publication_restricted : bool; publication_title : string }
type publication_storage = (nat, publication_supply) map
type return = operation list * publication_storage
type publication_id = nat

// Defining types for transfering publication.
type transfer_destination =
[@layout:comb]
{
  to_ : address;
  publication_id : publication_id;
  amount : nat;
}
 
type transfer =
[@layout:comb]
{
  from_ : address;
  txs : transfer_destination list;
}

// Address to be used to payout to book publisher.
let publisher_address : address = ("tz1Rm3pAnn6Se4JHaTQ6af3S1bPnjLL5VZbU" : address)

let main (publication_kind_index, publication_storage : nat * publication_storage) : return =
  // Check we current stock the requested publication
  let publication_kind : publication_supply =
    match Map.find_opt (publication_kind_index) publication_storage with
    | Some k -> k
    | None -> (failwith "Sorry, We do not stock the requested publication!" : publication_supply)
  in

  // Check if offer is enough to cover price of publication.  
  let () = if publication_kind.publication_restricted = true then
    failwith "Sorry, This publication is currently restricted!"
  in

  // Check if offer is enough to cover price of publication.  
  let () = if Tezos.amount < publication_kind.publication_price then
    failwith "Sorry, This publication is worth more tha that!"
  in

 // Check if the publication is in stock.
  let () = if publication_kind.publication_stock = 0n then
    failwith "Sorry, we dont have any stock of this publication."
  in

 //Update our `publication_storage` stock levels.
  let publication_storage = Map.update
    publication_kind_index
    (Some { publication_kind with publication_stock = abs (publication_kind.publication_stock - 1n) })
    publication_storage
  in

  let tr : transfer = {
    from_ = Tezos.self_address;
    txs = [ {
      to_ = Tezos.sender;
      publication_id = abs (publication_kind.publication_stock - 1n);
      amount = 1n;
    } ];
  } 
  in

  // Transfer FA2 functionality
  let entrypoint : transfer list contract = 
    match ( Tezos.get_entrypoint_opt "%transfer" publication_kind.publication_address : transfer list contract option ) with
    | None -> ( failwith "Invalid external token contract" : transfer list contract )
    | Some e -> e
  in
 
  let fa2_operation : operation =
    Tezos.transaction [tr] 0tez entrypoint
  in

  // Payout to the Publishers address.
  let receiver : unit contract =
    match (Tezos.get_contract_opt publisher_address : unit contract option) with
    | Some (contract) -> contract
    | None -> (failwith ("Not a contract") : (unit contract))
  in
 
  let payout_operation : operation = 
    Tezos.transaction unit amount receiver 
  in

 ([fa2_operation ; payout_operation], publication_storage)
