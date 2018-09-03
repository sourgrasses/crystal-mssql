# crystal-mssql

A wrapper around the unixODBC API, allowing one to connect to Microsoft SQL Server and, ostensibly, other databases that support ODBC from Crystal using the crystal-db API.

## Status

This is very much still a work in progress. Right now I'm definitely privileging making this work with MS SQL Server, mostly testing against SQL Server 2008 from Arch Linux and macOS when I get the chance.

Lots of things don't work or aren't yet implemented, all io is blocking, and I've used weird workarounds in a few places to deal with some pointer and buffer issues that definitely need to be cleaned up among many other things.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  crystal-mssql:
    github: sourgrasses/crystal-mssql
```

## Usage

```crystal
require "crystal-mssql"
require "db"

# connect to SQL Server dsn specified in /etc/odbc.ini or some other config file
DB.open "mssql://user:password@dsn" do |db|
  db.exec "drop table if exists goodfriends"
  db.exec "create table goodfriends (name varchar(30), age int)"
  db.exec "insert into goodfriends values (?, ?)", "Ben Buddy", 28

  args = [] of DB::Any
  args << "Sarah Bear"
  args << 33
  db.exec "insert into contacts values (?, ?)", args

  puts "max age:"
  puts db.scalar "select max(age) from contacts" # => 33

  puts "contacts:"
  db.query "select name, age from contacts order by age desc" do |rs|
    puts "#{rs.column_name(0)} (#{rs.column_name(1)})"
    # => name (age)
    rs.each do
      puts "#{rs.read} (#{rs.read})"
      # => Sarah Bear (33)
      # => Ben Buddy (28)
    end
  end
end
```

## Development

TODO: Lots and lots!

## Contributing

1. Fork it ( https://github.com/sourgrasses/crystal-mssql/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request
