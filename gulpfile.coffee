gulp = require('gulp')
gutil = require('gulp-util')
coffee = require('gulp-coffee')
stylus = require('gulp-stylus')
browser = require('browser-sync')

gulp.task 'default', [
  'build'
  'watch'
  'server'
], ->

gulp.task 'compile', [
  'coffee'
  'stylus'
], ->

gulp.task 'watch', ->
  gulp.watch './src/coffee/*.coffee', [ 'coffee' ]
  gulp.watch './src/stylus/*.styl', [ 'stylus' ]

gulp.task 'coffee', ->
  gulp.src('./src/coffee/*.coffee').pipe(coffee(bare: true).on('error', gutil.log)).pipe(gulp.dest('./src/js/')).pipe browser.reload(stream: true)

gulp.task 'stylus', ->
  gulp.src('./src/stylus/*.styl').pipe(stylus()).pipe(gulp.dest('./css/')).pipe browser.reload(stream: true)

gulp.task 'server', ->
  browser server: baseDir: 'src'

gulp.task "build", ["compile"], ->
  gulp.src(['src/index.html',"src/js/*.js","src/css/*.css", "src/images/**", "src/data/**"], base: "src").pipe(gulp.dest('src/dest')).on "end", ->
    gulp.src("src/dest/**", base: "src/dest").pipe(gulp.dest("www"))
