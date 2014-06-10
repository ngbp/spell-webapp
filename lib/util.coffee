util = module.exports = {}

# Determine if a relative path passed refers to a vendor file
_inVendor = ( file, files ) ->
  included = -1
  # FIXME(jdm): There is a remote possibility of collisions here.
  # FIXME(mm): Improved, but what if there are multiple files with exact same
  # names that we want to include from different libraries? They'd still collide
  files.forEach ( f, idx ) ->
    included = idx if f.substr( -1 - file.length ) is ( "/#{file}" )

  included

# Sort vendor files before other files, keep vendor files in the order declared.
_sortVendorFirst = ( files ) ->
  ( a, b ) ->
    aPos = _inVendor a.relative, files
    bPos = _inVendor b.relative, files

    if aPos isnt -1 and bPos isnt -1
      if aPos > bPos
        1
      else
        -1
    else if aPos isnt -1
      -1
    else if bPos isnt -1
      1
    else
      0

# A stream to sort the files.
util.sortFilesByVendor = ( warlock, key ) ->
  ( options, stream ) ->
      stream.collect()
        .invoke( 'sort', [ _sortVendorFirst warlock.config key ] )
        .flatten()

