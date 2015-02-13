var gulp = require('gulp');
var jshint = require('gulp-jshint');
var browserify = require('gulp-browserify');

gulp.task('jshint', function () {
    gulp.src('./app/**/*.js')
        .pipe(jshint())
        .pipe(jshint.reporter('default'));
});

// Browserify
gulp.task('jsbuild', function() {
    gulp.src('./app/fe/control/token.js')
        .pipe(browserify({
            insertGlobals : true,
            debug : !gulp.env.production
        }))
        .pipe(gulp.dest('./public/js/build'))
});

gulp.task('watch', function () {
    gulp.watch('./app/**/*.js', ['jshint']);
    gulp.watch('./app/fe/control/**/*.js', ['jsbuild']);
});
