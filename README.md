Forked from: https://github.com/propublica/daybreak

> Daybreak is a simple key value store for ruby. It has user defined persistence,
> and all data is stored in a table in memory so ruby niceties are available.
> Daybreak is faster than other ruby options like pstore or dbm.

The original code doesn't appear to be maintained anymore. I maintain it 
for my own personal and work projects.


**Repository**: https://github.com/muquit/daybreak


# How to build

```
rake build
daybreak 0.3.2 built to pkg/daybreak-0.3.2.gem
```

# Install

Do not install by calling: `gem install daybreak`, you will install the 
old version, which does not work with newer versions of ruby. Install from
llocal gem as follows:

```
gem install --force --no-document pkg/daybreak-0.3.2.gem
```
If you are not using rvm, `sudo` the command.

# Examples
See the [`examples/`](examples/) directory for sample scripts:


- `ruby create_db.rb` - create database
- `ruby dump_db.rb`      - dump all data
- `ruby dump_db_json.rb` - dump in pretty print JSON format
- `ruby update_db.rb`    - update some records
- `ruby delete_db.rb`    - delete some records
- `ruby batch.rb`        - batch operations
- `ruby maintenance.rb`  - maintenance tasks
- `safe_daybreak.rb`     - Safely read/write by checking disk space to avoid
corruption.

---
Original README:
```
               ^^            |
    daybreak     ^^        \ _ /
                        -= /   \ =-
  ~^~ ^ ^~^~ ~^~ ~ ~^~~^~^-=~=~=-~^~^~^~

Daybreak is a simple key value store for ruby. It has user defined persistence,
and all data is stored in a table in memory so ruby niceties are available.
Daybreak is faster than other ruby options like pstore or dbm.

$ gem install daybreak

You can find detailed documentation at http://propublica.github.com/daybreak.
```

