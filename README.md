# Smart-Contract-Presale

This SC is a simple Presale contract which allows investors to buy defined package of aMTN (at a specific price). <br>
Investors receive 50% of the aMTN right away, and the rest is vested during 3 days starting at the time defined by the owner. 

The presale starts at startTime and ends at endTime. 

After the end of the vesting, the investor can withdraw his 50% left from the contract.

## Walktrough : 

<ol>
  <li>Deploy of the SC (with payees and shares)</li>
  <li>Set StartTime of the presale (Unix timestamp)</li>
  <li>Set time vesting (Unix timestamp)</li>
  <li>Add to Whitelist the investors</li>
  <li>Investors buy tokens, and receive 50% of aMTN right away</li>
  <li>Vesting has ended => Investors can withdraw the rest of the tokens</li>  
</ol>


