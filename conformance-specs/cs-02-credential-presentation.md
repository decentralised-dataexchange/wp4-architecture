# WE BUILD - Conformance Specification:  Credential Presentation

Version 1.2 / Draft
Date: 20 May 2026

**Authors / Contributors**: WP4 Architecture

* Lal Chandran, iGrant.io, Sweden
* Sander Dijkhuis, Cleverbase, Netherlands
* George J Padayatti, iGrant.io, Sweden
* Nikolaos Triantafyllou, University of Aegean, Greece
* Malin Norlander, Bolagsverket, Sweden

Table Of Contents

- [WE BUILD - Conformance Specification:  Credential Presentation](#we-build---conformance-specification--credential-presentation)
- [1. Introduction](#1-introduction)
- [2. Scope](#2-scope)
- [3. Normative Language](#3-normative-language)
- [4. Roles and Components](#4-roles-and-components)
- [5. Protocol Overview](#5-protocol-overview)
- [6. High-level Flows](#6-high-level-flows)
  - [6.1 Same-device Presentation Flow](#61-same-device-presentation-flow)
    - [6.1.1 Presentation Request Creation](#611-presentation-request-creation)
    - [6.1.2 WU Invocation](#612-wu-invocation)
    - [6.1.3 WU Validation](#613-wu-validation)
    - [6.1.4 Holder Consent](#614-holder-consent)
    - [6.1.5 Presentation Generation](#615-presentation-generation)
    - [6.1.6 Presentation Submission](#616-presentation-submission)
    - [6.1.7 Result Handling](#617-result-handling)
  - [6.2 Cross-device Presentation Flow](#62-cross-device-presentation-flow)
    - [6.2.1 Presentation Request Creation and Display](#621-presentation-request-creation-and-display)
    - [6.2.2 Wallet Unit Invocation via QR](#622-wallet-unit-invocation-via-qr)
    - [6.2.3 Wallet Validation](#623-wallet-validation)
    - [6.2.4 Holder Consent](#624-holder-consent)
    - [6.2.5 Presentation Generation](#625-presentation-generation)
    - [6.2.6 Presentation Submission](#626-presentation-submission)
    - [6.2.7 Result Handling](#627-result-handling)
- [7. Normative Requirements](#7-normative-requirements)
  - [7.1 Wallet Unit Requirements](#71-wallet-unit-requirements)
  - [7.2 Verifier Requirements](#72-verifier-requirements)
- [8. Interface Definitions](#8-interface-definitions)
  - [8.1 Wallet Invocation Interface](#81-wallet-invocation-interface)
  - [8.2 Presentation Request Object Interface](#82-presentation-request-object-interface)
  - [8.3 Presentation Response Endpoint](#83-presentation-response-endpoint)
  - [8.4 Verifier Metadata Interface](#84-verifier-metadata-interface)
- [9. Conformance](#9-conformance)
- [References](#references)

# 1. Introduction

This document defines the **WE BUILD Conformance Specification for Credential Presentation**, describing how Wallet Units (WU) and Verifiers interoperate using OpenID for Verifiable Presentations (OpenID4VP) 1.0 [1] in alignment with the OpenID4VC High Assurance Interoperability Profile (HAIP) v1.0 [2], based on the decision recorded in WE BUILD [ADR Base Protocols](https://github.com/webuild-consortium/architecture/blob/main/adr/base-protocols.md).

It specifies a high‑assurance presentation profile for use within the WE BUILD ecosystem, covering:

* Presentation request and response flows
* Interfaces between Wallets and Verifiers
* Security, privacy and interoperability requirements
* Support for SD‑JWT‑VC credentials [3]
* Same‑device and cross‑device invocation patterns

This document complements the WE BUILD Conformance Specification: Credential Issuance v1.0. The document is used to build the WE BUILD Interoperability Test Bed Plus (ITB+) [4].


# 2. Scope

This specification defines the conformance profile for high‑assurance credential presentation:

* Requirements for:
    * WUs that respond to presentation requests
    * Verifiers that initiate presentation requests
* Mandatory features:
    * OpenID4VP 1.0
    * HAIP ID‑1 Section 5 requirements
    * JWT‑based Presentation Proof
    * SD‑JWT‑VC selective disclosure (Credential Format identifier `dc+sd-jwt`)
    * Same‑device and cross‑device invocation
    * `haip-vp://` Wallet invocation (per HAIP §5.1) and W3C Digital Credentials API invocation (per HAIP §5.2)

# 3. Normative Language

The terms MUST, MUST NOT, SHOULD, SHOULD NOT, REQUIRED, RECOMMENDED, MAY and OPTIONAL are to be interpreted as described in RFC 2119.


# 4. Roles and Components

The role names defined in this specification (Wallet Unit, Holder, Verifier) are **OpenID4VP protocol roles**, not organisational or product roles. A single software product may implement more than one role at different times, and any given role may be fulfilled by software that also performs other functions (for example, a Business Wallet implementing both Holder and Verifier roles in different interactions). The requirements in this specification attach to the role, not to the product or organisation that implements it.

This specification uses the following roles:

* **Wallet Unit (WU):** A software component on the Holder's device acting on behalf of the Holder to obtain, store and present Verifiable Credentials.

> **NOTE_CSCP_OAUTH_CLIENT** In OpenID4VP terminology, the OAuth Client role is played by the Verifier (Relying Party), not by the Wallet Unit. References to `client_id` in this specification refer to the Verifier.
* **Holder:** The subject or representative of the subject who controls the Wallet Unit.
* **Verifier:** Entity requesting verifiable presentations, validating responses and making authorisation decisions.

# 5. Protocol Overview

The WE BUILD presentation profile is based on OpenID4VP with the following mandatory features defined by HAIP v1.0:

* Response Type: MUST be `vp_token`.
* JWT-Secured Authorisation Request (JAR) [RFC 9101]: All authorisation requests MUST be signed and conveyed via `request_uri`.
* Digital Credentials Query Language (DCQL): MUST be used for querying credentials. AKI-based Trusted Authority Query (`trusted_authorities` with `aki`) MUST be supported (HAIP v1.0 §5).
* Client Identifier Prefix: `x509_hash` MUST be used (HAIP v1.0 §5). The X.509 certificate of the trust anchor MUST NOT be included in the `x5c` JOSE header of the signed request. Other Client Identifier prefixes are out of scope for WE BUILD.
* Crypto Suites: ECDSA with P-256 (secp256r1) and SHA-256 (`ES256`) MUST be supported for signing.
* Response Encryption: For `response_mode` values `direct_post.jwt` and `dc_api.jwt`, the response MUST be encrypted using JWE with `alg=ECDH-ES` (P-256 key agreement). Verifiers MUST list both `A128GCM` and `A256GCM` in `encrypted_response_enc_values_supported`. Wallets MUST support `A128GCM` or `A256GCM` or both; if both are supported, Wallets SHOULD use `A256GCM`.
* Ephemeral Encryption Keys: Verifiers MUST supply ephemeral encryption public keys specific to each Authorization Request, passed via `client_metadata`.
* Holder Binding: Mandatory Key Binding JWT (KB-JWT) for SD-JWT VCs. (See **NOTE_CS02_01**)
* Credential Format identifiers: SD-JWT VC MUST use `dc+sd-jwt`. mdoc (when used) MUST use `mso_mdoc`.

High‑level steps:

1. Verifier creates Presentation Request (JAR-signed, `vp_token` response type)
2. Wallet is invoked via `haip-vp://` (same or cross device) or the W3C DC API
3. Wallet validates Presentation Request
4. Holder consents
5. Wallet generates Presentation Proof + Disclosures
6. Wallet submits Presentation Response (encrypted via `direct_post.jwt` or `dc_api.jwt`)
7. Verifier validates and returns redirect/result

***NOTE_CS02_01: ISO18013-5 and ISO18013-7 will be supported in subsequent versions based on use case requirements.***

***NOTE_CS02_DCAPI: HAIP §5.2 defines a separate invocation profile via the W3C Digital Credentials API. This CS covers both invocation modes side-by-side as required by HAIP v1.0; a follow-up CS may further profile DC API-specific RP/JS and OS-level details.***


# 6. High-level Flows

This chapter defines the presentation flows required by WE BUILD.

## 6.1 Same-device Presentation Flow

### 6.1.1 Presentation Request Creation

The Verifier prepares a JAR-signed Presentation Request Object containing:

* `response_type=vp_token`
* Verifier identifier (`client_id`) using the `x509_hash` prefix
* `response_mode=direct_post.jwt` (redirect flow) or `dc_api.jwt` (DC API flow)
* `client_metadata` carrying the per-request ephemeral encryption JWK and supported `alg`/`enc` (ECDH-ES, A128GCM/A256GCM)
* DCQL query specifying requested credential types and disclosure constraints, including `trusted_authorities` with `aki`
* Proof requirements (`nonce`)
* Expiry (`exp`)

The request MUST be integrity‑protected via JAR (RFC 9101). The trust anchor MUST NOT be included in the `x5c` JOSE header.

### 6.1.2 WU Invocation

The Verifier invokes the Wallet via the `haip-vp://` custom URL scheme (or, alternatively, the W3C Digital Credentials API for in-browser flows):

```
haip-vp://?client_id=x509_hash:<thumbprint>&request_uri=https://verifier.example.org/request/<id>
```

The Wallet fetches the signed Presentation Request Object from `request_uri`.

### 6.1.3 WU Validation

The WU MUST validate:

* Signature of Presentation Request
* Nonce freshness
* Audience matches Wallet
* Expiry validity
* Credential types and disclosure constraints
* Request integrity

Unsigned or invalid requests MUST be rejected.


### 6.1.4 Holder Consent

The WU MUST display:

* Verifier identity
* Requested credential types
* Requested attributes or claims
* Any selective disclosure details

Holder MUST explicitly consent.

### 6.1.5 Presentation Generation

Upon consent, the Wallet MUST generate:

* JWT‑based Presentation Proof
* Selective disclosures for SD‑JWT‑VC
* Binding between:
    * Presentation Proof and Wallet‑held key
    * Nonce
    * Audience


### 6.1.6 Presentation Submission

The Wallet MUST POST the Presentation Response to the Verifier's `response_uri`, encrypted as a JWE (`alg=ECDH-ES`, `enc=A128GCM` or `A256GCM`) under `response_mode=direct_post.jwt`, including:

* `vp_token` containing the Verifiable Presentation
* For SD‑JWT VC, the Credential Format identifier `dc+sd-jwt` (mdoc uses `mso_mdoc`)

The Verifier MUST respond with an HTTP body containing `redirect_uri`; the Wallet MUST follow that redirect (HAIP §5.1).


### 6.1.7 Result Handling

The Verifier MUST return:

* A success object if verification succeeded
* Error information when the presentation is invalid or incomplete

Wallet MUST correctly display the outcome to the Holder.


## 6.2 Cross-device Presentation Flow


### 6.2.1 Presentation Request Creation and Display

Verifier constructs the Presentation Request Object (as in 6.1.1) and encodes a `haip-vp://` URL in a QR code. The URL carries `client_id` (with `x509_hash` prefix) and `request_uri`.


### 6.2.2 Wallet Unit Invocation via QR

Holder scans the QR code. WU retrieves the Presentation Request Object (embedded or via `request_uri`).

### 6.2.3 Wallet Validation

The same validation rules as 6.1.3 apply.

### 6.2.4 Holder Consent

Same as 6.1.4.


### 6.2.5 Presentation Generation

Same as 6.1.5.

### 6.2.6 Presentation Submission

WU delivers the Presentation directly to the Verifier’s Presentation Response Endpoint (back channel). Redirection flow MAY be used if supported.

### 6.2.7 Result Handling

Verifier processes the Presentation and returns the outcome as in 6.1.7.


# 7. Normative Requirements

The requirements in 7.1 and 7.2 attach to the OpenID4VP **roles** of Wallet Unit and Verifier respectively, as defined in chapter 4, not to the products or organisations implementing them. A relying party deploying a multi-role software product (for example a Business Wallet) to implement the Verifier role is a normal and supported pattern; the obligations in 7.2 apply to the Verifier role inside that product.

## 7.1 Wallet Unit Requirements

Wallets MUST:

1. Support HAIP v1.0‑compliant OpenID4VP with response type `vp_token`.
2. Support the same‑device and cross‑device redirect flows (HAIP §5.1) and Wallet Invocation via the W3C Digital Credentials API or an equivalent platform API (HAIP §5.2).
3. Register for and accept Wallet invocation via the `haip-vp://` custom URL scheme (IANA-registered, HAIP Appendix A.1.2). Implementations MAY additionally support claimed `https` scheme URIs.
4. Reject any Wallet invocation URI that does not carry a valid `client_id` with the `x509_hash` prefix and a `request_uri` resolvable to the Verifier identified by that certificate.
5. Validate signed Presentation Requests (JAR, RFC 9101) using X.509 certificate-based key resolution; reject requests whose `x5c` JOSE header includes the trust anchor.
6. Use the `x509_hash` Client Identifier Prefix only. Other Client Identifier prefixes are out of scope for WE BUILD.
7. Use DCQL and support AKI-based `trusted_authorities` queries (HAIP §5).
8. Implement SD‑JWT‑VC selective disclosure with Credential Format identifier `dc+sd-jwt`; KB-JWT MUST always be present when the credential has cryptographic Holder binding.
9. Support JWE response encryption with `alg=ECDH-ES` (P-256 key agreement) and `enc=A128GCM` or `A256GCM` (or both). When both are supported, the Wallet SHOULD use `A256GCM`. This applies to `response_mode=direct_post.jwt` (redirect flow, HAIP §5.1) and `response_mode=dc_api.jwt` (DC API flow, HAIP §5.2).
10. Support unsigned, signed, and multi-signed Authorization Requests as defined in Appendices A.3.1 and A.3.2 of OpenID4VP, when the DC API is used (HAIP §5.2).
11. Provide transparent Holder consent.
12. Generate JWT‑based Presentation Proof and bind it to the Verifier's `nonce` and `audience`.
13. Submit Presentation Responses to the Verifier's `response_uri` (redirect flow) or via the DC API platform call, encrypted per item 9.
14. In the same-device redirect flow, follow the `redirect_uri` returned by the Verifier in the HTTP response to the Wallet's POST to `response_uri` (HAIP §5.1).

Wallets MUST NOT:

* Accept unsigned or invalid Presentation Requests
* Accept Client Identifier prefixes other than `x509_hash`
* Accept invocation URIs missing a resolvable `client_id` or `request_uri`
* Auto‑consent
* Add unsolicited claims

## 7.2 Verifier Requirements

Verifier obligations are listed below in two groups: per-transaction protocol behaviours, and deployment-time obligations. All items are normative MUSTs. The wallet's reciprocal duty for the same protocol step is referenced in parentheses.

**Verifiers MUST ensure, on every transaction, that:**

1. The Presentation Request Object is signed (JAR, RFC 9101) and conveyed by `request_uri`. The trust anchor certificate MUST NOT appear in the `x5c` JOSE header. (Wallet reciprocal: 7.1.5)
2. The Client Identifier uses the `x509_hash` prefix exclusively. (Wallet reciprocal: 7.1.6)
3. A fresh `nonce` is generated and included. (Wallet reciprocal: 7.1.12)
4. An ephemeral encryption public key, specific to this Authorization Request, is supplied via `client_metadata`. (Wallet reciprocal: 7.1.9)
5. For redirect-based flows (HAIP §5.1), `response_mode=direct_post.jwt` is used; for DC API flows (HAIP §5.2), `response_mode=dc_api.jwt` is used. In both cases the response is encrypted with `alg=ECDH-ES` and one of `A128GCM` / `A256GCM`.
6. In the same-device redirect flow, the HTTP response to the Wallet's POST to `response_uri` includes a `redirect_uri`; presentations from Wallets that do not follow the redirect, or whose redirect arrives in a different user session than the one initiating the request, MUST be rejected (HAIP §5.1).
7. All Presentation Responses are validated, including:
    * Signature of the Verifiable Presentation (KB-JWT of SD-JWT VC or `deviceSignature` for mdoc)
    * Credential authenticity via X.509 trust chain (HAIP §6.1.1)
    * Wallet Unit Attestation validity (per HAIP)
    * SD‑JWT‑VC disclosure integrity
    * Holder binding (KB-JWT)
    * Nonce and audience binding
    * Satisfaction of request constraints via DCQL

   (Wallet reciprocal: 7.1.7, 7.1.8, 7.1.12)

**Verifiers MUST, at deployment:**

8. Support same‑device and cross‑device invocation (HAIP §5.1) AND Wallet Invocation via the W3C Digital Credentials API or an equivalent platform API (HAIP §5.2). (Wallet reciprocal: 7.1.2)
9. Publish Verifier Metadata, including supported `vp_formats`, the response modes `direct_post.jwt` and `dc_api.jwt`, and both `A128GCM` and `A256GCM` in `encrypted_response_enc_values_supported`.
10. Use the `x509_hash` Client Identifier Prefix only.
11. Support at least one of unsigned, signed, or multi-signed Authorization Requests as defined in Appendices A.3.1 and A.3.2 of OpenID4VP for the DC API flow (HAIP §5.2). (Wallet reciprocal: 7.1.10)
12. Provide a Presentation Response Endpoint (`response_uri`). (Wallet reciprocal: 7.1.13)

Verifiers MUST NOT:

* Request unnecessary personal information
* Disable `nonce` validation
* Use any Client Identifier prefix other than `x509_hash`
* Issue invocation URIs that omit a resolvable `client_id` or `request_uri`

# 8. Interface Definitions

Interfaces in this chapter follow the structure from the Issuance Conformance Specification.

## 8.1 Wallet Invocation Interface

Direction: Verifier → Wallet \
Transport: `haip-vp://` custom scheme (HAIP v1.0 §5.1 / Appendix A.1.2) OR W3C Digital Credentials API / equivalent platform API (HAIP §5.2) \
Usage: Same-device, cross-device, or in-browser via DC API

The `haip-vp://` invocation URI MUST include:

* `client_id` with the `x509_hash` prefix (e.g. `client_id=x509_hash:<base64url-cert-thumbprint>`)
* `request_uri` from which the Wallet fetches the JAR-signed Presentation Request Object

The Wallet MUST reject any invocation URI missing either field.

Example:

```
haip-vp://?client_id=x509_hash:<thumbprint>&request_uri=https://verifier.example.org/request/123
```

For DC API invocation, the Verifier MUST follow Appendix A of OpenID4VP. The Wallet MUST support unsigned, signed, and multi-signed requests (Appendices A.3.1 and A.3.2 of OpenID4VP); the Verifier MUST support at least one.


## 8.2 Presentation Request Object Interface

The Presentation Request Object MUST include:

* `response_type=vp_token`
* Verifier identifier (`client_id`) using the `x509_hash` Client Identifier Prefix
* `response_uri` for the redirect flow (HTTPS, served by the Verifier)
* `nonce`
* `response_mode`: `direct_post.jwt` (redirect flow) or `dc_api.jwt` (DC API flow)
* `client_metadata` carrying the per-request ephemeral encryption JWK and `encrypted_response_enc_values_supported` listing `A128GCM` and `A256GCM`
* DCQL query, including `trusted_authorities` with `aki` Authority Key Identifiers (HAIP §5)
* Expiry (`exp`)
* JAR signature (RFC 9101). Trust anchor MUST NOT appear in `x5c`

Wallet Units reject incomplete or invalid request objects.


## 8.3 Presentation Response Endpoint

Direction: Wallet → Verifier (`response_uri`) \
Method: POST \
Encoding: `application/x-www-form-urlencoded` with a JWE (`alg=ECDH-ES`, `enc=A128GCM` or `A256GCM`) as the `response` parameter (`response_mode=direct_post.jwt`). For DC API flows (`response_mode=dc_api.jwt`), the same JWE is returned through the platform API.

**Encrypted Response Payload (after decryption) Example**

```
{ "vp_token": "<sd-jwt-vc-with-kb>", "state": "<request-state>" }
```

The `vp_token` carries the Verifiable Presentation in the requested Credential Format (`dc+sd-jwt` for SD-JWT VC, `mso_mdoc` for mdoc).

**Verifier HTTP Response (same-device redirect flow)**

```
{ "redirect_uri": "https://verifier.example.org/result/<id>" }
```

The Wallet MUST follow the returned `redirect_uri` (HAIP §5.1).

**Error Example**

```
{ "error": "invalid_presentation", "error_description": "Nonce invalid or expired" }
```

## 8.4 Verifier Metadata Interface

Verifiers MUST publish metadata containing:

* `response_uri` (Presentation Response Endpoint)
* Supported `vp_formats` (including `dc+sd-jwt` and, where applicable, `mso_mdoc`)
* Supported response modes (`direct_post.jwt` for redirects, `dc_api.jwt` for DC API)
* `encrypted_response_enc_values_supported` listing both `A128GCM` and `A256GCM` (HAIP §5)
* Client Identifier Prefix: `x509_hash` only
* X.509 certificate chain used for JAR signing (`x5c` in signed request, with trust anchor omitted)
* Required credential types and `trusted_authorities` (AKI list) for DCQL

Wallet Units retrieve this metadata where available.


# 9. Conformance

An implementation **conforms to this specification as a Wallet Provider** if it:

1. Implements all Wallet requirements in Section 7.1
2. Implements all interfaces and behaviours in Section 8
3. Supports flows defined in Section 6
4. Supports SD‑JWT‑VC as defined for OpenID4VP

An implementation **conforms to this specification as an Issuer** if it:

1. Implements all Verifier requirements in Section 7.2
2. Publishes required Verifier Metadata
3. Implements the Presentation Request and Presentation Response Endpoint interfaces
4. Supports both same‑device and cross‑device flows

# References

[1]	OpenID Foundation (2025). OpenID for Verifiable Presentations 1.0. OpenID Foundation, 9 July. Available at: [https://openid.net/specs/openid-4-verifiable-presentations-1_0.html](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html) (Accessed: 20 May 2026).

[2]	OpenID Foundation (2026) OpenID4VC High Assurance Interoperability Profile v1.0. OpenID Foundation. Available at: [https://openid.net/specs/openid4vc-high-assurance-interoperability-profile-1_0.html](https://openid.net/specs/openid4vc-high-assurance-interoperability-profile-1_0.html) (Accessed: 20 May 2026).

[3]	IETF (2025) SD‑JWT‑based Verifiable Credentials (SD-JWT VC), draft-ietf-oauth-sd-jwt-vc-13. IETF, 6 November. Available at: [https://datatracker.ietf.org/doc/html/draft-ietf-oauth-sd-jwt-vc-13](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-sd-jwt-vc-13) (Accessed: 20 May 2026).

[4]	WE BUILD (2025) Interoperability Test Bed - Reference Specification, 12 November, Available at: [https://github.com/webuild-consortium/wp4-interop-test-bed/blob/main/docs/reference-implementation-interoperability-test-bed.md](https://github.com/webuild-consortium/wp4-interop-test-bed/blob/main/docs/reference-implementation-interoperability-test-bed.md) (Accessed: 24 November 2025).

[5]	W3C (2026) Digital Credentials API. W3C Working Draft. Available at: [https://www.w3.org/TR/digital-credentials/](https://www.w3.org/TR/digital-credentials/) (Accessed: 20 May 2026).