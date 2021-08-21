# Book Store front

A Smart contract that allows the owner to sell NFT's of books they have published on the Tezos protocol providing;

 - They currently have the publication in stock to do so.
 - The NFT publication has not been set to restricted.
	 - NFT Publication listings can be restricted by setting `publication_limited` to `true`
 - The offered Tozes is more than or equal to the cost of the published NFT.
	 - Any value sent over the asking price will be provided as a tip and not returned. 

# Storage
You can set up the storage for the smart contract  by  populating it with the details of published NFT's you are selling -- For example;
```Map.literal [ 
 (0n, { 
   publication_stock = 100n ; 
   publication_address = ("Address of publication NFT" : address); 
   publication_price = 20mutez;
   publication_restricted = false;
   publication_title = "Mmmmm Tezos - Recipes & Ideas.";
 }); 
 (1n, { 
   publication_stock = 200n ; 
   publication_address = ("Address of publication NFT" : address); 
   publication_price = 10mutez;
   publication_restricted = true;
   publication_title = "Mmmmm Tezos - Now for pudding!"
 })
]
```
