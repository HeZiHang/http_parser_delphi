unit uLibHttpParser;

interface

const
  LIBFILE = 'libhttpparser.dll';

type
  ULONG_PTR = NativeUInt;
  SIZE_T = ULONG_PTR;

  http_method = (http_DELETE = 0, http_GET = 1, http_HEAD = 2, http_POST = 3, http_PUT = 4,
    // pathological
    http_CONNECT = 5, http_OPTIONS = 6, http_TRACE = 7,
    // WebDAV
    http_COPY = 8, http_LOCK = 9, http_MKCOL = 10, http_MOVE = 11, http_PROPFIND = 12, http_PROPPATCH = 13, http_SEARCH = 14, http_UNLOCK = 15, http_BIND = 16, http_REBIND = 17, http_UNBIND = 18,
    http_ACL = 19,
    // subversion
    http_REPORT = 20, http_MKACTIVITY = 21, http_CHECKOUT = 22, http_MERGE = 23,
    // upnp
    http_MSEARCH = 24, http_NOTIFY = 25, http_SUBSCRIBE = 26, http_UNSUBSCRIBE = 27,
    // RFC-5789
    http_PATCH = 28, http_PURGE = 29,
    // CalDAV
    http_MKCALENDAR = 30,
    // RFC-2068,section 19.6.1.2
    http_LINK = 31, http_UNLINK = 32,
    // Ntrip 1.0
    http_SOURCE = 33);

  http_parser = record
    privatee: UInt32;
    // (** PRIVATE **)
    // unsigned int type : 2;         (* enum http_parser_type *)
    // unsigned int flags : 8;        (* F_* values from 'flags' enum; semi-public *)
    // unsigned int state : 7;        (* enum state from http_parser.c *)
    // unsigned int header_state : 7; (* enum header_state from http_parser.c *)
    // unsigned int index : 7;        (* index into current matcher *)
    // unsigned int lenient_http_headers : 1;
    nread: UInt32; (* # bytes read in various scenarios *)
    content_length: UInt64; (* # bytes in body (0 if no Content-Length header) *)
    (* * READ-ONLY * *)
    http_major: UInt16;
    http_minor: UInt16;
    status: UInt32;
    // unsigned int status_code : 16; (* responses only *)
    // unsigned int method : 8;       (* requests only *)
    // unsigned int http_errno : 7;
    //
    // (* 1 = Upgrade header was present and the parser has exited because of that.
    // * 0 = No upgrade header present.
    // * Should be checked when http_parser_execute() returns in addition to
    // * error checking.
    // *)
    // unsigned int upgrade : 1;

    (* * PUBLIC * *)
    data: Pointer; (* A pointer to get hook to the "connection" or "socket" object *)
    function &type: UInt32; inline; (* enum http_parser_type *)
    function flags: UInt32; inline; (* F_* values from 'flags' enum;inline; semi-public *)
    function state: UInt32; inline; (* enum state from http_parser.c *)
    function header_state: UInt32; inline; (* enum header_state from http_parser.c *)
    function index: UInt32; inline; (* index into current matcher *)
    function lenient_http_headers: UInt32; inline;
    function status_code: UInt32; inline; (* responses only *)
    function method: UInt32; inline; (* requests only *)
    function http_errno: UInt32; inline;
    function upgrade: UInt32; inline;
  end;

  phttp_parser = Pointer;
  http_parser_type = (HTTP_REQUEST, HTTP_RESPONSE, HTTP_BOTH);
  http_errno = (HPE_OK,
    // Callback-related errors
    HPE_CB_message_begin, HPE_CB_url, HPE_CB_header_field, HPE_CB_header_value, HPE_CB_headers_complete, HPE_CB_body, HPE_CB_message_complete, HPE_CB_status, HPE_CB_chunk_header,
    HPE_CB_chunk_complete,
    // Parsing-related errors
    HPE_INVALID_EOF_STATE, HPE_HEADER_OVERFLOW, HPE_CLOSED_CONNECTION, HPE_INVALID_VERSION, HPE_INVALID_STATUS, HPE_INVALID_METHOD, HPE_INVALID_URL, HPE_INVALID_HOST, HPE_INVALID_PORT,
    HPE_INVALID_PATH, HPE_INVALID_QUERY_STRING, HPE_INVALID_FRAGMENT, HPE_LF_EXPECTED, HPE_INVALID_HEADER_TOKEN, HPE_INVALID_CONTENT_LENGTH, HPE_UNEXPECTED_CONTENT_LENGTH, HPE_INVALID_CHUNK_SIZE,
    HPE_INVALID_CONSTANT, HPE_INVALID_INTERNAL_STATE, HPE_STRICT, HPE_PAUSED, HPE_UNKNOWN);

const
  http_errno_str: array [http_errno] of String = ('success', 'the on_message_begin callback failed', 'the on_url callback failed', 'the on_header_field callback failed',
    'the on_header_value callback failed', 'the on_headers_complete callback failed', 'the on_body callback failed', 'the on_message_complete callback failed', 'the on_status callback failed',
    'the on_chunk_header callback failed', 'the on_chunk_complete callback failed', 'stream ended at an unexpected time', 'too many header bytes seen; overflow detected',
    'data received after completed connection: close message', 'invalid HTTP version', 'invalid HTTP status code', 'invalid HTTP method', 'invalid URL', 'invalid host', 'invalid port', 'invalid path',
    'invalid query string', 'invalid fragment', 'LF character expected', 'invalid character in header', 'invalid character in content-length header', 'unexpected content-length header',
    'invalid character in chunk size header', 'invalid constant string', 'encountered unexpected internal state', 'strict mode assertion failed', 'parser is paused', 'an unknown error occurred');

type
  http_data_cb = function(p: phttp_parser; const at: PAnsiChar; length: SIZE_T): Integer; cdecl;
  http_cb = function(p: phttp_parser): Integer; cdecl;

  http_parser_settings = record
    on_message_begin: http_cb;
    on_url: http_data_cb;
    on_status: http_data_cb;
    on_header_field: http_data_cb;
    on_header_value: http_data_cb;
    on_headers_complete: http_cb;
    on_body: http_data_cb;
    on_message_complete: http_cb;
    (* When on_chunk_header is called, the current chunk length is stored
      * in parser->content_length.
    *)
    on_chunk_header: http_cb;
    on_chunk_complete: http_cb;
    on_ntripsource_password: http_data_cb;
  end;

  phttp_parser_settings = ^http_parser_settings;

  http_parser_url_fields = (UF_SCHEMA = 0, UF_HOST = 1, UF_PORT = 2, UF_PATH = 3, UF_QUERY = 4, UF_FRAGMENT = 5, UF_USERINFO = 6, UF_MAX = 7);

  http_parser_url_field_data = record
    off: UInt16; (* Offset into buffer in which field starts *)
    len: UInt16; (* Length of run in buffer *)
  end;

  http_parser_url = record
    field_set: UInt16; (* Bitmask of (1 << UF_* ) values *)
    port: UInt16; (* Converted UF_PORT string *)
    field_data: array [http_parser_url_fields] of http_parser_url_field_data;
  end;

  phttp_parser_url = ^http_parser_url;

function http_parser_version: LongWord; cdecl;

procedure http_parser_init(parser: phttp_parser; t: http_parser_type); cdecl;

procedure http_parser_settings_init(settings: phttp_parser_settings); cdecl;

function http_parser_execute(parser: phttp_parser; const settings: phttp_parser_settings; const data: Pointer; len: SIZE_T): SIZE_T; cdecl;

function http_should_keep_alive(const parser: phttp_parser): Integer; cdecl;

function http_method_str(m: http_method): PAnsiChar; cdecl;

function http_errno_name(err: http_errno): PAnsiChar; cdecl;

function http_errno_description(err: http_errno): PAnsiChar; cdecl;

procedure http_parser_url_init(u: phttp_parser_url); cdecl;

function http_parser_parse_url(const buf: PAnsiChar; buflen: SIZE_T; is_connect: Integer; u: phttp_parser_url): Integer; cdecl;

procedure http_parser_pause(parser: phttp_parser; paused: Integer); cdecl;

function http_body_is_final(const parser: phttp_parser): Integer; cdecl;

implementation

function http_parser_version; external LIBFILE;

procedure http_parser_init; external LIBFILE;

procedure http_parser_settings_init; external LIBFILE;

function http_parser_execute; external LIBFILE;

function http_should_keep_alive; external LIBFILE;

function http_method_str; external LIBFILE;

function http_errno_name; external LIBFILE;

function http_errno_description; external LIBFILE;

procedure http_parser_url_init; external LIBFILE;

function http_parser_parse_url; external LIBFILE;

procedure http_parser_pause; external LIBFILE;

function http_body_is_final; external LIBFILE;

{ http_parser }

function http_parser.flags: UInt32;
begin
  Result := (privatee shr 2) and $FF;
end;

function http_parser.header_state: UInt32;
begin
  Result := (privatee shr 17) and $7F;
end;

function http_parser.http_errno: UInt32;
begin
  Result := (status shr 24) and $7F;
end;

function http_parser.index: UInt32;
begin
  Result := (status shr 24) and $7F;
end;

function http_parser.lenient_http_headers: UInt32;
begin
  Result := privatee shr 31;
end;

function http_parser.method: UInt32;
begin
  Result := (status shr 16) and $FF;
end;

function http_parser.state: UInt32;
begin
  Result := (privatee shr 10) and $7F;
end;

function http_parser.status_code: UInt32;
begin
  Result := status and $FFFF;
end;

function http_parser.&type: UInt32;
begin
  Result := privatee and $3;
end;

function http_parser.upgrade: UInt32;
begin
  Result := status shr 31;
end;

end.
