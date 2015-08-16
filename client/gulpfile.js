var gulp = require('gulp');
var path = require('path');
var $ = require('gulp-load-plugins')();
var del = require('del');
var modRewrite = require('connect-modrewrite');

var environment = $.util.env.type || 'development';
var isProduction = environment === 'production';
var webpackConfig = require('./webpack.config.js')[environment];

var port = $.util.env.port || 1337;
var src = 'src/';
var dest = 'public/';

var autoprefixerBrowsers = [
  'ie >= 9',
  'ie_mob >= 10',
  'ff >= 30',
  'chrome >= 34',
  'safari >= 6',
  'opera >= 23',
  'ios >= 6',
  'android >= 4.4',
  'bb >= 10'
];

gulp.task('scripts', function() {
  return gulp.src(webpackConfig.entry)
    .pipe($.webpack(webpackConfig))
    .pipe(isProduction ? $.uglifyjs() : $.util.noop())
    .pipe(gulp.dest(dest + 'js/'))
    .pipe($.size({ title : 'js' }))
    .pipe($.connect.reload());
});

gulp.task('main-template', function() {
  return gulp.src(src + 'index.jade')
    .pipe($.jade())
    .pipe(gulp.dest(dest))
    .pipe($.size({ title : 'html' }))
    .pipe($.connect.reload());
});

gulp.task('serve', function() {
  $.connect.server({
    root: dest,
    port: port,
    livereload: {
      port: 35728
    },
    middleware: function() {
      return [
        modRewrite([
          '^/sites(.*)$ http://localhost:8989/sites$1 [P]'
        ])
      ];
    }
  });
});

gulp.task('static', function(cb) {
  return gulp.src(src + 'static/**/*')
    .pipe($.size({ title : 'static' }))
    .pipe(gulp.dest(dest + 'static/'));
});

gulp.task('coffeelint', function () {
  return gulp.src(src + 'app/**/*.coffee')
    .pipe($.coffeelint())
    .pipe($.coffeelint.reporter());
});

gulp.task('stylint', function () {
  return gulp.src(src + 'styles/*.styl')
    .pipe($.stylint());
});

gulp.task('nightwatch', function () {
  return gulp.src('')
    .pipe($.nightwatch());
});

gulp.task('nightwatch-chrome', function () {
  return gulp.src('')
    .pipe($.nightwatch({
      cliArgs: ['-e chrome']
    }));
});

gulp.task('watch', function() {
  gulp.watch(src + 'index.html', ['main-template']);
  gulp.watch(src + 'app/**/*.coffee', ['scripts']);
});

gulp.task('clean', function(cb) {
  del([dest], cb);
});

// by default build project and then watch files in order to trigger livereload
gulp.task('default', ['build', 'serve', 'watch']);
gulp.task('test', ['coffeelint', 'stylint', 'nightwatch']);

// waits until clean is finished then builds the project
gulp.task('build', ['clean'], function(){
  gulp.start(['static', 'main-template', 'scripts']);
});
