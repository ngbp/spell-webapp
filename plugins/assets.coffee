module.exports = ( warlock ) ->
  ###
  # Assets: Source -> Build
  ###
  warlock.flow 'assets-to-build',
    source: [ "<%= globs.source.assets %>" ]
    tasks: [ 'webapp-build' ]
    dest: '<%= paths.build_assets %>'

  ###
  # Assets: Build -> Compile
  ###
  warlock.flow 'assets-to-compile',
    source: [ "<%= globs.source.assets %>" ]
    tasks: [ 'webapp-compile' ]
    dest: '<%= paths.compile_assets %>'
    watch: false

