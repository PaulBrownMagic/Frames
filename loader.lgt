:- initialization((
	logtalk_load([
		nested_dictionaries(loader),
		sets(loader)
	]),
	logtalk_load([
		calculate_protocol,
		frames
	],
	[
		optimize(on)
	])
)).
