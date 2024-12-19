CLASS ltcl_url DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    METHODS:
      " Basic URL Parsing
      test_basic_url FOR TESTING RAISING zcx_error,
      test_empty_url FOR TESTING RAISING zcx_error,
      test_relative_url FOR TESTING RAISING zcx_error,

      " Scheme Tests
      test_special_schemes FOR TESTING RAISING zcx_error,
      test_nonspecial_schemes FOR TESTING RAISING zcx_error,
      test_invalid_scheme FOR TESTING RAISING zcx_error,

      " Authority Tests
      test_userinfo FOR TESTING RAISING zcx_error,
      test_empty_userinfo FOR TESTING RAISING zcx_error,
      test_credentials_with_atmark FOR TESTING RAISING zcx_error,
      test_ipv4_host FOR TESTING RAISING zcx_error,
      test_ipv6_host FOR TESTING RAISING zcx_error,
      test_invalid_ipv6_host FOR TESTING RAISING zcx_error,
      test_port_validation FOR TESTING RAISING zcx_error,

      " Path Tests
      test_path_normalization FOR TESTING RAISING zcx_error,
      test_empty_path FOR TESTING RAISING zcx_error,
      test_dot_segments FOR TESTING RAISING zcx_error,
      test_special_path_chars FOR TESTING RAISING zcx_error,

      " Query String Tests
      test_query_basic FOR TESTING RAISING zcx_error,
      test_query_special_chars FOR TESTING RAISING zcx_error,
      test_query_encoding FOR TESTING RAISING zcx_error,
      test_query_space_handling FOR TESTING RAISING zcx_error,
      test_query_plus_handling FOR TESTING RAISING zcx_error,
      test_query_multiple_params FOR TESTING RAISING zcx_error,
      test_query_no_value FOR TESTING RAISING zcx_error,
      test_query_empty_pairs FOR TESTING RAISING zcx_error,

      " Fragment Tests
      test_fragment_basic FOR TESTING RAISING zcx_error,
      test_fragment_special_chars FOR TESTING RAISING zcx_error,
      test_fragment_encoding FOR TESTING RAISING zcx_error,
      test_fragment_with_query FOR TESTING RAISING zcx_error,
      test_multiple_hashes FOR TESTING RAISING zcx_error,
      test_query_fragment_combis FOR TESTING RAISING zcx_error,

      " Percent Encoding/Decoding
      test_percent_encoding FOR TESTING RAISING zcx_error,
      test_percent_decoding FOR TESTING RAISING zcx_error,
      test_invalid_percent_encoding FOR TESTING RAISING zcx_error,

      " IDNA Processing
      test_idna_domains FOR TESTING RAISING zcx_error,
      test_punycode FOR TESTING RAISING zcx_error,

      " Serialization
      test_url_serialization FOR TESTING RAISING zcx_error,
      test_special_url_serialization FOR TESTING RAISING zcx_error.

ENDCLASS.

CLASS ltcl_url IMPLEMENTATION.

  METHOD test_basic_url.
    DATA(components) = zcl_url=>parse( 'https://example.com/path?query#fragment' )->components.

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

  METHOD test_empty_url.
    TRY.
        zcl_url=>parse( '' ).
        cl_abap_unit_assert=>fail( 'Should raise exception for empty URL' ).
      CATCH cx_static_check.
        " Expected
    ENDTRY.
  ENDMETHOD.

  METHOD test_relative_url.
    TRY.
        zcl_url=>parse( '/path/to/resource' ).
        cl_abap_unit_assert=>fail( 'Should raise exception for relative URL' ).
      CATCH cx_static_check.
        " Expected
    ENDTRY.
  ENDMETHOD.

  METHOD test_special_schemes.
    DATA(components) = zcl_url=>parse( 'https://example.com' )->components.
    cl_abap_unit_assert=>assert_true( components-is_special ).

    components = zcl_url=>parse( 'file:///path' )->components.
    cl_abap_unit_assert=>assert_true( components-is_special ).

    components = zcl_url=>parse( 'ftp://example.com' )->components.
    cl_abap_unit_assert=>assert_true( components-is_special ).
  ENDMETHOD.

  METHOD test_nonspecial_schemes.
    DATA(components) = zcl_url=>parse( 'git://example.com' )->components.
    cl_abap_unit_assert=>assert_false( components-is_special ).

    components = zcl_url=>parse( 'about:blank' )->components.
    cl_abap_unit_assert=>assert_false( components-is_special ).
  ENDMETHOD.

  METHOD test_invalid_scheme.
    TRY.
        zcl_url=>parse( '3https://example.com' ).
        cl_abap_unit_assert=>fail( 'Should raise exception for invalid scheme' ).
      CATCH cx_static_check.
        " Expected
    ENDTRY.
  ENDMETHOD.

  METHOD test_userinfo.
    DATA(components) = zcl_url=>parse( 'https://user:pass@example.com' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-username
      exp = 'user' ).
    cl_abap_unit_assert=>assert_equals(
      act = components-password
      exp = 'pass' ).
  ENDMETHOD.

  METHOD test_empty_userinfo.
    DATA(components) = zcl_url=>parse( 'https://@example.com' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-username
      exp = '' ).
    cl_abap_unit_assert=>assert_equals(
      act = components-password
      exp = '' ).
  ENDMETHOD.

  METHOD test_credentials_with_atmark.
    DATA(components) = zcl_url=>parse( 'https://user%40local:pass@example.com' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-username
      exp = 'user@local' ).
  ENDMETHOD.

  METHOD test_ipv4_host.
    DATA(components) = zcl_url=>parse( 'https://192.168.0.1/path' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-host
      exp = '192.168.0.1' ).
  ENDMETHOD.

  METHOD test_ipv6_host.
    DATA(components) = zcl_url=>parse( 'https://[2001:db8::1]/path' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-host
      exp = '2001:db8::1' ).
  ENDMETHOD.

  METHOD test_invalid_ipv6_host.
    TRY.
        zcl_url=>parse( 'https://[2001:db8:::1]/path' ).
        cl_abap_unit_assert=>fail( 'Should raise exception for invalid IPv6' ).
      CATCH cx_static_check.
        " Expected
    ENDTRY.
  ENDMETHOD.

  METHOD test_port_validation.
    DATA(components) = zcl_url=>parse( 'https://example.com:8080' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-port
      exp = '8080' ).

    TRY.
        zcl_url=>parse( 'https://example.com:port' ).
        cl_abap_unit_assert=>fail( 'Should raise exception for invalid port' ).
      CATCH cx_static_check.
        " Expected
    ENDTRY.
  ENDMETHOD.

  METHOD test_path_normalization.
    DATA(components) = zcl_url=>parse( 'https://example.com/a/./b/../../c/' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-path
      exp = '/c/' ).
  ENDMETHOD.

  METHOD test_empty_path.
    DATA(components) = zcl_url=>parse( 'https://example.com' )->components.

    cl_abap_unit_assert=>assert_equals(
    " ... continuing from test_empty_path
      act = components-path
      exp = '' ).
  ENDMETHOD.

  METHOD test_dot_segments.
    DATA(components) = zcl_url=>parse( 'https://example.com/a/../b/./c' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-path
      exp = '/b/c' ).
  ENDMETHOD.

  METHOD test_special_path_chars.
    DATA(components) = zcl_url=>parse(
      'https://example.com/path%20with%20spaces/file.txt' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-path
      exp = '/path with spaces/file.txt' ).
  ENDMETHOD.

  METHOD test_query_basic.
    " Basic query parameter parsing
    DATA(components) = zcl_url=>parse( 'https://example.com/?name=value' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'name=value' ).

    " Multiple parameters
    components = zcl_url=>parse( 'https://example.com/?a=1&b=2' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'a=1&b=2' ).
  ENDMETHOD.

  METHOD test_query_special_chars.
    " Query with special characters that should be percent-encoded
    DATA(components) = zcl_url=>parse( 'https://example.com/?q=special!*()%27' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'q=special!*()%27' ).

    " Verify roundtrip
    DATA(url) = zcl_url=>parse( 'https://example.com/?q=special!*()%27' )->serialize( components ).
    cl_abap_unit_assert=>assert_equals(
      act = url
      exp = 'https://example.com/?q=special!*()%27' ).
  ENDMETHOD.

  METHOD test_query_encoding.
    " Test various encoding scenarios in query parameters
    DATA(components) = zcl_url=>parse( 'https://example.com/?q=%20%2B%3F%26' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'q= +?&' ).

    " Non-ASCII characters
    components = zcl_url=>parse( 'https://example.com/?q=%C3%BC' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'q=ü' ).
  ENDMETHOD.

  METHOD test_query_space_handling.
    " Space handling in query strings
    DATA(components) = zcl_url=>parse( 'https://example.com/?q=hello%20world' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'q=hello world' ).

    " Actual space in URL (should be converted to %20)
    components = zcl_url=>parse( 'https://example.com/?q=hello world' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'q=hello world' ).

    " Verify serialization uses %20
    DATA(url) = zcl_url=>serialize( components ).
    cl_abap_unit_assert=>assert_equals(
      act = url
      exp = 'https://example.com/?q=hello%20world' ).
  ENDMETHOD.

  METHOD test_query_plus_handling.
    " Plus sign handling in query strings
    DATA(components) = zcl_url=>parse( 'https://example.com/?q=hello+world' )->components.

    " According to WHATWG spec, '+' should be treated as a literal '+'
    " in the query string, not as a space
    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'q=hello+world' ).

    " Actual plus sign
    components = zcl_url=>parse( 'https://example.com/?q=1%2B1' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'q=1+1' ).
  ENDMETHOD.

  METHOD test_query_multiple_params.
    " Multiple parameters with various formats
    DATA(components) = zcl_url=>parse( 'https://example.com/?a=1&b=&c=3&d' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'a=1&b=&c=3&d' ).
  ENDMETHOD.

  METHOD test_query_no_value.
    " Parameters without values
    DATA(components) = zcl_url=>parse( 'https://example.com/?key' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'key' ).

    components = zcl_url=>parse( 'https://example.com/?key=' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'key=' ).
  ENDMETHOD.

  METHOD test_query_empty_pairs.
    " Empty parameter pairs
    DATA(components) = zcl_url=>parse( 'https://example.com/?&&&&a=1' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = '&&&&a=1' ).
  ENDMETHOD.

  METHOD test_fragment_basic.
    " Basic fragment handling
    DATA(components) = zcl_url=>parse( 'https://example.com/#section1' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-fragment
      exp = 'section1' ).
  ENDMETHOD.

  METHOD test_fragment_special_chars.
    " Fragment with special characters
    DATA(components) = zcl_url=>parse( 'https://example.com/#section?query&more' )->components.

    " According to WHATWG spec, characters after # are part of the fragment
    cl_abap_unit_assert=>assert_equals(
      act = components-fragment
      exp = 'section?query&more' ).
  ENDMETHOD.

  METHOD test_fragment_encoding.
    " Encoded characters in fragment
    DATA(components) = zcl_url=>parse( 'https://example.com/#section%20with%20spaces' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-fragment
      exp = 'section with spaces' ).

    " Verify proper serialization
    DATA(url) = zcl_url=>serialize( components ).
    cl_abap_unit_assert=>assert_equals(
      act = url
      exp = 'https://example.com/#section%20with%20spaces' ).
  ENDMETHOD.

  METHOD test_fragment_with_query.
    " Fragment after query string
    DATA(components) = zcl_url=>parse( 'https://example.com/?q=1#fragment' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'q=1' ).
    cl_abap_unit_assert=>assert_equals(
      act = components-fragment
      exp = 'fragment' ).

    " Query-like syntax in fragment
    components = zcl_url=>parse( 'https://example.com/#section?param=value' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-fragment
      exp = 'section?param=value' ).

    " Fragment with hash
    components = zcl_url=>parse( 'https://example.com/?query#section#subsection' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-query
      exp = 'query' ).
    cl_abap_unit_assert=>assert_equals(
      act = components-fragment
      exp = 'section#subsection' ).
  ENDMETHOD.

  METHOD test_multiple_hashes.
    " Multiple hash marks
    DATA(components) = zcl_url=>parse( 'https://example.com/#first#second#third' )->components.

    " According to WHATWG spec, everything after the first # is the fragment
    cl_abap_unit_assert=>assert_equals(
      act = components-fragment
      exp = 'first#second#third' ).
  ENDMETHOD.

  METHOD test_percent_encoding.
    DATA(components) = zcl_url=>parse( 'https://example.com/path%20with%20spaces/%23fragment' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-path
      exp = '/path with spaces/#fragment' ).

    " Test serialization preserves encoding where necessary
    DATA(url) = zcl_url=>serialize( components ).
    cl_abap_unit_assert=>assert_equals(
      act = url
      exp = 'https://example.com/path%20with%20spaces/%23fragment' ).
  ENDMETHOD.

  METHOD test_percent_decoding.
    DATA(components) = zcl_url=>parse( 'https://user%3Aname:pass%40word@example.com' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-username
      exp = 'user:name' ).
    cl_abap_unit_assert=>assert_equals(
      act = components-password
      exp = 'pass@word' ).
  ENDMETHOD.

  METHOD test_invalid_percent_encoding.
    " Test incomplete percent encoding
    DATA(components) = zcl_url=>parse( 'https://example.com/path%2' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-path
      exp = '/path%2' ).

    " Test invalid hex digits
    components = zcl_url=>parse( 'https://example.com/path%XY' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-path
      exp = '/path%XY' ).
  ENDMETHOD.

  METHOD test_idna_domains.
    " TODO: requires zcl_punycode
*    DATA(components) = zcl_url=>parse( 'https://müller.de/path' )->components.
*
*    " Note: In a real implementation, this should be converted to Punycode
*    cl_abap_unit_assert=>assert_equals(
*      act = components-host
*      exp = 'xn--mller-kva.de' ).
  ENDMETHOD.

  METHOD test_punycode.
    DATA(components) = zcl_url=>parse( 'https://xn--mnchen-3ya.de/path' )->components.

    cl_abap_unit_assert=>assert_equals(
      act = components-host
      exp = 'xn--mnchen-3ya.de' ).
  ENDMETHOD.

  METHOD test_url_serialization.
    " Test complete URL serialization
    DATA(components) = VALUE zcl_url=>ty_url_components(
      scheme   = 'https'
      username = 'user'
      password = 'pass'
      host     = 'example.com'
      port     = '8080'
      path     = '/path/to/resource'
      query    = 'key=value'
      fragment = 'section'
    ).

    DATA(url) = zcl_url=>serialize( components ).
    cl_abap_unit_assert=>assert_equals(
      act = url
      exp = 'https://user:pass@example.com:8080/path/to/resource?key=value#section' ).
  ENDMETHOD.

  METHOD test_special_url_serialization.
    " Test file URL
    DATA(components) = VALUE zcl_url=>ty_url_components(
      scheme = 'file'
      host   = ''
      path   = '/C:/path/to/file.txt'
    ).

    DATA(url) = zcl_url=>serialize( components ).
    cl_abap_unit_assert=>assert_equals(
      act = url
      exp = 'file:///C:/path/to/file.txt' ).

    " Test URL with empty username but password
    components = VALUE zcl_url=>ty_url_components(
      scheme   = 'https'
      username = ''
      password = 'pass'
      host     = 'example.com'
    ).

    url = zcl_url=>serialize( components ).
    cl_abap_unit_assert=>assert_equals(
      act = url
      exp = 'https://:pass@example.com' ).
  ENDMETHOD.

  METHOD test_query_fragment_combis.
    " Test various combinations of query and fragment

    " Only path
    DATA(components) = zcl_url=>parse( 'https://example.com/path' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-path exp = '/path' ).
    cl_abap_unit_assert=>assert_initial( components-query ).
    cl_abap_unit_assert=>assert_initial( components-fragment ).

    " Path with query
    components = zcl_url=>parse( 'https://example.com/path?query=1' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-path exp = '/path' ).
    cl_abap_unit_assert=>assert_equals( act = components-query exp = 'query=1' ).
    cl_abap_unit_assert=>assert_initial( components-fragment ).

    " Path with fragment
    components = zcl_url=>parse( 'https://example.com/path#fragment' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-path exp = '/path' ).
    cl_abap_unit_assert=>assert_initial( components-query ).
    cl_abap_unit_assert=>assert_equals( act = components-fragment exp = 'fragment' ).

    " Path with query and fragment
    components = zcl_url=>parse( 'https://example.com/path?query=1#fragment' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-path exp = '/path' ).
    cl_abap_unit_assert=>assert_equals( act = components-query exp = 'query=1' ).
    cl_abap_unit_assert=>assert_equals( act = components-fragment exp = 'fragment' ).

    " Fragment before query (according to WHATWG spec)
    components = zcl_url=>parse( 'https://example.com/path#fragment?query=1' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-path exp = '/path' ).
    cl_abap_unit_assert=>assert_initial( components-query ).
    cl_abap_unit_assert=>assert_equals( act = components-fragment exp = 'fragment?query=1' ).

    " Empty query
    components = zcl_url=>parse( 'https://example.com/path?' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-path exp = '/path' ).
    cl_abap_unit_assert=>assert_equals( act = components-query exp = '' ).
    cl_abap_unit_assert=>assert_initial( components-fragment ).

    " Empty fragment
    components = zcl_url=>parse( 'https://example.com/path#' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-path exp = '/path' ).
    cl_abap_unit_assert=>assert_initial( components-query ).
    cl_abap_unit_assert=>assert_equals( act = components-fragment exp = '' ).

    " Multiple question marks
    components = zcl_url=>parse( 'https://example.com/path?query=1?more=2' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-path exp = '/path' ).
    cl_abap_unit_assert=>assert_equals( act = components-query exp = 'query=1?more=2' ).
    cl_abap_unit_assert=>assert_initial( components-fragment ).

    " Multiple hash marks
    components = zcl_url=>parse( 'https://example.com/path#frag1#frag2' )->components.
    cl_abap_unit_assert=>assert_equals( act = components-path exp = '/path' ).
    cl_abap_unit_assert=>assert_initial( components-query ).
    cl_abap_unit_assert=>assert_equals( act = components-fragment exp = 'frag1#frag2' ).
  ENDMETHOD.

ENDCLASS.
