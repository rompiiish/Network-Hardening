# Change log

1. Removed TLSv1 and TLSv1.1 from ssl_protocols.
2. Restricted cipher policy to modern AEAD-oriented suites.
3. Kept ssl_prefer_server_ciphers on.
4. Added HSTS header with max-age=300.
5. Added rate limiting on /api.
6. Added Host header filtering.
7. Restricted methods on /.
8. Added SQLi-style query-string blocking on /search.
