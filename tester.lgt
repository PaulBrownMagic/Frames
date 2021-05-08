:- initialization((
	set_logtalk_flag(report, warnings),
	logtalk_load([
		json(loader),
		nested_dictionaries(loader),
		sets(loader)
	]),
	logtalk_load(lgtunit(loader)),
	logtalk_load([
		calculate_protocol,
		frames,
		slimowl_inheritance
	], [
		source_data(on),
		debug(on)
	]),
	logtalk_load(tests, [hook(lgtunit)]),
	tests::run
)).
