![Version](https://img.shields.io/endpoint?url=https://shield.abap.space/version-shield-json/github/abapPM/ABAP-URL/src/zcl_url.clas.abap/c_version&label=Version&color=blue)

[![License](https://img.shields.io/github/license/abapPM/ABAP-URL?label=License&color=success)](https://github.com/abapPM/ABAP-URL/blob/main/LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg?color=success)](https://github.com/abapPM/.github/blob/main/CODE_OF_CONDUCT.md)
[![REUSE Status](https://api.reuse.software/badge/github.com/abapPM/ABAP-URL)](https://api.reuse.software/info/github.com/abapPM/ABAP-URL)

# URL Object

Full implementation of WHATWG [URL Standard](https://url.spec.whatwg.org/).

Limitations: No support for punycode.

NO WARRANTIES, [MIT License](https://github.com/abapPM/ABAP-URL/blob/main/LICENSE)

## Usage

Parse a URL into it's component:

```abap
DATA(url) = zcl_url=>parse( 'https://example.com/path?query#fragment' ).

" url->components-scheme   = 'https'
" url->components-host     = 'example.com'
" url->components-path     = '/path'
" url->components-query    = 'query'
" url->components-fragment = 'fragment'
```

Serialize a URL from components:

```abap
DATA(components) = VALUE zcl_url=>ty_url_components(
  scheme   = 'https'
  username = 'user'
  password = 'pass'
  host     = 'example.com'
  port     = '8080'
  path     = '/path/to/resource'
  query    = 'key=value'
  fragment = 'section' ).

DATA(url_string) = zcl_url=>serialize( components ).

" url_string = 'https://user:pass@example.com:8080/path/to/resource?key=value#section'
```

## Prerequisites

SAP Basis 7.50 or higher

## Installation

Install `url` as a global module in your system using [apm](https://abappm.com).

or

Specify the `url` module as a dependency in your project and import it to your namespace using [apm](https://abappm.com).

```abap
IMPORT '*' TO 'z$1_your_project$2' FROM 'url'.
" or
IMPORT '*' TO '/namespace/$1$2' FROM 'url'.
```

## Contributions

All contributions are welcome! Read our [Contribution Guidelines](https://github.com/abapPM/ABAP-URL/blob/main/CONTRIBUTING.md), fork this repo, and create a pull request.

You can install the developer version of ABAP Error using [abapGit](https://github.com/abapGit/abapGit) either by creating a new online repository for https://github.com/abapPM/ABAP-URL.

Recommended SAP package: `$URL`

## About

Made with ❤️ in Canada

Copyright 2024 apm.to Inc. <https://apm.to>

Follow [@marcf.be](https://bsky.app/profile/marcf.be) on Blueksy