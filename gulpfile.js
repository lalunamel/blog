var gulp = require('gulp');

var config = {
	octiconsDest: "./themes/codysehl.net/source/img/octicons",
	stylusDest: "./themes/codysehl.net/source/css/_codysehl.net-scaffold"
}

gulp.task('bower-move', function() {
	console.log('moving bower files...');
	gulp.src('./bower_components/octicons/**')
		.pipe(gulp.dest(config.octiconsDest));

	gulp.src('./bower_components/codysehl.net-scaffold/styl/**')
		.pipe(gulp.dest(config.stylusDest));
	console.log('complete!');
});

gulp.task('default', ['bower-move']);