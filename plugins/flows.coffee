jshint = require 'gulp-jshint'

module.exports = ( ngbp ) ->
  ngbp.flow 'source-js', [ '<%= globs.source.js %>' ],
    tasks: [ 'webapp-build' ] # the tasks to which this flow belongs, by default
    dest: '<%= paths.build.js %>' # to where should the files be written out at the end
  .add( 10, 'webapp-lintjs.lint', jshint )
  .add( 11, 'webapp-lintjs.reporter', jshint.reporter )

