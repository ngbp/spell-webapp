concat = require 'gulp-concat'
minifyCSS = require 'gulp-minify-css'
csslint = require 'csslint'
path = require 'path'

util = require "./../lib/util"

module.exports = ( warlock ) ->
  # A stream for adding files to the template data.
  # FIXME(JDM): I think this whole process is a little messy
  addToTemplateData = ( to ) ->
    () ->
      warlock.streams.map ( file ) ->
        return file if file.isNull()
        filepath = path.join warlock.config( to ), file.relative
        warlock.config "template-data.webappStyles", [ filepath ], true
        file

  sortFilesByVendor = ( options, stream ) ->
    stream.collect()
      .invoke( 'sort', [ util.sortVendorFirst warlock.config "globs.vendor.css" ] )
      .flatten()

  ###
  # CSS: Source -> Build
  ###
  warlock.flow 'styles-to-build',
    source: [ '<%= globs.source.css %>' ]
    source_options:
      base: "<%= paths.source_app %>"
    tasks: [ 'webapp-build' ]
    dest: '<%= paths.build_css %>'
    clean: true
  .add( 10, 'webapp-lintcss.lint', ( options ) ->
    rules = {}
    linter = csslint.CSSLint

    # Activate all rules by default.
    linter.getRules().forEach ( rule ) ->
      rules[ rule.id ] = on

    # Grab any rules specified in the options.
    warlock.util.mout.object.forOwn options, ( val, rule ) ->
      if not val
        delete rules[ rule ]
      else
        rules[ rule ] = val

    warlock.streams.map ( file ) ->
      file.csslint = {}
      report = linter.verify file.contents.toString(), rules
      if report.messages.length is 0
        file.csslint.success = true
      else
        file.csslint.success = false
        file.csslint.errors = report.messages

      file
  )
  .add( 11, 'webapp-lintcss.reporter', () ->
    warlock.streams.map ( file ) ->
      return file if file.isNull() or not file.csslint or file.csslint.success

      warlock.log.writeln "\n" + file.path.bold.underline
      rows = []
      file.csslint.errors.forEach ( err ) ->
        line = "line #{err.line}"
        col = "col #{err.col}"
        msg = "#{err.message} #{err.rule.desc} (#{err.rule.id})".cyan
        rows.push [ line, col, msg ]

      warlock.log.table rows
      warlock.log.writeln "#{rows.length} problem(s)".bold.red
      
      file
  )
  .add( 12, 'webapp-lintcss.failOnError', ( options ) ->
    warlock.streams.map ( file ) ->
      return file if file.isNull() or not options.fail or file.csslint.success
      warlock.log.fatal "One or more CSS files contain errors, so I'm exiting now."
  )
  .add( 100, 'webapp-sort', sortFilesByVendor, { raw: true } )
  .add( 110, 'webapp-tpl.styles', addToTemplateData( "paths.build_css" ) )

  warlock.flow 'vendor-styles-to-build',
    source: [ '<%= globs.vendor.css %>' ]
    merge: 'flow::styles-to-build::45'
  .add( 100, 'webapp-styles.vendor', () ->
    warlock.streams.map ( file ) ->
      # We mark all files as vendor so we can handle them appropriately, if needed.
      file.isVendor = true
      return file
  )

  ###
  # CSS: Build -> Compile
  ###
  warlock.flow 'styles-to-compile',
    source: [ "<%= paths.build_css %>/**/*.css" ]
    tasks: [ 'webapp-compile' ]
    depends: [ 'webapp-build', "webapp-clear-tpldata" ]
    dest: '<%= paths.compile_assets %>'
    clean: true
    watch: false
  .add( 10, 'webapp-sort', sortFilesByVendor, { raw: true } )
  .add( 50, 'webapp-concatcss', concat )
  .add( 90, 'webapp-minjs', minifyCSS )
  .add( 100, 'webapp-tpl.compile-styles', addToTemplateData( "paths.compile_assets" ) )

