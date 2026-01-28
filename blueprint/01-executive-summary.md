# 1. Executive Summary & Project Context
## Background
[WE BUILD](https://webuildconsortium.eu/) is a European project with a very practical mission: to use the European Digital Identity (EUDI) Wallet to make life easier, faster, and cheaper for businesses and citizens across the EU. Our goal is to strengthen European competitiveness by removing the "red tape" that usually slows down cross-border transactions, like opening a bank account or registering a company branch in another country.

Use Case Driven: We serve the business needs
WE BUILD is strictly use-case driven. We have gathered 13 specific use cases divided into three main areas:
- Business (WP2): Handling things like company registration and verified mandates.
- Supply Chain (WP2): Streamlining logistics, transport, and eInvoicing.
- Payments & Banking (WP3): Making secure, fraud-resistant payments and simplifying bank onboarding.

## Work Package 4 (WP4) - General Capabilities
WP4 does not build technology for its own sake. Our technical groups - Architecture, Semantics, Wallet Providers, PID & EBWOID Provider, Qualified Trust Service Provider (QTSP), Trust Registry Infrastructure, and Test Infrastructure exist solely to provide the "engine" that powers these 13 use cases. We aim to create shared solutions so that each use case doesn't have to reinvent the wheel, saving time and project budget.

<!-- Is this true? How about testing things that the EC wants us to test or that would benefit the EUDIW/BW implementations in EU? -->  

### How WP4 Works: From Strategy to Testing and Piloting
To keep everyone aligned and ensure that a wallet from one country actually works with a verifier from another, we use three levels of documentation:

1. This **Blueprint (D4.1)**: The "big picture." It describes high-level patterns and how the different parts of the system fit together.
2. [**Architectural Decision Records (ADRs)**](https://github.com/webuild-consortium/wp4-architecture/tree/main/adr): This is where we record and justify the "Why." When we make a major choice (like which standard to use), we document it here to ensure everyone understands the rationale.
3. [**WE BUILD Conformance Specifications (WBCS)**](https://github.com/webuild-consortium/wp4-architecture/tree/main/conformance-specs): This is the "How." These are the detailed technical rules that developers follow. If you implement your service according to these specs, you will be able to pass our automated tests.

## How to get started
If you are working in a use case, this Blueprint is your starting point to understand the "WE BUILD way" of doing things.
- Technical teams should look for the WBCS on GitHub to start building their interfaces.
- Every implementation must eventually pass through our Interoperability Testbed (ITB), to prove that your technical solution is ready for real-world piloting.

In short: Use cases set the requirements, and WP4 builds the interoperable foundation to meet them

<!-- How do we go about writing about "the EUDI-compliant architecture positioning within the eIDAS and ARF context? -->  


