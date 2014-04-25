module.exports = ( warlock ) ->
  ###
  # HTML: Source -> Build
  ###
  warlock.flow 'html-to-build',
    source: [ '<%= globs.source.html %>' ]
    source_options:
      base: "<%= paths.source %>"
    dest: '<%= paths.build %>'
    tasks: [ 'webapp-build' ]
    depends: [ "flow::styles-to-build", "flow::scripts-to-build" ]
    clean: true
  .add( 25, 'webapp-html-template.build', warlock.streams.template )

  # Between each, we need to clear the appropriate template data
  # FIXME(jdm): This feels like a hack.
  warlock.task.add "webapp-clear-tpldata", [ "webapp-build" ], () ->
    warlock.config "template-data.webappScripts", []
    warlock.config "template-data.webappStyles", []

  ###
  # HTML: Build -> Compile
  ###
  warlock.flow 'html-to-compile',
    source: [ '<%= globs.source.html %>' ]
    source_options:
      base: "<%= paths.source %>"
    dest: '<%= paths.compile %>'
    tasks: [ 'webapp-compile' ]
    depends: [ "flow::styles-to-compile", "flow::scripts-to-compile" ]
    clean: true
    watch: false
  .add( 25, 'webapp-html-template.compile', warlock.streams.template )

