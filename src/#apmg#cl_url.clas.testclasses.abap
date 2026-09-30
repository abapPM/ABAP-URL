CLASS ltcl_url DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    METHODS:
      " Basic URL Parsing
      basic_url FOR TESTING RAISING /apmg/cx_error,
      empty_url FOR TESTING RAISING /apmg/cx_error,
      relative_url FOR TESTING RAISING /apmg/cx_error,
      " Scheme Tests
      special_schemes FOR TESTING RAISING /apmg/cx_error,
      nonspecial_schemes FOR TESTING RAISING /apmg/cx_error,
      invalid_scheme FOR TESTING RAISING /apmg/cx_error,
      " Authority Tests
      userinfo FOR TESTING RAISING /apmg/cx_error,
      empty_userinfo FOR TESTING RAISING /apmg/cx_error,
      credentials_with_atmark FOR TESTING RAISING /apmg/cx_error,
      ipv4_host FOR TESTING RAISING /apmg/cx_error,
      ipv6_host FOR TESTING RAISING /apmg/cx_error,
      invalid_ipv6_host FOR TESTING RAISING /apmg/cx_error,
      port_validation FOR TESTING RAISING /apmg/cx_error,
      " Path Tests
      path_normalization FOR TESTING RAISING /apmg/cx_error,
      empty_path FOR TESTING RAISING /apmg/cx_error,
      dot_segments FOR TESTING RAISING /apmg/cx_error,
      special_path_chars FOR TESTING RAISING /apmg/cx_error,
      " Query String Tests
      query_basic FOR TESTING RAISING /apmg/cx_error,
      query_special_chars FOR TESTING RAISING /apmg/cx_error,
      query_encoding FOR TESTING RAISING /apmg/cx_error,
      query_space_handling FOR TESTING RAISING /apmg/cx_error,
      query_plus_handling FOR TESTING RAISING /apmg/cx_error,
      query_multiple_params FOR TESTING RAISING /apmg/cx_error,
      query_no_value FOR TESTING RAISING /apmg/cx_error,
      query_empty_pairs FOR TESTING RAISING /apmg/cx_error,
      " Fragment Tests
      fragment_basic FOR TESTING RAISING /apmg/cx_error,
      fragment_special_chars FOR TESTING RAISING /apmg/cx_error,
      fragment_encoding FOR TESTING RAISING /apmg/cx_error,
      fragment_with_query FOR TESTING RAISING /apmg/cx_error,
      multiple_hashes FOR TESTING RAISING /apmg/cx_error,
      query_fragment_combis FOR TESTING RAISING /apmg/cx_error,
      " Percent Encoding/Decoding
      percent_encoding FOR TESTING RAISING /apmg/cx_error,
      percent_decoding FOR TESTING RAISING /apmg/cx_error,
      invalid_percent_encoding FOR TESTING RAISING /apmg/cx_error,
      " IDNA Processing
      idna_domains FOR TESTING RAISING /apmg/cx_error,
      punycode FOR TESTING RAISING /apmg/cx_error,
      punycode_encoded_host FOR TESTING RAISING /apmg/cx_error,
      punycode_serialization FOR TESTING RAISING /apmg/cx_error,
      punycode_opaque_host FOR TESTING RAISING /apmg/cx_error,
      punycode_invalid_host FOR TESTING RAISING /apmg/cx_error,
      punycode_invalid_unicode FOR TESTING RAISING /apmg/cx_error,
      punycode_overflow FOR TESTING RAISING /apmg/cx_error,
      " Serialization
      url_serialization FOR TESTING RAISING /apmg/cx_error,
      special_url_serialization FOR TESTING RAISING /apmg/cx_error.

ENDCLASS.

CLASS ltcl_url IMPLEMENTATION.

  METHOD basic_url.
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com/path?query#fragment' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-scheme
      exp = 'https' ).
    cl_abap_unit_assert=>assert_equals(
      act = components-host
      exp = 'example.com' ).
    cl_abap_unit_assert=>assert_equals(
      act = components-path
      exp = '/path' ).
    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'query' ).
    cl_abap_unit_assert=>assert_equals(
      act = components-fragment
      exp = 'fragment' ).
  ENDMETHOD.

  METHOD empty_url.
    TRY.
        /apmg/cl_url=>parse( '' ).
        cl_abap_unit_assert=>fail( 'Should raise exception for empty URL' ).
      CATCH cx_static_check.
        " Expected
    ENDTRY.
  ENDMETHOD.

  METHOD relative_url.
    TRY.
        /apmg/cl_url=>parse( '/path/to/resource' ).
        cl_abap_unit_assert=>fail( 'Should raise exception for relative URL' ).
      CATCH cx_static_check.
        " Expected
    ENDTRY.
  ENDMETHOD.

  METHOD special_schemes.
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com' )->components.
    cl_abap_unit_assert=>assert_true( components-is_special ).

    components = /apmg/cl_url=>parse( 'file://c:/path' )->components.
    cl_abap_unit_assert=>assert_true( components-is_special ).

    components = /apmg/cl_url=>parse( 'ftp://example.com' )->components.
    cl_abap_unit_assert=>assert_true( components-is_special ).
  ENDMETHOD.

  METHOD nonspecial_schemes.
    DATA(components) = /apmg/cl_url=>parse( 'git://example.com' )->components.
    cl_abap_unit_assert=>assert_false( components-is_special ).

    components = /apmg/cl_url=>parse( 'about:blank' )->components.
    cl_abap_unit_assert=>assert_false( components-is_special ).
  ENDMETHOD.

  METHOD invalid_scheme.
    TRY.
        /apmg/cl_url=>parse( '3https://example.com' ).
        cl_abap_unit_assert=>fail( 'Should raise exception for invalid scheme' ).
      CATCH cx_static_check.
        " Expected
    ENDTRY.
  ENDMETHOD.

  METHOD userinfo.
    DATA(components) = /apmg/cl_url=>parse( 'https://user:pass@example.com' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-username
      exp = 'user' ).
    cl_abap_unit_assert=>assert_equals(
      act = components-password
      exp = 'pass' ).
  ENDMETHOD.

  METHOD empty_userinfo.
    DATA(components) = /apmg/cl_url=>parse( 'https://@example.com' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-username
      exp = '' ).
    cl_abap_unit_assert=>assert_equals(
      act = components-password
      exp = '' ).
  ENDMETHOD.

  METHOD credentials_with_atmark.
    DATA(components) = /apmg/cl_url=>parse( 'https://user%40local:pass@example.com' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-username
      exp = 'user@local' ).
  ENDMETHOD.

  METHOD ipv4_host.
    DATA(components) = /apmg/cl_url=>parse( 'https://192.168.0.1/path' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-host
      exp = '192.168.0.1' ).
  ENDMETHOD.

  METHOD ipv6_host.
    DATA(components) = /apmg/cl_url=>parse( 'https://[2001:db8::1]/path' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-host
      exp = '2001:db8::1' ).
  ENDMETHOD.

  METHOD invalid_ipv6_host.
    TRY.
        /apmg/cl_url=>parse( 'https://[2001:db8:::1]/path' ).
        cl_abap_unit_assert=>fail( 'Should raise exception for invalid IPv6' ).
      CATCH cx_static_check.
        " Expected
    ENDTRY.
  ENDMETHOD.

  METHOD port_validation.
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com:8080' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-port
      exp = '8080' ).

    TRY.
        /apmg/cl_url=>parse( 'https://example.com:port' ).
        cl_abap_unit_assert=>fail( 'Should raise exception for invalid port' ).
      CATCH cx_static_check.
        " Expected
    ENDTRY.
  ENDMETHOD.

  METHOD path_normalization.
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com/a/./b/../../c/' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-path
      exp = '/c/' ).
  ENDMETHOD.

  METHOD empty_path.
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com' )->components.

    cl_abap_unit_assert=>assert_equals(
    " ... continuing from empty_path
      act = components-path
      exp = '' ).
  ENDMETHOD.

  METHOD dot_segments.
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com/a/../b/./c' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-path
      exp = '/b/c' ).
  ENDMETHOD.

  METHOD special_path_chars.
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com/path%20with%20spaces/file.txt' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-path
      exp = '/path with spaces/file.txt' ).
  ENDMETHOD.

  METHOD query_basic.
    " Basic query parameter parsing
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com/?name=value' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'name=value' ).

    " Multiple parameters
    components = /apmg/cl_url=>parse( 'https://example.com/?a=1&b=2' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'a=1&b=2' ).
  ENDMETHOD.

  METHOD query_special_chars.
    " Query with special characters that should be percent-encoded
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com/?q=special!*()%27' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'q=special!*()%27' ).

    " Verify roundtrip
    DATA(url)        = /apmg/cl_url=>parse( 'https://example.com/?q=special!*()%27' ).
    DATA(url_string) = /apmg/cl_url=>serialize( url->components ).

    cl_abap_unit_assert=>assert_equals(
      act = url_string
      exp = 'https://example.com/?q=special!*()%27' ).
  ENDMETHOD.

  METHOD query_encoding.
    " Test various encoding scenarios in query parameters
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com/?q=%20%2B%3F%26' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'q= +?&' ).

    " Non-ASCII characters
    components = /apmg/cl_url=>parse( 'https://example.com/?q=%C3%BC' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'q=ü' ).
  ENDMETHOD.

  METHOD query_space_handling.
    " Space handling in query strings
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com/?q=hello%20world' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'q=hello world' ).

    " Actual space in URL (should be converted to %20)
    components = /apmg/cl_url=>parse( 'https://example.com/?q=hello world' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'q=hello world' ).

    " Verify serialization uses %20
    DATA(url) = /apmg/cl_url=>serialize( components ).
    cl_abap_unit_assert=>assert_equals(
      act = url
      exp = 'https://example.com/?q=hello%20world' ).
  ENDMETHOD.

  METHOD query_plus_handling.
    " Plus sign handling in query strings
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com/?q=hello+world' )->components.

    " According to WHATWG spec, '+' should be treated as a literal '+'
    " in the query string, not as a space
    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'q=hello+world' ).

    " Actual plus sign
    components = /apmg/cl_url=>parse( 'https://example.com/?q=1%2B1' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'q=1+1' ).
  ENDMETHOD.

  METHOD query_multiple_params.
    " Multiple parameters with various formats
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com/?a=1&b=&c=3&d' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'a=1&b=&c=3&d' ).
  ENDMETHOD.

  METHOD query_no_value.
    " Parameters without values
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com/?key' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'key' ).

    components = /apmg/cl_url=>parse( 'https://example.com/?key=' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'key=' ).
  ENDMETHOD.

  METHOD query_empty_pairs.
    " Empty parameter pairs
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com/?&&&&a=1' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = '&&&&a=1' ).
  ENDMETHOD.

  METHOD fragment_basic.
    " Basic fragment handling
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com/#section1' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-fragment
      exp = 'section1' ).
  ENDMETHOD.

  METHOD fragment_special_chars.
    " Fragment with special characters
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com/#section?query&more' )->components.

    " According to WHATWG spec, characters after # are part of the fragment
    cl_abap_unit_assert=>assert_equals(
      act = components-fragment
      exp = 'section?query&more' ).
  ENDMETHOD.

  METHOD fragment_encoding.
    " Encoded characters in fragment
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com/#section%20with%20spaces' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-fragment
      exp = 'section with spaces' ).

    " Verify proper serialization
    DATA(url) = /apmg/cl_url=>serialize( components ).
    cl_abap_unit_assert=>assert_equals(
      act = url
      exp = 'https://example.com/#section%20with%20spaces' ).
  ENDMETHOD.

  METHOD fragment_with_query.
    " Fragment after query string
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com/?q=1#fragment' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'q=1' ).
    cl_abap_unit_assert=>assert_equals(
      act = components-fragment
      exp = 'fragment' ).

    " Query-like syntax in fragment
    components = /apmg/cl_url=>parse( 'https://example.com/#section?param=value' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-fragment
      exp = 'section?param=value' ).

    " Fragment with hash
    components = /apmg/cl_url=>parse( 'https://example.com/?query#section#subsection' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'query' ).
    cl_abap_unit_assert=>assert_equals(
      act = components-fragment
      exp = 'section#subsection' ).
  ENDMETHOD.

  METHOD multiple_hashes.
    " Multiple hash marks
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com/#first#second#third' )->components.

    " According to WHATWG spec, everything after the first # is the fragment
    cl_abap_unit_assert=>assert_equals(
      act = components-fragment
      exp = 'first#second#third' ).
  ENDMETHOD.

  METHOD percent_encoding.
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com/path%20with%20spaces/%23fragment' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-path
      exp = '/path with spaces/#fragment' ).

    " Test serialization preserves encoding where necessary
    DATA(url) = /apmg/cl_url=>serialize( components ).
    cl_abap_unit_assert=>assert_equals(
      act = url
      exp = 'https://example.com/path%20with%20spaces/%23fragment' ).
  ENDMETHOD.

  METHOD percent_decoding.
    DATA(components) = /apmg/cl_url=>parse( 'https://user%3Aname:pass%40word@example.com' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-username
      exp = 'user:name' ).
    cl_abap_unit_assert=>assert_equals(
      act = components-password
      exp = 'pass@word' ).
  ENDMETHOD.

  METHOD invalid_percent_encoding.
    " Test incomplete percent encoding
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com/path%2' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-path
      exp = '/path%2' ).

    " Test invalid hex digits
    components = /apmg/cl_url=>parse( 'https://example.com/path%XY' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-path
      exp = '/path%XY' ).
  ENDMETHOD.

  METHOD idna_domains.
    TYPES:
      BEGIN OF ty_case,
        input TYPE string,
        host  TYPE string,
      END OF ty_case,
      ty_cases TYPE STANDARD TABLE OF ty_case WITH EMPTY KEY.
    DATA(cases) = VALUE ty_cases(
      ( input = 'müller.de'        host = 'xn--mller-kva.de' )
      ( input = 'BÜCHER.Example'   host = 'xn--bcher-kva.example' )
      ( input = 'mañana.com'       host = 'xn--maana-pta.com' )
      ( input = '例え.テスト'           host = 'xn--r8jz45g.xn--zckzah' )
      ( input = 'россия.рф'        host = 'xn--h1alffa9f.xn--p1ai' )
      ( input = 'faß.de'           host = 'xn--fa-hia.de' )
      ( input = 'üüü.de'           host = 'xn--tdaaa.de' )
      ( input = '😀.example'       host = 'xn--e28h.example' )
      ( input = 'bücher'           host = 'xn--bcher-kva' )
      ( input = 'bücher..de.'      host = 'xn--bcher-kva..de.' )
      ( input = 'www。bücher．de｡'   host = 'www.xn--bcher-kva.de.' )
      ( input = 'xn--bcher-kva.例え' host = 'xn--bcher-kva.xn--r8jz45g' ) ).

    LOOP AT cases INTO DATA(test_case).
      DATA(components) = /apmg/cl_url=>parse( |https://{ test_case-input }/path| )->components.
      cl_abap_unit_assert=>assert_equals(
        act = components-host
        exp = test_case-host
        msg = test_case-input ).
    ENDLOOP.
  ENDMETHOD.

  METHOD punycode_encoded_host.
    DATA(mixed) = /apmg/cl_url=>parse( 'https://bücher.%E4%BE%8B%E3%81%88/' )->components.
    cl_abap_unit_assert=>assert_equals( act = mixed-host exp = 'xn--bcher-kva.xn--r8jz45g' ).

    mixed = /apmg/cl_url=>parse( 'https://%f0%9f%98%80.example/' )->components.
    cl_abap_unit_assert=>assert_equals( act = mixed-host exp = 'xn--e28h.example' ).

    mixed = /apmg/cl_url=>parse( 'https://b%C3%BCcher%2Bshop.de/' )->components.
    cl_abap_unit_assert=>assert_equals( act = mixed-host exp = 'xn--bcher+shop-9db.de' ).

    DATA(components) = /apmg/cl_url=>parse( 'https://user:pass@b%C3%BCcher.de:8080?q=1#part' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-host exp = 'xn--bcher-kva.de' ).
    cl_abap_unit_assert=>assert_equals( act = components-port exp = '8080' ).
    cl_abap_unit_assert=>assert_equals( act = components-username exp = 'user' ).
    cl_abap_unit_assert=>assert_equals( act = components-password exp = 'pass' ).
    cl_abap_unit_assert=>assert_equals( act = components-query exp = 'q=1' ).
    cl_abap_unit_assert=>assert_equals( act = components-fragment exp = 'part' ).

    components = /apmg/cl_url=>parse( 'https://bücher.de#part' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-host exp = 'xn--bcher-kva.de' ).
    cl_abap_unit_assert=>assert_equals( act = components-fragment exp = 'part' ).

    components = /apmg/cl_url=>parse( 'https://b%C3%BCcher+shop.de/' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-host exp = 'xn--bcher+shop-9db.de' ).

    components = /apmg/cl_url=>parse( 'https://bücher.de\path\to\file' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-host exp = 'xn--bcher-kva.de' ).
    cl_abap_unit_assert=>assert_equals( act = components-path exp = '/path/to/file' ).
  ENDMETHOD.

  METHOD punycode_serialization.
    DATA(schemes) = VALUE string_table( ( `http` ) ( `https` ) ( `ftp` ) ( `ws` ) ( `wss` ) ( `file` ) ).
    LOOP AT schemes INTO DATA(scheme).
      DATA(components) = VALUE /apmg/cl_url=>ty_url_components(
        scheme = scheme
        host   = 'bücher.de'
        path   = '/path' ).
      DATA(url) = /apmg/cl_url=>serialize( components ).
      cl_abap_unit_assert=>assert_equals( act = url exp = |{ scheme }://xn--bcher-kva.de/path| ).
      components = /apmg/cl_url=>parse( url )->components.
      cl_abap_unit_assert=>assert_equals( act = /apmg/cl_url=>serialize( components ) exp = url ).
      components = /apmg/cl_url=>parse( |{ scheme }://bücher.de/path| )->components.
      cl_abap_unit_assert=>assert_equals( act = components-host exp = 'xn--bcher-kva.de' ).
    ENDLOOP.
  ENDMETHOD.

  METHOD punycode_opaque_host.
    DATA(components) = /apmg/cl_url=>parse( 'git://bücher.de/path' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-host exp = 'bücher.de' ).
    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_url=>serialize( components )
      exp = 'git://bücher.de/path' ).
  ENDMETHOD.

  METHOD punycode_invalid_host.
    DATA(hosts) = VALUE string_table(
      ( `bücher%.de` ) ( `bücher%2.de` ) ( `bücher%GG.de` )
      ( `bücher%C3.de` ) ( `bücher%FF.de` ) ( `bücher%C0%AF.de` )
      ( `bücher%ED%A0%80.de` ) ( `bücher%F4%90%80%80.de` )
      ( `b%C3%BCcher%20.de` ) ( `bücher%2F.de` ) ( `bücher%23.de` ) ( `bücher%25.de` )
      ( `bücher%00.de` )      ( `bücher%7F.de` ) ( `bücher%09.de` ) ).
    LOOP AT hosts INTO DATA(host).
      TRY.
          /apmg/cl_url=>parse( |https://{ host }/| ).
          cl_abap_unit_assert=>fail( |Should reject invalid host: { host }| ).
        CATCH /apmg/cx_error.
          " Expected
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD punycode_overflow.
    " A high scalar after many ASCII characters exceeds signed 32-bit delta.
    DATA(host) = repeat( val = `a` occ = 18000 ) && '😀.example'.
    TRY.
        /apmg/cl_url=>parse( |https://{ host }/| ).
        cl_abap_unit_assert=>fail( 'Should reject Punycode integer overflow' ).
      CATCH /apmg/cx_error.
        " Expected
    ENDTRY.
  ENDMETHOD.

  METHOD punycode_invalid_unicode.
    DATA(pair) = `😀`.
    DATA(high) = pair(1).
    DATA(low) = pair+1(1).
    DATA(hosts) = VALUE string_table( ( |{ high }| ) ( |{ low }| ) ( |{ high }a| ) ).
    LOOP AT hosts INTO DATA(host).
      TRY.
          /apmg/cl_url=>parse( |https://{ host }/| ).
          cl_abap_unit_assert=>fail( 'Should reject an unpaired UTF-16 surrogate' ).
        CATCH /apmg/cx_error.
          " Expected
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD punycode.
    DATA(components) = /apmg/cl_url=>parse( 'https://xn--mnchen-3ya.de/path' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-host
      exp = 'xn--mnchen-3ya.de' ).
  ENDMETHOD.

  METHOD url_serialization.
    " Test complete URL serialization
    DATA(components) = VALUE /apmg/cl_url=>ty_url_components(
      scheme   = 'https'
      username = 'user'
      password = 'pass'
      host     = 'example.com'
      port     = '8080'
      path     = '/path/to/resource'
      query    = 'key=value'
      fragment = 'section' ).

    DATA(url) = /apmg/cl_url=>serialize( components ).

    cl_abap_unit_assert=>assert_equals(
      act = url
      exp = 'https://user:pass@example.com:8080/path/to/resource?key=value#section' ).
  ENDMETHOD.

  METHOD special_url_serialization.
    " Test file URL
    DATA(components) = VALUE /apmg/cl_url=>ty_url_components(
      scheme = 'file'
      host   = ''
      path   = '/C:/path/to/file.txt' ).

    DATA(url) = /apmg/cl_url=>serialize( components ).

    cl_abap_unit_assert=>assert_equals(
      act = url
      exp = 'file:///C:/path/to/file.txt' ).

    " Test URL with empty username but password
    components = VALUE /apmg/cl_url=>ty_url_components(
      scheme   = 'https'
      username = ''
      password = 'pass'
      host     = 'example.com' ).

    url = /apmg/cl_url=>serialize( components ).

    cl_abap_unit_assert=>assert_equals(
      act = url
      exp = 'https://:pass@example.com' ).
  ENDMETHOD.

  METHOD query_fragment_combis.
    " Test various combinations of query and fragment

    " Only path
    DATA(components) = /apmg/cl_url=>parse( 'https://example.com/path' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-path exp = '/path' ).
    cl_abap_unit_assert=>assert_initial( components-query ).
    cl_abap_unit_assert=>assert_initial( components-fragment ).

    " Path with query
    components = /apmg/cl_url=>parse( 'https://example.com/path?query=1' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-path exp = '/path' ).
    cl_abap_unit_assert=>assert_equals( act = components-query exp = 'query=1' ).
    cl_abap_unit_assert=>assert_initial( components-fragment ).

    " Path with fragment
    components = /apmg/cl_url=>parse( 'https://example.com/path#fragment' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-path exp = '/path' ).
    cl_abap_unit_assert=>assert_initial( components-query ).
    cl_abap_unit_assert=>assert_equals( act = components-fragment exp = 'fragment' ).

    " Path with query and fragment
    components = /apmg/cl_url=>parse( 'https://example.com/path?query=1#fragment' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-path exp = '/path' ).
    cl_abap_unit_assert=>assert_equals( act = components-query exp = 'query=1' ).
    cl_abap_unit_assert=>assert_equals( act = components-fragment exp = 'fragment' ).

    " Fragment before query (according to WHATWG spec)
    components = /apmg/cl_url=>parse( 'https://example.com/path#fragment?query=1' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-path exp = '/path' ).
    cl_abap_unit_assert=>assert_initial( components-query ).
    cl_abap_unit_assert=>assert_equals( act = components-fragment exp = 'fragment?query=1' ).

    " Empty query
    components = /apmg/cl_url=>parse( 'https://example.com/path?' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-path exp = '/path' ).
    cl_abap_unit_assert=>assert_equals( act = components-query exp = '' ).
    cl_abap_unit_assert=>assert_initial( components-fragment ).

    " Empty fragment
    components = /apmg/cl_url=>parse( 'https://example.com/path#' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-path exp = '/path' ).
    cl_abap_unit_assert=>assert_initial( components-query ).
    cl_abap_unit_assert=>assert_equals( act = components-fragment exp = '' ).

    " Multiple question marks
    components = /apmg/cl_url=>parse( 'https://example.com/path?query=1?more=2' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-path exp = '/path' ).
    cl_abap_unit_assert=>assert_equals( act = components-query exp = 'query=1?more=2' ).
    cl_abap_unit_assert=>assert_initial( components-fragment ).

    " Multiple hash marks
    components = /apmg/cl_url=>parse( 'https://example.com/path#frag1#frag2' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-path exp = '/path' ).
    cl_abap_unit_assert=>assert_initial( components-query ).
    cl_abap_unit_assert=>assert_equals( act = components-fragment exp = 'frag1#frag2' ).
  ENDMETHOD.

ENDCLASS.

" WHATWG Test Cases
* from https://url.spec.whatwg.org/#writing
CLASS ltcl_whatwg DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    METHODS:
      " IDNA
      domain_to_ascii FOR TESTING RAISING /apmg/cx_error, " TODO
      domain_invalid_code_point FOR TESTING RAISING /apmg/cx_error, " TODO
      domain_to_unicode FOR TESTING RAISING /apmg/cx_error, " TODO
      " Host parsing
      host_invalid_code_point FOR TESTING RAISING /apmg/cx_error,
      ipv4_empty_part FOR TESTING RAISING /apmg/cx_error,
      ipv4_too_many_parts FOR TESTING RAISING /apmg/cx_error,
      ipv4_non_numeric_part FOR TESTING RAISING /apmg/cx_error, " TODO
      ipv4_non_decimal_part FOR TESTING RAISING /apmg/cx_error,
      ipv4_out_of_range_part FOR TESTING RAISING /apmg/cx_error,
      ipv6_unclosed FOR TESTING RAISING /apmg/cx_error,
      ipv6_invalid_compression FOR TESTING RAISING /apmg/cx_error,
      ipv6_too_many_pieces FOR TESTING RAISING /apmg/cx_error,
      ipv6_multiple_compression FOR TESTING RAISING /apmg/cx_error,
      ipv6_invalid_code_point FOR TESTING RAISING /apmg/cx_error,
      ipv6_too_few_pieces FOR TESTING RAISING /apmg/cx_error,
      ipv4_in_ipv6_too_many_pieces FOR TESTING RAISING /apmg/cx_error,
      ipv4_in_ipv6_invalid_code_pnt FOR TESTING RAISING /apmg/cx_error,
      ipv4_in_ipv6_out_of_range_prt FOR TESTING RAISING /apmg/cx_error,
      ipv4_in_ipv6_too_few_parts FOR TESTING RAISING /apmg/cx_error,
      " URL parsing
      invalid_url_unit FOR TESTING RAISING /apmg/cx_error, " TODO
      special_scheme_missing FOR TESTING RAISING /apmg/cx_error,
      missing_scheme_non_rel_url FOR TESTING RAISING /apmg/cx_error,
      invalid_reverse_solidus FOR TESTING RAISING /apmg/cx_error,
      invalid_credentials FOR TESTING RAISING /apmg/cx_error,
      host_missing FOR TESTING RAISING /apmg/cx_error,
      port_out_of_range FOR TESTING RAISING /apmg/cx_error,
      port_invalid FOR TESTING RAISING /apmg/cx_error,
      file_invalid_win_drive_letter FOR TESTING RAISING /apmg/cx_error,
      file_invalid_win_drive_host FOR TESTING RAISING /apmg/cx_error.

ENDCLASS.

CLASS ltcl_whatwg IMPLEMENTATION.

  " *** IDNA ***

  METHOD domain_to_ascii.
    " TODO: requires full IDNA validation
    " Unicode ToASCII records an error or returns the empty string.
    ASSERT 0 = 0.
  ENDMETHOD.

  METHOD domain_invalid_code_point.
    " The input’s host contains a forbidden domain code point.
    TRY.
        /apmg/cl_url=>parse( 'https://bücher%3E.de/' ).
        cl_abap_unit_assert=>fail( 'Should reject a percent-encoded forbidden domain code point' ).
      CATCH /apmg/cx_error.
        " Expected
    ENDTRY.
  ENDMETHOD.

  METHOD domain_to_unicode.
    " TODO: requires IDNA ToUnicode validation
    " Unicode ToUnicode records an error.
    ASSERT 0 = 0.
  ENDMETHOD.

  " *** Host Parsing ***

  METHOD host_invalid_code_point.
    " An opaque host (in a URL that is not special) contains a forbidden host code point.
    TRY.
        /apmg/cl_url=>parse( 'foo://exa[mple.org' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD ipv4_empty_part.
    " An IPv4 address ends with a U+002E (.).
    TRY.
        /apmg/cl_url=>parse( 'https://127.0.0.1./' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD ipv4_too_many_parts.
    " An IPv4 address does not consist of exactly 4 parts.
    TRY.
        /apmg/cl_url=>parse( 'https://1.2.3.4.5/' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD ipv4_non_numeric_part.
    " An IPv4 address part is not numeric.
    TRY.
        " TODO: Is this really an IP address?
        " /apmg/cl_url=>parse( 'https://test.42' )
        " cl_abap_unit_assert=>fail( )
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD ipv4_non_decimal_part.
    " The IPv4 address contains numbers expressed using hexadecimal or octal digits.
    TRY.
        /apmg/cl_url=>parse( 'https://127.0.0x0.1' ).
      CATCH cx_root.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD ipv4_out_of_range_part.
    " An IPv4 address part exceeds 255.
    TRY.
        /apmg/cl_url=>parse( 'https://255.255.4000.1' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD ipv6_unclosed.
    " An IPv6 address is missing the closing U+005D (]).
    TRY.
        /apmg/cl_url=>parse( 'https://[::1' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD ipv6_invalid_compression.
    " An IPv6 address begins with improper compression.
    TRY.
        /apmg/cl_url=>parse( 'https://[:1]' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD ipv6_too_many_pieces.
    " An IPv6 address contains more than 8 pieces.
    TRY.
        /apmg/cl_url=>parse( 'https://[1:2:3:4:5:6:7:8:9]' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD ipv6_multiple_compression.
    " An IPv6 address is compressed in more than one spot.
    TRY.
        /apmg/cl_url=>parse( 'https://[1::1::1]' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD ipv6_invalid_code_point.
    " An IPv6 address contains a code point that is neither an
    " ASCII hex digit nor a U+003A (:). Or it unexpectedly ends.
    TRY.
        /apmg/cl_url=>parse( 'https://[1:2:3!:4]' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    TRY.
        /apmg/cl_url=>parse( 'https://[1:2:3:]' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD ipv6_too_few_pieces.
    " An uncompressed IPv6 address contains fewer than 8 pieces.
    TRY.
        /apmg/cl_url=>parse( 'https://[1:2:3]' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD ipv4_in_ipv6_too_many_pieces.
    " An IPv6 address with IPv4 address syntax: the IPv6 address has more than 6 pieces.
    TRY.
        /apmg/cl_url=>parse( 'https://[1:1:1:1:1:1:1:127.0.0.1]' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD ipv4_in_ipv6_invalid_code_pnt.
    " An IPv6 address with IPv4 address syntax:
    " - An IPv4 part is empty or contains a non-ASCII digit.
    " - An IPv4 part contains a leading 0.
    " - There are too many IPv4 parts.
    TRY.
        /apmg/cl_url=>parse( 'https://[ffff::.0.0.1]' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    TRY.
        /apmg/cl_url=>parse( 'https://[ffff::.0.0.1]' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    TRY.
        /apmg/cl_url=>parse( 'https://[ffff::127.0.xyz.1]' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    TRY.
        /apmg/cl_url=>parse( 'https://[ffff::127.0xyz]' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    TRY.
        /apmg/cl_url=>parse( 'https://[ffff::127.00.0.1]' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    TRY.
        /apmg/cl_url=>parse( 'https://[ffff::127.0.0.1.2]' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD ipv4_in_ipv6_out_of_range_prt.
    " An IPv6 address with IPv4 address syntax: an IPv4 part exceeds 255.
    TRY.
        /apmg/cl_url=>parse( 'https://[ffff::127.0.0.4000]' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD ipv4_in_ipv6_too_few_parts.
    " An IPv6 address with IPv4 address syntax: an IPv4 address contains too few parts.
    TRY.
        /apmg/cl_url=>parse( 'https://[ffff::127.0.0]' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  " *** URL Parsing ***

  METHOD invalid_url_unit.
    " A code point is found that is not a URL unit.
    TRY.
        /apmg/cl_url=>parse( 'https://example.org/>' ).
      CATCH cx_root.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.

    TRY.
        /apmg/cl_url=>parse( ' https://example.org ' ).
      CATCH cx_root.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.

    TRY.
        " TODO: Should this really be valid?
        " /apmg/cl_url=>parse( |ht\ntps://example.org| )
      CATCH cx_root.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.

    TRY.
        /apmg/cl_url=>parse( 'https://example.org/%s' ).
      CATCH cx_root.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD special_scheme_missing.
    " The input's scheme is not followed by '//'.
    TRY.
        /apmg/cl_url=>parse( 'file:c:/my-secret-folder' ).
      CATCH cx_root.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.

    TRY.
        /apmg/cl_url=>parse( 'https:example.org' ).
      CATCH cx_root.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.

    TRY.
        " const url = new url('https:foo.html', 'https://example.org/');
        /apmg/cl_url=>parse( 'https:foo.html' ).
      CATCH cx_root.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD missing_scheme_non_rel_url.
    " The input is missing a scheme, because it does not begin with an ASCII alpha,
    " and either no base URL was provided or the base URL cannot be used as a base
    " URL because it has an opaque path.
    TRY.
        /apmg/cl_url=>parse( '💩' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD invalid_reverse_solidus.
    " The URL has a special scheme and it uses U+005C (\) instead of U+002F (/).
    TRY.
        /apmg/cl_url=>parse( 'https://example.org\path\to\file' ).
      CATCH cx_root.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD invalid_credentials.
    " The input includes credentials.
    TRY.
        /apmg/cl_url=>parse( 'https://user@example.org' ).
      CATCH cx_root.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.

    TRY.
        /apmg/cl_url=>parse( 'ssh://user@example.org' ).
      CATCH cx_root.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD host_missing.
    " The input has a special scheme, but does not contain a host.
    TRY.
        /apmg/cl_url=>parse( 'https://#fragment' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    TRY.
        /apmg/cl_url=>parse( 'https://:443' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    TRY.
        /apmg/cl_url=>parse( 'https://user:pass@' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD port_out_of_range.
    " The input's port is too big.
    TRY.
        /apmg/cl_url=>parse( 'https://example.org:70000' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD port_invalid.
    " The input's port is invalid.
    TRY.
        /apmg/cl_url=>parse( 'https://example.org:7z' ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD file_invalid_win_drive_letter.
    " The input is a relative-URL string that starts with a Windows drive
    " letter and the base URL's scheme is 'file'.
    TRY.
        " TODO
        " const url = new URL('/c:/path/to/file', 'file:///c:/');
      CATCH cx_root.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD file_invalid_win_drive_host.
    " A file: URL's host is a Windows drive letter.
    TRY.
        /apmg/cl_url=>parse( 'file://c:' ).
      CATCH cx_root.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
