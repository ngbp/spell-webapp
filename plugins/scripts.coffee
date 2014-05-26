jshint = require 'gulp-jshint'
stylish = require 'jshint-stylish'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
path = require 'path'

util = require "./../lib/util"

module.exports = ( warlock ) ->
  # A stream for adding files to the template data.
  # FIXME(JDM): I think this whole process is a little messy
  addToTemplateData = ( to ) ->
    () ->
      warlock.streams.map ( file ) ->
        return file if file.isNull()
        # We choose to manually ignore map files.
        # FIXME(jdm): This is inflexible.
        if not /\.map$/.test file.path
          filepath = path.join warlock.config( to ), file.relative
          warlock.config "template-data.webappScripts", [ filepath ], true

        file

  lintFn = ( options ) ->
    warlock.streams.map ( file ) ->
      return file if file.isNull() or not options.fail

      if not file.jshint?.success
        warlock.fatal "One or more JS files contain errors, so I'm exiting now."

      file

  warlock.flow 'scripts-to-lint',
    source: [ '<%= globs.source.js %>' ]
    source_options:
      base: "<%= paths.source_app %>"
    tasks: [ 'webapp-build' ]
    watch: true

  .add( 10, 'webapp-lintjs.lint', jshint )
  .add( 11, 'webapp-lintjs.reporter', ( options ) -> jshint.reporter( stylish ) )
  .add( 12, 'webapp-lintjs.failOnError', lintFn)

  warlock.flow 'test-scripts-to-lint',
    source: [ '<%= globs.source.test.js %>' ]
    source_options:
      base: "<%= paths.source_app %>"
    watch: true
    tasks: [ 'webapp-build' ]

  .add( 10, 'webapp-lintjs.lint', jshint )
  .add( 11, 'webapp-lintjs.reporter', ( options ) -> jshint.reporter( stylish ) )
  .add( 12, 'webapp-lintjs.failOnError', lintFn)

  ###
  # JavaScript: Source -> Build
  ###
  warlock.flow 'scripts-to-build',
    # TODO(jdm): should these be in package.json too?
    source: [ '<%= globs.source.js %>' ]
    source_options:
      base: "<%= paths.source_app %>"
    tasks: [ 'webapp-build' ]
    dest: '<%= paths.build_js %>'
    clean: true
    watch: true
  .add( 100, 'webapp-sort', util.sortFilesByVendor( warlock, "globs.vendor.js" ), { raw: true } )
  .add( 110, 'webapp-tpl.scripts', addToTemplateData( "paths.build_js" ) )

  warlock.flow 'vendor-scripts-to-build',
    source: [ '<%= globs.vendor.js %>' ]
    merge: 'flow::scripts-to-build::60'
  .add( 100, 'webapp-scripts.vendor', () ->
    warlock.streams.map ( file ) ->
      # We mark all files as vendor so we can handle them appropriately, if needed.
      file.isVendor = true
      return file
  )

  ###
  # JavaScript: Build -> Compile
  ###
  warlock.flow 'scripts-to-compile',
    source: [ "<%= paths.build_js %>/**/*.js" ]
    tasks: [ 'webapp-compile' ]
    depends: [ 'webapp-build', "webapp-clear-tpldata" ]
    dest: '<%= paths.compile_assets %>'
    clean: true
    watch: false
  .add( 10, 'webapp-sort', util.sortFilesByVendor( warlock, "globs.vendor.js" ), { raw: true } )
  .add( 50, 'webapp-concatjs', concat )
  .add( 90, 'webapp-minjs', uglify )
  .add( 100, 'webapp-tpl.compile-scripts', addToTemplateData( "paths.compile_assets" ) )

