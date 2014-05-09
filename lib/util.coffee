util = module.exports = {}

# Determine if a relative path passed refers to a vendor file
inVendor = ( file, files ) ->
  included = -1
  # FIXME(jdm): There is a remote possibility of collisions here.
  files.forEach ( f, idx ) ->
    included = idx if f.substr( 0 - file.length ) is file

  included

# Sort vendor files before other files, keep vendor files in the order declared.
util.sortVendorFirst = ( files ) ->
  ( a, b ) ->
    aPos = inVendor a.relative, files
    bPos = inVendor b.relative, files

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

