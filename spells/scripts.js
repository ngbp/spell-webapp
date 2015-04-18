var jshint = require( 'gulp-jshint' );
var stylish = require( 'jshint-stylish' );
var concat = require( 'gulp-concat' );
var uglify = require( 'gulp-uglify' );
var path = require( 'path' );

module.exports = function ( warlock ) {
  var config = warlock.config.get( 'pipelines.browser-js.streams' );
  var lint = warlock.util.object.get( config, 'lint' );
  var concatConfig = warlock.util.object.get( config, 'concat' );
  var minConfig = warlock.util.object.get( config, 'min' );

  warlock.pipeline( 'browser-js' )
    .append( 'lint.lint', jshint( lint.lint ) )
    .append( 'lint.reporter', jshint.reporter( stylish ) )
    .append( 'lint.failOnError', warlock.doto( function ( file ) {
      if ( ! file.isNull() && lint.failOnError && ( ! file.jshint || ! file.jshint.success ) ) {
        warlock.fatal( "One or more JS files contain errors, so I'm exiting now." );
      }
    }))
    .append( 'concat', concat( concatConfig ) )
    .append( 'min', uglify( minConfig ) )
    .append( 'browser-tpl.scripts', warlock.doto( function ( file ) {
      // FIXME(jdm): This is ugly, but we need to manually exclude the sourcemaps.
      if ( ! file.isNull() && ! /\.map$/.test( file.path ) ) {
        var filepath = path.join( warlock.config.get( 'paths.build.js' ), file.relative );
        warlock.config.set( '$$scripts', [ filepath ] );
      }
    }))
    ;
};

