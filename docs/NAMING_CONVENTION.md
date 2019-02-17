# Naming Conventions

Everything is named as something from Terry Pratchett's Discworld series. 

Names should follow RFC1123 specification (only lowercase letters, numbers and `-` sign).

### Locations/Availability Zones

Should be named as lands from Discworld.
Currently in use:
- ankhmorpork
- lancre

### Servers

Servers should be named as characters from Discworld in a way that reflects nature of a chosen character ex.:

"Vetinari" - living in Ankhmorpork AZ and managing it. Name for Home Assistant server.

Currently in use:
- rincewind
- vetinari
- dibbler
- nacmacfeegle0[1-3] (etcd cluster)

Currently only one exception is `nas.ankhmorpork`. This should be changed in the future.

### DNS names (WIP)

TLD for everything is `thaum.xyz`. Every server should be named in a following format:

```
<short_hostname>.<az>.<tld>

Example:
vetinari.ankhmorpork.thaum.xyz
```
