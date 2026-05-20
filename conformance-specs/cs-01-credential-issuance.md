# WE BUILD - Conformance Specification:  Credential Issuance

Version 1.0

Table Of Contents

- [WE BUILD - Conformance Specification:  Credential Issuance](#we-build---conformance-specification--credential-issuance)
- [1. Introduction](#1-introduction)
- [2. Scope](#2-scope)
- [3. Normative Language](#3-normative-language)
- [4. Roles and Components](#4-roles-and-components)
- [5. Protocol Overview](#5-protocol-overview)
- [6. High-level Flows](#6-high-level-flows)
  - [6.1 Wallet-initiated Issuance Flow](#61-wallet-initiated-issuance-flow)
    - [6.1.1 Configuration and discovery](#611-configuration-and-discovery)
    - [6.1.2 User selects credential](#612-user-selects-credential)
    - [6.1.3 Pushed Authorisation Request (PAR)](#613-pushed-authorisation-request-par)
    - [6.1.4 User authorisation](#614-user-authorisation)
    - [6.1.5 Token request](#615-token-request)
    - [6.1.6 Credential request](#616-credential-request)
    - [6.1.7 Storage](#617-storage)
  - [6.2 Issuer-initiated Issuance via Credential Offer](#62-issuer-initiated-issuance-via-credential-offer)
    - [6.2.1 Issuance decision](#621-issuance-decision)
    - [6.2.2 Credential Offer creation](#622-credential-offer-creation)
    - [6.2.3 Credential Offer delivery and Wallet invocation](#623-credential-offer-delivery-and-wallet-invocation)
    - [6.2.4 WU processes the offer](#624-wu-processes-the-offer)
    - [6.2.5 Authorisation and token exchange](#625-authorisation-and-token-exchange)
    - [6.2.6 Credential Request](#626-credential-request)
    - [6.2.7 Deferred Credential Request](#627-deferred-credential-request)
  - [6.3 Deferred Credential Request](#63-deferred-credential-request)
- [7. Normative Requirements](#7-normative-requirements)
  - [7.1 Common requirements (WU and Issuer)](#71-common-requirements-wu-and-issuer)
  - [7.2 Credential Offer](#72-credential-offer)
  - [7.3 Authorisation Endpoint and PAR](#73-authorisation-endpoint-and-par)
  - [7.4 Token Endpoint and Wallet Attestation](#74-token-endpoint-and-wallet-attestation)
  - [7.5 Credential Endpoint](#75-credential-endpoint)
  - [7.6 Deferred Credential Endpoint](#76-deferred-credential-endpoint)
  - [7.7 Server Metadata](#77-server-metadata)
- [8. Interface Definitions](#8-interface-definitions)
  - [8.1 WU Invocation Interface](#81-wu-invocation-interface)
  - [8.2 Credential Offer Interface](#82-credential-offer-interface)
  - [8.3 PAR Endpoint](#83-par-endpoint)
  - [8.4 Token Endpoint](#84-token-endpoint)
  - [8.5 Credential Endpoint](#85-credential-endpoint)
  - [8.7 Deferred Credential Endpoint](#87-deferred-credential-endpoint)
  - [8.8 Metadata Endpoints](#88-metadata-endpoints)
- [9. Conformance](#9-conformance)
- [References](#references)


# 1. Introduction

This document defines the **WE BUILD Consortium Conformance Specification (CS)** for high assurance credential issuance based on the decision recorded in WE BUILD [ADR Base Protocols](https://github.com/webuild-consortium/architecture/blob/main/adr/base-protocols.md).

It profiles:

* OpenID for Verifiable Credential Issuance (OpenID4VCI) v1.0 [1]
* The OpenID4VC High Assurance Interoperability Profile (HAIP) v1.0 [2]

The aim is to ensure that Wallet Units and Credential Issuers within the WE BUILD ecosystem interoperate consistently for the **issuance of SD-JWT-VC credentials** [3] with high security and privacy.

This specification focuses **only on issuance**. Presentation, verification of requirements, and trust management are out of scope and covered in separate documents. The document is used to build the WE BUILD Interoperability Test Bed Plus (ITB+) [4].


# 2. Scope

This specification defines:

* A profile of OpenID4VCI for issuing SD-JWT-VC credentials
* Requirements for:
    * Wallets that receive credentials
    * Credential Issuers and their Authorisation Servers
* Support for:
    * Wallet-initiated issuance
    * Issuer-initiated issuance via Credential Offer

This document describes:

* Protocol flows for high assurance issuance
* Interfaces and endpoints, including Wallet invocation, Credential Offer, Pushed Authorisation Requests (PAR), Token Endpoint, Credential Endpoint and metadata

# 3. Normative Language

The keywords MUST, MUST NOT, REQUIRED, SHALL, SHOULD, SHOULD NOT, RECOMMENDED, MAY and OPTIONAL are to be interpreted as commonly used in technical specifications.

# 4. Roles and Components

This specification uses the following roles:

* **Wallet Unit (WU):** A client application or component acting on behalf of the Holder to obtain and store Verifiable Credentials.
* **Holder:** The subject or representative of the subject who controls the Wallet Unit.
* **Attestation Provider (Issuer):** The entity that decides to issue Verifiable Credentials and controls issuance policy.
* **Authorisation Server (AS):** The OAuth 2.0 and OpenID provider responsible for authenticating the user and issuing tokens for the Issuer. It may be co-located with the Issuer.


# 5. Protocol Overview

The WE BUILD issuance profile is based on the OAuth 2.0 Authorisation Code Flow with the following mandatory features:

* Authorisation Code Flow for all issuance interactions
* OpenID4VCI SD-JWT-VC credential format profile, Credential Format identifier `dc+sd-jwt` (See NOTE **CS01_01**)
* Sender-constrained access tokens using Demonstration of Proof of Possession at the Application Layer (DPoP) [5]. Wallets MUST handle the `DPoP-Nonce` HTTP response header from the Credential Issuer's Nonce Endpoint and from other endpoints
* DPoP MUST be applied at the PAR, Token, Credential and Deferred Credential Endpoints
* PKCE with `S256` code challenge method (RFC 7636)
* Pushed Authorisation Requests (PAR, RFC 9126) for all authorisation requests
* OAuth 2.0 Attestation-Based Client Authentication (Wallet Unit Attestation, WUA) [6] for client authentication, in the format defined in Appendix E of OpenID4VCI
* RFC 9207 OAuth 2.0 Authorization Server Issuer Identification: the AS MUST include the `iss` value in the Authorization Response and Wallets MUST validate it

> [!NOTE]
> WUA and DPoP are complementary: WUA provides client authentication (proving *which* client is calling), while DPoP provides sender-constraining at the resource (proving *the same client* that obtained the token is the one using it). WUA does not replace DPoP.

Issuance can be:

* **Wallet-initiated**: the Holder starts from the WU and selects a credential type
* **Issuer-initiated**: the Issuer provides a **Credential Offer** that the WU consumes

Both modes are required in this profile.

> [!NOTE]
> CS01_01: ISO18013-5 and ISO18013-7 will be supported in subsequent versions, based on use-case requirements.

# 6. High-level Flows

This section presents the flows as text-based sequence descriptions.

## 6.1 Wallet-initiated Issuance Flow

**Actors**: Holder, WU, Issuer (AS and Credential Issuer).


### 6.1.1 Configuration and discovery

1. The WU retrieves Issuer metadata, which includes:
    * OAuth and OpenID configuration
    * Credential Issuer metadata
    * Mapping between credential types and `scope` values

### 6.1.2 User selects credential

1. The Holder chooses a credential type, for example, a PID, QEAA or business credential.
2. The WU selects the appropriate Issuer and the corresponding `scope` value.


### 6.1.3 Pushed Authorisation Request (PAR)

1. The WU constructs an authorisation request containing, at a minimum:
        * `client_id`
        * `scope` identifying the credential type
        * `code_challenge` using PKCE `S256`
        * `redirect_uri`
        * `response_type=code`
        * `state`
        * `nonce`
1. The WU sends this request to the Issuer’s PAR endpoint, with client authentication bound to the WUA. \

2. The PAR endpoint returns a `request_uri` and a validity period.


### 6.1.4 User authorisation

1. The WU directs the Holder’s user-agent to the Authorisation Endpoint with the `request_uri` obtained from PAR.
2. The Holder authenticates to the AS in accordance with the Issuer’s policy.
3. The Holder consents to the issuance of the requested credential.
4. The AS redirects back to the WU with an authorisation `code`, `state` and the `iss` value identifying the Authorization Server (RFC 9207). The WU MUST validate `iss`.

### 6.1.5 Token request

1. The WU sends a token request to the Token Endpoint, including:
        * `grant_type=authorization_code`
        * `code`
        * `redirect_uri`
        * `code_verifier` matching the earlier `code_challenge`
        * client authentication using WUA
2. The Token Endpoint validates the request and returns:
        * sender-constrained `access_token`
        * optional `refresh_token` for credential refresh

### 6.1.6 Credential request

1. The WU sends a request to the Credential Endpoint containing:
        * `Authorization: Bearer {access_token}`
        * the requested credential format (SD-JWT-VC / mdoc)
        * a `proof` object using the `JWT` proof type that binds the credential to the WU’s subject key

2. The Credential Issuer validates:
        * the access token and its sender-constraining mechanism
        * the proof JWT
        * issuance policy

3. The Issuer returns the issued SD-JWT-VC.


### 6.1.7 Storage

1. The WU validates the credential signature and Issuer binding.
2. The WU stores the credential under the Holder's control.


## 6.2 Issuer-initiated Issuance via Credential Offer

**Actors**: Holder, WU, Issuer.

### 6.2.1 Issuance decision

1. The Holder interacts with the Issuer, for example, digital onboarding, customer due diligence or contract signing.

2. Following successful internal checks, the Issuer decides to issue one or more credentials.

### 6.2.2 Credential Offer creation

1. The Issuer constructs a **Credential Offer object** that includes:
   * the `credential_issuer` identifier
   * grant information for the `authorization_code` grant type
   * one or more identifiers for supported credential types
   * for each type, a `scope` value that maps unambiguously to that credential type

### 6.2.3 Credential Offer delivery and Wallet invocation

1.	The Issuer delivers the offer to the Holder by one of:

	* displaying a QR code that encodes a Wallet invocation URL using the `haip-vci://` custom scheme (HAIP v1.0 §4.2 / Appendix A.1.1)
   * sending a link using the same scheme to a device with a registered WU
   * implementations MAY additionally support claimed `https` scheme URIs or other ecosystem-agreed schemes

2.	Both same-device and cross-device delivery methods MUST be supported.

### 6.2.4 WU processes the offer

1.	The WU is invoked via `haip-vci://` and receives the Credential Offer.

2.	The WU parses the offer and determines:
   * Issuer base URL
 * offered credential types
 * associated `scope` values used for authorisation 

3. The WU displays the offer to the Holder and asks for confirmation to proceed.


### 6.2.5 Authorisation and token exchange

1. The WU initiates the Authorisation Code Flow using PAR as defined in Section 6.1, reusing `scope` values from the offer.

2. The remainder of the flow, including authorisation, token request, credential request and storage, is identical to the Wallet-initiated flow.

### 6.2.6 Credential Request

The Wallet sends a Credential Request (or Batch Request) to the Credential Endpoint, including:

* `Authorization: Bearer {access_token}`
* SD‑JWT‑VC configuration
* `proof` object


### 6.2.7 Deferred Credential Request

If issuance cannot be completed immediately, the Issuer returns:

* `transaction_id`
* optional `interval` (retry hint)

Batch requests may contain both immediate and deferred items.

## 6.3 Deferred Credential Request

Deferred issuance applies to both wallet-initiated and issuer-initiated flows.

When the Credential Issuer cannot immediately produce one or more credentials:

1. The Issuer returns:
    * `transaction_id`
    * optional `interval` (retry hint) \

2. The WU MUST store the `transaction_id` associated with the pending credential(s). \

3. The WU periodically retries the Deferred Credential Endpoint with the `transaction_id` until:
    * the credential is successfully issued, or
    * the Issuer signals an unrecoverable error. \

4. Batch requests may contain a mix of immediate and deferred items. Each deferred item receives its own `transaction_id` and can be polled independently.

# 7. Normative Requirements

This section summarises the mandatory requirements for WE BUILD implementations.

## 7.1 Common requirements (WU and Issuer)

Both WU and Issuer **MUST**:

1. Support the Authorisation Code Flow as the only flow for credential issuance.
2. Support the SD-JWT-VC credential format with Credential Format identifier `dc+sd-jwt`.
3. Support DPoP [5] as the sender-constraining mechanism for access tokens, including `DPoP-Nonce` rotation.
4. Apply DPoP at the PAR, Token, Credential, Nonce and Deferred Credential Endpoints.
5. Support PKCE with the `S256` code challenge method (RFC 7636) for all authorisation requests.
6. Support Wallet-initiated and Issuer-initiated issuance.
7. Support OAuth 2.0 Attestation-Based Client Authentication (WUA) [6] using the Wallet Attestation format in Appendix E of OpenID4VCI as the client authentication mechanism at the PAR and Token Endpoints.
8. Support RFC 9207 Authorization Server Issuer Identification: the AS MUST include `iss` in the Authorization Response and the WU MUST validate it.

## 7.2 Credential Offer

Issuers **MUST**:

1. Support the grant type `authorization_code` in Credential Offers, aligned with OpenID4VCI.
2. Include a `scope` value for each offered credential type so that the Wallet can identify the correct type and use the same value in the authorisation request.
3. Support both same-device and cross-device sending of Credential Offers.
4. Support Wallet invocation via the `haip-vci://` custom URL scheme as defined in HAIP v1.0 §4.2 and Appendix A.1.1.

WUs **MUST**:

1. Be able to parse a Credential Offer that uses `authorization_code` as the grant type.
2. Use the `scope` value (and/or `credential_configuration_ids`) from the offer in the authorisation request.
3. Register for and accept invocation via the `haip-vci://` custom URL scheme. Implementations MAY also accept claimed `https` URIs as agreed by the ecosystem.

## 7.3 Authorisation Endpoint and PAR

Issuers **MUST**:

1. Require Pushed Authorisation Requests (PAR) for all authorisation requests. Direct front-channel authorisation requests without PAR MUST NOT be used.
2. Ensure that the Wallet authenticates at the PAR endpoint using the same method as used for client authentication at the Token Endpoint.

WUs **MUST**:

1. Use PAR for all authorisation requests.
2. Use the `scope` parameter to indicate the credential type to be issued. Each `scope` value MUST map to a specific credential type that is known from Issuer metadata or from the Credential Offer.
3. Ensure that the `client_id` in the PAR request matches the `sub` claim in the Wallet attestation JWT used for client authentication.

## 7.4 Token Endpoint, Wallet Attestation and DPoP

WUs **MUST**:

1. Perform client authentication at the Token Endpoint and at PAR using the Wallet Attestation format defined in Appendix E of OpenID4VCI v1.0 (per HAIP v1.0 §4.4.1).
2. Include the public key certificate, and optionally a trust certificate chain excluding the trust anchor, used to validate the signature on the Wallet Attestation in the `x5c` JOSE header of the Client Attestation JWT.
3. Ensure the `sub` claim in the Wallet Attestation is a value **shared by all Wallet instances of the same Wallet implementation type** (per HAIP v1.0 §4.4.1 and OpenID4VCI v1.0 §15.4.4). The `sub` MUST NOT be a unique per-instance identifier.
4. Where applicable, ensure the `client_id` in the PAR request equals the `sub` value in the Client Attestation JWT.
5. Send a DPoP proof JWT in the `DPoP` HTTP header on the Token Request, with `htm`, `htu`, `iat`, `jti` claims as defined in RFC 9449 [5].
6. Handle the `DPoP-Nonce` HTTP response header from the Authorization Server, the Credential Issuer Nonce Endpoint, and the Credential Endpoint, replaying the supplied nonce in subsequent DPoP proofs.
7. Use the same DPoP key on subsequent Credential and Deferred Credential Requests; the Issuer binds the issued `access_token` to that key (`token_type=DPoP`).

Wallet Attestations MUST NOT be reused across different Issuers and MUST NOT introduce a unique identifier specific to a single Wallet instance (HAIP v1.0 §4.4.1).

Issuers **MUST**:

1. Validate the DPoP proof on every Token, Credential and Deferred Credential Request and reject mismatched key bindings.
2. Issue access tokens with `token_type=DPoP` and bind them via the `cnf.jkt` claim.
3. Issue and rotate DPoP nonces via the `DPoP-Nonce` HTTP response header on Token, Credential and Nonce Endpoint responses.
4. Return `authorization_details` in the Token Response (per OpenID4VCI v1.0 §7.3) containing one or more `credential_identifier` values when the Issuer needs to differentiate between multiple instances of the same credential type for the same Holder (for example, multiple credentials of the same type issued with different data). Wallets **MUST** use the returned `credential_identifier` on the corresponding Credential Request.

Issuers **SHOULD**:

1. Support refresh tokens for credential refresh, following OpenID4VCI guidance on refresh usage and lifetime.

## 7.5 Credential Endpoint

Issuers **MUST**:

1. Support the `jwt` proof type with the `key_attestation` parameter AND the `attestation` proof type in the Credential Endpoint (HAIP v1.0 §4.5.1).
2. Support the SD-JWT-VC credential format with Credential Format identifier `dc+sd-jwt` and validate the proof binding between the Wallet subject and credential.
3. Validate the DPoP proof on every Credential Request and ensure the access token's `cnf.jkt` matches the DPoP key thumbprint.
4. Expose a `nonce_endpoint` in Credential Issuer Metadata whenever any supported Credential Configuration declares `cryptographic_binding_methods_supported` (HAIP v1.0 §4.1).
5. Validate the Key Attestation per OpenID4VCI Appendix D: the public key used to validate the Key Attestation MUST be included in the `x5c` JOSE header; the trust anchor certificate MUST NOT be included in `x5c`.
6. When `authorization_details` with `credential_identifier` was returned at the Token Endpoint, require the Wallet to identify the requested credential by `credential_identifier` rather than by `format`/`credential_configuration_id` alone.
7. When batch issuance is used and `cryptographic_binding_methods_supported` is set, all public keys in the Credential Request SHOULD be attested within a single Key Attestation (HAIP v1.0 §4.5.1).

Wallets **MUST**:

1. Send a proof JWT containing the Key Attestation in the `jwt` proof type's `key_attestation` parameter, or use the dedicated `attestation` proof type, in the format defined in OpenID4VCI Appendix D (HAIP v1.0 §4.5.1).
2. Include the `Authorization: DPoP {access_token}` header and a matching `DPoP` proof header on every Credential and Deferred Credential Request.
3. Replay the latest `DPoP-Nonce` value received from the Credential Issuer in subsequent DPoP proofs.
4. When the Token Response contained `authorization_details` with `credential_identifier`, send the matching `credential_identifier` in the Credential Request.
5. Validate the returned SD-JWT-VC, including:
    * signature, anchored via X.509 (issuer signing certificate trust chain in `x5c` JOSE header; trust anchor not in `x5c`) per HAIP v1.0 §6.1.1
    * Issuer identifier
    * key binding (KB-JWT)
    * status information using `status_list` (Token Status List, draft-ietf-oauth-status-list-14)

## 7.6 Deferred Credential Endpoint

Issuers **MUST**:

* Support a `deferred_credential_endpoint`.
* Return a `transaction_id` (as defined in OpenID4VCI v1.0 §8.3) when issuance is delayed.
* Validate `transaction_id` and ensure proper lifetime and binding to the issuance session.
* Publish endpoint in metadata.

Issuers **SHOULD**:

* Provide clear retry guidance via the `interval` parameter.
* Return explicit errors when the `transaction_id` is expired or the credential cannot be issued.

Wallets **MUST**:

* Recognise deferred responses and store the `transaction_id`.
* Call the Deferred Credential Endpoint with the `transaction_id` until the credential is ready or the transaction ends.
* Distinguish *pending* vs *failed* issuance in UI.

Wallets **SHOULD**:

* Apply poll intervals/back‑off.
* Allow users to stop polling.


## 7.7 Server Metadata

Issuers **MUST** publish metadata that includes:

1. OAuth 2.0 Authorization Server Metadata (RFC 8414), including Authorisation, Token, PAR, Nonce and Deferred Credential endpoints.
2. Credential Issuer metadata (`/.well-known/openid-credential-issuer`) that describes:
    * all supported credential types
    * a mapping from each credential type to a unique `scope` value
    * `cryptographic_binding_methods_supported` for each Credential Configuration that requires holder binding
    * `nonce_endpoint` when any supported Credential Configuration sets `cryptographic_binding_methods_supported` (HAIP v1.0 §4.1)
    * `batch_credential_issuance` parameter indicating whether batch issuance is supported (HAIP v1.0 §4)
3. Signed Credential Issuer Metadata (`signed_metadata` JWT) as specified in OpenID4VCI v1.0 §11.2.3 and required by HAIP v1.0 §4.1 when Ecosystem policies require Issuer authentication beyond TLS. The signing certificate MUST be included in the `x5c` JOSE header per RFC 7515. The X.509 certificate of the trust anchor MUST NOT be included in `x5c`.

Wallets **MUST**:

1. Retrieve and process Issuer metadata, including the mapping from credential type to `scope`.
2. When `signed_metadata` is present, validate the signature using X.509 key resolution from the `x5c` JOSE header and reject unsigned or untrusted metadata.
3. Use the metadata when constructing authorisation requests and when interpreting Credential Offers.

# 8. Interface Definitions

This section defines the logical interfaces for conformance. Exact URL paths are deployment-specific and discovered through metadata.


## 8.1 WU Invocation Interface

* **Direction**: Issuer to Wallet
* **Transport**: `haip-vci://` custom URL scheme (HAIP v1.0 §4.2 / Appendix A.1.1), optional QR code
* **Requirement**:
	* Wallets and Issuers MUST support the `haip-vci://` scheme in both same-device and cross-device scenarios
	* Implementations MAY additionally support claimed `https` scheme URIs

**Example (illustrative)**

```
haip-vci://?credential_offer_uri=https://issuer.example.org/offer/abc
```

The concrete parameters and encoding follow HAIP v1.0 and OpenID4VCI v1.0 Credential Offer rules.

## 8.2 Credential Offer Interface

* **Direction**: Issuer to WU

The **Credential Offer object** MUST contain at least:

* `credential_issuer`: base URL identifying the Issuer
* `grants`: object that includes support for `authorization_code`
* For each credential type:
    * a credential type identifier
    * the associated `scope` value

The exact JSON structure MUST comply with OpenID4VCI Credential Offer definitions.

## 8.3 PAR Endpoint

* **Direction**: Wallet to Issuer (AS)
* **Method**: `POST`

**Request (logical fields)**

* `client_id`
* `scope` and/or `authorization_details`
* `code_challenge` using PKCE `S256`
* `code_challenge_method=S256`
* `redirect_uri`
* `response_type=code`
* `state`, `nonce`
* Client authentication: `client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-client-attestation` and `client_assertion` carrying the WUA [6]
* `DPoP` HTTP header carrying the DPoP proof JWT [5]

**Response**

* `request_uri`
* `expires_in`

All PAR requests MUST be client-authenticated using WUA and DPoP-bound according to Section 7.4.


## 8.4 Token Endpoint

* **Direction**: WU to Issuer (AS)
* **Method**: `POST`

**Request (logical fields)**

* `grant_type=authorization_code`
* `code`
* `redirect_uri`
* `code_verifier`
* Client authentication using WUA: `client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-client-attestation` and `client_assertion`
* `DPoP` HTTP header carrying the DPoP proof JWT bound to the Token Endpoint URL

**Response**

* `access_token` (DPoP-bound, `cnf.jkt` set)
* `token_type=DPoP`
* `expires_in`
* `authorization_details` (per OpenID4VCI v1.0) MAY include one or more `credential_identifier` values when the Holder is entitled to multiple credentials of the same type with different data
* optional `refresh_token`

## 8.5 Credential Endpoint

* **Direction**: WU to Issuer
* **Method**: `POST`
**Request (logical fields)**

* HTTP headers:
    * `Authorization: DPoP {access_token}`
    * `DPoP: {dpop-proof-jwt}` bound to this endpoint
* Body:
    * `credential_identifier` (REQUIRED when returned by the Token Endpoint in `authorization_details`) **OR** `credential_configuration_id` / `format` (for example, `dc+sd-jwt`) when no `authorization_details` was returned
    * `proof` object with:
        * `proof_type="jwt"`
        * `jwt` containing proof claims

**Response**
* SD-JWT-VC credential and any associated metadata defined by the OpenID4VCI SD-JWT-VC profile

## 8.7 Deferred Credential Endpoint

**Direction:** WU → Issuer \
**Method:** POST
**Request (logical fields)**

* HTTP headers:
    * `Authorization: DPoP {access_token}`
    * `DPoP: {dpop-proof-jwt}` bound to this endpoint
    * `Content-Type: application/json`
* Body parameters:
    * `transaction_id`

**Response**

A Deferred Credential Response MAY either provide the issued credentials or indicate that issuance is still pending.


If credential issuance is complete:

* The response MUST contain the **credentials** parameter
* HTTP status code MUST be **200 (OK)**.

If credential issuance is still pending

* The response MUST contain:
    * **transaction_id**: MUST match the request.
    * **interval:** recommended waiting time before retrying.
* HTTP status code MUST be **202 (Accepted)**.

**Error Response**
If the Deferred Credential Request is invalid, the Issuer returns an error response. 

* <code>invalid_transaction_id:</code> Indicates that the `transaction_id` was not issued by the Credential Issuer or has already been used.
* If the Credential Issuer can no longer issue the credential(s), it returns `credential_request_denied`. The WU stops retrying for the given `transaction_id`.

## 8.8 Metadata Endpoints

Issuers **MUST** publish:

* OAuth 2.0 Authorization Server Metadata (RFC 8414)
* Credential Issuer metadata document at `/.well-known/openid-credential-issuer`, including `signed_metadata` per HAIP v1.0 §4.1 (with `x5c` JOSE header; trust anchor not in `x5c`)

The latter MUST include:
* supported credential types
* for each type, the associated `scope` value
* `cryptographic_binding_methods_supported` where holder binding is required
* `nonce_endpoint` when any Credential Configuration requires holder binding (HAIP v1.0 §4.1)
* the `deferred_credential_endpoint` when deferred issuance is supported
* the `batch_credential_issuance` parameter when batch issuance is supported

Wallets **MUST** validate `signed_metadata` when present and reject unsigned or untrusted metadata.

WU uses these documents for dynamic configuration.

# 9. Conformance

An implementation **conforms to this specification as a Wallet Provider** if it:

1. Implements the WU requirements in Sections 6 and 7.
2. Supports the interfaces defined for WU behaviour in Section 8.
3. Uses SD-JWT-VC and OpenID4VCI as profiled by the OpenID4VC High Assurance Interoperability Profile Implementer’s Draft, Section 4.

An implementation **conforms to this specification as an Issuer** if it:

1. Implements the Issuer requirements in Sections 6 and 7.
2. Publishes server metadata, including type to `scope` mappings.
3. Provides the PAR, Token, Credential and WU invocation interfaces described in Section 8.

Profiles may define additional constraints for specific WE BUILD credential types, such as PID, QEAA, or business credentials. Such profiles MUST NOT relax the mandatory requirements in this document. The specific issuance will be taken into a separate CS.

# References

[1]	OpenID Foundation (2025) OpenID for Verifiable Credential Issuance 1.0. OpenID Foundation. Available at: [https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html](https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html) (Accessed: 20 May 2026).

[2]	OpenID Foundation (2026) OpenID4VC High Assurance Interoperability Profile v1.0. OpenID Foundation. Available at: [https://openid.net/specs/openid4vc-high-assurance-interoperability-profile-1_0.html](https://openid.net/specs/openid4vc-high-assurance-interoperability-profile-1_0.html) (Accessed: 20 May 2026).

[3] IETF (2025) SD‑JWT‑based Verifiable Credentials (SD-JWT VC), draft-ietf-oauth-sd-jwt-vc-13. IETF, 6 November. Available at: [https://datatracker.ietf.org/doc/html/draft-ietf-oauth-sd-jwt-vc-13](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-sd-jwt-vc-13) (Accessed: 20 May 2026).

[4]	WE BUILD (2025) Interoperability Test Bed - Reference Specification, 12 November, Available at: [https://github.com/webuild-consortium/wp4-interop-test-bed/blob/main/docs/reference-implementation-interoperability-test-bed.md](https://github.com/webuild-consortium/wp4-interop-test-bed/blob/main/docs/reference-implementation-interoperability-test-bed.md) (Accessed: 24 November 2025).

[5]	IETF (2023) RFC 9449 - OAuth 2.0 Demonstrating Proof of Possession (DPoP). Available at: [https://www.rfc-editor.org/rfc/rfc9449.html](https://www.rfc-editor.org/rfc/rfc9449.html) (Accessed: 20 May 2026).

[6]	IETF (2026) OAuth 2.0 Attestation-Based Client Authentication, draft-ietf-oauth-attestation-based-client-auth-08. Available at: [https://www.ietf.org/archive/id/draft-ietf-oauth-attestation-based-client-auth-08.html](https://www.ietf.org/archive/id/draft-ietf-oauth-attestation-based-client-auth-08.html) (Accessed: 20 May 2026).

[7]	IETF (2022) RFC 9207 - OAuth 2.0 Authorization Server Issuer Identification. Available at: [https://www.rfc-editor.org/rfc/rfc9207.html](https://www.rfc-editor.org/rfc/rfc9207.html) (Accessed: 20 May 2026).

[8]	IETF (2021) RFC 9126 - OAuth 2.0 Pushed Authorization Requests. Available at: [https://www.rfc-editor.org/rfc/rfc9126.html](https://www.rfc-editor.org/rfc/rfc9126.html) (Accessed: 20 May 2026).

[9]	IETF (2025) Token Status List (TSL), draft-ietf-oauth-status-list-14. Available at: [https://datatracker.ietf.org/doc/html/draft-ietf-oauth-status-list-14](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-status-list-14) (Accessed: 20 May 2026).
