# How the Wallet Interacts with Services

## Our Shared Design Principles
Modularity, standardization, versioning.

## High-Level Flows
- Credential issuance
- Presentation & verification
- Revocation and status checking

### General PID issuing process
Todo: EUDI: ARF
EBW: the issuing we do
This chapter describes the general **WE BUILD PID/EBWOID issuing process** in a sequence diagram.
Todo: Mention ETSI standardization: ETSI TS 119 472-3 for (Q)EAA and PID issuance. ETSI TS 119 476-3 will standardize WUA and WIA.

### Examples for Wallet and PID Lifecycle in Germany
This chapter shows examples from the German EUDI Wallet in sequence diagrams for

1) [Wallet Activation](https://gitlab.opencode.de/bmi/eudi-wallet/wallet-development-documentation-public/-/blob/main/doc/architecture-concept/flows/00-wallet-activation.md)
2) [Wallet Registration](https://gitlab.opencode.de/bmi/eudi-wallet/wallet-development-documentation-public/-/blob/main/doc/architecture-concept/flows/01-wallet-registration.md)
3) [PID Issuance](https://gitlab.opencode.de/bmi/eudi-wallet/wallet-development-documentation-public/-/blob/main/doc/architecture-concept/flows/21-pid-issuance.md)

There are more diagrams on [Wallet Development Documentation](https://gitlab.opencode.de/bmi/eudi-wallet/wallet-development-documentation-public/-/blob/main/doc/architecture-concept/04-data-flows.md?ref_type=heads)
##  The Technical Languages We Use 
List of integration points that will be formalized in Conformance Specifications.

## Interaction Pattern: Attestation Issuance
To be authored by Group 6 (QTSP) and Group 7 (Wallets). Focuses on how use cases get data into the wallet (e.g., PID or QEAA) using protocols like OpenID4VCI (but no need to mention that part, stuff like that should be mainly in CS). 

## Interaction Pattern: Attestation Presentation (Receiving) 
To be authored by Architecture and Wallets. This is the "Receiving" flow for Relying Parties, detailing how they request and receive verified attributes under the user's sole control using OpenID4VP. 

## Signature and Seal Integration 
To be authored by Group 6 (QTSP). Explains the technical flows for wallet-centric and QTSP-centric (remote) signing/sealing, allowing individuals to sign on behalf of a company with full legal effect

## Secure communication channel
To be authored by the QTSP group in consultation with the Architecture and Wallets groups. Explains the technical flows for usage of the qualified electronic registered delivery service (QERDS).
