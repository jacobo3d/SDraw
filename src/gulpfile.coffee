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
  gulp.watch './coffee/*.coffee', [ 'coffee' ]
  gulp.watch './stylus/*.styl', [ 'stylus' ]

gulp.task 'coffee', ->
  gulp.src('./coffee/*.coffee').pipe(coffee(bare: true).on('error', gutil.log)).pipe(gulp.dest('./js/')).pipe browser.reload(stream: true)

gulp.task 'stylus', ->
  gulp.src('./stylus/*.styl').pipe(stylus()).pipe(gulp.dest('./css/')).pipe browser.reload(stream: true)

gulp.task 'server', ->
  browser server: baseDir: './'

gulp.task "build", ["compile"], ->
  gulp.src(['index.html',"js/*.js","css/*.css", "images/**", "data/**", "kanji/**"], base: ".").pipe(gulp.dest('dest')).on "end", ->
    gulp.src("dest/**", base: "dest").pipe(gulp.dest("../www"))