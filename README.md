# nntp-lib

This is a pure Crystal source (single file, fully documented) code, provides
a minimum requisite functions for NNTP (Network News Transfer Protocol)
clients, per [RFC977](http://www.ietf.org/rfc/rfc977.txt), extensions
[RFC2980](http://www.ietf.org/rfc/rfc2980.txt) and authentication [DRAFT](http://www.ietf.org/internet-drafts/draft-ietf-nntpext-authinfo-07.txt).

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     nntp-lib:
       github: spoved/nntp-lib.cr
   ```

2. Run `shards install`

## Usage

The NNTP socket can be established via the `start` method which yields itself to the provided block.

```crystal
require "nntp-lib"

nntp = Net::NNTP.new("secure.usenetserver.com", 563)
nntp.start(user: "myuser", secret: "pass", :original) do |socket|
  # Perform nntp requests here
end
```

The socket can also be started without a block, but `finish` should be called to close the nntp session.

```crystal
require "nntp-lib"

nntp = Net::NNTP.new("secure.usenetserver.com", 563)
nntp.start(user: "myuser", secret: "pass", :original)

# Perform nntp requests here

nntp.finish
```

## Missing Features

* [RFC977](https://www.ietf.org/rfc/rfc977.txt)
  * 3.4.  The IHAVE command
  * 3.10.  The POST command
* [RFC2980](https://www.ietf.org/rfc/rfc2980.txt)
  * 1.3.1  The TAKETHIS command
  * 1.4.1  The XREPLIC command
  * 2.1.1 Extensions to the LIST command
  * 2.2 LISTGROUP
  * 2.4 XGTITLE
  * 2.7 XINDEX
  * 2.9 XPAT
  * 2.10 The XPATH command
  * 2.11 The XROVER command
  * 2.12 XTHREAD
  * 3.3 The WILDMAT format
* Misc commands
  * xfeature compress gzip [terminator]
  * xzver [range]
  * xzhdr field [range]

## Contributing

1. Fork it (<https://github.com/spoved/nntp-lib.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Holden Omans](https://github.com/kalinon) - creator and maintainer
