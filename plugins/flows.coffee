jshint = require 'gulp-jshint'
stylish = require 'jshint-stylish'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'

module.exports = ( ngbp ) ->
  ###
  # Source -> Build
  ###
  ngbp.flow 'source-js',
    # should these be in package.json too?
    source: [ '<%= globs.source.js %>' ]
    tasks: [ 'webapp-build' ]
    dest: '<%= paths.build_js %>'
    clean: true

  .add( 10, 'webapp-lintjs.lint', jshint )
  .add( 11, 'webapp-lintjs.reporter', ( options ) -> jshint.reporter( stylish ) )
  .add( 12, 'webapp-lintjs.failOnError', ( options ) ->
    return ngbp.util.toStream ( file, callback ) ->
      return callback( null, file ) unless options.fail
      return callback( null, file ) if file.isNull()

      unless file.jshint.success
        ngbp.util.exit 1

      callback null, file
  )

  ###
  # Build -> Compile
  ###
  ngbp.flow 'build-js',
    source: [ "<%= paths.build_js %>/**/*.js" ]
    tasks: [ 'webapp-compile' ]
    #depends: [ 'webapp-build' ]
    dest: '<%= paths.compile_assets %>'
    clean: true

  .add( 10, 'webapp-test1', () ->
    ngbp.util.toStream ( data, callback ) ->
      ngbp.log.log "test1 got #{data.path}"
      callback null, data
  )
  .add( 50, 'webapp-concatjs', concat )
  .add( 90, 'webapp-minjs', uglify )
  ###
  .add( 70, 'webapp-test2', () ->
    ngbp.util.toStream ( data, callback ) ->
      ngbp.log.log "test2 got #{data.path}"
      callback null, data
  )
  ###
  ###
  .add( 95, 'webapp-test3', () ->
    ngbp.util.toStream ( data, callback ) ->
      ngbp.log.log "test3 got #{data.path}"
      callback null, data
  )
  ###

