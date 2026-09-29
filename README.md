![Version](https://img.shields.io/endpoint?url=https://shield.abappm.com/github/abapPM/ABAP-URL/src/%2523apmg%2523cl_url.clas.abap/c_version&label=Version&color=blue)

[![License](https://img.shields.io/github/license/abapPM/ABAP-URL?label=License&color=success)](https://github.com/abapPM/ABAP-URL/blob/main/LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg?color=success)](https://github.com/abapPM/.github/blob/main/CODE_OF_CONDUCT.md)
[![REUSE Status](https://api.reuse.software/badge/github.com/abapPM/ABAP-URL)](https://api.reuse.software/info/github.com/abapPM/ABAP-URL)

# URL Object

URL parsing and serialization based on the WHATWG [URL Standard](https://url.spec.whatwg.org/).

NO WARRANTIES, [MIT License](https://github.com/abapPM/ABAP-URL/blob/main/LICENSE)

```txt
┌────────┬──┬──────────┬──────────┬─────────────────┬──────┬──────────┬─┬───────────┬──────────┐
" https:  //    user   :   pass   @ sub.example.com : 8080   /p/a/t/h  ?  key=val     #hash    "
│ scheme │  │ username │ password │    host         │ port │   path   │ |  query    │ fragment │
├────────┴──┴──────────┴──────────┴─────────────────┴──────┴──────────┴─┴───────────┴──────────┤
│                                            url                                               │
└──────────────────────────────────────────────────────────────────────────────────────────────┘
(All spaces in the "" line should be ignored. They are purely for formatting.)
```

## Usage

Parse a URL into its components:

```abap
DATA(url) = /apmg/cl_url=>parse( 'https://example.com/path?query#fragment' ).

" url->components-scheme   = 'https'
" url->components-host     = 'example.com'
" url->components-path     = '/path'
" url->components-query    = 'query'
" url->components-fragment = 'fragment'
```

Serialize a URL from components:

```abap
DATA(components) = VALUE /apmg/cl_url=>ty_url_components(
  scheme   = 'https'
  username = 'user'
  password = 'pass'
  host     = 'example.com'
  port     = '8080'
  path     = '/path/to/resource'
  query    = 'key=value'
  fragment = 'section' ).

DATA(url_string) = /apmg/cl_url=>serialize( components ).

" url_string = 'https://user:pass@example.com:8080/path/to/resource?key=value#section'
```

### International domain names

Unicode hostnames in `http`, `https`, `ftp`, `ws`, `wss`, and `file` URLs are
converted to ASCII labels using [Punycode (RFC 3492)](https://www.rfc-editor.org/rfc/rfc3492).
Both parsing and serialization support this conversion:

```abap
DATA(url) = /apmg/cl_url=>parse( 'https://bücher.de/path' ).
" url->components-host = 'xn--bcher-kva.de'

DATA(url_string) = /apmg/cl_url=>serialize( url->components ).
" url_string = 'https://xn--bcher-kva.de/path'
```

Hostnames are lowercased, Unicode dot separators are mapped to `.`, and
percent-encoded UTF-8 hostnames are decoded when parsing. Existing ASCII
`xn--` labels remain in ASCII form. IPv4/IPv6 processing and hosts for
non-special schemes retain their existing behavior.

## Prerequisites

SAP Basis 7.50 or higher

## Limitations

Punycode support is not a complete IDNA/UTS #46 implementation. Unicode NFC
normalization, full compatibility mapping, contextual/bidirectional checks,
validation of existing `xn--` labels, and DNS length checks are not performed.
Supply normalized Unicode hostnames when canonical equivalence matters.

## Installation

Install `url` as a global module in your system using [apm](https://abappm.com).

or

Specify the `url` module as a dependency in your project and import it to your namespace using [apm](https://abappm.com).

## Contributions

All contributions are welcome! Read our [Contribution Guidelines](https://github.com/abapPM/ABAP-URL/blob/main/CONTRIBUTING.md), fork this repo, and create a pull request.

You can install the developer version of ABAP URL using [abapGit](https://github.com/abapGit/abapGit) by creating a new online repository for `https://github.com/abapPM/ABAP-URL`.

Recommended SAP package: `/APMG/URL`

## About

Made with ❤ in Canada

Copyright 2025 apm.to Inc. <https://apm.to>

Follow [@marcf.be](https://bsky.app/profile/marcf.be) on Bluesky and [@marcfbe](https://linkedin.com/in/marcfbe) or LinkedIn
