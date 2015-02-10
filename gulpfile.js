var gulp = require('gulp'),
    jshint = require('gulp-jshint');

gulp.task('jshint', function () {
    gulp.src('./app/**/*.js')
        .pipe(jshint())
        .pipe(jshint.reporter('default'));
});

gulp.task('watch', function () {
    gulp.watch('./app/**/*.js', ['jshint']);
});