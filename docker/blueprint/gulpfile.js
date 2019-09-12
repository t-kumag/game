const gulp = require('gulp');
const aglio = require('gulp-aglio');
const aglioConfig = require('./aglioconfig.json');
const docs = 'docs';
const output = 'output';

gulp.task('output', function() {
  gulp.src(docs+'/*.apib')
    .pipe(aglio(aglioConfig))
    .pipe(gulp.dest(output));
});

gulp.task('watch', function() {
  gulp.watch(docs+'/*.apib', gulp.task('output'));
});

gulp.task('default', gulp.series(gulp.parallel('output', 'watch')));