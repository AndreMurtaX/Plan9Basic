# HttpLib - HTTP Client Library for Plan9Basic

## Overview

HttpLib provides comprehensive HTTP client functionality for Plan9Basic, enabling RESTful API interactions, file transfers, and full HTTP protocol support across all platforms.

**Version:** 4.0
**Total Functions:** 92

## Features

- All HTTP methods (GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS)
- **Comprehensive form data support** (text fields + multiple files)
- Multipart/form-data uploads
- File download and upload
- Custom headers and cookies
- Basic, Bearer, and custom authentication
- Query string parameter building
- Proxy configuration
- SSL/TLS configuration
- Response caching and access
- URL/HTML encoding utilities
- Simple one-liner functions for quick requests

---

## Error Handling

### Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 0 | ERR_NONE | No error |
| 1 | ERR_INVALID_CLIENT | Invalid or null client pointer |
| 2 | ERR_INVALID_URL | Malformed URL |
| 3 | ERR_CONNECTION | Network connection failed |
| 4 | ERR_TIMEOUT | Request timed out |
| 5 | ERR_SSL | SSL/TLS certificate error |
| 6 | ERR_INVALID_ARGUMENT | Invalid function argument |
| 7 | ERR_FILE | File read/write error |
| 8 | ERR_AUTH | Authentication failed |
| 9 | ERR_INVALID_RESPONSE | Malformed response |
| 10 | ERR_INVALID_FORM | Invalid form data pointer |

### Error Functions

```basic
' Get last error code
let errcode = http_error()

' Get detailed error message
let errmsg$ = http_errormsg$()

' Get description for error code
let desc$ = http_strerror$(errcode)

' Clear error state
let result = http_clearerror()
```

---

## Client Management

### Creating a Client

```basic
' Create basic client
let client# = http_client#

' Create client with base URL
let client# = http_client#("https://api.example.com")
```

### Client Lifecycle

```basic
' Free client when done
let success = http_free(client#)

' Reset client to defaults
let client# = http_reset#(client#)
```

---

## Configuration

All configuration functions return the client pointer for chaining.

### Base URL and Timeouts

```basic
' Set base URL
let client# = http_baseurl#(client#, "https://api.example.com")

' Get base URL
let url$ = http_baseurl$(client#)

' Set connection timeout (milliseconds)
let client# = http_timeout#(client#, 30000)

' Get connection timeout
let ms = http_timeout(client#)

' Set response timeout
let client# = http_responsetimeout#(client#, 60000)
```

### Headers and Content

```basic
' Set User-Agent
let client# = http_useragent#(client#, "MyApp/1.0")

' Set Content-Type
let client# = http_contenttype#(client#, "application/json")

' Set Accept header
let client# = http_accept#(client#, "application/json")
```

### Redirects and SSL

```basic
' Enable/disable redirect following (1=on, 0=off)
let client# = http_followredirects#(client#, 1)

' Set maximum redirects
let client# = http_maxredirects#(client#, 5)

' Enable/disable SSL certificate validation
let client# = http_validatessl#(client#, 1)
```

---

## Query String Parameters

```basic
' Add/update query parameter
let client# = http_param#(client#, "page", "1")
let client# = http_param#(client#, "limit", "20")

' Get parameter value
let value$ = http_param$(client#, "page")

' Remove parameter
let client# = http_paramremove#(client#, "page")

' Clear all parameters
let client# = http_paramclear#(client#)
```

Parameters are automatically URL-encoded and appended to requests.

---

## Custom Headers

```basic
' Set header
let client# = http_header#(client#, "X-API-Key", "abc123")
let client# = http_header#(client#, "X-Request-ID", "req-456")

' Get header value
let apikey$ = http_header$(client#, "X-API-Key")

' Remove header
let client# = http_headerremove#(client#, "X-API-Key")

' Clear all headers
let client# = http_headerclear#(client#)

' Get header count
let count = http_headercount(client#)
```

---

## Authentication

### Basic Authentication

```basic
let client# = http_basicauth#(client#, "username", "password")
```

### Bearer Token

```basic
let client# = http_bearerauth#(client#, "eyJhbGciOiJIUzI1NiIs...")
```

### Custom Authorization

```basic
let client# = http_customauth#(client#, "ApiKey my-secret-key")
```

### Clear Authentication

```basic
let client# = http_clearauth#(client#)
```

---

## Cookie Management

```basic
' Set cookie
let client# = http_cookie#(client#, "session", "abc123")

' Get cookie value
let session$ = http_cookie$(client#, "session")

' Remove cookie
let client# = http_cookieremove#(client#, "session")

' Clear all cookies
let client# = http_cookieclear#(client#)

' Get cookie count
let count = http_cookiecount(client#)
```

---

## Proxy Configuration

```basic
' Set proxy server
let client# = http_proxy#(client#, "proxy.example.com", 8080)

' Set proxy authentication
let client# = http_proxyauth#(client#, "proxyuser", "proxypass")

' Clear proxy settings
let client# = http_clearproxy#(client#)
```

---

## Form Data

The form data system allows building complex multipart forms with both text fields and multiple files.

### Creating Form Data

```basic
' Create empty form
let form# = http_form#()
```

### Adding Text Fields

```basic
let form# = http_formfield#(form#, "username", "john")
let form# = http_formfield#(form#, "email", "john@example.com")
let form# = http_formfield#(form#, "message", "Hello World!")
```

### Adding Files

```basic
' Add file (uses original filename)
let form# = http_formfile#(form#, "document", "C:\docs\report.pdf")

' Add file with custom filename
let form# = http_formfilenamed#(form#, "avatar", "C:\pics\me.jpg", "profile.jpg")

' Add file with custom filename and content type
let form# = http_formfiletype#(form#, "data", "C:\data\export.csv", "data.csv", "text/csv")
```

### Form Utilities

```basic
' Get field count (text fields only)
let fields = http_formfieldcount(form#)

' Get file count
let files = http_formfilecount(form#)

' Get URL-encoded string (text fields only)
let encoded$ = http_formurlencoded$(form#)

' Clear all fields
let form# = http_formclear#(form#)

' Free form data
let success = http_formfree(form#)
```

### Posting Form Data

```basic
' POST as multipart/form-data (supports files)
let response$ = http_postform$(client#, "/upload", form#)

' POST as application/x-www-form-urlencoded (text fields only)
let response$ = http_postformurl$(client#, "/login", form#)

' PUT as multipart/form-data
let response$ = http_putform$(client#, "/update", form#)
```

---

## HTTP Methods (Synchronous)

These functions block until the request completes. Use on desktop platforms.

### GET Request

```basic
let response$ = http_get$(client#, "/api/users")
let response$ = http_get$(client#, "/api/users/123")
```

### POST Request

```basic
' POST with JSON body
let body$ = "{\"name\":\"John\",\"email\":\"john@example.com\"}"
let response$ = http_post$(client#, "/api/users", body$)

' POST with form string
let formdata$ = "username=john&password=secret"
let response$ = http_postformstr$(client#, "/login", formdata$)
```

### PUT Request

```basic
let body$ = "{\"name\":\"John Updated\"}"
let response$ = http_put$(client#, "/api/users/123", body$)
```

### PATCH Request

```basic
let body$ = "{\"email\":\"newemail@example.com\"}"
let response$ = http_patch$(client#, "/api/users/123", body$)
```

### DELETE Request

```basic
let response$ = http_delete$(client#, "/api/users/123")
```

### HEAD Request

```basic
let ok = http_head(client#, "/api/resource")
let statusCode = http_status(client#)
let contentLength = http_contentlength(client#)
```

### OPTIONS Request

```basic
let allowedMethods$ = http_options$(client#, "/api/users")
```

---

## Response Access

### Status Information

```basic
' Get status code (200, 404, 500, etc.)
let status = http_status(client#)

' Get status text ("OK", "Not Found", etc.)
let statusText$ = http_statustext$(client#)

' Check if successful (2xx)
if http_ok(client#) <> 0 then
    println "Success!"
end if

' Check response categories
let isRedirect = http_isredirect(client#)      ' 3xx
let isClientErr = http_isclienterror(client#)  ' 4xx
let isServerErr = http_isservererror(client#)  ' 5xx
```

### Response Body

```basic
' Get response body
let body$ = http_body$(client#)

' Get response body as Base64 (for binary content)
let base64$ = http_bodybase64$(client#)

' Save body to file
let success = http_savebody(client#, "C:\response.json")
```

### Response Headers

```basic
' Get specific header
let contentType$ = http_respheader$(client#, "Content-Type")

' Get all headers as text
let allHeaders$ = http_respheaders$(client#)

' Get header count
let count = http_respheadercount(client#)

' Iterate headers by index
for i = 0 to count - 1
    let name$ = http_respheadername$(client#, i)
    let value$ = http_respheadervalue$(client#, i)
    println name$ + ": " + value$
next
```

### Response Cookies

```basic
' Get specific cookie
let session$ = http_respcookie$(client#, "session_id")

' Get all cookies
let allCookies$ = http_respcookies$(client#)

' Get cookie count
let count = http_respcookiecount(client#)
```

### Other Response Info

```basic
' Get content type
let contentType$ = http_respcontenttype$(client#)

' Get content length
let length = http_contentlength(client#)

' Get redirect URL (if 3xx response)
let redirectUrl$ = http_redirecturl$(client#)
```

---

## File Operations

### Download File

```basic
let success = http_download(client#, "/files/document.pdf", "C:\downloads\doc.pdf")

if success <> 0 then
    println "Downloaded successfully"
else
    println "Download failed: " + http_errormsg$()
end if
```

### Upload File (Raw Body)

```basic
' Upload as POST (raw file content)
let response$ = http_upload$(client#, "/upload", "C:\file.bin")

' Upload as PUT (raw file content)
let response$ = http_uploadput$(client#, "/files/123", "C:\file.bin")
```

### Upload File (Multipart)

```basic
' Single file upload as multipart
let response$ = http_postfile$(client#, "/upload", "file", "C:\docs\report.pdf")
```

---

## URL and HTML Encoding

```basic
' URL encode/decode
let encoded$ = http_urlencode$("hello world & more")
' Result: "hello%20world%20%26%20more"

let decoded$ = http_urldecode$("hello%20world")
' Result: "hello world"

' HTML encode/decode
let htmlEnc$ = http_htmlencode$("<script>alert('hi')</script>")
' Result: "&lt;script&gt;alert('hi')&lt;/script&gt;"

let htmlDec$ = http_htmldecode$("&lt;p&gt;")
' Result: "<p>"
```

---

## Simple Functions (No Client Required)

For quick one-off requests without creating a client:

```basic
' Simple GET
let response$ = http_simpleget$("https://api.example.com/data")

' Simple POST
let body$ = "{\"key\":\"value\"}"
let response$ = http_simplepost$("https://api.example.com/data", body$)

' Simple download
let success = http_simpledownload("https://example.com/file.zip", "C:\file.zip")
```

---

## Complete Examples

### Example 1: REST API Client (Desktop)

```basic
' Create API client
let api# = http_client#("https://jsonplaceholder.typicode.com")
let api# = http_accept#(api#, "application/json")

' GET request
let users$ = http_get$(api#, "/users")
if http_ok(api#) <> 0 then
    println "Users: " + users$
end if

' POST new user
let newUser$ = "{\"name\":\"John\",\"email\":\"john@test.com\"}"
let result$ = http_post$(api#, "/users", newUser$)
println "Created: " + result$

let x = http_free(api#)
```

### Example 2: File Upload with Form Fields

```basic
let client# = http_client#("https://upload.example.com")
let client# = http_bearerauth#(client#, myToken$)

' Build form with metadata and file
let form# = http_form#()
let form# = http_formfield#(form#, "title", "Quarterly Report")
let form# = http_formfield#(form#, "department", "Finance")
let form# = http_formfield#(form#, "year", "2024")
let form# = http_formfile#(form#, "document", "C:\Reports\Q4-2024.pdf")

' Upload
let response$ = http_postform$(client#, "/api/reports/upload", form#)

if http_ok(client#) <> 0 then
    println "Upload complete!"
else
    println "Failed: " + stri$(http_status(client#))
end if

let x = http_formfree(form#)
let x = http_free(client#)
```

### Example 3: Login with Session Cookie

```basic
let client# = http_client#("https://app.example.com")

' Login
let form# = http_form#()
let form# = http_formfield#(form#, "username", "john")
let form# = http_formfield#(form#, "password", "secret123")

let response$ = http_postformurl$(client#, "/login", form#)

if http_ok(client#) <> 0 then
    ' Get session cookie from response
    let sessionId$ = http_respcookie$(client#, "session_id")
    
    ' Set it for future requests
    let client# = http_cookie#(client#, "session_id", sessionId$)
    
    ' Access protected resource
    let data$ = http_get$(client#, "/api/dashboard")
    println data$
end if

let x = http_formfree(form#)
let x = http_free(client#)
```

---

## Function Reference Summary

### Error Handling (4 functions)
- `http_error` - Get last error code
- `http_errormsg$` - Get last error message
- `http_strerror$(code)` - Get error description
- `http_clearerror` - Clear error state

### Client Management (4 functions)
- `http_client#` - Create client
- `http_client#(baseUrl$)` - Create client with base URL
- `http_free(client#)` - Free client
- `http_reset#(client#)` - Reset to defaults

### Configuration (11 functions)
- `http_baseurl#`, `http_baseurl$`
- `http_timeout#`, `http_timeout`
- `http_responsetimeout#`
- `http_useragent#`
- `http_contenttype#`
- `http_accept#`
- `http_followredirects#`
- `http_maxredirects#`
- `http_validatessl#`

### Query Parameters (4 functions)
- `http_param#`, `http_param$`
- `http_paramremove#`, `http_paramclear#`

### Headers (5 functions)
- `http_header#`, `http_header$`
- `http_headerremove#`, `http_headerclear#`
- `http_headercount`

### Authentication (4 functions)
- `http_basicauth#`, `http_bearerauth#`
- `http_customauth#`, `http_clearauth#`

### Cookies (5 functions)
- `http_cookie#`, `http_cookie$`
- `http_cookieremove#`, `http_cookieclear#`
- `http_cookiecount`

### Proxy (3 functions)
- `http_proxy#`, `http_proxyauth#`, `http_clearproxy#`

### Form Data (10 functions)
- `http_form#` - Create form
- `http_formfield#` - Add text field
- `http_formfile#` - Add file
- `http_formfilenamed#` - Add file with custom name
- `http_formfiletype#` - Add file with name and content type
- `http_formclear#` - Clear fields
- `http_formfieldcount` - Count text fields
- `http_formfilecount` - Count files
- `http_formurlencoded$` - Get URL-encoded string
- `http_formfree` - Free form

### Synchronous HTTP Methods (11 functions)
- `http_get$`, `http_post$`
- `http_postform$`, `http_postformurl$`, `http_postformstr$`
- `http_put$`, `http_putform$`
- `http_patch$`, `http_delete$`
- `http_head`, `http_options$`

### Response Access (20 functions)
- `http_status`, `http_statustext$`
- `http_body$`, `http_bodybase64$`, `http_savebody`
- `http_respheader$`, `http_respheaders$`
- `http_respheadercount`, `http_respheadername$`, `http_respheadervalue$`
- `http_respcookie$`, `http_respcookies$`, `http_respcookiecount`
- `http_respcontenttype$`, `http_contentlength`
- `http_redirecturl$`
- `http_ok`, `http_isredirect`, `http_isclienterror`, `http_isservererror`

### File Operations (4 functions)
- `http_download`, `http_upload$`, `http_uploadput$`
- `http_postfile$`

### Encoding Utilities (4 functions)
- `http_urlencode$`, `http_urldecode$`
- `http_htmlencode$`, `http_htmldecode$`

### Simple Functions (3 functions)
- `http_simpleget$`, `http_simplepost$`, `http_simpledownload`

---

## Integration

Add to your Delphi project:

```pascal
uses
  HttpLib;

// In initialization
RegisterHttpFuncs(LibFunctionsTable, BasicEngine, ConsoleOutput);
```

Required Delphi units:
- System.Net.HttpClient
- System.Net.URLClient  
- System.Net.HttpClientComponent
- System.Net.Mime
- System.NetEncoding

